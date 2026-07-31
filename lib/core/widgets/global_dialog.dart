import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';


enum DialogType {
  error,
  success,
}

Future<void> showDialogBanner(
    DialogType dialogType,
    String message,
    BuildContext context,
    ) async {
  final bool isError = dialogType == DialogType.error;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              color: isError ? Colors.red : Colors.green,
                  ),
            const SizedBox(width: 8),
            Text(
              isError
                  ? 'common.error'.tr()
                  : 'common.success'.tr(),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text('common.ok'.tr()),
          ),
        ],
      );
    },
  );
}