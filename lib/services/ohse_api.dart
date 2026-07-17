import '../core/api_client.dart';
import '../models/dashboard_stats.dart';
import '../models/incident.dart';
import '../models/inspection.dart';
import '../models/named_ref.dart';
import '../models/permit.dart';
import '../models/user.dart';

/// Repository that maps OHSE Enterprise REST endpoints to typed models.
class OhseApi {
  OhseApi(this._client);

  final ApiClient _client;

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  // ---- Auth ----
  Future<({String token, AppUser user})> login(
      String email, String password) {
    return _guard(() async {
      final res = await _client.dio.post('/login', data: {
        'email': email,
        'password': password,
        'device_name': 'flutter-app',
      });
      final data = res.data as Map<String, dynamic>;
      return (
        token: data['token'] as String,
        user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
      );
    });
  }

  Future<AppUser> me() {
    return _guard(() async {
      final res = await _client.dio.get('/me');
      return AppUser.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<void> logout() {
    return _guard(() async {
      await _client.dio.post('/logout');
    });
  }

  // ---- Dashboard ----
  Future<DashboardStats> dashboard() {
    return _guard(() async {
      final res = await _client.dio.get('/dashboard');
      return DashboardStats.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ---- Incidents ----
  Future<List<Incident>> incidents({String? severity, String? status}) {
    return _guard(() async {
      final res = await _client.dio.get('/incidents', queryParameters: {
        if (severity != null) 'severity': severity,
        if (status != null) 'status': status,
      });
      final list = (res.data['data'] as List?) ?? [];
      return list.map((e) => Incident.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<Incident> incident(int id) {
    return _guard(() async {
      final res = await _client.dio.get('/incidents/$id');
      return Incident.fromJson(res.data['data'] as Map<String, dynamic>);
    });
  }

  Future<Incident> createIncident(Map<String, dynamic> payload) {
    return _guard(() async {
      final res = await _client.dio.post('/incidents', data: payload);
      return Incident.fromJson(res.data['data'] as Map<String, dynamic>);
    });
  }

  // ---- Permits ----
  Future<List<Permit>> permits({String? status}) {
    return _guard(() async {
      final res = await _client.dio.get('/permits', queryParameters: {
        if (status != null) 'status': status,
      });
      final list = (res.data['data'] as List?) ?? [];
      return list.map((e) => Permit.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<Permit> approvePermit(int id) {
    return _guard(() async {
      final res = await _client.dio.post('/permits/$id/approve');
      return Permit.fromJson(res.data['data'] as Map<String, dynamic>);
    });
  }

  // ---- Inspections ----
  Future<List<Inspection>> inspections({String? status}) {
    return _guard(() async {
      final res = await _client.dio.get('/inspections', queryParameters: {
        if (status != null) 'status': status,
      });
      final list = (res.data['data'] as List?) ?? [];
      return list.map((e) => Inspection.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  // ---- Lookups ----
  Future<List<NamedRef>> sites() {
    return _guard(() async {
      final res = await _client.dio.get('/lookups/sites');
      return (res.data as List)
          .map((e) => NamedRef.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<NamedRef>> companies() {
    return _guard(() async {
      final res = await _client.dio.get('/lookups/companies');
      return (res.data as List)
          .map((e) => NamedRef.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}
