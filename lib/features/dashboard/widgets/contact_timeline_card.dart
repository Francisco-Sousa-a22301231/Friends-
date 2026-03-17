import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/models/contact_communication.dart';

/// Displays a single contact's communication summary in the timeline.
class ContactTimelineCard extends StatelessWidget {
  final ContactSummary summary;

  const ContactTimelineCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _getUrgencyColor(summary.timeSinceLastContact);
    final timeAgoText = timeago.format(summary.lastCommunication,
        locale: 'pt_BR');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: urgencyColor.withValues(alpha: 0.2),
          child: Text(
            summary.contactName.isNotEmpty
                ? summary.contactName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: urgencyColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          summary.contactName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Icon(
              summary.lastType == CommunicationType.call
                  ? Icons.phone
                  : Icons.sms,
              size: 14,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(timeAgoText),
            const SizedBox(width: 12),
            if (summary.totalCalls > 0) ...[
              const Icon(Icons.phone, size: 12, color: Colors.grey),
              const SizedBox(width: 2),
              Text('${summary.totalCalls}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 8),
            ],
            if (summary.totalMessages > 0) ...[
              const Icon(Icons.sms, size: 12, color: Colors.grey),
              const SizedBox(width: 2),
              Text('${summary.totalMessages}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: urgencyColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDuration(summary.timeSinceLastContact),
            style: TextStyle(
              color: urgencyColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// Color-code by urgency: green (recent), yellow (weeks), red (months+).
  Color _getUrgencyColor(Duration timeSince) {
    if (timeSince.inDays < 7) return Colors.green;
    if (timeSince.inDays < 30) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(Duration d) {
    if (d.inDays >= 365) {
      final years = d.inDays ~/ 365;
      return '${years}a';
    }
    if (d.inDays >= 30) {
      final months = d.inDays ~/ 30;
      return '${months}m';
    }
    if (d.inDays >= 7) {
      final weeks = d.inDays ~/ 7;
      return '${weeks}sem';
    }
    if (d.inDays >= 1) {
      return '${d.inDays}d';
    }
    if (d.inHours >= 1) {
      return '${d.inHours}h';
    }
    return 'agora';
  }
}
