import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kds_shared/kds_shared.dart';

import 'providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Para que el “tiempo transcurrido” se refresque sin depender de Firestore
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(stationsProvider);
    final selectedStationId = ref.watch(selectedStationIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cocina - Estación'),
        actions: [
          stationsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (stations) {
              if (stations.isEmpty) return const SizedBox.shrink();
              final current = selectedStationId ?? stations.first.id;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: current,
                    items: stations
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        ref.read(selectedStationIdProvider.notifier).state = v,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: stationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error estaciones: $e')),
        data: (stations) {
          if (stations.isEmpty) {
            return const Center(
              child: Text('No hay estaciones (crea en Admin)'),
            );
          }

          // set default station al arrancar
          if (selectedStationId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(selectedStationIdProvider.notifier).state =
                  stations.first.id;
            });
            return const Center(child: CircularProgressIndicator());
          }

          final queueAsync = ref.watch(stationQueueProvider);

          return queueAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error cola: $e')),
            data: (items) {
              final todo = items.where((i) => i.status == 'todo').toList();
              final doing = items
                  .where((i) => i.status == 'in_progress')
                  .toList();
              final ready = items.where((i) => i.status == 'ready').toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;
                  if (!wide) {
                    // Lista simple en pantallas estrechas
                    final all = [...todo, ...doing, ...ready];
                    all.sort(_sortByCreated);
                    return ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: all.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _ItemCard(item: all[i]),
                    );
                  }

                  // Kanban
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Column(title: 'TODO', items: todo),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Column(title: 'IN PROGRESS', items: doing),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Column(title: 'READY', items: ready),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  int _sortByCreated(OrderItem a, OrderItem b) {
    final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return da.compareTo(db);
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.title, required this.items});

  final String title;
  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    final sorted = [...items];
    sorted.sort((a, b) {
      final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return da.compareTo(db);
    });

    return Card(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            '$title (${items.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          Expanded(
            child: sorted.isEmpty
                ? const Center(child: Text('Vacío'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _ItemCard(item: sorted[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(kitchenRepositoryProvider);

    // SLA: tiempo transcurrido desde startedAt (si está en progreso),
    // si no, desde createdAt (aprox. para TODO)
    final DateTime? start = item.startedAt ?? item.createdAt;

    Duration? elapsed;

    if (start != null) {
      if (item.status == 'ready' && item.readyAt != null) {
        // congelado
        elapsed = item.readyAt!.difference(start);
      } else {
        // sigue contando
        elapsed = DateTime.now().difference(start);
      }
    }

    final std = Duration(
      seconds: item.stdPrepTimeSec <= 0 ? 1 : item.stdPrepTimeSec,
    );

    // Color “lógico”: no lo especifico con colores concretos, solo texto.
    final slaText = elapsed == null
        ? '—'
        : '${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s / ${(std.inMinutes)}m';

    final bool late = elapsed != null && elapsed > std;

    String? next;
    String? label;
    if (item.status == 'todo') {
      next = 'in_progress';
      label = 'Empezar';
    } else if (item.status == 'in_progress') {
      next = 'ready';
      label = 'Listo';
    } else {
      next = null;
      label = null;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mesa ${item.table}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(item.dishName),
            const SizedBox(height: 6),
            Text('Qty: ${item.qty}'),
            if (item.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Notas: ${item.notes}'),
            ],
            const SizedBox(height: 10),
            if (item.status == 'ready')
              Text('Completado en $slaText')
            else
              Text('Tiempo: $slaText${late ? '  (RETRASO)' : ''}'),
            const SizedBox(height: 10),
            Row(
              children: [
                if (label != null)
                  FilledButton(
                    onPressed: () async {
                      await repo.setItemStatus(
                        orderId: item.orderId,
                        itemId: item.id,
                        status: next!,
                      );
                    },
                    child: Text(label!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
