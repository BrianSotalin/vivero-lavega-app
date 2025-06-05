
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';

class MonthFilterDropdown extends StatefulWidget {
  final Function(DateTime? start, DateTime? end) onDateRangeSelected;

  const MonthFilterDropdown({super.key, required this.onDateRangeSelected});

  @override
  State<MonthFilterDropdown> createState() => _MonthFilterDropdownState();
}

class _MonthFilterDropdownState extends State<MonthFilterDropdown> {
  late List<String> _monthsOptions;
  late String _selectedOption;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    // Lista de meses hasta el mes actual, formateados como "MMMM yyyy"
    _monthsOptions = List.generate(now.month, (index) {
      final date = DateTime(now.year, index + 1);
      return DateFormat('MMMM yyyy').format(date);
    });

    // Añadir "Año Actual" y "Año Pasado"
    _monthsOptions.add('Año Actual');
    _monthsOptions.add('Año Pasado');

    // Por defecto seleccionamos el mes actual (último mes generado)
    _selectedOption = _monthsOptions[now.month - 1];

    // Llamada inicial para aplicar filtro mes actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilter(_selectedOption);
    });
  }

  void _applyFilter(String selected) {
    final now = DateTime.now();
    if (selected == 'Año Pasado') {
      final start = DateTime(now.year - 1, 1, 1);
      final end = DateTime(now.year - 1, 12, 31, 23, 59, 59);
      widget.onDateRangeSelected(start, end);
    } else if (selected == 'Año Actual') {
      final start = DateTime(now.year, 1, 1);
      final end = DateTime(now.year, 12, 31, 23, 59, 59);
      widget.onDateRangeSelected(start, end);
    } else {
      // Mes seleccionado
      final parts = selected.split(' ');
      final monthName = parts[0];
      final year = int.parse(parts[1]);
      final month = DateFormat('MMMM').parse(monthName).month;

      final start = DateTime(year, month, 1);
      final end = DateTime(
        year,
        month + 1,
        0,
        23,
        59,
        59,
      ); // último día del mes
      widget.onDateRangeSelected(start, end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background, // color de fondo deseado
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<String>(
        value: _selectedOption,
        dropdownColor: Colors.white,
        items:
            _monthsOptions
                .map(
                  (month) => DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _selectedOption = value;
          });
          _applyFilter(value);
        },
      ),
    );
  }
}
