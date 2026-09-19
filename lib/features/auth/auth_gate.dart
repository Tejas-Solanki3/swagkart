// =============================================================================
// File: lib/features/auth/auth_gate.dart
// Purpose: Root reactive authentication router directing users to LoginScreen,
//          AdminDashboardScreen, or AppShell depending on auth state and user role.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_store.dart';
import '../admin/admin_dashboard_screen.dart';
import '../shell/app_shell.dart';
import 'login_screen.dart';

/// Root reactive authentication gate.
///
/// Listens to [SwagAppStore] and routes dynamically:
/// - Unauthenticated: [LoginScreen]
/// - Authenticated Admin: [AdminDashboardScreen]
/// - Authenticated Customer: [AppShell]
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<SwagAppStore>(
      builder: (context, store, _) {
        if (!store.isLoggedIn) {
          return const LoginScreen();
        }
        if (store.isAdmin) {
          return const AdminDashboardScreen();
        }
        return const AppShell();
      },
    );
  }
}
