import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vivero_lavega/shared/themes/app_colors.dart';

Future<void> showPhoneActionsModal(BuildContext context, String phone) async {
  final navigator = Navigator.of(context); //
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
              final whatsappUri = Uri.parse('https://wa.me/$phone');
              if (await canLaunchUrl(whatsappUri)) {
                await launchUrl(
                  whatsappUri,
                  mode: LaunchMode.externalApplication,
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
