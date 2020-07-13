import 'package:equatable/equatable.dart';
import '../data/model/plan.dart';
import '../data/model/receipt.dart';
import '../data/model/invoice.dart';
import '../data/model/registration.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();
}

class RegistrationInitial extends RegistrationState {
  const RegistrationInitial();

  @override
  List<Object> get props => [];
}

class RegistrationInput extends RegistrationState {
  const RegistrationInput();

  @override
  List<Object> get props => [];
}

class RegistrationLoading extends RegistrationState {
  const RegistrationLoading();

  @override
  List<Object> get props => [];
}

class RegistrationRecovery extends RegistrationState {
  const RegistrationRecovery();

  @override
  List<Object> get props => [];
}

class RegistrationWallet extends RegistrationState {
  final Registration registration;
  const RegistrationWallet(this.registration);
  
  @override
  List<Object> get props => [registration];
}

class RegistrationInProgress extends RegistrationState {
  final Registration registration;
  const RegistrationInProgress(this.registration);
  
  @override
  List<Object> get props => [registration];
}

class RegistrationLoaded extends RegistrationState {
  final Registration registration;
  final List<Plan> plans;
  const RegistrationLoaded(this.registration,this.plans);

  @override
  List<Object> get props => [registration,plans];
}

class RegistrationPlan extends RegistrationState {
  final Plan plan;
  final String token;
  const RegistrationPlan(this.plan,this.token);
  
  @override
  List<Object> get props => [plan,token];
}

class RegistrationInvoice extends RegistrationState {
  final Invoice invoice;
  final String token;
  const RegistrationInvoice(this.invoice,this.token);
  
  @override
  List<Object> get props => [invoice,token];
}

class RegistrationReceipt extends RegistrationState {
  final Receipt receipt;
  final String token;
  
  const RegistrationReceipt(this.receipt,this.token);
  
  @override
  List<Object> get props => [receipt,token];
}

class RegistrationError extends RegistrationState {
  final String message;
  const RegistrationError(this.message);

  @override
  List<Object> get props => [message];
}

class RegistrationProblem extends RegistrationState {
  final String message;
  const RegistrationProblem(this.message);

  @override
  List<Object> get props => [message];
}

class RegistrationTaken extends RegistrationState {
  final String message;
  final String email;
  const RegistrationTaken(this.message,this.email);

  @override
  List<Object> get props => [message,email];
}
