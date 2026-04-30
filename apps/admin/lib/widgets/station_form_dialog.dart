import 'package:flutter/material.dart';
import 'package:kds_shared/kds_shared.dart';

class StationFormValues {
  const StationFormValues({required this.name, required this.order});

  final String name;
  final int order;
}

Future<StationFormValues?> showStationFormDialog({
  required BuildContext context,
  Station? initialStation,
}) async {
  final nameCtrl = TextEditingController(text: initialStation?.name ?? '');
  final orderCtrl = TextEditingController(
    text: (initialStation?.order ?? 0).toString(),
  );

  final result = await showDialog<StationFormValues>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(
        initialStation == null
            ? 'A\u00F1adir estaci\u00F3n'
            : 'Editar estaci\u00F3n',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: orderCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Orden'),
          ),
        ],
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
            final order = int.tryParse(orderCtrl.text.trim()) ?? 0;
            Navigator.pop(context, StationFormValues(name: name, order: order));
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );

  nameCtrl.dispose();
  orderCtrl.dispose();
  return result;
}
