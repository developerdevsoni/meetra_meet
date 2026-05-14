import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetra_meet/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final UserModel? user;
  const AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {}

class AuthEmailSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthEmailSignInRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class AuthEmailSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthEmailSignUpRequested(this.name, this.email, this.password);
  @override
  List<Object?> get props => [name, email, password];
}

class AuthUserUpdated extends AuthEvent {
  final UserModel user;
  const AuthUserUpdated(this.user);
  @override
  List<Object?> get props => [user];
}


abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}


class AuthUnauthenticated extends AuthState {}

class AuthLoading extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}
