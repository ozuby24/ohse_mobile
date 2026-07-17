import 'named_ref.dart';

class Incident {
  Incident({
    required this.id,
    required this.incidentNumber,
    required this.title,
    this.description,
    required this.incidentType,
    required this.severity,
    required this.status,
    this.location,
    this.injuredPerson,
    this.daysLost,
    this.immediateAction,
    this.rootCause,
    this.correctiveAction,
    this.occurredAt,
    this.reportedAt,
    this.site,
    this.reporter,
  });

  final int id;
  final String incidentNumber;
  final String title;
  final String? description;
  final String incidentType;
  final String severity;
  final String status;
  final String? location;
  final String? injuredPerson;
  final int? daysLost;
  final String? immediateAction;
  final String? rootCause;
  final String? correctiveAction;
  final DateTime? occurredAt;
  final DateTime? reportedAt;
  final NamedRef? site;
  final NamedRef? reporter;

  factory Incident.fromJson(Map<String, dynamic> json) {
    NamedRef? ref(String key) {
      final v = json[key];
      return v is Map<String, dynamic> ? NamedRef.fromJson(v) : null;
    }

    DateTime? dt(String key) {
      final v = json[key];
      return v == null ? null : DateTime.tryParse(v.toString());
    }

    return Incident(
      id: json['id'] as int,
      incidentNumber: json['incident_number']?.toString() ?? '-',
      title: json['title']?.toString() ?? '-',
      description: json['description']?.toString(),
      incidentType: json['incident_type']?.toString() ?? 'near_miss',
      severity: json['severity']?.toString() ?? 'low',
      status: json['status']?.toString() ?? 'reported',
      location: json['location']?.toString(),
      injuredPerson: json['injured_person']?.toString(),
      daysLost: json['days_lost'] as int?,
      immediateAction: json['immediate_action']?.toString(),
      rootCause: json['root_cause']?.toString(),
      correctiveAction: json['corrective_action']?.toString(),
      occurredAt: dt('occurred_at'),
      reportedAt: dt('reported_at'),
      site: ref('site'),
      reporter: ref('reporter'),
    );
  }
}
