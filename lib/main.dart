import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/app_providers.dart';
import 'core/services/database_service.dart';
import 'features/permissions/screens/onboarding_permissions_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'core/providers/permission_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initialize();
  runApp(const FriendsApp());
}

class FriendsApp extends StatelessWidget {
  const FriendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        title: 'Friends',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF6750A4),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        home: const AppEntryPoint(),
      ),
    );
  }
}

/// Decides whether to show onboarding (permissions) or the main dashboard.
class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    final permissionProvider = context.watch<PermissionProvider>();

    if (!permissionProvider.hasCompletedOnboarding) {
      return const OnboardingPermissionsScreen();
    }

    return const DashboardScreen();
  }
}
