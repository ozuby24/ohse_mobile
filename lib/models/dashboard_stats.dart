import 'incident.dart';

class DashboardStats {
  DashboardStats({
    required this.incidentsTotal,
    required this.incidentsOpen,
    required this.incidentsBySeverity,
    required this.permitsTotal,
    required this.permitsPending,
    required this.permitsActive,
    required this.permitsByStatus,
    required this.inspectionsTotal,
    required this.inspectionsScheduled,
    required this.inspectionsCompleted,
    required this.inspectionsAvgScore,
    required this.observationsTotal,
    required this.observationsOpen,
    required this.recentIncidents,
  });

  final int incidentsTotal;
  final int incidentsOpen;
  final Map<String, int> incidentsBySeverity;
  final int permitsTotal;
  final int permitsPending;
  final int permitsActive;
  final Map<String, int> permitsByStatus;
  final int inspectionsTotal;
  final int inspectionsScheduled;
  final int inspectionsCompleted;
  final double inspectionsAvgScore;
  final int observationsTotal;
  final int observationsOpen;
  final List<Incident> recentIncidents;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    Map<String, int> intMap(dynamic v) {
      if (v is Map) {
        return v.map((k, val) => MapEntry(k.toString(), (val as num).toInt()));
      }
      return {};
    }

    final inc = json['incidents'] as Map<String, dynamic>? ?? {};
    final per = json['permits'] as Map<String, dynamic>? ?? {};
    final insp = json['inspections'] as Map<String, dynamic>? ?? {};
    final obs = json['observations'] as Map<String, dynamic>? ?? {};

    return DashboardStats(
      incidentsTotal: (inc['total'] as num?)?.toInt() ?? 0,
      incidentsOpen: (inc['open'] as num?)?.toInt() ?? 0,
      incidentsBySeverity: intMap(inc['by_severity']),
      permitsTotal: (per['total'] as num?)?.toInt() ?? 0,
      permitsPending: (per['pending'] as num?)?.toInt() ?? 0,
      permitsActive: (per['active'] as num?)?.toInt() ?? 0,
      permitsByStatus: intMap(per['by_status']),
      inspectionsTotal: (insp['total'] as num?)?.toInt() ?? 0,
      inspectionsScheduled: (insp['scheduled'] as num?)?.toInt() ?? 0,
      inspectionsCompleted: (insp['completed'] as num?)?.toInt() ?? 0,
      inspectionsAvgScore: (insp['avg_score'] as num?)?.toDouble() ?? 0,
      observationsTotal: (obs['total'] as num?)?.toInt() ?? 0,
      observationsOpen: (obs['open'] as num?)?.toInt() ?? 0,
      recentIncidents: ((json['recent_incidents'] as Map?)?['data'] as List? ??
              json['recent_incidents'] as List? ??
              [])
          .map((e) => Incident.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
