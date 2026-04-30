import 'package:flutter/material.dart';
import 'package:kds_shared/kds_shared.dart';

class DishFormValues {
  const DishFormValues({
    required this.name,
    required this.stationId,
    required this.stdPrepTimeSec,
    required this.available,
    required this.category,
  });

  final String name;
  final String stationId;
  final int stdPrepTimeSec;
  final bool available;
  final String category;
}

Future<DishFormValues?> showDishFormDialog({
  required BuildContext context,
  required List<Station> stations,
  Dish? initialDish,
}) async {
  final nameCtrl = TextEditingController(text: initialDish?.name ?? '');
  final initMinutes = initialDish == null
      ? 10
      : (initialDish.stdPrepTimeSec / 60).round().clamp(1, 999);
  final minutesCtrl = TextEditingController(text: initMinutes.toString());

  var selectedStationId = initialDish?.stationId.isNotEmpty == true
      ? initialDish!.stationId
      : stations.first.id;
  var selectedCategory = (initialDish?.category.isNotEmpty == true)
      ? initialDish!.category
      : kDefaultDishCategories.first;
  var available = initialDish?.available ?? true;

  final categoryOptions = _categoryOptions(selectedCategory);

  final result = await showDialog<DishFormValues>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(initialDish == null ? 'A\u00F1adir plato' : 'Editar plato'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                items: categoryOptions
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(
                  () => selectedCategory = v ?? kDefaultDishCategories.first,
                ),
                decoration: const InputDecoration(labelText: 'Categor\u00EDa'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedStationId,
                items: stations
                    .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => selectedStationId = v ?? stations.first.id),
                decoration: const InputDecoration(labelText: 'Estaci\u00F3n'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: minutesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tiempo est\u00E1ndar (minutos)',
                  helperText: 'Se guarda en segundos en Firestore',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: available,
                onChanged: (v) => setState(() => available = v),
                title: const Text('Disponible'),
                subtitle: const Text(
                  'Si est\u00E1 desactivado, act\u00FAa como 86',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;

              final minutes = int.tryParse(minutesCtrl.text.trim()) ?? 0;
              final sec = minutes <= 0 ? 60 : minutes * 60;

              Navigator.pop(
                context,
                DishFormValues(
                  name: name,
                  stationId: selectedStationId,
                  stdPrepTimeSec: sec,
                  available: available,
                  category: selectedCategory,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );

  nameCtrl.dispose();
  minutesCtrl.dispose();
  return result;
}

List<String> _categoryOptions(String selectedCategory) {
  final normalizedSelected = selectedCategory.trim();
  return <String>[
    ...kDefaultDishCategories,
    if (normalizedSelected.isNotEmpty &&
        !kDefaultDishCategories.contains(normalizedSelected))
      normalizedSelected,
  ];
}
