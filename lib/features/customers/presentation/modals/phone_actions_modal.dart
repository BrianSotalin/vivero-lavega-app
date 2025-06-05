import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';

Future<void> showPhoneActionsModal(BuildContext context, String phone) async {
  final navigator = Navigator.of(context); //
  final cleanedPhone = phone.replaceAll(
    RegExp(r'\D'),
    '',
  ); // Elimina espacios y símbolos
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.phone, color: AppColors.third),
            title: const Text('Llamar'),
            onTap: () async {
              final uri = Uri.parse('tel:$phone');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }

              navigator.pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.message, color: AppColors.primary),
            title: const Text('WhatsApp'),
            onTap: () async {
              // final whatsappUri = Uri.parse('https://wa.me/$phone');
              // print(phone);
              // if (await canLaunchUrl(whatsappUri)) {
              //   await launchUrl(
              //     whatsappUri,
              //     mode: LaunchMode.externalApplication,
              //   );
              // } else {
              //   print(context);
              // }

              // navigator.pop();
              final whatsappUri = Uri.parse('https://wa.me/593$cleanedPhone');
              if (await canLaunchUrl(whatsappUri)) {
                await launchUrl(
                  whatsappUri,
                  mode: LaunchMode.externalApplication,
                );
              } else {
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No se pudo abrir WhatsApp')),
                );
              }
              navigator.pop();
            },
          ),
        ],
      );
    },
  );
}
