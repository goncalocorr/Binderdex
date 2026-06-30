import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'billing_ids.dart';

/// Liga o Play Billing à Cloud Function de verificação. A app nunca escreve
/// marketTier — só envia o token para `verifyPurchase`, que valida e grava.
class BillingService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFunctions _fns =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  Future<bool> isAvailable() => _iap.isAvailable();

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  /// Offers/base plans disponíveis para o produto premium.
  Future<List<ProductDetails>> loadOffers() async {
    final resp = await _iap.queryProductDetails({kPremiumProductId});
    return resp.productDetails;
  }

  /// Lança a compra/troca de um offer, marcando o uid (obfuscatedAccountId).
  Future<void> buy(ProductDetails offer) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final param = GooglePlayPurchaseParam(
      productDetails: offer,
      applicationUserName: uid,
    );
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() => _iap.restorePurchases();

  /// Valida no servidor e finaliza a compra. Devolve o tier concedido (ou 0).
  Future<int> handlePurchase(PurchaseDetails p) async {
    int tier = 0;
    if (p.status == PurchaseStatus.purchased ||
        p.status == PurchaseStatus.restored) {
      final token = p.verificationData.serverVerificationData;
      try {
        final res = await _fns.httpsCallable('verifyPurchase').call({
          'purchaseToken': token,
          'basePlanId': p.productID, // informativo; a função recalcula pela Play
        });
        tier = (res.data?['tier'] as int?) ?? 0;
      } catch (_) {
        // Falha de verificação — não concede nada; a app fica como está.
      }
    }
    if (p.pendingCompletePurchase) {
      await _iap.completePurchase(p);
    }
    return tier;
  }
}
