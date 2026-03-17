import 'package:flutter/foundation.dart';

import '../models/contact_communication.dart';
import '../services/contact_aggregator_service.dart';

/// Provides contact summaries to the UI, managing loading state.
class ContactProvider extends ChangeNotifier {
  final ContactAggregatorService _aggregator = ContactAggregatorService();

  List<ContactSummary> _summaries = [];
  bool _isLoading = false;
  String? _error;

  List<ContactSummary> get summaries => _summaries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch and aggregate all communication data.
  Future<void> loadContacts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summaries = await _aggregator.getContactSummaries();
    } catch (e) {
      _error = 'Failed to load communication history: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh data (pull-to-refresh).
  Future<void> refresh() async {
    await loadContacts();
  }
}
