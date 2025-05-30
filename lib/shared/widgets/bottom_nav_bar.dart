// import 'package:flutter/material.dart';

// class BottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const BottomNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTap,
//       type: BottomNavigationBarType.fixed,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.inventory),
//           label: 'Inventario',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.attach_money),
//           label: 'Ventas',
//         ),
//         BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Clientes'),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary, // ✅ Fondo verde
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ), // ✅ Margen para flotarlo
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.inventory, "Inventory", 0),
          _buildNavItem(Icons.attach_money, "Sales", 1),
          _buildNavItem(Icons.group, "Customers", 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isSelected
                      ? Colors.white
                      : Colors.transparent, // ✅ Círculo blanco en seleccionado
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : Colors.white,
                  size: 30,
                ),
                if (isSelected)
                  Text(
                    label,
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
