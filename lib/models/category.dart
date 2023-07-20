import 'package:flutter/material.dart';

enum Categories {
  hygiene,
  other,
  sweets,
  convenience,
  spices,
  vegetables,
  carbs,
  dairy,
  fruit,
  meat
}

class Category {
  const Category(this.title, this.color);

  final String title;
  final Color color;
}
