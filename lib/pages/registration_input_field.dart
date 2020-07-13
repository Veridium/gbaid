import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

class RegistrationInputField extends StatefulWidget {
  const RegistrationInputField({Key key}) : super(key: key);

  @override
  _RegistrationInputFieldState createState() => _RegistrationInputFieldState();
}

class _RegistrationInputFieldState extends State<RegistrationInputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: TextField(
        onSubmitted: (value) => submitEmail(context, value),
        textInputAction: TextInputAction.go,
        decoration: InputDecoration(
          hintText: "email",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: Icon(Icons.email),
        ),
      ),
    );
  }

  void submitEmail(BuildContext context, String email) {
    final registrationBloc = BlocProvider.of<RegistrationBloc>(context);
    registrationBloc.add(SubmitRegistration(email));
  }
}