import '../data/model/plan.dart';
import '../data/model/invoice.dart';
import 'package:equatable/equatable.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();
}

class SubmitRegistration extends RegistrationEvent {
  final String email;

  const SubmitRegistration(this.email);

  @override
  List<Object> get props => [email];
}

class StartRecovery extends RegistrationEvent {
  final String email;

  const StartRecovery(this.email);

  @override
  List<Object> get props => [email];
}

class SubmitRecovery extends RegistrationEvent {
  final String resetCode;

  const SubmitRecovery(this.resetCode);

  @override
  List<Object> get props => [resetCode];
}

class CancelRecovery extends RegistrationEvent {
  final String auth_token;

  const CancelRecovery(this.auth_token);

  @override
  List<Object> get props => [auth_token];
}

class ResendRegistration extends RegistrationEvent {
  final String email;
  final String auth_token;

  const ResendRegistration(this.email,this.auth_token);

  @override
  List<Object> get props => [email,auth_token];
}

class LoadRegistration extends RegistrationEvent {
  const LoadRegistration();
  
  @override
  List<Object> get props => [];
}

class ShowPlans extends RegistrationEvent {
  const ShowPlans();
  
  @override
  List<Object> get props => [];
}

class ShowWallet extends RegistrationEvent {
  const ShowWallet();
  
  @override
  List<Object> get props => [];
}

class ShowReceipt extends RegistrationEvent {
  final String token;
  final Invoice invoice;
  final String nonce;
  
  const ShowReceipt(this.token,this.invoice,this.nonce);
  
  @override
  List<Object> get props => [token,invoice,nonce];
}

class ShowInvoice extends RegistrationEvent {
  final String token;
  final Plan plan;
  final String coupon;
  
  const ShowInvoice(this.token,this.plan,this.coupon);
  
  @override
  List<Object> get props => [token,plan,coupon];
}

class ShowPlan extends RegistrationEvent {
  final String planName;
  final String token;
  
  const ShowPlan(this.planName,this.token);
  
  @override
  List<Object> get props => [planName,token];
}

class SelectPlan extends RegistrationEvent {
  final int planId;
  final String token;
  
  const SelectPlan(this.planId,this.token);
  
  @override
  List<Object> get props => [planId,token];
}

class CancelPlan extends RegistrationEvent {
  final String token;
  
  const CancelPlan(this.token);
  
  @override
  List<Object> get props => [token];
}

class ConfirmRegistration extends RegistrationEvent {
  final String email;
  final String auth_token;

  const ConfirmRegistration(this.email,this.auth_token);
  
  @override
  List<Object> get props => [email,auth_token];
}
