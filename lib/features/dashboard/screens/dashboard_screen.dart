import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/contact_communication.dart';
import '../../../core/providers/contact_provider.dart';
import '../widgets/contact_timeline_card.dart';
import '../widgets/empty_state_widget.dart';

/// F1.3: Contact Timeline Dashboard — "Lista dos tempos"
/// Shows all contacts sorted by how long since last communication.
/// US1.1.3: Combined view of calls and texts per contact.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<ContactProvider>();
    Future.microtask(() => provider.loadContacts());
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
      body: Column(
        children: [
          _buildFilterBar(provider),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  /// US1.1.3: Filter chips for All / Calls / SMS view.
  Widget _buildFilterBar(ContactProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Todos'),
            selected: provider.filterType == null,
            onSelected: (_) => provider.setFilter(null),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Chamadas'),
            avatar: provider.filterType == CommunicationType.call
                ? null
                : const Icon(Icons.phone, size: 16),
            selected: provider.filterType == CommunicationType.call,
            onSelected: (_) => provider.setFilter(
              provider.filterType == CommunicationType.call
                  ? null
                  : CommunicationType.call,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('SMS'),
            avatar: provider.filterType == CommunicationType.sms
                ? null
                : const Icon(Icons.sms, size: 16),
            selected: provider.filterType == CommunicationType.sms,
            onSelected: (_) => provider.setFilter(
              provider.filterType == CommunicationType.sms
                  ? null
                  : CommunicationType.sms,
            ),
          ),
          const Spacer(),
          if (provider.allSummaries.isNotEmpty)
            Text(
              '${provider.allSummaries.length} contactos',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
        ],
      ),
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
