# SmartSpend — Development Guide

## Prerequisites

| Tool                      | Minimum Version | Notes                           |
| ------------------------- | --------------- | ------------------------------- |
| Flutter SDK               | 3.10+           | Includes Dart 3.0+              |
| Docker Desktop            | 4.x             | For PostgreSQL + backend        |
| Git                       | 2.x             |                                 |
| VS Code or Android Studio | latest          | VS Code launch configs included |

Verify your Flutter installation:

```bash
flutter doctor
```

---

## Initial Setup

### 1. Clone and configure environment

```bash
git clone <repo-url>
cd ase485-capstone-finance-ml
```

**Windows (PowerShell):**

```powershell
.\scripts\setup.ps1
```

**macOS / Linux:**

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

The setup script:

- Copies `.env.example` → `.env`
- Runs `flutter pub get`
- Verifies Flutter and Docker installations

### 2. Edit `.env`

Open `.env` and replace all `CHANGE_ME` placeholders:

```env
POSTGRES_PASSWORD=your_secure_db_password
JWT_SECRET=use_a_long_random_string_at_least_32_chars
PGADMIN_PASSWORD=your_pgadmin_password
```

> **Security:** Never commit `.env` to version control. It is listed in `.gitignore`.

### 3. Start the full stack

**Windows:**

```powershell
.\scripts\start.ps1
# Optional: specify a Flutter device
.\scripts\start.ps1 -Device chrome
.\scripts\start.ps1 -Device windows
```

**macOS / Linux:**

```bash
./scripts/start.sh
./scripts/start.sh --device chrome
```

The start script:

1. Starts Docker Compose (PostgreSQL + FastAPI + pgAdmin)
2. Waits for the API health check to pass
3. Launches the Flutter app on the specified device (defaults to the first available)

---

## Running Manually

If you prefer to start services individually:

### Backend only

```bash
docker-compose up -d db backend
```

### Flutter app only (backend already running)

```bash
flutter run
# Specify a device:
flutter run -d chrome
flutter run -d windows
```

### Override API base URL at runtime

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000/api/v1
```

---

## Service URLs (local development)

| Service     | URL                                 |
| ----------- | ----------------------------------- |
| Flutter app | Device display                      |
| FastAPI     | `http://localhost:8000`             |
| Swagger UI  | `http://localhost:8000/api/v1/docs` |
| API health  | `http://localhost:8000/health`      |
| pgAdmin     | `http://localhost:5050`             |

**pgAdmin credentials:** `admin@smartspend.dev` / value from `PGADMIN_PASSWORD` in `.env`

**Demo account:** `demo@smartspend.dev` / `password123`

---

## Project Structure

```
lib/
├── config/         App-wide constants, colors, theme, routing, spacing
├── data/           Static sample data (used while screens are not yet live-wired)
├── models/         Immutable domain data classes
├── viewmodels/     UI-only composite objects (no persistence)
├── providers/      ChangeNotifier state management (6 providers)
├── services/       HTTP API layer (ApiClient + domain services)
├── screens/        11 UI screens organized by feature
├── widgets/        5 reusable UI components
└── utils/          Formatters, validators, category helpers, error helpers
```

---

## Adding a New Feature

### Typical flow for a new domain feature

1. **Model** — Define the immutable data class in `lib/models/`. Implement `fromJson`, `toJson`, `copyWith`, `==`, `hashCode`.
2. **Service** — Add a method to the relevant service in `lib/services/`, or create a new `XxxService` class. The service should call `ApiClient` and return typed model objects.
3. **Provider** — Add state and methods to the relevant `ChangeNotifier` in `lib/providers/`. The provider accepts an optional service parameter for test injection.
4. **Screen / Widget** — Consume the provider via `context.watch<XxxProvider>()` (for reactive state) or `context.read<XxxProvider>()` (for one-time reads inside callbacks).
5. **Tests** — Write unit tests for the model, provider, and service. Use `mocktail` to mock the service in provider tests and mock `ApiClient` in service tests.

### Adding a new screen

1. Create `lib/screens/<feature>/<feature>_screen.dart`
2. Add a route constant to `lib/config/routes.dart` in `AppRoutes`
3. Add the route to the `routes` map in `AppRoutes.routes`
4. Navigate with `Navigator.pushNamed(context, AppRoutes.yourRoute)`

---

## Code Conventions

### Models

- All fields `final`; constructor `const` when possible
- Assert invariants in the constructor body (`assert(amount != 0, '...')`)
- `fromJson` parses `snake_case` JSON keys → `camelCase` Dart fields
- `toJson` returns `snake_case` keys to match the API

### Providers

- Single `isLoading` bool — set to `true` before async work, `false` in `finally`
- Single `error` String? — set in `catch`, cleared by `clearError()` or before the next load
- Always `notifyListeners()` after mutating state
- Never access `BuildContext` in providers

### Services

- Throw descriptive `Exception('...')` messages on error — never return `null` for failure
- Use `ApiClient.extractError(response)` to parse server error bodies
- Service constructors take `ApiClient` as a required parameter

### Widgets

- Prefer `StatelessWidget` unless local animation or form state is needed
- Pass data as constructor parameters — avoid accessing providers deep inside widgets
- Use `LoadingOverlay` instead of conditionally hiding content during loads

### Naming

| Artifact            | Convention           | Example                    |
| ------------------- | -------------------- | -------------------------- |
| Files               | `snake_case.dart`    | `transaction_service.dart` |
| Classes             | `PascalCase`         | `TransactionService`       |
| Variables / methods | `camelCase`          | `fetchTransactions`        |
| Constants           | `camelCase` in class | `AppConstants.apiBaseUrl`  |
| Enum values         | `camelCase`          | `TransactionCategory.food` |

---

## Testing

### Running Tests

```bash
# All unit + widget tests
flutter test

# Single file
flutter test test/models/transaction_test.dart

# With coverage
flutter test --coverage
# View HTML report (requires lcov):
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Integration tests (requires a running device)
flutter test integration_test/
```

### Test Structure

```
test/
├── app_test.dart                  App smoke test
├── models/                        Domain model tests
│   ├── transaction_test.dart
│   ├── budget_test.dart
│   ├── goal_test.dart
│   ├── recommendation_test.dart
│   └── user_test.dart
├── providers/                     ChangeNotifier tests (with mocked services)
│   ├── auth_provider_test.dart
│   ├── transaction_provider_test.dart
│   ├── budget_provider_test.dart
│   └── goal_provider_test.dart
├── services/                      Service tests (with mocked ApiClient)
│   ├── api_client_test.dart
│   ├── auth_service_test.dart
│   ├── transaction_service_test.dart
│   ├── budget_service_test.dart
│   ├── goal_service_test.dart
│   └── recommendation_service_test.dart
├── utils/
│   ├── validators_test.dart
│   └── error_helpers_test.dart
└── widgets/                       Widget render + behavior tests
    ├── summary_card_test.dart
    ├── transaction_tile_test.dart
    ├── goal_progress_card_test.dart
    ├── category_card_test.dart
    └── loading_overlay_test.dart
```

### Writing Provider Tests

Provider tests use `mocktail` to inject a fake service:

```dart
class MockTransactionService extends Mock implements TransactionService {}

void main() {
  late MockTransactionService mockService;
  late TransactionProvider provider;

  setUp(() {
    mockService = MockTransactionService();
    provider = TransactionProvider(service: mockService);
  });

  test('fetchTransactions updates state on success', () async {
    when(() => mockService.fetchTransactions()).thenAnswer(
      (_) async => [sampleTransaction],
    );

    await provider.fetchTransactions();

    expect(provider.transactions, [sampleTransaction]);
    expect(provider.isLoading, isFalse);
    expect(provider.error, isNull);
  });
}
```

### Writing Widget Tests

```dart
testWidgets('SummaryCard displays title and value', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: SummaryCard(
          title: 'Balance',
          value: '\$1,234.56',
          icon: Icons.account_balance_wallet,
        ),
      ),
    ),
  );

  expect(find.text('Balance'), findsOneWidget);
  expect(find.text('\$1,234.56'), findsOneWidget);
});
```

---

## Backend Development

### Viewing logs

```bash
docker-compose logs -f backend
docker-compose logs -f db
```

### Restarting the backend

```bash
docker-compose restart backend
```

### Rebuilding after dependency changes

```bash
docker-compose up -d --build backend
```

### Running database migrations

Schema changes are applied by modifying `docker/init.sql`. To reset the database with the new schema:

```bash
docker-compose down -v           # removes DB volume — destroys all data
docker-compose up -d             # recreates with new init.sql
```

> **Warning:** `-v` deletes all data. Only do this in development.

### Accessing the database directly

```bash
docker exec -it smartspend-db psql -U smartspend -d smartspend
```

Or use pgAdmin at `http://localhost:5050`.

---

## VS Code Configuration

A `launch.json` is included at `.vscode/launch.json` with pre-configured debug targets for common Flutter devices. Open the Run & Debug panel (Ctrl+Shift+D) and select a configuration.

---

## Common Issues

### `flutter pub get` fails

Ensure Flutter SDK is in your `PATH` and the version is ≥ 3.10:

```bash
flutter --version
```

### Cannot connect to backend

1. Verify Docker is running: `docker-compose ps`
2. Check backend logs: `docker-compose logs backend`
3. Test the health endpoint: `curl http://localhost:8000/health`
4. Ensure `API_BASE_URL` matches the running backend address

### Database connection refused

The backend waits for a DB health check, but if the DB takes too long to initialize:

```bash
docker-compose restart backend
```

### Token expired / 401 errors

Log out and log back in. Tokens expire after 24 hours and there is no automatic refresh.

### Hot reload not reflecting model changes

Model changes may require a full restart (`R` in the terminal or the restart button in the IDE) rather than hot reload (`r`).
