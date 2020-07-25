import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'bloc/registration_bloc.dart';
import 'data/registration_repo.dart';
import 'data/resource/registration_fake_repo.dart';
import 'data/resource/registration_api_repo.dart';
import 'bloc/registration_event.dart';
import 'pages/registration_signup_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Remote Config Example',
      home: FutureBuilder<RemoteConfig>(
        future: setupRemoteConfig(),
        builder: (BuildContext context, AsyncSnapshot<RemoteConfig> snapshot) {
          return snapshot.hasData
              ? MyApp(remoteConfig: snapshot.data)
              : Container();
        },
      )));
}

class MyApp extends StatelessWidget {
  final RemoteConfig remoteConfig;

  MyApp({this.remoteConfig}) : super();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GBA Id',
      home: BlocProvider(
        builder: (context) => RegistrationBloc(ApiRegistrationRepo(remoteConfig))..add(LoadRegistration()),
        child: RegistrationSignupPage(remoteConfig),
      ),
    );
  }
}

Future<RemoteConfig> setupRemoteConfig() async {
  final RemoteConfig remoteConfig = await RemoteConfig.instance;
  // Enable developer mode to relax fetch throttling
  remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: true));
  remoteConfig.setDefaults(<String, dynamic>{
    'welcome': 'Welcome!',
    'baseUrl': 'http://localhost:3000',
  });
  await remoteConfig.fetch(expiration: const Duration(seconds: 0));
  await remoteConfig.activateFetched();
  print("remote config fetched");
  return remoteConfig;
}