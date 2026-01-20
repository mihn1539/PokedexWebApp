import 'package:flutter/material.dart';
import 'package:pokedex/pages/pokedex_page.dart';
import 'package:pokedex/controllers/theme_controller.dart';
import 'package:pokedex/controllers/daily_trivia_controller.dart';
import 'package:pokedex/themes/light_theme.dart';
import 'package:pokedex/themes/dark_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Esperar a que el ThemeController cargue el tema guardado
  await ThemeController.instance.waitForInitialization();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DailyTriviaController()..initialize(),
        ),
      ],
      child: AnimatedBuilder(
        animation: ThemeController.instance,
        builder: (context, _) {
          return MaterialApp(
            title: 'Pokédex',
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: ThemeController.instance.mode,
            home: const PokedexPage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
} 
