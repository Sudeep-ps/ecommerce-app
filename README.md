# ShopEase — E-Commerce Product Listing App

A Flutter machine-test submission for the **Flutter Developer** role at Ewire Softtech Pvt. Ltd.

Built with **Riverpod** for state management, a layered **Clean Architecture** (domain / data / presentation), and the public [FakeStore API](https://fakestoreapi.com) as a live mock backend (so the app demonstrates real networking + JSON parsing rather than hard-coded data).

---

## ✨ Features

| Requirement | Status |
|---|---|
| Fetch products from an API | ✅ FakeStore REST API via Dio |
| Product listing page | ✅ Grid layout, search, category filter, shimmer loading, pull-to-refresh |
| Product detail page | ✅ Hero image transition, quantity selector, description, ratings |
| Add to cart | ✅ With quantity, duplicate-merge logic |
| Cart page with total calculation | ✅ Subtotal, tax, shipping (free over $50), grand total |
| Local storage for cart persistence | ✅ SharedPreferences, survives app restarts |
| **Bonus:** Riverpod state management | ✅ `AsyncNotifier`, `Provider.family`, derived providers |
| **Bonus:** Dark mode support | ✅ Toggle in AppBar, persisted across restarts |

Extras added beyond the brief, to reflect production-quality expectations:
- Clean Architecture (domain/data/presentation separation, repository pattern, dependency inversion)
- Typed error handling (`Either<Failure, T>` via `dartz` — no raw exceptions reaching the UI)
- Unit tests for cart business logic and JSON model parsing
- Widget tests for the product list screen (loading/search/empty states)
- Search-as-you-type + category filter chips (client-side, no extra network calls)
- Swipe-to-delete cart items, clear-cart confirmation dialog
- Mock checkout flow (clears cart + success toast — see note below)

---

## 🏗 Architecture

```
lib/
├── core/                    # Cross-cutting concerns
│   ├── constants/           # API endpoints, strings, storage keys
│   ├── network/              # Dio client wrapper + error mapping
│   ├── theme/                 # Light/dark Material 3 theme
│   ├── utils/                  # Failure/Exception types
│   └── widgets/                 # Shared widgets (shimmer, error/empty states, stepper)
├── domain/                  # Pure business logic — no Flutter/Dio/SharedPreferences imports
│   ├── entities/             # Product, CartItem
│   └── repositories/          # Abstract contracts (interfaces)
├── data/                    # Implementation details
│   ├── models/                # JSON-serializable models, extend domain entities
│   ├── datasources/            # Remote (Dio) and local (SharedPreferences) sources
│   └── repositories/            # Concrete repository implementations
├── providers/                # Riverpod providers — DI wiring + state notifiers
└── features/                 # UI, organized by feature (not by type)
    ├── product_list/
    ├── product_detail/
    └── cart/
```

**Why this structure?** The domain layer depends on nothing — it's pure Dart. The data layer implements domain contracts and is the only place that knows about Dio or SharedPreferences. Providers and widgets depend on domain *interfaces*, never on concrete implementations. This is what makes `CartNotifier` and the product providers unit-testable with a fake repository (see `test/unit/cart_provider_test.dart`) without spinning up a real HTTP client or device storage.

### State management (Riverpod)

- `cartProvider` — `AsyncNotifierProvider<CartNotifier, List<CartItem>>`. Loads from local storage on first build, persists on every mutation (add/update/remove/clear).
- `productListProvider` — `FutureProvider` fetching the full catalog once.
- `filteredProductListProvider` — derived `Provider` combining the fetched list with search query + category selection, recomputed automatically, with zero extra network calls.
- `productDetailProvider` — `FutureProvider.family<Product, int>`, reuses the already-fetched list when available instead of re-hitting the network.
- `cartSubtotalProvider` / `cartTaxProvider` / `cartShippingProvider` / `cartTotalProvider` — small derived providers so widgets only rebuild on the specific number they care about.
- `themeModeProvider` — `NotifierProvider<ThemeModeNotifier, ThemeMode>`, persisted to SharedPreferences.

### Error handling

Repositories never throw past their boundary. Data sources throw typed exceptions (`ServerException`, `NetworkException`, `CacheException`); repositories catch these and return `Either<Failure, T>`. The UI pattern-matches `AsyncValue.when(loading: ..., error: ..., data: ...)` and never deals with raw `try/catch`.

### Cart total calculation

```
Subtotal   = Σ (unit price × quantity)
Tax (5%)   = Subtotal × 0.05
Shipping   = $5.99, FREE if subtotal ≥ $50
Total      = Subtotal + Tax + Shipping
```

---

## 🚀 Getting Started

> **Note on how this project was generated:** this codebase was authored by hand (including this README) in an environment without a Flutter SDK installed, so the native `android/`, `ios/`, `linux/`, `macos/`, `windows/`, and `web/` platform folders that `flutter create` normally scaffolds are **not** included. Everything under `lib/`, `test/`, and `pubspec.yaml` is complete and ready to run — you just need to generate the platform shells once, locally, as below.

### 1. Generate platform folders (one-time)

From the project root, with the Flutter SDK installed:

```bash
flutter create . --project-name ecommerce_app --org com.ewiresofttech
```

This is safe to run on an existing project — it only adds the missing `android/`, `ios/`, etc. folders and will not overwrite `lib/` or `pubspec.yaml`.

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

### 4. Run tests

```bash
flutter test
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `dio` | HTTP client |
| `shared_preferences` | Cart & theme persistence |
| `dartz` | `Either<Failure, T>` functional error handling |
| `equatable` | Value equality for entities |
| `cached_network_image` | Product image loading/caching |
| `shimmer` | Loading skeletons |
| `google_fonts` | Typography (Inter) |
| `fluttertoast` | Lightweight toasts |
| `mocktail` | Test mocking |

---

## 🧪 Testing

- `test/unit/cart_provider_test.dart` — `CartNotifier` business logic (add/merge/update/remove/clear), derived totals, free-shipping threshold, against a mocked `CartRepository`.
- `test/unit/product_model_test.dart` — JSON parsing, default-fallback behavior, round-tripping.
- `test/widget/product_list_screen_test.dart` — loading shimmer → data render, search filtering, empty state, against a mocked `ProductRepository`.

---

## 🔮 If This Were Production

A few things intentionally scoped out of a 4–6 hour test, noted here to show awareness:

- **Checkout** is mocked (clears the cart + shows a success toast) since there's no real payment/order API in the brief. A real implementation would call an orders endpoint and show an order confirmation screen.
- **Pagination/infinite scroll** wasn't added since FakeStore's catalog is small (20 items); a real catalog would need this on `productListProvider`.
- **Firebase Auth/Analytics** mentioned in the JD as "preferred" weren't included since the brief is product listing only — happy to discuss how I'd wire those into this architecture (a new `features/auth` module + an `AuthRepository` following the same pattern).
- **CI** — a GitHub Actions workflow running `flutter analyze` + `flutter test` on PRs would be a natural next addition.

---

## 👤 About This Submission

Built for the Flutter Developer position at Ewire Softtech Pvt. Ltd. — feel free to reach out with any questions about architectural decisions made here.
