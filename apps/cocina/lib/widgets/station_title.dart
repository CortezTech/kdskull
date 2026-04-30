import 'package:flutter/material.dart';
import 'package:kds_shared/kds_shared.dart';

class KitchenStationTitleSkeleton extends StatelessWidget {
  const KitchenStationTitleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDFE6F2)),
      ),
      child: const Text('Cocina'),
    );
  }
}

class KitchenStationTitleDropdown extends StatelessWidget {
  const KitchenStationTitleDropdown({
    super.key,
    required this.current,
    required this.stations,
    required this.onChanged,
  });

  final String current;
  final List<Station> stations;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = stations.firstWhere(
      (s) => s.id == current,
      orElse: () => stations.first,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDFE6F2)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected.id,
            isDense: true,
            borderRadius: BorderRadius.circular(12),
            iconEnabledColor: const Color(0xFF334155),
            selectedItemBuilder: (_) => stations
                .map(
                  (s) => Text(
                    'Cocina \u00B7 ${s.name}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2233),
                    ),
                  ),
                )
                .toList(),
            items: stations
                .map(
                  (s) => DropdownMenuItem<String>(
                    value: s.id,
                    child: SizedBox(
                      width: 260,
                      child: Text(
                        'Cocina \u00B7 ${s.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
