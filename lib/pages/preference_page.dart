import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';

class PreferencePage extends StatefulWidget {
  const PreferencePage({super.key});

  @override
  State<PreferencePage> createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  /// ONE list that drives the UI.
  final List<String> _prefs = ['金額', '距離', '評價', '人潮'];

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
      setState(() => _prefs.add(res.trim()));
      _textCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationService>();

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
                itemCount: _prefs.length,
                onReorder: (oldIdx, newIdx) {
                  setState(() {
                    if (oldIdx < newIdx) newIdx--;
                    final item = _prefs.removeAt(oldIdx);
                    _prefs.insert(newIdx, item);
                  });
                },
                itemBuilder: (_, i) => _PrefChip(
                  key: ValueKey(_prefs[i]),
                  label: _prefs[i],
                  onDelete: () => setState(() => _prefs.removeAt(i)),
                ),
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
    required this.onDelete,
  }) : super(key: key);

  final String label;
  final VoidCallback onDelete;

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
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              splashRadius: 24,
              onPressed: onDelete,
            ),
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
