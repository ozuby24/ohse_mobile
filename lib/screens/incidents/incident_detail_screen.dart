import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../models/incident.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../dashboard_screen.dart' show formatDate;

final _incidentDetailProvider =
    FutureProvider.autoDispose.family<Incident, int>((ref, id) {
  return ref.watch(ohseApiProvider).incident(id);
});

/// Local photo (internal storage) saved for this incident number, if any.
final _incidentPhotoProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, number) {
  return ref.watch(photoStorageProvider).photoPathFor(number);
});

class IncidentDetailScreen extends ConsumerWidget {
  const IncidentDetailScreen({super.key, required this.incidentId});

  final int incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_incidentDetailProvider(incidentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Insiden')),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_incidentDetailProvider(incidentId)),
        ),
        data: (inc) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(inc.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                TagChip(
                  label: Labels.of(Labels.severity, inc.severity),
                  color: Labels.severityColor(inc.severity),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(inc.incidentNumber,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TagChip(
                  label: Labels.of(Labels.incidentStatus, inc.status),
                  color: Labels.statusColor(inc.status),
                ),
                TagChip(
                  label: Labels.of(Labels.incidentType, inc.incidentType),
                  color: Colors.blueGrey,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _InfoCard(rows: [
              _Row('Lokasi', inc.location ?? '-'),
              _Row('Waktu Kejadian', formatDate(inc.occurredAt, withTime: true)),
              _Row('Dilaporkan', formatDate(inc.reportedAt, withTime: true)),
              _Row('Pelapor', inc.reporter?.name ?? '-'),
              _Row('Site', inc.site?.name ?? '-'),
              _Row('Korban', inc.injuredPerson ?? '-'),
              _Row('Hari Kerja Hilang', '${inc.daysLost ?? 0}'),
            ]),
            const SizedBox(height: 16),
            _PhotoSection(incidentNumber: inc.incidentNumber),
            _TextSection('Deskripsi', inc.description),
            _TextSection('Tindakan Segera', inc.immediateAction),
            _TextSection('Akar Masalah', inc.rootCause),
            _TextSection('Tindakan Korektif', inc.correctiveAction),
          ],
        ),
      ),
    );
  }
}

class _Row {
  _Row(this.label, this.value);
  final String label;
  final String value;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(r.label,
                          style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    Expanded(
                      child: Text(r.value,
                          style:
                              const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoSection extends ConsumerWidget {
  const _PhotoSection({required this.incidentNumber});

  final String incidentNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_incidentPhotoProvider(incidentNumber));
    final path = async.valueOrNull;
    if (path == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Foto',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Icon(Icons.folder, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 2),
              Text('penyimpanan internal',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(path),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection(this.title, this.body);
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    if (body == null || body!.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(body!, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}
