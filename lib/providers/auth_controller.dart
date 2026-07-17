import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../models/user.dart';
import '../services/ohse_api.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.loading = false,
    this.error,
  });

  final AuthStatus status;
  final AppUser? user;
  final bool loading;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._api, this._storage) : super(const AuthState()) {
    _bootstrap();
  }

  final OhseApi _api;
  final TokenStorage _storage;

  /// On startup, if a token exists validate it via /me.
  Future<void> _bootstrap() async {
    final token = await _storage.read();
    if (token == null || token.isEmpty) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _api.me();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await _storage.clear();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await _api.login(email, password);
      await _storage.write(result.token);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        loading: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // ignore network errors on logout
    }
    await _storage.clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
