import 'package:flutter/material.dart';

import '../../../core/models/gdpr_consent.dart';

/// F5.2: GDPR consent dialog with granular toggles.
class GdprConsentDialog extends StatefulWidget {
  const GdprConsentDialog({super.key});

  @override
  State<GdprConsentDialog> createState() => _GdprConsentDialogState();
}

class _GdprConsentDialogState extends State<GdprConsentDialog> {
  bool _callLog = false;
  bool _sms = false;
  bool _contacts = false;
  bool _dataStorage = false;

  bool get _allAccepted => _callLog && _sms && _contacts && _dataStorage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Política de Dados e RGPD'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A aplicação Friends recolhe os seguintes dados, que ficam '
              'armazenados apenas no teu dispositivo:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _consentToggle(
              'Acesso ao histórico de chamadas',
              'Lemos o registo de chamadas para saber quando falaste '
                  'com cada contacto.',
              _callLog,
              (v) => setState(() => _callLog = v ?? false),
            ),
            _consentToggle(
              'Acesso às mensagens SMS',
              'Lemos as mensagens para identificar a última conversa '
                  'com cada contacto.',
              _sms,
              (v) => setState(() => _sms = v ?? false),
            ),
            _consentToggle(
              'Acesso aos contactos',
              'Lemos os nomes dos contactos para os mostrar na app.',
              _contacts,
              (v) => setState(() => _contacts = v ?? false),
            ),
            _consentToggle(
              'Armazenamento local de dados',
              'Os dados são guardados localmente no teu telemóvel. '
                  'Nunca são partilhados com terceiros.',
              _dataStorage,
              (v) => setState(() => _dataStorage = v ?? false),
            ),
            const SizedBox(height: 12),
            Text(
              'Podes apagar todos os teus dados a qualquer momento nas '
              'definições da aplicação (Direito ao Esquecimento - Art. 17 RGPD).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _allAccepted
              ? () {
                  Navigator.of(context).pop(GdprConsent(
                    callLogAccess: _callLog,
                    smsAccess: _sms,
                    contactsAccess: _contacts,
                    dataStorageConsent: _dataStorage,
                  ));
                }
              : null,
          child: const Text('Aceitar Tudo'),
        ),
      ],
    );
  }

  Widget _consentToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return CheckboxListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
