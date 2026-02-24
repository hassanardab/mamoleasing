import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthGate is no longer strictly necessary with GoRouter redirect logic,
    // but it can serve as a splash/loading gate.
    final appProvider = Provider.of<AppProvider>(context);

    if (appProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return const Scaffold(
      body: Center(child: Text("Redirecting...")),
    );
  }
}
