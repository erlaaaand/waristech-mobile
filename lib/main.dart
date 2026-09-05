import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('Warning: .env tidak ditemukan, melanjutkan tanpa konfigurasi.');
  }

  runApp(const ProviderScope(child: WarisTechApp()));
}

class WarisTechApp extends ConsumerWidget {
  const WarisTechApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'WarisTech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        // Membatasi grid aplikasi agar tidak "mentok menuhin layar"
        // pada device besar (tablet/web) dengan membungkusnya di maxWidth 480px.
        return Container(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.black 
              : const Color(0xFFF3F4F6), // Warna latar luar (letterbox)
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ClipRect(
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
