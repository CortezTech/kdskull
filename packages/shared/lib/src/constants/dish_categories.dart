const String kUncategorizedDishCategory = 'Sin categoría';

const List<String> kDefaultDishCategories = <String>[
  'Entrantes',
  'Principal',
  'Postres',
  'Bebidas',
  'Otros',
];

List<String> buildDishCategoryOrder(Iterable<String> categories) {
  final present =
      categories.map((c) => c.trim()).where((c) => c.isNotEmpty).toSet();

  final ordered = <String>[];
  for (final category in kDefaultDishCategories) {
    if (present.contains(category)) {
      ordered.add(category);
    }
  }

  final extras = present
      .where(
        (c) =>
            c != kUncategorizedDishCategory &&
            !kDefaultDishCategories.contains(c),
      )
      .toList()
    ..sort();
  ordered.addAll(extras);

  if (present.contains(kUncategorizedDishCategory)) {
    ordered.add(kUncategorizedDishCategory);
  }

  return ordered;
}
