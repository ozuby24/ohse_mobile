import 'named_ref.dart';

class Inspection {
  Inspection({
    required this.id,
    required this.inspectionNumber,
    required this.type,
    required this.title,
    this.area,
    required this.status,
    this.score,
    this.findingsCount,
    this.notes,
    this.scheduledDate,
    this.completedDate,
    this.site,
    this.inspector,
  });

  final int id;
  final String inspectionNumber;
  final String type;
  final String title;
  final String? area;
  final String status;
  final double? score;
  final int? findingsCount;
  final String? notes;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final NamedRef? site;
  final NamedRef? inspector;

  factory Inspection.fromJson(Map<String, dynamic> json) {
    NamedRef? ref(String key) {
      final v = json[key];
      return v is Map<String, dynamic> ? NamedRef.fromJson(v) : null;
    }

    DateTime? dt(String key) {
      final v = json[key];
      return v == null ? null : DateTime.tryParse(v.toString());
    }

    return Inspection(
      id: json['id'] as int,
      inspectionNumber: json['inspection_number']?.toString() ?? '-',
      type: json['type']?.toString() ?? 'routine',
      title: json['title']?.toString() ?? '-',
      area: json['area']?.toString(),
      status: json['status']?.toString() ?? 'scheduled',
      score: json['score'] == null ? null : double.tryParse(json['score'].toString()),
      findingsCount: json['findings_count'] as int?,
      notes: json['notes']?.toString(),
      scheduledDate: dt('scheduled_date'),
      completedDate: dt('completed_date'),
      site: ref('site'),
      inspector: ref('inspector'),
    );
  }
}
