"""Transaction-description classifier (TF-IDF + Multinomial Naive Bayes).

Why this combo: the descriptions are very short ("Starbucks coffee", "Uber
ride") which favours bag-of-words representations. Multinomial NB is robust
on small training sets, fast to fit, and lets us return a useful confidence
score (the max class probability) for the UI to surface.

The pipeline is built on first use rather than at import time so test files
that don't exercise categorization don't pay the (small) fit cost.
"""

from __future__ import annotations

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline

from app.ml.training_data import CATEGORIES, TRAINING_DATA

__all__ = ["predict_category", "predict_category_with_confidence"]


def _validate_training_labels() -> None:
    """Catch corpus typos at startup rather than at predict time.

    Raises a ``RuntimeError`` if any label in the training data is not part of
    :data:`CATEGORIES`; otherwise the model would happily learn a phantom
    class and the budget generator would silently ignore those rows.
    """
    valid = set(CATEGORIES)
    bad = sorted({label for _, label in TRAINING_DATA if label not in valid})
    if bad:
        raise RuntimeError(
            f"Training data contains labels outside CATEGORIES: {bad}. "
            "Add them to app.ml.training_data.CATEGORIES or fix the typo."
        )


def _build_pipeline() -> Pipeline:
    """Fit a fresh TF-IDF + Multinomial NB pipeline on the training corpus."""
    _validate_training_labels()
    texts = [t for t, _ in TRAINING_DATA]
    labels = [label for _, label in TRAINING_DATA]
    pipe = Pipeline(
        [
            (
                "tfidf",
                TfidfVectorizer(
                    lowercase=True,
                    ngram_range=(1, 2),
                    max_features=5000,
                ),
            ),
            ("clf", MultinomialNB(alpha=0.1)),
        ]
    )
    pipe.fit(texts, labels)
    return pipe


_pipeline: Pipeline | None = None


def _get_pipeline() -> Pipeline:
    """Return the lazily-initialised, in-memory pipeline."""
    global _pipeline
    if _pipeline is None:
        _pipeline = _build_pipeline()
    return _pipeline


def predict_category(description: str) -> str:
    """Return the predicted category label for a transaction description.

    Empty/whitespace input returns ``"Other"`` directly so the model never has
    to handle the degenerate empty-string case.
    """
    if not description or not description.strip():
        return "Other"
    pipe = _get_pipeline()
    return pipe.predict([description])[0]


def predict_category_with_confidence(description: str) -> tuple[str, float]:
    """Return ``(category, confidence)`` where confidence is the max class probability.

    For the UI: low confidence (~0.3) suggests the description is unfamiliar
    and the user might want to manually re-categorize.
    """
    if not description or not description.strip():
        return ("Other", 1.0)
    pipe = _get_pipeline()
    probs = pipe.predict_proba([description])[0]
    idx = probs.argmax()
    return (pipe.classes_[idx], float(probs[idx]))
