import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// 1. AuthCheckRequested class (App start hone par login check ke liye)
class AuthCheckRequested extends AuthEvent {}

// 2. LoginRequested class
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// 3. SignUpRequested class
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  SignUpRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// 4. LogoutRequested class (Iska naam 'Logout' nahi, 'LogoutRequested' hona chahiye)
class LogoutRequested extends AuthEvent {}