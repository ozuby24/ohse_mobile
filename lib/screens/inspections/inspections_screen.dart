import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/theme.dart';
import '../../models/inspection.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../dashboard_screen.dart' show formatDate;

class InspectionsScreen extends ConsumerWidget {
  const InspectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inspectionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inspeksi & Checklist')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(inspectionsProvider),
        child: async.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(inspectionsProvider),
          ),
          data: (items) => items.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 160),
                    EmptyView(message: 'Belum ada inspeksi'),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _InspectionTile(items[i]),
                ),
        ),
      ),
    );
  }
}

class _InspectionTile extends StatelessWidget {
  const _InspectionTile(this.inspection);

  final Inspection inspection;

  @override
  Widget build(BuildContext context) {
    final i = inspection;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(i.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                TagChip(
                  label: Labels.of(Labels.inspectionStatus, i.status),
                  color: Labels.statusColor(i.status),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${i.inspectionNumber} • ${i.area ?? '-'}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                _meta(Icons.event, formatDate(i.scheduledDate)),
                const SizedBox(width: 16),
                _meta(Icons.warning_amber_rounded, '${i.findingsCount ?? 0} temuan'),
                const Spacer(),
                if (i.score != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Skor ${i.score!.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      );
}
