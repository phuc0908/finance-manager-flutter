import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/services/isar_service.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/navigation/presentation/pages/main_screen.dart';
import 'core/services/sync_service.dart';
import 'features/wallet/presentation/providers/wallet_provider.dart';
import 'features/transaction/presentation/providers/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Isar Database
  await IsarService.getInstance();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Finance Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return SyncWrapper(userId: user.id, child: const MainScreen());
        }
        return const SplashScreen(); // Or Login directly, but better to show Splash first
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class SyncWrapper extends ConsumerStatefulWidget {
  final String userId;
  final Widget child;

  const SyncWrapper({super.key, required this.userId, required this.child});

  @override
  ConsumerState<SyncWrapper> createState() => _SyncWrapperState();
}

class _SyncWrapperState extends ConsumerState<SyncWrapper> {
  @override
  void initState() {
    super.initState();
    // Trigger sync when this wrapper is built (meaning user just logged in or app restarted with session)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncServiceProvider).syncFromCloud(widget.userId).then((_) {
        // Refresh providers after sync
        ref.invalidate(walletListProvider);
        ref.invalidate(recentTransactionsProvider);
        ref.invalidate(totalBalanceProvider);
        ref.invalidate(allTransactionsProvider);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Temporary Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Finance Manager',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
      ),
    );
  }
}
