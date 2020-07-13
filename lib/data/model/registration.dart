import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class Registration extends Equatable {
  final String email;
  final String token;
  final String confirmed_at;
  final int numOfCredentials;

  Registration({
    @required this.email,
    this.token,
    this.confirmed_at,
    this.numOfCredentials,
  });

  @override
  List<Object> get props => [
    email,
    token,
    confirmed_at,
    numOfCredentials,
  ];
}