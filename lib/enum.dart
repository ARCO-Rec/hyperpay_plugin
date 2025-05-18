part of 'flutter_hyperpay.dart';

/// This enum is used to store the result of a Payment operation. It can be either 'sync', 'success', 'error', 'noResult' or 'cancelled'.
enum PaymentResult { noResult, sync, success, error, cancelled }

/// PaymentMode is an enumeration which can take on the values of either 'live' or 'test' and is used to indicate which payment mode is used.
enum PaymentMode { live, test }
