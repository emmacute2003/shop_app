import 'package:flutter/material.dart';
import '../models/cart.dart';

class CartScope extends InheritedNotifier<CartModel> {
  const CartScope({
    super.key,
    required CartModel cart,
    required super.child,
  }) : super(notifier: cart);

  static CartModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'No CartScope found in context');
    return scope!.notifier!;
  }
}