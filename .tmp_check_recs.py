from app.database import query
from app.ml_engine import generate_recommendations

UID = "67d162a2-4779-4c6b-bb1f-1e02342fe007"

txns = query("SELECT * FROM transactions WHERE user_id=%s", (UID,))
buds = query("SELECT * FROM budgets WHERE user_id=%s", (UID,))
print(f"transactions: {len(txns)}, budgets: {len(buds)}")

recs = generate_recommendations(txns, buds)
print(f"\n{len(recs)} tips would be generated:\n")
for r in recs:
    print(f"  [{r['category']:14}] {r['title']:42}  save ${r['potential_savings']:.2f}")
