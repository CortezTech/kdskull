import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

class CartLine {
  CartLine({required this.dish, this.qty = 1, this.notes = ''});

  final Dish dish;
  final int qty;
  final String notes;

  CartLine copyWith({int? qty, String? notes}) =>
      CartLine(dish: dish, qty: qty ?? this.qty, notes: notes ?? this.notes);
}

class CartNotifier extends Notifier<List<CartLine>> {
  @override
  List<CartLine> build() => [];

  void add(Dish dish) {
    final i = state.indexWhere((l) => l.dish.id == dish.id);
    if (i == -1) {
      state = [...state, CartLine(dish: dish, qty: 1)];
    } else {
      final line = state[i];
      final updated = line.copyWith(qty: line.qty + 1);
      final next = [...state]..[i] = updated;
      state = next;
    }
  }

  void removeOne(Dish dish) {
    final i = state.indexWhere((l) => l.dish.id == dish.id);
    if (i == -1) return;
    final line = state[i];
    if (line.qty <= 1) {
      state = [...state]..removeAt(i);
    } else {
      final updated = line.copyWith(qty: line.qty - 1);
      final next = [...state]..[i] = updated;
      state = next;
    }
  }

  void clear() => state = [];
}

final cartProvider = NotifierProvider<CartNotifier, List<CartLine>>(
  CartNotifier.new,
);