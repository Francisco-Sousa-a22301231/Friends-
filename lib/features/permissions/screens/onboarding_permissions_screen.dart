import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/gdpr_consent.dart';
import '../../../core/providers/permission_provider.dart';
import '../widgets/permission_card.dart';
import '../widgets/gdpr_consent_dialog.dart';

/// F5.1 & F5.2: Onboarding screen that requests permissions and GDPR consent.
class OnboardingPermissionsScreen extends StatefulWidget {
  const OnboardingPermissionsScreen({super.key});

  @override
  State<OnboardingPermissionsScreen> createState() =>
      _OnboardingPermissionsScreenState();
}

class _OnboardingPermissionsScreenState
    extends State<OnboardingPermissionsScreen> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    context.read<PermissionProvider>().checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PermissionProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Bem-vindo ao Friends',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Há quanto tempo não falas com os teus amigos ou a tua família?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Para te ajudar, precisamos de aceder ao teu histórico de '
                'chamadas e mensagens. Os teus dados ficam apenas no teu '
                'telemóvel.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Stepper(
                  currentStep: _currentStep,
                  controlsBuilder: (context, details) =>
                      const SizedBox.shrink(),
                  steps: [
                    Step(
                      title: const Text('Histórico de Chamadas'),
                      subtitle: Text(provider.callLogGranted
                          ? 'Permissão concedida'
                          : 'Necessário para ver as tuas chamadas'),
                      isActive: _currentStep >= 0,
                      state: provider.callLogGranted
                          ? StepState.complete
                          : StepState.indexed,
                      content: PermissionCard(
                        icon: Icons.phone,
                        title: 'Chamadas',
                        description:
                            'Permite ver quando falaste com cada contacto '
                            'pela última vez.',
                        isGranted: provider.callLogGranted,
                        onRequest: () async {
                          await provider.requestCallLogPermission();
                          if (provider.callLogGranted) {
                            setState(() => _currentStep = 1);
                          }
                        },
                      ),
                    ),
                    Step(
                      title: const Text('Mensagens SMS'),
                      subtitle: Text(provider.smsGranted
                          ? 'Permissão concedida'
                          : 'Necessário para ver as tuas mensagens'),
                      isActive: _currentStep >= 1,
                      state: provider.smsGranted
                          ? StepState.complete
                          : StepState.indexed,
                      content: PermissionCard(
                        icon: Icons.sms,
                        title: 'SMS',
                        description:
                            'Permite ver quando enviaste mensagens a cada '
                            'contacto.',
                        isGranted: provider.smsGranted,
                        onRequest: () async {
                          await provider.requestSmsPermission();
                          if (provider.smsGranted) {
                            setState(() => _currentStep = 2);
                          }
                        },
                      ),
                    ),
                    Step(
                      title: const Text('Contactos'),
                      subtitle: Text(provider.contactsGranted
                          ? 'Permissão concedida'
                          : 'Necessário para identificar os teus contactos'),
                      isActive: _currentStep >= 2,
                      state: provider.contactsGranted
                          ? StepState.complete
                          : StepState.indexed,
                      content: PermissionCard(
                        icon: Icons.contacts,
                        title: 'Contactos',
                        description:
                            'Permite associar números de telefone aos nomes '
                            'dos teus contactos.',
                        isGranted: provider.contactsGranted,
                        onRequest: () async {
                          await provider.requestContactsPermission();
                          if (provider.contactsGranted) {
                            setState(() => _currentStep = 3);
                          }
                        },
                      ),
                    ),
                    Step(
                      title: const Text('Consentimento RGPD'),
                      subtitle: const Text('Proteção dos teus dados'),
                      isActive: _currentStep >= 3,
                      state: provider.consent.hasAllRequiredConsents
                          ? StepState.complete
                          : StepState.indexed,
                      content: _buildGdprStep(provider),
                    ),
                  ],
                ),
              ),
              if (provider.allPermissionsGranted &&
                  provider.consent.hasAllRequiredConsents)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => provider.completeOnboarding(),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Começar'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGdprStep(PermissionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Os teus dados são armazenados apenas localmente no teu '
          'dispositivo. Nunca são enviados para servidores externos.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () => _showGdprDialog(provider),
          child: const Text('Rever e Aceitar Política de Dados'),
        ),
      ],
    );
  }

  Future<void> _showGdprDialog(PermissionProvider provider) async {
    final consent = await showDialog<GdprConsent>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GdprConsentDialog(),
    );

    if (consent != null) {
      await provider.updateConsent(consent);
    }
  }
}
