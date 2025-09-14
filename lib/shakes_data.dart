import 'package:flutter/rendering.dart';

/// Model class for a milkshake item
class MilkShakeModel {
  final String image;
  final String name;
  final String price;
  final Color color;

  MilkShakeModel({
    required this.image,
    required this.name,
    required this.price,
    required this.color,
  });
}

/// Dummy data
final List<MilkShakeModel> milkshakes = [
  MilkShakeModel(
    image: 'assets/images/banhoney.png',
    name: 'Banhoney',
    price: '12.00',
    color: Color.fromARGB(255, 255, 140, 0),
  ),
  MilkShakeModel(
    image: 'assets/images/strawmilk.png',
    name: 'Strawmilk',
    price: '11.00',
    color: Color.fromARGB(255, 255, 0, 0),
  ),
  MilkShakeModel(
    image: 'assets/images/chocoffe.png',
    name: 'Chocoffee',
    price: '15.00',
    color: Color.fromARGB(255, 66, 14, 3),
  ),
  MilkShakeModel(
    image: 'assets/images/cosmoberry.png',
    name: 'Cosmoberry',
    price: '10.00',
    color: Color.fromARGB(255, 97, 22, 218),
  ),
];
