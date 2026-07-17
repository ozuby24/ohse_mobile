import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/theme.dart';
import '../../core/api_client.dart';
import '../../models/permit.dart';
import '../../providers/providers.dart';
import '../../services/ohse_api.dart';
import '../dashboard_screen.dart' show formatDate;

class PermitDetailScreen extends ConsumerStatefulWidget {
  const PermitDetailScreen({super.key, required this.permit});

  final Permit permit;

  @override
  ConsumerState<PermitDetailScreen> createState() => _PermitDetailScreenState();
}

class _PermitDetailScreenState extends ConsumerState<PermitDetailScreen> {
  late Permit _permit = widget.permit;
  bool _approving = false;

  Future<void> _approve() async {
    setState(() => _approving = true);
    try {
      final updated = await ref.read(ohseApiProvider).approvePermit(_permit.id);
      setState(() => _permit = updated);
      ref.invalidate(permitsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin kerja disetujui'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.critical),
        );
      }
    } finally {
      if (mounted) setState(() => _approving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _permit;
    final canApprove = p.status == 'submitted' ||
        p.status == 'pending' ||
        p.status == 'draft';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Izin Kerja')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(p.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(p.permitNumber, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Labels.of(Labels.permitStatus, p.status),
                  Labels.statusColor(p.status)),
              _chip('Risiko: ${Labels.of(Labels.riskLevel, p.riskLevel)}',
                  Labels.severityColor(p.riskLevel)),
              if (p.category != null) _chip(p.category!.name, Colors.blueGrey),
            ],
          ),
          const SizedBox(height: 20),
          _infoCard([
            _kv('Lokasi Kerja', p.workLocation ?? '-'),
            _kv('Site', p.site?.name ?? '-'),
            _kv('Pemohon', p.requester?.name ?? '-'),
            _kv('Kontraktor', p.contractor?.name ?? '-'),
            _kv('Berlaku Dari', formatDate(p.validFrom, withTime: true)),
            _kv('Berlaku Sampai', formatDate(p.validTo, withTime: true)),
            _kv('Disetujui', formatDate(p.approvedAt, withTime: true)),
          ]),
          const SizedBox(height: 16),
          _section('Deskripsi', p.description),
          _section('Bahaya (Hazards)', p.hazards),
          _section('Pengendalian', p.controlMeasures),
          const SizedBox(height: 8),
          if (canApprove)
            FilledButton.icon(
              onPressed: _approving ? null : _approve,
              icon: _approving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(_approving ? 'Memproses...' : 'Setujui Izin Kerja'),
            ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );

  Widget _infoCard(List<Widget> rows) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: rows),
        ),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 130,
                child: Text(k, style: TextStyle(color: Colors.grey.shade600))),
            Expanded(
                child: Text(v,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );

  Widget _section(String title, String? body) {
    if (body == null || body.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}
