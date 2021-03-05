import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/model/plan.dart';
import '../data/model/receipt.dart';
import '../data/model/invoice.dart';
import '../data/model/registration.dart';
import '../data/registration_repo.dart';
import './bloc.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final RegistrationRepo registrationRepo;

  RegistrationBloc(this.registrationRepo) : super(RegistrationInitial());

  @override
  RegistrationState get initialState => RegistrationInitial();

  @override
  Stream<RegistrationState> mapEventToState(RegistrationEvent event) async* {
    if (event is LoadRegistration) {
      yield* _mapLoadToState();
    } else if (event is SubmitRegistration) {
      yield* _mapSubmitToState(event.email);
    } else if (event is SubmitRecovery) {
      yield* _mapRecoveryToState(event.resetCode);
    }else if (event is ResendRegistration) {
      yield* _mapResendToState(event.email,event.auth_token);
    } else if (event is ConfirmRegistration) {
      yield* _mapConfirmToState(event.email,event.auth_token);
    } else if (event is CancelRecovery) {
      if(event.auth_token != null) await registrationRepo.deleteRegistration(event.auth_token);
      yield RegistrationInput();
    } else if (event is StartRecovery) {
      yield* _mapResetToState(event.email);
    } else if (event is ShowPlan) {
      yield* _mapShowToPlan(event.planName,event.token);
    } else if (event is CancelPlan) {
      yield RegistrationLoading();
      yield* _mapLoadToState();
    } else if (event is ShowInvoice) {
      yield* _mapShowToInvoice(event.token,event.plan,event.coupon);
    } else if (event is ShowReceipt) {
      yield* _mapShowToReceipt(event.token,event.invoice,event.nonce);
    } else if (event is ShowWallet) {
      yield* _mapLoadToState();
    } else if (event is ShowPlans) {
      yield* _mapShowPlans();
    }
  }

  Stream<RegistrationState> _mapShowPlans() async* {
    yield RegistrationLoading();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email');
    String token = prefs.getString('token');
    String confirmed_at = prefs.getString('confirmed_at');
    int numOfCredentials = prefs.getInt('numOfCredentials') ?? 0;

    final Registration registration = Registration(
      email: email,
      token: token,
      confirmed_at: confirmed_at,
      numOfCredentials: numOfCredentials,
    );

    try {
      final List<Plan> plans = await registrationRepo.loadPlans(token);
      yield RegistrationLoaded(registration,plans);
    } on NetworkError {
      if(numOfCredentials > 0) {
        yield RegistrationProblem("Network or server problem.  Try again later.");
        yield RegistrationWallet(registration);
      } else {
        yield RegistrationProblem("Network error.  Please try again later.");
      }
    }
  }

  Stream<RegistrationState> _mapShowToReceipt(String token,Invoice invoice,String nonce) async* {
    yield RegistrationLoading();
    try {
      final Receipt receipt = await registrationRepo.makePayment(token,invoice,nonce);
      yield RegistrationReceipt(receipt,token);
    } on NetworkError {
      yield RegistrationProblem("Network error.  Please try again later.");
      yield RegistrationLoading();
    }
  }

  Stream<RegistrationState> _mapShowToInvoice(String token,Plan plan,String coupon) async* {
    try {
      final Invoice invoice = await registrationRepo.fetchInvoice(token,plan,coupon);
      yield RegistrationInvoice(invoice,token);
    } on ResetError {
      yield RegistrationProblem("Plan unavailable.  Select another plan.");
      yield RegistrationLoading();
    }
  }

  Stream<RegistrationState> _mapShowToPlan(String planName,String auth_token) async* {
    try {
      final Plan plan = await registrationRepo.fetchPlan(planName,auth_token);
      yield RegistrationPlan(plan,auth_token);
    } on ResetError {
      yield RegistrationError("Plan unavailable.  Select another plan.");
    } on NetworkError {
      yield RegistrationProblem("Plan unavailable.  Select another plan.");
    }
  }

  Stream<RegistrationState> _mapResetToState(String email) async* {
    try {
      await registrationRepo.submitResetRequest(email);
      yield RegistrationRecovery();
    } on ResetError {
      yield RegistrationError("You must first confirm your registration.  Please check your email.");
      yield RegistrationInput();
    }
  }

  Stream<RegistrationState> _mapLoadToState() async* {
    print("mapLoadToState...");
    yield RegistrationLoading();
    final registration = await registrationRepo.loadRegistration();
    if (registration.numOfCredentials > 0) {
      yield RegistrationWallet(registration);
    } else if (registration.confirmed_at != null) {
      try {
        final plans = await registrationRepo.loadPlans(registration.token);
        yield RegistrationLoaded(registration,plans);
      } on NetworkError {
        print("mapLoadToState network error...");
        yield RegistrationProblem("Cannot reach server.  Try again later.");
        if(registration.numOfCredentials > 0) {
          yield RegistrationWallet(registration);
        } else {
          yield RegistrationLoading();
        }
      }
    } else if(registration.token != null) {
      yield RegistrationInProgress(registration);
    } else {
      yield RegistrationInput();
    }
  }

  Stream<RegistrationState> _mapResendToState(String email,String auth_token) async* {
    Registration registration;
    try {
      registration = await registrationRepo.resendRegistration(email,auth_token);
      yield RegistrationInProgress(registration);
    } on ResendError {
      yield RegistrationError("Resend error.  Try again later or re-register.");
      yield RegistrationInProgress(
        Registration(
          email: email,
          token: auth_token,
          confirmed_at: null,)
      );
    }
  }

  Stream<RegistrationState> _mapSubmitToState(String email) async* {
    try {
      yield RegistrationLoading();
      final registration = await registrationRepo.submitRegistration(email);
      if(registration.confirmed_at != null) {
        final plans = await registrationRepo.loadPlans(registration.token);
        yield RegistrationLoaded(registration,plans);
      } else {
        yield RegistrationInProgress(registration);
      }
    } on NetworkError {
      yield RegistrationError(
          "Couldn't connect to registration server. Is the device online?");
    } on EmailTakenError {
      yield RegistrationTaken("Do you want us to email you a recovery code?",email);
    }
  }

  Stream<RegistrationState> _mapRecoveryToState(String resetCode) async* {
    try {
      yield RegistrationLoading();
      final registration = await registrationRepo.submitRecovery(resetCode);
      if(registration.confirmed_at != null) {
        final plans = await registrationRepo.loadPlans(registration.token);
        yield RegistrationLoaded(registration,plans);
      } else {
        yield RegistrationInProgress(registration);
      }
    } on NetworkError {
      yield RegistrationError("Couldn't reset.  Try again later.");
    }
  }

  Stream<RegistrationState> _mapConfirmToState(String email,String auth_token) async* {
    try {
      final registration = await registrationRepo.confirmRegistration(email,auth_token);
      if(registration.confirmed_at != null) {
        final plans = await registrationRepo.loadPlans(registration.token);
        yield RegistrationLoaded(registration,plans);
      } else {
        yield RegistrationInProgress(registration);
      }
    } on NetworkError {
      yield RegistrationError("Couldn't connect to registration server. Is the device online?");
    } on NotConfirmedError {
      yield RegistrationError("You need to confirm your account.  See your email or resend.");
      yield RegistrationInProgress(
        Registration(
          email: email,
          token: auth_token,
          confirmed_at: null,)
      );
    }
  }

}
