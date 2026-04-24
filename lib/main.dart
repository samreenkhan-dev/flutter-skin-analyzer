import 'package:aiskinscan/src/logic/auth_bloc/auth_state.dart';
import 'package:aiskinscan/src/logic/chat_bloc/chat_bloc.dart';
import 'package:aiskinscan/src/presentation/screens/home_screen.dart';
import 'package:aiskinscan/src/presentation/screens/login_screen.dart';
import 'package:aiskinscan/src/presentation/screens/main_nav_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// Screens
import 'src/presentation/screens/splash_screen.dart';

// Services & Repositories
import 'src/data/sources/gemini_service.dart';
import 'src/data/sources/supabase_service.dart';
import 'src/data/repositories/auth_repository.dart';
import 'src/data/repositories/scan_repository.dart';

// BLoCs
import 'src/logic/auth_bloc/auth_bloc.dart';
import 'src/logic/auth_bloc/auth_event.dart';
import 'src/logic/scanner_bloc/scanner_bloc.dart';
import 'src/logic/history_bloc/history_bloc.dart';

// Theme
import 'src/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables (.env)
  await dotenv.load(fileName: ".env");

  // 2. Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 3. Initialize Repositories (Singletons)
  final authRepository = AuthRepository();
  final scanRepository = ScanRepository(GeminiService(), SupabaseService());
  final geminiService = GeminiService();

  runApp(DermAI(
    authRepository: authRepository,
    scanRepository: scanRepository,
    geminiService: geminiService,
  ));
}

class DermAI extends StatelessWidget {
  final AuthRepository authRepository;
  final ScanRepository scanRepository;
  final GeminiService geminiService;


  const DermAI({
    super.key,
    required this.authRepository,
    required this.scanRepository,
    required this.geminiService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      // Providing Repositories so they can be accessed anywhere
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: scanRepository),
      ],
      // main.dart ke andar MultiBlocProvider wala hissa update karein:

      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            // FIX: Yahan () brackets add karein taakay class ka instance create ho
            create: (context) => AuthBloc(authRepository)..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => ScannerBloc(scanRepository),
          ),
          BlocProvider(
            create: (context) => HistoryBloc(scanRepository),
          ),
          BlocProvider(create: (context) => ChatBloc(geminiService)),
        ],
        child: MaterialApp(
          title: 'DermAI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme, // Premium Dark Theme
           // main.dart mein home property ko aise set karein:
          home: const SplashScreen(),
      )));
  }
}