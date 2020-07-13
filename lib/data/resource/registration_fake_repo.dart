import 'dart:math';
import '../registration_repo.dart';
import '../model/plan.dart';
import '../model/receipt.dart';
import '../model/invoice.dart';
import '../model/registration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRegistrationRepo implements RegistrationRepo {
  String token;

  @override
  Future<Registration> submitRegistration(email) {
    return Future.delayed(
      Duration(seconds: 1),
      () {
        final random = Random();

        // Simulate some network error
        if (random.nextBool()) {
          throw NetworkError();
        }

        token = "3787a3492f8288ee1212";
        return Registration(
          email: email,
          token: token);
      }
    );
  }

  @override
  Future<void> submitResetRequest(resetCode) {
    return Future.delayed(
      Duration(seconds: 1),
      () {
        final random = Random();

        // Simulate some network error
        if (random.nextBool()) {
          throw NetworkError();
        }

        return;
      }
    );
  }

  @override
  Future<Registration> submitRecovery(resetCode) {
    return Future.delayed(
      Duration(seconds: 1),
      () {
        final random = Random();

        // Simulate some network error
        if (random.nextBool()) {
          throw NetworkError();
        }

        token = "3787a3492f8288ee1212";
        return Registration(
          email: "me@example.com",
          token: "3787a3492f8288ee1212");
      }
    );
  }

  @override
  Future<Registration> confirmRegistration(email,auth_token) {
    return Future.delayed(
      Duration(seconds: 1),
      () {
        final random = Random();

        // Simulate some network error
        if (random.nextBool()) {
          throw NetworkError();
        }

        token = "3787a3492f8288ee1212";
        return Registration(
          email: email,
          token: token);
      }
    );
  }

  @override
  Future<void> deleteRegistration(String auth_token) async {
    
  }

  @override
  Future<Registration> resendRegistration(email,auth_token) async {
    final random = Random();

    // Simulate no pre-existing, locally stored registration
    if (random.nextBool()) {
      return null;
    } else {
      return Registration(
          email: email,
          token: "3787a3492f8288ee1212");
    }
  }

  @override
  Future<Registration> loadRegistration() async {
    final random = Random();

    // Simulate no pre-existing, locally stored registration
    if (random.nextBool()) {
      return null;
    } else {
      return Registration(
          email: "me@example.com",
          token: "3787a3492f8288ee1212");
    }
  }

  @override
  Future<List<Plan>> loadPlans(String auth_token) async {
    
    final List<Plan> plans = null;

    return plans;
  }

  @override
  Future<Plan> fetchPlan(String planName,String auth_token) async {
    return Plan(
        id: 1,
        name: planName,
        price: 3000);;
  }

  @override
  Future<Invoice> fetchInvoice(String token,Plan plan,String coupon) async {
    return null;
  }

  @override
  Future<Receipt> makePayment(String token,Invoice invoice,String nonce) async {
    return null;
  }
}