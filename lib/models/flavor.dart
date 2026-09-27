import 'package:flutter/material.dart';

enum Brand { redbull, monster }

class DrinkSize {
  final int ml;
  final int caffeineMg;
  const DrinkSize(this.ml, this.caffeineMg);
  String get label => '${ml}ml';
}

class Flavor {
  final String id;
  final String name;
  final Brand brand;
  final Color color;
  final Color textColor;
  final double caffeinePer100ml;
  final List<DrinkSize> sizes;
  final String? imageUrl;

  const Flavor({
    required this.id,
    required this.name,
    required this.brand,
    required this.color,
    this.textColor = Colors.white,
    required this.caffeinePer100ml,
    required this.sizes,
    this.imageUrl,
  });

  String get brandName => brand == Brand.redbull ? 'Red Bull' : 'Monster';
}
