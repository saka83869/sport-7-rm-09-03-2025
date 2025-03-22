import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mathfun/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/storage_service.dart';
import 'core/utils/game_service.dart';
import 'features/history/history_bloc.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  await StorageService.init();
  
  runApp(const MathFunApp());
}

class MathFunApp extends StatelessWidget {
  const MathFunApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final storageService = StorageService();
    final gameService = GameService();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StorageService>(
          create: (context) => storageService,
        ),
        RepositoryProvider<GameService>(
          create: (context) => gameService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<HistoryBloc>(
            create: (context) => HistoryBloc(
              storageService: context.read<StorageService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Math Fun',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
