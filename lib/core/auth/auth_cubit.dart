import 'dart:async';
import 'package:al_furkan/core/utils/admin_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthState {
  final User? user;
  final bool isLoading;

  const AuthState({
    this.user,
    this.isLoading = true,
  });

  bool get isAuthenticated => user != null;
  bool get isAdmin => AdminConstants.isAdminEmail(user?.email);

  AuthState copyWith({
    User? user,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  late final StreamSubscription<User?> _authSubscription;

  AuthCubit() : super(const AuthState(isLoading: true)) {
    _init();
  }

  void _init() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      emit(AuthState(user: user, isLoading: false));
    });
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
