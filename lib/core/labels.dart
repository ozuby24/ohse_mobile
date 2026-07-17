import 'package:flutter/material.dart';

import 'theme.dart';

/// Indonesian labels + colors for the enum-like string fields from the API.
class Labels {
  static const severity = {
    'low': 'Rendah',
    'medium': 'Sedang',
    'high': 'Tinggi',
    'critical': 'Kritis',
  };

  static const incidentType = {
    'near_miss': 'Nyaris Celaka',
    'first_aid': 'P3K',
    'medical_treatment': 'Perawatan Medis',
    'lost_time': 'Hilang Waktu Kerja',
    'fatality': 'Fatal',
    'property_damage': 'Kerusakan Aset',
    'environmental': 'Lingkungan',
  };

  static const incidentStatus = {
    'reported': 'Dilaporkan',
    'investigating': 'Investigasi',
    'action': 'Tindak Lanjut',
    'closed': 'Selesai',
  };

  static const permitStatus = {
    'draft': 'Draf',
    'submitted': 'Diajukan',
    'pending': 'Menunggu',
    'approved': 'Disetujui',
    'rejected': 'Ditolak',
    'closed': 'Ditutup',
  };

  static const riskLevel = {
    'low': 'Rendah',
    'medium': 'Sedang',
    'high': 'Tinggi',
    'critical': 'Kritis',
  };

  static const inspectionStatus = {
    'scheduled': 'Terjadwal',
    'in_progress': 'Berlangsung',
    'completed': 'Selesai',
    'cancelled': 'Batal',
  };

  static const observationCategory = {
    'unsafe_condition': 'Kondisi Tidak Aman',
    'unsafe_action': 'Tindakan Tidak Aman',
    'positive': 'Pengamatan Positif',
  };

  static String of(Map<String, String> map, String? key) =>
      map[key] ?? (key ?? '-');

  static Color severityColor(String? key) {
    switch (key) {
      case 'low':
        return AppColors.low;
      case 'medium':
        return AppColors.medium;
      case 'high':
        return AppColors.high;
      case 'critical':
        return AppColors.critical;
      default:
        return AppColors.info;
    }
  }

  static Color statusColor(String? key) {
    switch (key) {
      case 'approved':
      case 'completed':
      case 'closed':
        return AppColors.low;
      case 'submitted':
      case 'pending':
      case 'investigating':
      case 'in_progress':
      case 'action':
        return AppColors.medium;
      case 'rejected':
      case 'cancelled':
        return AppColors.critical;
      default:
        return AppColors.info;
    }
  }
}
