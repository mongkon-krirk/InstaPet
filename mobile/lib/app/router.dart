import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activity/presentation/screens/activity_screen.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/discover/presentation/screens/discover_screen.dart';
import '../features/feed/presentation/screens/feed_screen.dart';
import '../features/home/presentation/screens/home_shell.dart';
import '../features/post/presentation/screens/create_post_screen.dart';
import '../features/post/presentation/screens/post_detail_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/change_password_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<AuthState>(ref.read(authControllerProvider));
  ref.listen<AuthState>(authControllerProvider, (_, next) {
    authNotifier.value = next;
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final auth = authNotifier.value;
      final path = state.matchedLocation;
      final isAuthRoute = path == '/splash' || path == '/welcome' || path == '/login' || path == '/register';

      if (auth.status == AuthStatus.unknown && path != '/splash') {
        return '/splash';
      }
      if (auth.status == AuthStatus.unauthenticated && !isAuthRoute) {
        return '/welcome';
      }
      if (auth.status == AuthStatus.authenticated && (path == '/login' || path == '/register' || path == '/welcome')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const FeedScreen()),
          GoRoute(path: '/home/discover', builder: (_, __) => const DiscoverScreen()),
          GoRoute(path: '/home/create', builder: (_, __) => const CreatePostScreen()),
          GoRoute(path: '/home/activity', builder: (_, __) => const ActivityScreen()),
          GoRoute(path: '/home/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/profile/:username',
        builder: (_, state) => ProfileScreen(username: state.pathParameters['username']),
      ),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(
        path: '/post/:documentId',
        builder: (_, state) => PostDetailScreen(documentId: state.pathParameters['documentId']!),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/settings/change-password', builder: (_, __) => const ChangePasswordScreen()),
    ],
  );
});
