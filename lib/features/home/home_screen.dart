import 'package:flutter/material.dart'; // ✅ Base de Flutter para UI
import 'package:vivero_lavega/shared/themes/app_colors.dart';
//import '../../../shared/widgets/bottom_nav_bar.dart'; // ✅ Tu Bottom Navigation Bar
import '../inventory/presentation/pages/inventory_screen.dart'; // ✅ Pantalla de Inventario
import '../sales/presentation/pages/sales_screen.dart'; // ✅ Pantalla de Ventas
import '../customers/presentation/pages/customers_screen.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> _screens = const [
    InventoryScreen(),
    SalesScreen(),
    CustomersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // ← permite que el body se muestre debajo del navbar
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha((0.8 * 255).round()),
                borderRadius: BorderRadius.circular(25),
                // border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: currentIndex,
                onTap: (index) => setState(() => currentIndex = index),
                selectedItemColor: AppColors.secondary,
                unselectedItemColor: AppColors.background,
                showUnselectedLabels: false,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory),
                    label: 'Inventario',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.attach_money),
                    label: 'Ventas',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.groups),
                    label: 'Clientes',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
