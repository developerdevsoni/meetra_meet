import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meetra_meet/services/auth_service.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription? _userSubscription;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSignInRequested>(_onSignInRequested);

    _userSubscription = _authService.user.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  bool _isFirstCheck = true;

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) async {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      if (_isFirstCheck) {
        _isFirstCheck = false;
        await Future.delayed(const Duration(seconds: 2));
      }
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authService.signOut();
  }

  Future<void> _onSignInRequested(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authService.signInWithGoogle();
    if (result == null) {
      emit(const AuthFailure("Sign in failed or cancelled"));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
