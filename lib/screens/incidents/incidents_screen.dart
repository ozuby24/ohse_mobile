import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../models/incident.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../dashboard_screen.dart' show formatDate;
import 'incident_detail_screen.dart';
import 'incident_form_screen.dart';

class IncidentsScreen extends ConsumerWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(incidentsProvider);
    final filter = ref.watch(incidentFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insiden')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const IncidentFormScreen()),
          );
          if (created == true) ref.invalidate(incidentsProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Lapor'),
      ),
      body: Column(
        children: [
          _SeverityFilterBar(
            selected: filter,
            onSelected: (v) =>
                ref.read(incidentFilterProvider.notifier).state = v,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(incidentsProvider),
              child: async.when(
                loading: () => const LoadingView(),
                error: (e, _) => ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(incidentsProvider),
                ),
                data: (items) => items.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 160),
                          EmptyView(message: 'Tidak ada insiden'),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _IncidentTile(items[i]),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityFilterBar extends StatelessWidget {
  const _SeverityFilterBar({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final chips = <MapEntry<String?, String>>[
      const MapEntry(null, 'Semua'),
      ...Labels.severity.entries.map((e) => MapEntry(e.key, e.value)),
    ];
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = chips[i];
          final isSel = c.key == selected;
          return ChoiceChip(
            label: Text(c.value),
            selected: isSel,
            onSelected: (_) => onSelected(c.key),
          );
        },
      ),
    );
  }
}

class _IncidentTile extends StatelessWidget {
  const _IncidentTile(this.incident);

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: CircleAvatar(
          backgroundColor:
              Labels.severityColor(incident.severity).withValues(alpha: 0.15),
          child: Icon(Icons.warning_amber_rounded,
              color: Labels.severityColor(incident.severity)),
        ),
        title: Text(incident.title,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${incident.incidentNumber} • ${formatDate(incident.occurredAt)}',
        ),
        trailing: TagChip(
          label: Labels.of(Labels.severity, incident.severity),
          color: Labels.severityColor(incident.severity),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IncidentDetailScreen(incidentId: incident.id),
          ),
        ),
      ),
    );
  }
}
