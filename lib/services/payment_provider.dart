import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentProvider with ChangeNotifier {
  GlobalKey<ScaffoldState> scaffolKey = GlobalKey();
  PaymentMethod _paymentMethod = PaymentMethod();

  PaymentProvider.initialize() {
    StripePayment.setOptions(StripeOptions(
        publishableKey: 'pk_test_gPlqnEqiVydntTBkyFzc4aUb001o1vGwb6'));
  }

  void addCard() {
    StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
        .then((paymentMethod) {
          _paymentMethod = paymentMethod;
    }).catchError((err){
      print(err.toString());
    });
  }
}
