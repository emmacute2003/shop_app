import 'package:flutter/material.dart';
import '../models/wishlist.dart';

class WishlistScope extends InheritedNotifier<WishlistModel> {
  const WishlistScope({
    super.key,
    required WishlistModel wishlist,
    required super.child,
  }) : super(notifier: wishlist);

  static WishlistModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WishlistScope>();
    assert(scope != null, 'No WishlistScope found in context');
    return scope!.notifier!;
  }
}