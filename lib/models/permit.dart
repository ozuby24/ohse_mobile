import 'named_ref.dart';

class Permit {
  Permit({
    required this.id,
    required this.permitNumber,
    required this.title,
    this.description,
    this.workLocation,
    this.hazards,
    this.controlMeasures,
    required this.riskLevel,
    required this.status,
    this.validFrom,
    this.validTo,
    this.approvedAt,
    this.category,
    this.site,
    this.requester,
    this.contractor,
  });

  final int id;
  final String permitNumber;
  final String title;
  final String? description;
  final String? workLocation;
  final String? hazards;
  final String? controlMeasures;
  final String riskLevel;
  final String status;
  final DateTime? validFrom;
  final DateTime? validTo;
  final DateTime? approvedAt;
  final NamedRef? category;
  final NamedRef? site;
  final NamedRef? requester;
  final NamedRef? contractor;

  factory Permit.fromJson(Map<String, dynamic> json) {
    NamedRef? ref(String key) {
      final v = json[key];
      return v is Map<String, dynamic> ? NamedRef.fromJson(v) : null;
    }

    DateTime? dt(String key) {
      final v = json[key];
      return v == null ? null : DateTime.tryParse(v.toString());
    }

    return Permit(
      id: json['id'] as int,
      permitNumber: json['permit_number']?.toString() ?? '-',
      title: json['title']?.toString() ?? '-',
      description: json['description']?.toString(),
      workLocation: json['work_location']?.toString(),
      hazards: json['hazards']?.toString(),
      controlMeasures: json['control_measures']?.toString(),
      riskLevel: json['risk_level']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'draft',
      validFrom: dt('valid_from'),
      validTo: dt('valid_to'),
      approvedAt: dt('approved_at'),
      category: ref('category'),
      site: ref('site'),
      requester: ref('requester'),
      contractor: ref('contractor'),
    );
  }
}
