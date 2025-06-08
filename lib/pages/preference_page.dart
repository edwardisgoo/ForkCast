import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';
import '../models/userSetting.dart';

class PreferencePage extends StatefulWidget {
  const PreferencePage({super.key});

  @override
  State<PreferencePage> createState() => _PreferencePageState();
}

class _PrefItem {
  _PrefItem(this.label, {required this.deletable});

  String label;
  bool deletable;
}

class _PreferencePageState extends State<PreferencePage> {
  /// ONE list that drives the UI with deletion info.
  static const _builtIns = ['金額', '距離', '評價'];

  final _textCtrl = TextEditingController();

  // ───────────── add a new keyword ─────────────
  Future<void> _addPref() async {
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新增喜好'),
        content: TextField(
          controller: _textCtrl,
          decoration: const InputDecoration(hintText: '輸入新的喜好…'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(context, _textCtrl.text),
              child: const Text('確定')),
        ],
      ),
    );
    if (res != null && res.trim().isNotEmpty) {
      final setting = context.read<UserSetting>();
      setting.addPreference(res.trim());
      _textCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationService>();
    final setting = context.watch<UserSetting>();

    final prefs = setting.sortedPreference;
    final List<_PrefItem> items = prefs
        .map((p) => _PrefItem(p, deletable: !_builtIns.contains(p)))
        .toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        toolbarHeight:
            kToolbarHeight + 15, // Increased height to lower the title
        title: const Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text('請排序喜好',
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            // ───────────── draggable list ─────────────
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                onReorder: (oldIdx, newIdx) {
                  final list = List<String>.from(prefs);
                  if (oldIdx < newIdx) newIdx--;
                  final item = list.removeAt(oldIdx);
                  list.insert(newIdx, item);
                  setting.updatePreferences(list);
                },
                itemBuilder: (_, i) {
                  final pref = items[i];
                  return _PrefChip(
                    key: ValueKey(pref.label),
                    label: pref.label,
                    deletable: pref.deletable,
                    onDelete: pref.deletable
                        ? () {
                            final list = List<String>.from(prefs);
                            list.removeAt(i);
                            setting.updatePreferences(list);
                          }
                        : null,
                  );
                },
              ),
            ),

            // ───────────── add button ─────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _addPref,
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 32,
                ),
                label: const Text('其他喜好'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  textStyle: const TextStyle(fontSize: 28),
                ),
              ),
            ),

            // ───────────── finish ─────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: ElevatedButton.icon(
                onPressed: nav.goMain,
                label: const Text('完成'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  textStyle: const TextStyle(fontSize: 28),
                  alignment: Alignment.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────── single tag chip ─────────────────
class _PrefChip extends StatelessWidget {
  const _PrefChip({
    required Key key,
    required this.label,
    required this.deletable,
    this.onDelete,
  })  : assert(!deletable || onDelete != null),
        super(key: key);

  final String label;
  final bool deletable;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      color: Colors.deepPurple[200],
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: Row(
          children: [
            // close icon (left)
            if (deletable)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                splashRadius: 24,
                onPressed: onDelete,
              )
            else
              const SizedBox(width: 48),
            // centred label
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 24, color: Colors.white, height: 1),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // empty space (right) so drag-handle doesn’t overlap text
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}
