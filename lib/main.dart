import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'data/auth_repository.dart';
import 'data/catalog_repository.dart';
import 'data/supabase_auth_repository.dart';
import 'data/supabase_catalog_repository.dart';
import 'home/home_shell.dart';
import 'login/jornada_login_screen.dart';
import 'splash/jornada_splash_screen.dart';
import 'ui/app_tokens.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // A tela do sistema é só a cor azul (sem logo): segura até o 1º quadro
  // do Flutter e some direto no splash animado.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // O degradê vai até atrás das barras do sistema.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Banco de dados: Supabase, ou os dados de exemplo com USE_MOCK=true.
  if (!SupabaseConfig.useMock) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    final client = Supabase.instance.client;
    AuthRepository.shared = SupabaseAuthRepository(client);
    CatalogRepository.shared = SupabaseCatalogRepository(client);
  }

  runApp(const JornadaTechApp());
}

class JornadaTechApp extends StatefulWidget {
  const JornadaTechApp({super.key});

  @override
  State<JornadaTechApp> createState() => _JornadaTechAppState();
}

class _JornadaTechAppState extends State<JornadaTechApp> {
  final _navigator = GlobalKey<NavigatorState>();

  NavigatorState get _nav => _navigator.currentState!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FlutterNativeSplash.remove());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JornadaTech',
      navigatorKey: _navigator,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: kManrope,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          primary: AppColors.blue,
          secondary: AppColors.orange,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
        ),
      ),
      home: JornadaSplashScreen(
        initialize: _carregarDadosIniciais,
        onFinished: () => _nav.pushReplacement(PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 400),
          // Sessão salva: vai direto para as trilhas.
          pageBuilder: (_, __, ___) {
            final user = AuthRepository.shared.currentUser;
            return user == null ? _login() : _home(user);
          },
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        )),
      ),
    );
  }

  Widget _login() => JornadaLoginScreen(
        // Ao entrar (login, conta nova ou senha redefinida), vai para as
        // trilhas.
        onLoggedIn: _goHome,
      );

  Widget _home(AppUser user) => HomeShell(
        user: user,
        onLogout: () async {
          await AuthRepository.shared.logout();
          _nav.pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => _login()),
            (_) => false,
          );
        },
      );

  void _goHome(AppUser user) => _nav.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => _home(user)),
        (_) => false,
      );

  Future<void> _carregarDadosIniciais() async {
    // Coloque aqui o que o app precisa antes de abrir (ex.: materiais
    // offline). A sessão salva já é restaurada pelo Supabase.initialize.
  }
}
