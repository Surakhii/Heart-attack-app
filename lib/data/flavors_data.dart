import 'package:flutter/material.dart';
import '../models/flavor.dart';

// Red Bull: 32mg caffeine per 100ml
const _rbSizes = [
  DrinkSize(250, 80),
  DrinkSize(355, 114),
  DrinkSize(473, 151),
];

// Monster standard: 32mg/100ml | Ultra: 30mg/100ml
const _mStdSizes = [
  DrinkSize(250, 80),
  DrinkSize(355, 114),
  DrinkSize(500, 160),
];
const _mUltraSizes = [
  DrinkSize(250, 75),
  DrinkSize(355, 107),
  DrinkSize(500, 150),
];

const List<Flavor> redbullFlavors = [
  Flavor(
    id: 'rb_original',
    name: 'Original',
    brand: Brand.redbull,
    color: Color(0xFF1565C0),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_sugar_free',
    name: 'Sugar Free',
    brand: Brand.redbull,
    color: Color(0xFF455A64),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_red',
    name: 'Red Edition',
    brand: Brand.redbull,
    color: Color(0xFFC62828),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_blue',
    name: 'Blue Edition',
    brand: Brand.redbull,
    color: Color(0xFF0D47A1),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_yellow',
    name: 'Yellow Edition',
    brand: Brand.redbull,
    color: Color(0xFFF9A825),
    textColor: Color(0xFF1A1A1A),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_green',
    name: 'Green Edition',
    brand: Brand.redbull,
    color: Color(0xFF2E7D32),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_purple',
    name: 'Purple Edition',
    brand: Brand.redbull,
    color: Color(0xFF6A1B9A),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_peach',
    name: 'Peach Edition',
    brand: Brand.redbull,
    color: Color(0xFFBF360C),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_coconut',
    name: 'Coconut Edition',
    brand: Brand.redbull,
    color: Color(0xFF37474F),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_orange',
    name: 'Orange Edition',
    brand: Brand.redbull,
    color: Color(0xFFE65100),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_white',
    name: 'White Edition',
    brand: Brand.redbull,
    color: Color(0xFF546E7A),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_summer',
    name: 'Summer Edition',
    brand: Brand.redbull,
    color: Color(0xFF00838F),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_apple',
    name: 'Apple Edition',
    brand: Brand.redbull,
    color: Color(0xFF558B2F),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_ice',
    name: 'Ice Edition',
    brand: Brand.redbull,
    color: Color(0xFF80DEEA),
    textColor: Color(0xFF1A1A1A),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
  Flavor(
    id: 'rb_ruby',
    name: 'Ruby Edition',
    brand: Brand.redbull,
    color: Color(0xFF880E4F),
    caffeinePer100ml: 32,
    sizes: _rbSizes,
  ),
];

const List<Flavor> monsterFlavors = [
  Flavor(
    id: 'm_original',
    name: 'Original',
    brand: Brand.monster,
    color: Color(0xFF1B5E20),
    caffeinePer100ml: 32,
    sizes: _mStdSizes,
  ),
  Flavor(
    id: 'm_mango',
    name: 'Mango Loco',
    brand: Brand.monster,
    color: Color(0xFFE65100),
    caffeinePer100ml: 32,
    sizes: _mStdSizes,
  ),
  Flavor(
    id: 'm_pipeline',
    name: 'Pipeline Punch',
    brand: Brand.monster,
    color: Color(0xFFAD1457),
    caffeinePer100ml: 32,
    sizes: _mStdSizes,
  ),
  Flavor(
    id: 'm_pacific',
    name: 'Pacific Punch',
    brand: Brand.monster,
    color: Color(0xFFB71C1C),
    caffeinePer100ml: 32,
    sizes: _mStdSizes,
  ),
  Flavor(
    id: 'm_ultra_white',
    name: 'Ultra White',
    brand: Brand.monster,
    color: Color(0xFF546E7A),
    caffeinePer100ml: 30,
    sizes: _mUltraSizes,
  ),
  Flavor(
    id: 'm_ultra_red',
    name: 'Ultra Red',
    brand: Brand.monster,
    color: Color(0xFFC62828),
    caffeinePer100ml: 30,
    sizes: _mUltraSizes,
  ),
  Flavor(
    id: 'm_ultra_blue',
    name: 'Ultra Blue',
    brand: Brand.monster,
    color: Color(0xFF0D47A1),
    caffeinePer100ml: 30,
    sizes: _mUltraSizes,
  ),
  Flavor(
    id: 'm_ultra_black',
    name: 'Ultra Black',
    brand: Brand.monster,
    color: Color(0xFF263238),
    caffeinePer100ml: 30,
    sizes: _mUltraSizes,
  ),
  Flavor(
    id: 'm_ultra_gold',
    name: 'Ultra Gold',
    brand: Brand.monster,
    color: Color(0xFFF9A825),
    textColor: Color(0xFF1A1A1A),
    caffeinePer100ml: 30,
    sizes: _mUltraSizes,
  ),
  Flavor(
    id: 'm_ultra_watermelon',
    name: 'Ultra Watermelon',
    brand: Brand.monster,
    color: Color(0xFFAD1457),
    caffeinePer100ml: 30,
    sizes: _mUltraSizes,
  ),
  Flavor(
    id: 'm_ultra_paradise',
    name: 'Ultra Paradise',
    brand: Brand.monster,
    color: Color(0xFF00695C),
    caffeinePer100ml: 30,
    sizes: _mUltraSizes,
  ),
  Flavor(
    id: 'm_ultra_peachy',
    name: 'Ultra Peachy Keen',
    brand: Brand.monster,
    color: Color(0xFFBF360C),
    caffeinePer100ml: 30,
    sizes: _mUltraSizes,
  ),
  Flavor(
    id: 'm_bad_apple',
    name: 'Bad Apple',
    brand: Brand.monster,
    color: Color(0xFF4CAF50),
    caffeinePer100ml: 32,
    sizes: _mStdSizes,
  ),
  Flavor(
    id: 'm_fantasy_ruby',
    name: 'Fantasy Ruby Red',
    brand: Brand.monster,
    color: Color(0xFF9C1A40),
    caffeinePer100ml: 32,
    sizes: _mStdSizes,
  ),
  Flavor(
    id: 'm_rosa',
    name: 'Ultra Rosa',
    brand: Brand.monster,
    color: Color(0xFFE91E8C),
    caffeinePer100ml: 30,
    sizes: _mUltraSizes,
  ),
  Flavor(
    id: 'm_viking_berry',
    name: 'Viking Berry',
    brand: Brand.monster,
    color: Color(0xFF4A148C),
    caffeinePer100ml: 32,
    sizes: _mStdSizes,
  ),
  Flavor(
    id: 'm_rio_punch',
    name: 'Rio Punch',
    brand: Brand.monster,
    color: Color(0xFFE65100),
    caffeinePer100ml: 32,
    sizes: _mStdSizes,
  ),
  Flavor(
    id: 'm_lando',
    name: 'Lando Norris',
    brand: Brand.monster,
    color: Color(0xFFFF6D00),
    caffeinePer100ml: 32,
    sizes: _mStdSizes,
  ),
  Flavor(
    id: 'm_full_throttle',
    name: 'Full Throttle',
    brand: Brand.monster,
    color: Color(0xFFFFD600),
    textColor: Color(0xFF1A1A1A),
    caffeinePer100ml: 32,
    sizes: _mStdSizes,
  ),
];

const allFlavors = [...redbullFlavors, ...monsterFlavors];

Flavor? flavorById(String id) {
  try {
    return allFlavors.firstWhere((f) => f.id == id);
  } catch (_) {
    return null;
  }
}
