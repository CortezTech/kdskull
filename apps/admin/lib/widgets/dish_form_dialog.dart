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
  String formatMinutesFromSeconds(int sec) {
    final minutes = sec / 60;
    if (minutes == minutes.roundToDouble()) {
      return minutes.toInt().toString();
    }
    return minutes.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(
      RegExp(r'\.$'),
      '',
    );
  }

  final initMinutesText = initialDish == null
      ? '10'
      : formatMinutesFromSeconds(initialDish.stdPrepTimeSec.clamp(1, 99999));
  final minutesCtrl = TextEditingController(text: initMinutesText);

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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Tiempo est\u00E1ndar (minutos)',
                  helperText:
                      'Acepta decimales (0.5 o 0,5 = 30s; 2 = 2 min)',
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

              final rawMinutes = minutesCtrl.text.trim().replaceAll(',', '.');
              final minutes = double.tryParse(rawMinutes) ?? 0;
              final normalizedSec = minutes <= 0
                  ? 1
                  : (minutes * 60).round().clamp(1, 99999);

              Navigator.pop(
                context,
                DishFormValues(
                  name: name,
                  stationId: selectedStationId,
                  stdPrepTimeSec: normalizedSec,
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

