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
    on<AuthEmailSignInRequested>(_onEmailSignInRequested);
    on<AuthEmailSignUpRequested>(_onEmailSignUpRequested);
    on<AuthUserUpdated>(_onUserUpdated);


    _userSubscription = _authService.user.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _authService.getCurrentUserModel();
    }).listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }


  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authService.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onSignInRequested(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userModel = await _authService.signInWithGoogle();
      if (userModel != null) {
        print(state);
        add(AuthUserUpdated(userModel));
        print(state);
      } else {
        emit(const AuthFailure("Sign in cancelled or failed"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onEmailSignInRequested(AuthEmailSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userModel = await _authService.signInWithEmail(event.email, event.password);
      if (userModel != null) {
        add(AuthUserUpdated(userModel));
      } else {
        emit(const AuthFailure("Login failed. Please check your credentials."));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onEmailSignUpRequested(AuthEmailSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userModel = await _authService.signUpWithEmail(event.name, event.email, event.password);
      if (userModel != null) {
        add(AuthUserUpdated(userModel));
      } else {
        emit(const AuthFailure("Registration failed."));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
