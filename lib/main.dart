import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import './providers/app_provider.dart'; 
import './router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final router = AppRouter(appProvider).router;
          return MaterialApp.router(
            title: 'Vehicle Rental Manager',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              textTheme: GoogleFonts.interTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
