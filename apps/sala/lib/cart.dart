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

  void add(String table, Dish dish, {String notes = '', int qty = 1}) {
    if (qty <= 0) return;

    final cart = [...cartOf(table)];
    final normalizedNotes = notes.trim();
    final i = cart.indexWhere(
      (l) => l.dish.id == dish.id && l.notes.trim() == normalizedNotes,
    );

    if (i == -1) {
      cart.add(CartLine(dish: dish, qty: qty, notes: normalizedNotes));
    } else {
      cart[i] = cart[i].copyWith(qty: cart[i].qty + qty);
    }
    state = {...state, table: cart};
  }

  void removeOne(String table, Dish dish, {String? preferredNotes}) {
    final cart = [...cartOf(table)];
    final i = _findLineIndex(
      cart,
      dish.id,
      preferredNotes: preferredNotes?.trim(),
    );
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
    final normalizedNotes = notes.trim();
    final i = _findLineIndex(cart, dishId, preferredNotes: '');
    if (i == -1) return;

    setNotesForLine(
      table,
      dishId,
      fromNotes: cart[i].notes,
      toNotes: normalizedNotes,
    );
  }

  void setNotesForLine(
    String table,
    String dishId, {
    required String fromNotes,
    required String toNotes,
  }) {
    final cart = [...cartOf(table)];
    final normalizedFrom = fromNotes.trim();
    final normalizedTo = toNotes.trim();
    final i = cart.indexWhere(
      (l) => l.dish.id == dishId && l.notes.trim() == normalizedFrom,
    );
    if (i == -1) return;

    final line = cart[i];
    final currentNotes = line.notes.trim();
    if (currentNotes == normalizedTo) return;

    if (line.qty > 1) {
      cart[i] = line.copyWith(qty: line.qty - 1);
      final existingWithNotes = cart.indexWhere(
        (l) => l.dish.id == dishId && l.notes.trim() == normalizedTo,
      );
      if (existingWithNotes == -1) {
        cart.add(CartLine(dish: line.dish, qty: 1, notes: normalizedTo));
      } else {
        cart[existingWithNotes] = cart[existingWithNotes].copyWith(
          qty: cart[existingWithNotes].qty + 1,
        );
      }
    } else {
      final existingWithNotes = cart.indexWhere(
        (l) => l.dish.id == dishId && l.notes.trim() == normalizedTo,
      );
      if (existingWithNotes != -1 && existingWithNotes != i) {
        cart[existingWithNotes] = cart[existingWithNotes].copyWith(
          qty: cart[existingWithNotes].qty + line.qty,
        );
        cart.removeAt(i);
      } else {
        cart[i] = line.copyWith(notes: normalizedTo);
      }
    }

    state = {...state, table: _mergeEquivalentLines(cart)};
  }

  void clearTable(String table) {
    final next = {...state}..remove(table);
    state = next;
  }

  int _findLineIndex(
    List<CartLine> cart,
    String dishId, {
    String? preferredNotes,
  }) {
    if (preferredNotes != null) {
      final exact = cart.indexWhere(
        (l) => l.dish.id == dishId && l.notes.trim() == preferredNotes,
      );
      if (exact != -1) return exact;
    }

    final withoutNotes = cart.indexWhere(
      (l) => l.dish.id == dishId && l.notes.trim().isEmpty,
    );
    if (withoutNotes != -1) return withoutNotes;

    return cart.indexWhere((l) => l.dish.id == dishId);
  }

  List<CartLine> _mergeEquivalentLines(List<CartLine> cart) {
    final merged = <CartLine>[];
    for (final line in cart) {
      final normalizedNotes = line.notes.trim();
      final i = merged.indexWhere(
        (m) => m.dish.id == line.dish.id && m.notes.trim() == normalizedNotes,
      );
      if (i == -1) {
        merged.add(
          CartLine(dish: line.dish, qty: line.qty, notes: normalizedNotes),
        );
      } else {
        merged[i] = merged[i].copyWith(qty: merged[i].qty + line.qty);
      }
    }
    return merged.where((l) => l.qty > 0).toList();
  }
}

final cartByTableProvider =
    NotifierProvider<CartByTableNotifier, Map<String, List<CartLine>>>(
      CartByTableNotifier.new,
    );
