import 'package:flutter/material.dart';
import 'package:vivero_lavega/features/inventory/presentation/pages/inventory_screen.dart';
import 'package:vivero_lavega/features/customers/presentation/pages/customers_screen.dart';
import 'package:vivero_lavega/features/sales/presentation/pages/sales_screen.dart';
import 'package:vivero_lavega/features/auth/presentation/pages/login.dart';
import 'package:vivero_lavega/features/home/home_screen.dart';

final Map<String, WidgetBuilder> routes = {
  '/login': (context) => LoginPage(),
  '/home': (context) => HomeScreen(),
  '/inventory': (context) => InventoryScreen(),
  '/sales': (context) => SalesScreen(),
  '/customers': (context) => CustomersScreen(),
};
