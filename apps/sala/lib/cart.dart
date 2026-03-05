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

class CartByTableNotifier extends Notifier<Map<String, List<CartLine>>> {
  @override
  Map<String, List<CartLine>> build() => {};

  List<CartLine> cartOf(String table) => state[table] ?? const [];

  int totalItemsOf(String table) =>
      cartOf(table).fold<int>(0, (acc, l) => acc + l.qty);

  void add(String table, Dish dish) {
    final cart = [...cartOf(table)];
    final i = cart.indexWhere((l) => l.dish.id == dish.id);

    if (i == -1) {
      cart.add(CartLine(dish: dish, qty: 1));
    } else {
      cart[i] = cart[i].copyWith(qty: cart[i].qty + 1);
    }
    state = {...state, table: cart};
  }

  void removeOne(String table, Dish dish) {
    final cart = [...cartOf(table)];
    final i = cart.indexWhere((l) => l.dish.id == dish.id);
    if (i == -1) return;

    final line = cart[i];
    if (line.qty <= 1) {
      cart.removeAt(i);
    } else {
      cart[i] = line.copyWith(qty: line.qty - 1);
    }

    if (cart.isEmpty) {
      final next = {...state}..remove(table);
      state = next;
    } else {
      state = {...state, table: cart};
    }
  }

  void setNotes(String table, String dishId, String notes) {
    final cart = [...cartOf(table)];
    final i = cart.indexWhere((l) => l.dish.id == dishId);
    if (i == -1) return;

    cart[i] = cart[i].copyWith(notes: notes);
    state = {...state, table: cart};
  }

  void clearTable(String table) {
    final next = {...state}..remove(table);
    state = next;
  }
}

final cartByTableProvider =
    NotifierProvider<CartByTableNotifier, Map<String, List<CartLine>>>(
      CartByTableNotifier.new,
    );
