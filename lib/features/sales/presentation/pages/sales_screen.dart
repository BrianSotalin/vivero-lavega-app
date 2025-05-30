import 'package:flutter/material.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';
//import 'package:vivero_lavega/shared/widgets/bottom_nav_bar.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // title: const Text('Sales'),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
      ),
      body: Center(
        child: const Text(
          'Registro de Ventas',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
