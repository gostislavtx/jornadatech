import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'data/auth_repository.dart';
import 'home/home_shell.dart';
import 'login/jornada_login_screen.dart';
import 'splash/jornada_splash_screen.dart';
import 'ui/app_tokens.dart';

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // A tela do sistema é só a cor azul (sem logo): segura até o 1º quadro
  // do Flutter e some direto no splash animado.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // O degradê vai até atrás das barras do sistema.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
          pageBuilder: (_, __, ___) => _login(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        )),
      ),
    );
  }

  Widget _login() => JornadaLoginScreen(
        // RF001/RF003: ao autenticar (login direto ou troca de senha
        // no primeiro acesso), segue para a área logada.
        onLoggedIn: _goHome,
      );

  void _goHome(AppUser user) => _nav.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => HomeShell(
            user: user,
            onLogout: () => _nav.pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => _login()),
              (_) => false,
            ),
          ),
        ),
        (_) => false,
      );

  Future<void> _carregarDadosIniciais() async {
    // Coloque aqui o que o app precisa antes de abrir:
    // sessão salva, trilhas recomendadas, materiais offline etc.
  }
}
