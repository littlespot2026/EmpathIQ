import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'storage_service.dart';

enum PaymentGateway {
  sandbox,
  stripe,
  lemonSqueezy,
  appStore,
}

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  static PaymentService get instance => _instance;

  PaymentService._internal();

  PaymentGateway activeGateway = PaymentGateway.sandbox;

  // External live checkout URLs (configurable by developer)
  String stripeWeeklyCheckoutUrl = 'https://buy.stripe.com/test_weekly';
  String stripeMonthlyCheckoutUrl = 'https://buy.stripe.com/test_monthly';
  String stripeYearlyCheckoutUrl = 'https://buy.stripe.com/test_yearly';
  String lemonSqueezyStoreUrl = 'https://empathiq.lemonsqueezy.com/buy';

  /// Execute checkout for selected subscription tier or token pack
  Future<bool> processCheckout({
    required BuildContext context,
    required String planId, // 'weekly', 'monthly', 'yearly', 'pack_10'
    bool forceSandbox = true,
  }) async {
    final storage = await StorageService.getInstance();

    if (forceSandbox || activeGateway == PaymentGateway.sandbox) {
      // Simulate real gateway processing delay
      await Future.delayed(const Duration(milliseconds: 650));

      if (planId == 'pack_10') {
        await storage.addEmergencyScans(10);
        return true;
      } else {
        await storage.setUserPro(true, plan: planId);
        return true;
      }
    }

    // In a live web deployment with Lemon Squeezy or Stripe:
    if (kIsWeb) {
      String targetUrl = lemonSqueezyStoreUrl;
      if (activeGateway == PaymentGateway.stripe) {
        if (planId == 'weekly') targetUrl = stripeWeeklyCheckoutUrl;
        if (planId == 'monthly') targetUrl = stripeMonthlyCheckoutUrl;
        if (planId == 'yearly') targetUrl = stripeYearlyCheckoutUrl;
      }
      debugPrint('Redirecting to checkout URL: $targetUrl');
    }

    return true;
  }

  /// Restore user purchases from local storage or cloud receipt
  Future<bool> restorePurchases() async {
    final storage = await StorageService.getInstance();
    // Simulate query
    await Future.delayed(const Duration(milliseconds: 500));
    return storage.isUserPro();
  }
}
