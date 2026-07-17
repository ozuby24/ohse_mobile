import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/labels.dart';
import '../../core/theme.dart';
import '../../models/named_ref.dart';
import '../../providers/providers.dart';
import '../../services/ohse_api.dart';
import '../dashboard_screen.dart' show formatDate;

class IncidentFormScreen extends ConsumerStatefulWidget {
  const IncidentFormScreen({super.key});

  @override
  ConsumerState<IncidentFormScreen> createState() => _IncidentFormScreenState();
}

class _IncidentFormScreenState extends ConsumerState<IncidentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _injuredCtrl = TextEditingController();
  final _actionCtrl = TextEditingController();

  NamedRef? _company;
  NamedRef? _site;
  String _type = 'near_miss';
  String _severity = 'medium';
  DateTime _occurredAt = DateTime.now();
  XFile? _photo;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _injuredCtrl.dispose();
    _actionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    setState(() {
      _occurredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 0,
        time?.minute ?? 0,
      );
    });
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _photo = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // Fall back to the first company when the user never touched the dropdown.
    final companies = ref.read(companiesProvider).valueOrNull ?? const [];
    final company =
        _company ?? (companies.isNotEmpty ? companies.first : null);
    if (company == null) {
      _snack('Data perusahaan belum termuat, coba lagi', AppColors.critical);
      return;
    }
    setState(() => _submitting = true);
    try {
      final created = await ref.read(ohseApiProvider).createIncident({
        'company_id': company.id,
        if (_site != null) 'site_id': _site!.id,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'incident_type': _type,
        'severity': _severity,
        'location': _locationCtrl.text.trim(),
        'injured_person': _injuredCtrl.text.trim(),
        'immediate_action': _actionCtrl.text.trim(),
        'occurred_at': _occurredAt.toUtc().toIso8601String(),
      });

      // Persist the captured photo to the app's internal storage folder,
      // keyed by the server-generated incident number.
      var savedPhoto = false;
      if (_photo != null) {
        try {
          await ref
              .read(photoStorageProvider)
              .saveIncidentPhoto(_photo!.path, created.incidentNumber);
          savedPhoto = true;
        } catch (_) {
          // Non-fatal: the incident is already reported.
        }
      }

      if (!mounted) return;
      _snack(
        savedPhoto
            ? 'Insiden dilaporkan • foto disimpan di penyimpanan internal'
            : 'Insiden berhasil dilaporkan',
        AppColors.primary,
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      _snack(e.message, AppColors.critical);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companies = ref.watch(companiesProvider);
    final sites = ref.watch(sitesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lapor Insiden')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            companies.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Gagal memuat perusahaan: $e'),
              data: (list) => DropdownButtonFormField<NamedRef>(
                value: _company ?? (list.isNotEmpty ? list.first : null),
                decoration: const InputDecoration(labelText: 'Perusahaan'),
                items: [
                  for (final c in list)
                    DropdownMenuItem(value: c, child: Text(c.name)),
                ],
                onChanged: (v) => setState(() => _company = v),
              ),
            ),
            const SizedBox(height: 14),
            sites.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Gagal memuat site: $e'),
              data: (list) => DropdownButtonFormField<NamedRef>(
                value: _site,
                decoration: const InputDecoration(labelText: 'Site (opsional)'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('—')),
                  for (final s in list)
                    DropdownMenuItem(value: s, child: Text(s.name)),
                ],
                onChanged: (v) => setState(() => _site = v),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul insiden'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Jenis insiden'),
              items: [
                for (final e in Labels.incidentType.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _severity,
              decoration:
                  const InputDecoration(labelText: 'Tingkat keparahan'),
              items: [
                for (final e in Labels.severity.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _severity = v ?? _severity),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(labelText: 'Lokasi'),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              tileColor: Colors.white,
              leading: const Icon(Icons.event),
              title: const Text('Waktu kejadian'),
              subtitle: Text(formatDate(_occurredAt, withTime: true)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _injuredCtrl,
              decoration:
                  const InputDecoration(labelText: 'Korban (jika ada)'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _actionCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Tindakan segera'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            const SizedBox(height: 16),
            _PhotoPicker(photo: _photo, onTap: _pickPhoto),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Icon(Icons.send),
              label: Text(_submitting ? 'Mengirim...' : 'Kirim Laporan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.photo, required this.onTap});

  final XFile? photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: photo == null ? 90 : 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        child: photo == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_a_photo_outlined,
                      color: AppColors.primary),
                  const SizedBox(height: 6),
                  Text('Ambil foto (opsional)',
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              )
            : Image.file(File(photo!.path), fit: BoxFit.cover, width: double.infinity),
      ),
    );
  }
}
