import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_in_app_payments/models.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info/package_info.dart';

import '../bloc/bloc.dart';
import '../data/model/plan.dart';
import '../data/model/receipt.dart';
import '../data/model/invoice.dart';
import '../data/model/registration.dart';
import '../widget/poweredby.dart';

import 'registration_input_field.dart';
import 'recovery_input_field.dart';
import 'listview_credential.dart';

class RegistrationSignupPage extends StatefulWidget {
  RemoteConfig remoteConfig;

  RegistrationSignupPage(RemoteConfig remoteConfig) {
    this.remoteConfig = remoteConfig;
  }

  RegistrationSignupPageState createState() =>
      RegistrationSignupPageState(remoteConfig);
}

class RegistrationSignupPageState extends State<RegistrationSignupPage> {
  final RemoteConfig remoteConfig;
  BuildContext _context;
  Invoice _invoice;
  String _token;
  String _nonce;

  RegistrationSignupPageState(this.remoteConfig) : super();

  @override
  void initState() {
    super.initState();
    _nonce = null;
    _context = null;
  }

  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String build = packageInfo.buildNumber;

    return "v${version} build ${build}";
  }

  Widget _noButton(BuildContext context) {
    return FlatButton(
      child: Text("No"),
      onPressed: () {
        final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
        registrationBloc.add(CancelRecovery(null));
      },
    );
  }

  Widget _yesButton(BuildContext context, String email) {
    return FlatButton(
      child: Text("Yes"),
      onPressed: () {
        final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
        registrationBloc.add(StartRecovery(email));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GBA Id"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          title: Text("GBA Id"),
                          content: FutureBuilder(
                              future: getVersionNumber(),
                              builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) =>
                                  Text(
                                    snapshot.hasData
                                        ? snapshot.data
                                        : "Loading ...",
                                    style: TextStyle(color: Colors.black38),
                                  )));
                    });
              })
        ],
      ),
      bottomNavigationBar: new Container(height: 100, child: PoweredByLogo()),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: BlocListener<RegistrationBloc, RegistrationState>(
            listener: (context, state) {
          if (state is RegistrationError) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          } else if (state is RegistrationProblem) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        }, child: BlocBuilder<RegistrationBloc, RegistrationState>(
          builder: (context, state) {
            if (state is RegistrationInitial) {
              print("*** RegistrationInitial");
              return _buildInitialSplash();
            } else if (state is RegistrationInput) {
              print("*** RegistrationInput");
              return _buildInitialInput();
            } else if (state is RegistrationLoading) {
              print("*** RegistrationLoading");
              return _buildLoading();
            } else if (state is RegistrationInProgress) {
              print("*** RegistrationInProgress");
              return _buildAwaitingConfirmation(context, state.registration);
            } else if (state is RegistrationLoaded) {
              print("*** RegistrationLoaded");
              return _buildColumnWithData(
                  context, state.registration, state.plans);
            } else if (state is RegistrationRecovery) {
              print("*** RegistrationRecovery");
              return _buildRecoveryInput();
            } else if (state is RegistrationError) {
              print("*** RegistrationError");
              return _buildInitialInput();
            } else if (state is RegistrationTaken) {
              return _buildRecoveryChoice(context, state.message, state.email);
            } else if (state is RegistrationPlan) {
              print("*** RegistrationPlan ");
              return _buildShowPlan(context, state.plan, state.token);
            } else if (state is RegistrationInvoice) {
              print("*** RegistrationInvoice");
              _context = context;
              _invoice = state.invoice;
              _token = state.token;
              return _buildShowInvoice(context, state.invoice, state.token);
            } else if (state is RegistrationReceipt) {
              print("*** RegistrationReceipt");
              return _buildShowReceipt(context,state.receipt);
            } else if (state is RegistrationWallet) {
              return _buildWallet(context, state.registration);
            }
          },
        ) // BlocBuilder
            ), // BlocListener
      ), // Container
    ); // Scaffold
  }

  Widget _buildWallet(BuildContext context, Registration registration) {
    return ListViewNote();
  }

  Widget _buildShowReceipt(BuildContext context, Receipt receipt) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('images/GBA-logo-100.png'),
          SizedBox(height: 12),
          Text(
              "Thank you!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          SizedBox(height: 25),
          Table(
              border: TableBorder(
                  horizontalInside: BorderSide(color: Colors.lightBlue)),
              children: <TableRow>[
                TableRow(children: <Widget>[
                  Text("${receipt.plan_name}"),
                  Text("\$", textAlign: TextAlign.right),
                  Text("${(receipt.price_cents / 100).toStringAsFixed(2)}",
                      textAlign: TextAlign.right),
                ]),
                TableRow(children: <Widget>[
                  receipt.discount_name.isNotEmpty
                      ? Text("coupon: ${receipt.discount_name}")
                      : Text("coupon: none"),
                  Text("\$", textAlign: TextAlign.right),
                  Text("${(receipt.rebate_cents / 100).toStringAsFixed(2)}",
                      textAlign: TextAlign.right),
                ]),
                TableRow(children: <Widget>[
                  Text("Total"),
                  Text("\$", textAlign: TextAlign.right),
                  Text("${(receipt.total_cents / 100).toStringAsFixed(2)}",
                      textAlign: TextAlign.right)
                ])
              ]),
          SizedBox(height: 12),
          Text("An email receipt will be sent to:"),
          Text(
              "${receipt.email}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          Text("and appear as:"),
          Text(
              "${receipt.description}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          Text("on your statement."),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.green)),
                  onPressed: () {
                    _showWallet(context);
                  },
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text(
                    "Got it!",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ]
          ),
        ],
      ),
    );
  }

  Widget _buildShowInvoice(
      BuildContext context, Invoice invoice, String token) {
    return SizedBox(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/sovrin-logo-large.png', height: 75),
            SizedBox(height: 20),
            Text(
              invoice.plan_name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Table(
                border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.lightBlue)),
                children: <TableRow>[
                  TableRow(children: <Widget>[
                    Text("Plan base price"),
                    Text("\$", textAlign: TextAlign.right),
                    Text("${(invoice.price_cents / 100).toStringAsFixed(2)}",
                        textAlign: TextAlign.right),
                  ]),
                  TableRow(children: <Widget>[
                    invoice.discount_name.isNotEmpty
                        ? Text("coupon: ${invoice.discount_name}")
                        : Text("coupon: none"),
                    Text("\$", textAlign: TextAlign.right),
                    Text("${(invoice.rebate_cents / 100).toStringAsFixed(2)}",
                        textAlign: TextAlign.right),
                  ]),
                  TableRow(children: <Widget>[
                    Text("Total"),
                    Text("\$", textAlign: TextAlign.right),
                    Text("${(invoice.total_cents / 100).toStringAsFixed(2)}",
                        textAlign: TextAlign.right)
                  ])
                ]),
            SizedBox(width: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.green)),
                  onPressed: () {
                    _showPlan(context, token, invoice.plan_name);
                  },
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text(
                    "Back".toUpperCase(),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                SizedBox(width: 20),
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.green)),
                  onPressed: () {
                    _pay();
                  },
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text(
                    "Continue".toUpperCase(),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildShowPlan(BuildContext context, Plan plan, String token) {
    final couponController = TextEditingController();
    return SizedBox(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/sovrin-logo-large.png', height: 75),
            SizedBox(height: 20),
            Text(
              plan.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              plan.description,
            ),
            SizedBox(height: 12),
            Text("\$${(plan.price / 100).toStringAsFixed(2)}"),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.green)),
                  onPressed: () {
                    _cancelPlan(context, token);
                  },
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text(
                    "Back".toUpperCase(),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                SizedBox(width: 20),
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.green)),
                  onPressed: () {
                    _showInvoice(
                        context, token, plan, couponController.value.text);
                  },
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text(
                    "Continue".toUpperCase(),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              decoration: new InputDecoration(
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                  hintText: 'Coupon code'),
              controller: couponController,
            ),
          ],
        ));
  }

  Widget _buildRecoveryChoice(
      BuildContext context, String message, String email) {
    return AlertDialog(
      title: Text("Email already taken"),
      content: Text(message),
      actions: [
        _noButton(context),
        _yesButton(context, email),
      ],
    );
  }

  Widget _buildInitialSplash() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset('images/GBA-logo-100.png'),
        SizedBox(height: 25),
        Text(this.remoteConfig.getString('welcome')),
        SizedBox(height: 25),
        CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildInitialInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset('images/GBA-logo-100.png'),
        SizedBox(height: 12),
        RegistrationInputField(),
      ],
    );
  }

  Widget _buildRecoveryInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset('images/GBA-logo-100.png'),
        SizedBox(height: 10),
        RecoveryInputField(),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildAwaitingConfirmation(
      BuildContext context, Registration registration) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset('images/GBA-logo-100.png'),
        SizedBox(height: 10),
        Text("... waiting to confirm ${registration.email}"),
        SizedBox(height: 10),
        RaisedButton(
          onPressed: () =>
              confirmEmail(context, registration.email, registration.token),
          child: Text("I confirmed my email"),
        ),
        SizedBox(height: 10),
        RaisedButton(
          onPressed: () =>
              resendEmail(context, registration.email, registration.token),
          child: Text("Please resend confirmation email"),
        ),
        SizedBox(height: 10),
        RaisedButton(
          onPressed: () => {
            showDialog(
              context: context,
              builder: (buildContext) {
                return AlertDialog(
                  title: Text("AlertDialog"),
                  content: Text("Cancel your registration?"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("No"),
                      onPressed: () {
                        Navigator.pop(buildContext);
                      },
                    ),
                    FlatButton(
                      child: Text("Yes"),
                      onPressed: () {
                        Navigator.pop(buildContext);
                        cancelInProgress(context, registration.token);
                      },
                    ),
                  ],
                );
              },
            )
          },
          child: Text("Cancel pending registration?"),
        ),
      ],
    );
  }

  Column _buildColumnWithData(
      BuildContext context, Registration registration, List<Plan> plans) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if(registration.numOfCredentials > 0) RaisedButton(
          onPressed: () { _showWallet(context); },
          child: Text("Cancel"),
        ),
        Text("You are registered as:"),
        Text("${registration.email}",style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Image.asset('images/GBA-logo-100.png'),
        SizedBox(height: 10),
        DropdownButton<String>(
          hint: Text("Please choose a plan"),
          onChanged: (String planName) {
            _showPlan(context, registration.token, planName);
          },
          items: plans
              .map((plan) => DropdownMenuItem<String>(
                    value: plan.name,
                    child: Text(
                        "${plan.name} (\$${(plan.price / 100).toStringAsFixed(2)})"),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _showWallet(BuildContext context) {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    registrationBloc.add(ShowWallet());
  }

  void _showInvoice(
    BuildContext context, String token, Plan plan, String coupon) {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    registrationBloc.add(ShowInvoice(token, plan, coupon));
  }

  void _pay() {
    InAppPayments.setSquareApplicationId(
        this.remoteConfig.getString('squareAppId'));
    InAppPayments.startCardEntryFlow(
      onCardNonceRequestSuccess: _cardNonceRequestSuccess,
      onCardEntryCancel: _cardEntryCancel,
    );
  }

  void _cardEntryCancel() {
    // cancelled
  }

  void _cardNonceRequestSuccess(CardDetails result) {
    setState(() {
      _nonce = result.nonce;
    });
    InAppPayments.completeCardEntry(
      onCardEntryComplete: _cardEntryComplete,
    );
  }

  void _cardEntryComplete() {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(_context);
    registrationBloc.add(ShowReceipt(_token,_invoice,_nonce));
  }

  void _showPlan(BuildContext context, String token, String planName) {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    registrationBloc.add(ShowPlan(planName, token));
  }

  void _cancelPlan(BuildContext context, String token) {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    registrationBloc.add(CancelPlan(token));
  }

  void confirmEmail(BuildContext context, String email, String token) {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    registrationBloc.add(ConfirmRegistration(email, token));
  }

  void resendEmail(BuildContext context, String email, String token) {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    registrationBloc.add(ResendRegistration(email, token));
  }

  void cancelInProgress(BuildContext context, String token) {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    registrationBloc.add(CancelRecovery(token));
  }
}
