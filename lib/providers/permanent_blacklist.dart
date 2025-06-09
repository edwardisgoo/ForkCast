import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kKey = 'permanent_blacklist_ids';

/// A [ChangeNotifier] that keeps a persistent list of permanently
/// blacklisted restaurant IDs.
class PermanentBlacklist extends ChangeNotifier {
  PermanentBlacklist() {
    _load();
  }

  List<String> _ids = [];

  /// The list of blacklisted restaurant IDs.
  List<String> get ids => _ids;

  /// Adds [id] to the blacklist if not already present and persists the list.
  Future<void> add(String id) async {
    if (_ids.contains(id)) return;
    _ids.add(id);
    notifyListeners();
    await _save();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _ids = sp.getStringList(_kKey) ?? [];
    notifyListeners();
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_kKey, _ids);
  }
}
