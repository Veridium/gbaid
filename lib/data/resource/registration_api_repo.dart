import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../registration_repo.dart';
import '../model/credential.dart';
import '../model/plan.dart';
import '../model/receipt.dart';
import '../model/invoice.dart';
import '../model/registration.dart';
import '../database_helper.dart';

final bool _kReleaseMode = const bool.fromEnvironment("dart.vm.product");

class ApiRegistrationRepo implements RegistrationRepo {
  final RemoteConfig remoteConfig;

  ApiRegistrationRepo(this.remoteConfig) : super();

  String _getBaseURL() {
    if(_kReleaseMode) {
      return this.remoteConfig.getString('baseUrl');
    } else {
      return "http://localhost:3000";
    }
  }

  @override
  Future<Registration> submitRegistration(email) async {
    final String baseUrl = _getBaseURL();
    final registrationUrl = '$baseUrl/users.json';
    http.Response registrationResponse;
    try {
      final password = randomString(15);
      print(password);
      registrationResponse = await http.post(Uri.encodeFull(registrationUrl),
          body: json.encode({
            'user': {
              'email': email,
              'password': password,
              'password_confirmation': password
            }
          }),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 30));
    } catch (e) {
      print(e);
      throw NetworkError();
    }

    if (registrationResponse.statusCode != 201) {
      final Map errors = json.decode(registrationResponse.body);
      if (errors['errors']['email'][0] == "has already been taken") {
        throw EmailTakenError();
      } else {
        throw NetworkError();
      }
    }

    print(registrationResponse.body);
    final Map registration = json.decode(registrationResponse.body);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', registration['email']);
    prefs.setString('token', registration['auth_token']);
    prefs.setString('confirmed_at', null);
    prefs.setInt('numOfCredentials', 0);

    return Registration(
      email: registration['email'],
      token: registration['auth_token'],
      confirmed_at: null,
      numOfCredentials: 0,
    );
  }

  @override
  Future<void> submitResetRequest(email) async {
    final String baseUrl = _getBaseURL();
    final registrationUrl = '$baseUrl/api/reset.json';
    http.Response registrationResponse;
    try {
      registrationResponse = await http.post(Uri.encodeFull(registrationUrl),
          body: json.encode({'email': email}),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 30));
    } catch (e) {
      print(e);
      throw NetworkError();
    }

    if (registrationResponse.statusCode != 200) {
      throw ResetError();
    }

    return;
  }

  @override
  Future<Registration> submitRecovery(resetCode) async {
    final String baseUrl = _getBaseURL();
    final registrationUrl = '$baseUrl/users/password.json';
    http.Response registrationResponse;
    try {
      final password = randomString(15);
      print(password);
      registrationResponse = await http.put(Uri.encodeFull(registrationUrl),
          body: json.encode({
            'user': {
              'reset_password_token': resetCode,
              'password': password,
              'password_confirmation': password
            }
          }),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 30));
    } catch (e) {
      print(e);
      throw NetworkError();
    }

    if (registrationResponse.statusCode != 200) {
      throw NetworkError();
    }

    print(registrationResponse.body);
    final Map registration = json.decode(registrationResponse.body);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', registration['email']);
    prefs.setString('token', registration['auth_token']);
    prefs.setString('confirmed_at', registration['confirmed_at']);
    prefs.setInt('numOfCredentials',0);

    return Registration(
      email: registration['email'],
      token: registration['auth_token'],
      confirmed_at: registration['confirmed_at'],
      numOfCredentials: 0,
    );
  }

  @override
  Future<Registration> confirmRegistration(email, auth_token) async {
    final String baseUrl = _getBaseURL();
    final registrationUrl = '$baseUrl/api/confirm.json';
    http.Response registrationResponse;
    try {
      registrationResponse = await http.post(Uri.encodeFull(registrationUrl),
          body: json.encode({'auth_token': auth_token}),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 30));
    } catch (e) {
      print(e);
      return Registration(
        email: email,
        token: auth_token,
        confirmed_at: null,
      );
    }

    if (registrationResponse.statusCode != 200) {
      throw NotConfirmedError();
    }

    print(registrationResponse.body);
    final Map registration = json.decode(registrationResponse.body);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', registration['email']);
    prefs.setString('token', registration['auth_token']);
    prefs.setString('confirmed_at', registration['confirmed_at']);
    prefs.setInt('numOfCredentials',0);

    return Registration(
        email: registration['email'],
        token: registration['auth_token'],
        confirmed_at: registration['confirmed_at'],
        numOfCredentials: 0);
  }

  @override
  Future<void> deleteRegistration(String auth_token) async {
    final String baseUrl = _getBaseURL();
    final registrationUrl = '$baseUrl/api/delete.json';
    http.Response registrationResponse;
    try {
      registrationResponse = await http.post(Uri.encodeFull(registrationUrl),
          body: json.encode({'auth_token': auth_token}),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 30));
    } catch (e) {
      print(e);
      throw NetworkError();
    }

    if (registrationResponse.statusCode != 200) {
      throw NetworkError();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', null);
    prefs.setString('token', null);
    prefs.setString('confirmed_at', null);
    prefs.setInt('numOfCredentials', 0);
  }

  @override
  Future<Registration> resendRegistration(String email,String auth_token) async {
    final String baseUrl = _getBaseURL();
    final registrationUrl = '$baseUrl/api/resend.json';
    http.Response registrationResponse;
    try {
      registrationResponse = await http.post(Uri.encodeFull(registrationUrl),
          body: json.encode({'auth_token': auth_token}),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 30));
    } catch (e) {
      print(e);
      throw NetworkError();
    }

    if (registrationResponse.statusCode != 200) {
      print("resend failed");
      throw ResendError();
    }

    print(registrationResponse.body);
    final Map registration = json.decode(registrationResponse.body);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', registration['email']);
    prefs.setString('token', registration['auth_token']);
    prefs.setString('confirmed_at', registration['confirmed_at']);
    prefs.setInt('numOfCredentials',0);

    return Registration(
        email: registration['email'],
        token: registration['auth_token'],
        confirmed_at: registration['confirmed_at']);
  }

  @override
  Future<Registration> loadRegistration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email');
    String token = prefs.getString('token');
    String confirmed_at = prefs.getString('confirmed_at');
    int numOfCredentials = prefs.getInt('numOfCredentials') ?? 0;
    print("Loaded: ${email}, ${token}, ${confirmed_at}, ${numOfCredentials}");
    return Future.delayed(Duration(seconds: 2), () {
      if (email == null) {
        return Registration(
          email: null,
          token: null,
          confirmed_at: null,
          numOfCredentials: 0,
        );
      } else {
        return Registration(
          email: email,
          token: token,
          confirmed_at: confirmed_at,
          numOfCredentials: numOfCredentials,
        );
      }
    });
  }

  @override
  Future<List<Plan>> loadPlans(String auth_token) async {
    final String baseUrl = _getBaseURL();
    final plansUrl = '$baseUrl/api/plans.json';
    http.Response plansResponse;
    try {
      plansResponse = await http.post(Uri.encodeFull(plansUrl),
          body: json.encode({'auth_token': auth_token}),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 30));
    } catch (e) {
      print(e);
      throw NetworkError();
    }

    if (plansResponse.statusCode != 200) {
      throw NetworkError();
    }

    print(plansResponse.body);
    final List l = json.decode(plansResponse.body);
    final List<Plan> plans = new List();
    l.forEach((i) {
      plans.add(new Plan(name: i["name"],price: i["price_cents"]));
    });

    return plans;
  }

  @override
  Future<Plan> fetchPlan(String planName,String auth_token) async {
    final String baseUrl = _getBaseURL();
    final plansUrl = '$baseUrl/api/plan.json';
    http.Response planResponse;
    try {
      planResponse = await http.post(Uri.encodeFull(plansUrl),
          body: json.encode({'auth_token': auth_token, 'planName': planName}),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 30));
    } catch (e) {
      print(e);
      throw NetworkError();
    }

    if (planResponse.statusCode != 200) {
      throw NetworkError();
    }

    print(planResponse.body);
    final Map plan = json.decode(planResponse.body);

    return Plan(
        id: plan['id'],
        name: plan['name'],
        description: plan['description'],
        price: plan['price_cents']);
  }

  @override
  Future<Invoice> fetchInvoice(String token,Plan plan,String coupon) async {
    final String baseUrl = _getBaseURL();
    final invoiceUrl = '$baseUrl/api/invoice.json';
    http.Response invoiceResponse;
    try {
      invoiceResponse = await http.post(Uri.encodeFull(invoiceUrl),
          body: json.encode({'auth_token': token, 'plan_id': plan.id, 'coupon': coupon}),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 30));
    } catch (e) {
      print(e);
      throw NetworkError();
    }

    if (invoiceResponse.statusCode != 200) {
      throw NetworkError();
    }

    print(invoiceResponse.body);
    final Map i = json.decode(invoiceResponse.body);

    print(i['discount']);

    final Invoice invoice = Invoice(
        invoice_id: i['id'],
        plan_name: i['plan']['name'],
        price_cents: i['plan']['price_cents'],
        discount_name: i['discount'] != null ? i['discount']['name'] : "",
        rebate_cents: i['rebate_cents'],
        total_cents: i['total_cents']);

    print(invoice);

    return invoice;
  }

  @override
  Future<Receipt> makePayment(String token,Invoice invoice,String nonce) async {
    final String baseUrl = _getBaseURL();
    final paymentUrl = '$baseUrl/api/payment.json';
    http.Response paymentResponse;
    try {
      paymentResponse = await http.post(Uri.encodeFull(paymentUrl),
          body: json.encode({'auth_token': token, 'invoice_id': invoice.invoice_id, 'nonce': nonce}),
          headers: {
            "Content-Type": "application/json"
          }).timeout(Duration(seconds: 30));
    } catch (e) {
      print(e);
      throw NetworkError();
    }

    if (paymentResponse.statusCode != 200) {
      throw NetworkError();
    }

    print(paymentResponse.body);
    final Map r = json.decode(paymentResponse.body);
    String expires = "";
    if (r['expires'] == null) {
      expires = "never";
    } else {
      DateTime expires_at = DateTime.parse(r['expires']);
      expires = DateFormat('dd MMM yyyy').format(expires_at);
    }
    
    final Receipt receipt = Receipt(
        email: r['user']['email'],
        plan_name: invoice.plan_name,
        expires: expires,
        price_cents: invoice.price_cents,
        discount_name: invoice.discount_name,
        rebate_cents: invoice.rebate_cents,
        total_cents: invoice.total_cents,
        description: r['description']);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int numOfCredentials = prefs.getInt('numOfCredentials');

    Note note = Note(receipt.plan_name,"${receipt.email} (exp:${receipt.expires})");
    DatabaseHelper db = new DatabaseHelper();
    await db.saveNote(note);

    prefs.setInt('numOfCredentials', numOfCredentials+1);

    return receipt;
  }

}
