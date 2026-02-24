import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import './providers/app_provider.dart';
import './providers/booking_provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppProvider()),
        ChangeNotifierProxyProvider<AppProvider, BookingProvider>(
          create: (context) => BookingProvider(),
          update: (context, appProvider, bookingProvider) {
            bookingProvider!.updateCompanyId(appProvider.currentCompanyId);
            return bookingProvider;
          },
        ),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final router = AppRouter(appProvider).router;
          return MaterialApp.router(
            title: 'Vehicle Rental Manager',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E3A8A), // Deep Blue
                brightness: Brightness.light,
              ),
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
