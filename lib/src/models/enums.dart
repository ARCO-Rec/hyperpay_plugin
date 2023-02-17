part of hyperpay;

enum PaymentMode {
  /// Use the test mode in your development environment.
  test,

  /// Use the test mode in your production environment.
  live,

  none,
}

enum BrandType {
  visa,

  master,

  mada,

  applepay,

  /// If no brand is chosen, use none to avoid
  /// any unnecessary errors.
  none,
}
