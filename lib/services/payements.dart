import 'package:stripe_payment/stripe_payment.dart';

class PaymentService{


  PaymentService(){
    StripePayment.setOptions(
      StripeOptions(publishableKey: 'pk_test_gPlqnEqiVydntTBkyFzc4aUb001o1vGwb6')
    );
  }
}