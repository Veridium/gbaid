import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class Plan extends Equatable {
  final int id;
  final String name;
  final String description;
  final int price;
  final String icon;

  Plan({
    @required this.id,
    @required this.name,
    this.description,
    this.price,
    this.icon,
  });

  @override
  List<Object> get props => [
    id,
    name,
    description,
    price,
    icon,
  ];
}