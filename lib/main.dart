import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/converter_screen.dart';
import 'state/converter_state.dart';
import 'state/favorites_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CambioApp());
}

class CambioApp extends StatelessWidget {
  const CambioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConverterState()..init()),
        ChangeNotifierProvider(create: (_) => FavoritesState()..init()),
      ],
      child: MaterialApp(
        title: 'Cambio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const ConverterScreen(),
      ),
    );
  }
}
