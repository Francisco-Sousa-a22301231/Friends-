import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/contact_provider.dart';
import '../widgets/contact_timeline_card.dart';
import '../widgets/empty_state_widget.dart';

/// F1.3: Contact Timeline Dashboard — "Lista dos tempos"
/// Shows all contacts sorted by how long since last communication.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load contacts on first open
    Future.microtask(() => context.read<ContactProvider>().loadContacts());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContactProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings (data export/deletion)
            },
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(ContactProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(provider.error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => provider.refresh(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (provider.summaries.isEmpty) {
      return const EmptyStateWidget();
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: provider.summaries.length,
        itemBuilder: (context, index) {
          return ContactTimelineCard(summary: provider.summaries[index]);
        },
      ),
    );
  }
}
