/// Centralized spacing scale so widgets don't hard-code magic numbers.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
}

/// User-facing copy kept in one place to ease localization later.
class AppStrings {
  AppStrings._();

  static const String appName = 'Ewire';

  // Product list
  static const String products = 'Products';
  static const String searchHint = 'Search products...';
  static const String noProductsFound = 'No products found';
  static const String somethingWentWrong = 'Something went wrong';
  static const String retry = 'Retry';
  static const String pullToRefresh = 'Pull down to refresh';

  // Product detail
  static const String addToCart = 'Add to Cart';
  static const String goToCart = 'Go to Cart';
  static const String description = 'Description';
  static const String quantity = 'Quantity';
  static const String addedToCart = 'Added to cart';

  // Cart
  static const String myCart = 'My Cart';
  static const String emptyCartTitle = 'Your cart is empty';
  static const String emptyCartSubtitle =
      'Browse products and add items to your cart';
  static const String subtotal = 'Subtotal';
  static const String tax = 'Tax (5%)';
  static const String shipping = 'Shipping';
  static const String total = 'Total';
  static const String checkout = 'Proceed to Checkout';
  static const String free = 'Free';
  static const String removeItem = 'Remove item';
  static const String clearCart = 'Clear Cart';
  static const String checkoutSuccess = 'Order placed successfully!';
}
