import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  final int invoice_id;
  final String plan_name;
  final int price_cents;
  final String discount_name;
  final int rebate_cents;
  final int total_cents;

  Invoice({
    @required this.invoice_id,
    @required this.plan_name,
    @required this.price_cents,
    this.discount_name,
    this.rebate_cents,
    @required this.total_cents,
  });

  @override
  List<Object> get props => [
    invoice_id,
    plan_name,
    price_cents,
    discount_name,
    rebate_cents,
    total_cents,
  ];
}