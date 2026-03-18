import 'package:flutter/foundation.dart';

import '../models/contact_communication.dart';
import '../services/contact_aggregator_service.dart';

/// Provides contact summaries to the UI, managing loading state and filtering.
class ContactProvider extends ChangeNotifier {
  final ContactAggregatorService _aggregator;

  List<ContactSummary> _summaries = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefreshed;
  CommunicationType? _filterType;

  ContactProvider({ContactAggregatorService? aggregator})
      : _aggregator = aggregator ?? ContactAggregatorService();

  List<ContactSummary> get summaries {
    if (_filterType == null) return _summaries;
    return _summaries.where((s) {
      if (_filterType == CommunicationType.call) return s.totalCalls > 0;
      return s.totalMessages > 0;
    }).toList();
  }

  List<ContactSummary> get allSummaries => _summaries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastRefreshed => _lastRefreshed;
  CommunicationType? get filterType => _filterType;

  /// Fetch and aggregate all communication data from native sources.
  Future<void> loadContacts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summaries = await _aggregator.getContactSummaries();
      _lastRefreshed = DateTime.now();
    } catch (e) {
      _error = 'Failed to load communication history: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load from local DB cache only (faster, no native access).
  Future<void> loadFromCache() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summaries = await _aggregator.getCachedSummaries();
    } catch (e) {
      _error = 'Failed to load cached data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh data (pull-to-refresh).
  Future<void> refresh() async {
    await loadContacts();
  }

  /// Filter summaries by communication type (null = show all).
  void setFilter(CommunicationType? type) {
    _filterType = type;
    notifyListeners();
  }
}
