# 🛒 ShopEase — E-Commerce Product Listing App

Welcome to **ShopEase**! This is a modern, fully functional e-commerce catalog app built with Flutter. 

I built this project to practice writing clean, production-ready code using **Riverpod** for state management and **Clean Architecture** principles. It connects to the live public [FakeStore API](https://fakestoreapi.com) to fetch real products, categories, and ratings instead of using hardcoded mock data.

---

## ✨ Features

### 📦 Product Browsing
* **Live API Fetching** — Loads real product data using the Dio HTTP client.
* **Smart Search & Filters** — Instant search-as-you-type and category filter chips without extra network lag.
* **Smooth UI/UX** — Features a beautiful grid layout, shimmer loading skeletons, and pull-to-refresh.
* **Detailed View** — Product pages with shared Hero image transitions, quantity selectors, and full descriptions.

### 💳 Cart & Checkout System
* **Add to Cart** — Handles quantities with smart logic to merge duplicate items.
* **Dynamic Calculations** — Automatically calculates subtotal, 5% tax, and adaptive shipping fees.
* **Free Shipping** — Dynamically updates to unlock free shipping on orders over \$50.
* **Persistent Storage** — Saves your cart and theme choices locally so they survive app restarts.
* **Smooth Animations** — Swipe-to-delete cart items and a clear-cart confirmation dialog.
* **Mock Checkout** — Simulates a successful order placement by clearing the cart and showing a success toast.

### 🎨 App Extras
* **Dark Mode** — A beautiful dark theme toggled right from the AppBar.
* **Persisted Settings** — Remembers your light/dark mode preference across sessions.

---

## 🏗 How the Project is Organized (Clean Architecture)

To keep the code clean, testable, and organized, I separated the project into three distinct layers. This prevents UI code from getting mixed up with business logic or database queries.

lib/├── core/                    # Global elements (Themes, network wrappers, shared widgets)├── domain/                  # Business Logic (Pure Dart entities and repository blueprints)├── data/                    # Data Layer (API models, network calls, local database saving)├── providers/                # Riverpod state wiring and controllers└── features/                 # UI screens grouped by feature (List, Detail, Cart)

### Why I chose this structure:
* **Separation of Concerns** — The `domain` layer doesn't care if we use Dio, Http, or Hive. It is pure Dart.
* **Easy Testing** — Because the UI and Data layers are decoupled, I can test the cart business logic without needing a real device or network connection.

---

## ⚡ State Management (Riverpod)

I used **Riverpod** because it is safe, fast, and makes managing application state incredibly predictable.

* `cartProvider` — Manages the list of items in the cart, updating local storage on every change.
* `productListProvider` — Fetches the product catalog from the web once and caches it.
* `filteredProductListProvider` — Combines the main product list with the search query to filter items instantly.
* `cartTotalProviders` — Small, split-up providers for subtotal, tax, and shipping so widgets only rebuild when their specific data changes.
* `themeModeProvider` — Controls the light and dark mode state.

---

## 🛠 Tech Stack & Tools

* **Flutter & Dart** — Cross-platform UI toolkit.
* **Flutter Riverpod** — State management and dependency injection.
* **Dio** — Advanced HTTP networking client with custom error handling.
* **Shared Preferences** — Quick local data caching for the cart and theme.
* **Dartz** — Used for functional programming error handling (`Either<Failure, Success>`).
* **Cached Network Image** — To cache product images locally for offline speed.
* **Shimmer & Fluttertoast** — For polished UI feedback animations and alerts.
* **Mocktail** — For writing clean, reliable unit and widget tests.

---

## 🧪 Testing Coverage

I wanted to make sure the app works reliably, so I included automated tests:

* **Unit Tests** — Validates the `CartNotifier` math (tax math, free shipping thresholds, item merging) and JSON model parsing.
* **Widget Tests** — Tests the product list screen UI states (loading shimmers, successful data loading, and empty search results).

---

## 🚀 Getting Started

> 💡 **Note on project setup:** This codebase contains the complete `lib/`, `test/`, and configurations. If you clone this repo directly, you just need to generate the native platform folders for your specific machine before running it.

### 1. Generate local platform folders
Run this command in the project root to scaffold the missing native wrappers safely without touching the core code:
```bash
flutter create . --project-name ecommerce_app
```

### 2. Grab dependencies
```bash
flutter pub get
```

### 3. Launch the app
```bash
flutter run
```

### 4. Run the test suite
```bash
flutter test
```

---

## 🔮 Future Improvements I'd Love to Add

If I spent more time on this project, my next steps would be:
1. **Real Authentication** — Integrating Firebase Auth or Auth0 for safe user sign-ins.
2. **Infinite Scroll Pagination** — Modifying the product list provider to load items sequentially for massive catalogs.
3. **CI/CD Pipelines** — Setting up GitHub Actions to automatically run tests and check code quality on every push.