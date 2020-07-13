import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

class RecoveryInputField extends StatefulWidget {
  const RecoveryInputField({Key key}) : super(key: key);

  @override
  _RecoveryInputFieldState createState() => _RecoveryInputFieldState();
}

class _RecoveryInputFieldState extends State<RecoveryInputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(children: <Widget>[
          TextField(
            onSubmitted: (value) => submitRecovery(context, value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: "reset code",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: Icon(Icons.lock),
            ),
          ),
          SizedBox(height: 10),
          RaisedButton(
            onPressed: () => cancelRecovery(context),
            child: Text("Cancel"),
          ),
        ]));
  }

  void submitRecovery(BuildContext context, String resetCode) {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    registrationBloc.add(SubmitRecovery(resetCode));
  }

  void cancelRecovery(BuildContext context) {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    registrationBloc.add(CancelRecovery(null));
  }
}