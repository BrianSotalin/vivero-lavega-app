import 'package:flutter/material.dart';

class QrDialog extends StatelessWidget {
  const QrDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
        child: const Text(
          'QR Banco Pichincha',
          style: TextStyle(color: Colors.deepPurple),
        ),
      ),
      content: Image.asset(
        'assets/images/banco_qr.jpg',
        width: 200,
        height: 200,
      ),
      actions: [
        Expanded(
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.deepPurple, // Cambia aquí el color de fondo
                foregroundColor: Colors.white, // Color del texto o íconos
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> showQrDialog(BuildContext context) {
  return showDialog(context: context, builder: (context) => const QrDialog());
}
