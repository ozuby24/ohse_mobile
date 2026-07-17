import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../models/permit.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../dashboard_screen.dart' show formatDate;
import 'permit_detail_screen.dart';

class PermitsScreen extends ConsumerWidget {
  const PermitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(permitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Izin Kerja (PTW)')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(permitsProvider),
        child: async.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(permitsProvider),
          ),
          data: (items) => items.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 160),
                    EmptyView(message: 'Belum ada izin kerja'),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _PermitTile(items[i]),
                ),
        ),
      ),
    );
  }
}

class _PermitTile extends StatelessWidget {
  const _PermitTile(this.permit);

  final Permit permit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: CircleAvatar(
          backgroundColor:
              Labels.severityColor(permit.riskLevel).withValues(alpha: 0.15),
          child: Icon(Icons.assignment,
              color: Labels.severityColor(permit.riskLevel)),
        ),
        title:
            Text(permit.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${permit.permitNumber} • s/d ${formatDate(permit.validTo)}',
        ),
        trailing: TagChip(
          label: Labels.of(Labels.permitStatus, permit.status),
          color: Labels.statusColor(permit.status),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PermitDetailScreen(permit: permit),
          ),
        ),
      ),
    );
  }
}
