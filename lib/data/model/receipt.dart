import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class Receipt extends Equatable {
  final String email;
  final String plan_name;
  final String expires;
  final int price_cents;
  final String discount_name;
  final int rebate_cents;
  final int total_cents;
  final String description;

  Receipt({
    @required this.email,
    @required this.plan_name,
    @required this.expires,
    @required this.price_cents,
    this.discount_name,
    this.rebate_cents,
    @required this.total_cents,
    this.description,
  });

  @override
  List<Object> get props => [
    email,
    plan_name,
    expires,
    price_cents,
    discount_name,
    rebate_cents,
    total_cents,
    description,
  ];
}