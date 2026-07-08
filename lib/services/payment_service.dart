import 'package:cloud_functions/cloud_functions.dart';

/// All real merchant/wallet credentials live server-side in Cloud Functions
/// (see /functions/index.js). This client only calls callable functions.
class PaymentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Initiates an EVC Plus (Hormuud) mobile money payment request.
  /// Requires HORMUUD_MERCHANT_API_KEY to be configured server-side.
  Future<Map<String, dynamic>> payWithEvcPlus({
    required String phoneNumber,
    required double amountUsd,
  }) async {
    final callable = _functions.httpsCallable('createEvcPlusPayment');
    final result = await callable.call({
      'phoneNumber': phoneNumber,
      'amountUsd': amountUsd,
    });
    return Map<String, dynamic>.from(result.data);
  }

  /// Generates a USDT (TRC20) deposit address / payment intent for the user
  /// to send USDT to. Confirmation happens via blockchain webhook, handled
  /// server-side in Cloud Functions.
  Future<Map<String, dynamic>> createUsdtPaymentIntent({
    required String uid,
    required double amountUsd,
  }) async {
    final callable = _functions.httpsCallable('createUsdtPaymentIntent');
    final result = await callable.call({
      'uid': uid,
      'amountUsd': amountUsd,
    });
    return Map<String, dynamic>.from(result.data);
  }

  /// Polls / checks current subscription status after payment.
  Future<bool> checkPremiumStatus(String uid) async {
    final callable = _functions.httpsCallable('checkPremiumStatus');
    final result = await callable.call({'uid': uid});
    return result.data['isPremium'] == true;
  }

  /// Fetches the current subscription price (admin-configurable).
  Future<double> getCurrentSubscriptionPrice() async {
    final callable = _functions.httpsCallable('getSubscriptionPrice');
    final result = await callable.call();
    return (result.data['priceUsd'] as num).toDouble();
  }
}
