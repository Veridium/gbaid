import 'model/plan.dart';
import 'model/receipt.dart';
import 'model/invoice.dart';
import 'model/registration.dart';

abstract class RegistrationRepo {
  Future<Registration> loadRegistration();
  Future<Registration> submitRegistration(String email);
  Future<Registration> resendRegistration(String email,String auth_token);
  Future<Registration> confirmRegistration(String email,String auth_token);
  Future<Registration> submitRecovery(String resetCode);
  
  Future<void> deleteRegistration(String auth_token);
  Future<void> submitResetRequest(String email);

  Future<List<Plan>> loadPlans(String auth_token);
  Future<Plan> fetchPlan(String planName,String auth_token);
  Future<Invoice> fetchInvoice(String token,Plan plan,String coupon);
  Future<Receipt> makePayment(String token,Invoice invoice,String nonce);
}

class NetworkError extends Error {}

class EmailTakenError extends Error {}

class NotConfirmedError extends Error {}

class ResendError extends Error {}

class ResetError extends Error {}
