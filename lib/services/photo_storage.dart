import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saves incident photos into the app's **internal** storage
/// (`<app documents>/incident_photos/`, i.e. `/data/data/<pkg>/app_flutter/…`
/// on Android — private to the app) and keeps a local map of
/// `incident_number -> file path` in SharedPreferences.
class PhotoStorage {
  static const _folder = 'incident_photos';
  static const _mapKey = 'incident_photo_map';

  Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_folder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _safe(String name) =>
      name.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

  /// Copies [sourcePath] into internal storage, records the mapping,
  /// and returns the absolute destination path.
  Future<String> saveIncidentPhoto(
      String sourcePath, String incidentNumber) async {
    final dir = await _dir();
    final dest = '${dir.path}/${_safe(incidentNumber)}.jpg';
    await File(sourcePath).copy(dest);
    await _remember(incidentNumber, dest);
    return dest;
  }

  Future<void> _remember(String incidentNumber, String path) async {
    final prefs = await SharedPreferences.getInstance();
    final map = _decode(prefs.getString(_mapKey));
    map[incidentNumber] = path;
    await prefs.setString(_mapKey, jsonEncode(map));
  }

  /// Returns the saved photo path for [incidentNumber], or null if there is
  /// none (or the file has since been removed).
  Future<String?> photoPathFor(String incidentNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final map = _decode(prefs.getString(_mapKey));
    final path = map[incidentNumber];
    if (path == null) return null;
    return await File(path).exists() ? path : null;
  }

  Map<String, String> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return {};
  }
}
