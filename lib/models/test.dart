import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'unwanted.dart';
import 'userSetting.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UnwantedList(unwantedIds: [])),
        ChangeNotifierProvider(create: (_) => UserSetting()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '黑名單 + 使用者設定測試',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CombinedTestScreen(),
    );
  }
}

class CombinedTestScreen extends StatefulWidget {
  const CombinedTestScreen({super.key});

  @override
  State<CombinedTestScreen> createState() => _CombinedTestScreenState();
}

class _CombinedTestScreenState extends State<CombinedTestScreen> {
  final _placeIdController = TextEditingController();
  final _preferenceController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _placeIdController.dispose();
    _preferenceController.dispose();
    _requirementsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unwantedList = Provider.of<UnwantedList>(context);
    final setting = Provider.of<UserSetting>(context);

    _requirementsController.text = setting.requirements;
    _notesController.text = setting.notes;

    return Scaffold(
      appBar: AppBar(title: const Text('黑名單 & 使用者設定測試')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 黑名單部分
            const Text('🔒 黑名單功能', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _placeIdController,
                    decoration: const InputDecoration(labelText: '輸入 Place ID'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final id = _placeIdController.text.trim();
                    if (id.isNotEmpty) {
                      unwantedList.addToUnwanted(id);
                      _placeIdController.clear();
                    }
                  },
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: unwantedList.unwantedIds.length,
              itemBuilder: (_, index) {
                final id = unwantedList.unwantedIds[index];
                return ListTile(
                  title: Text(id),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => unwantedList.removeFromUnwanted(id),
                  ),
                );
              },
            ),

            const Divider(height: 32),

            /// 使用者設定部分
            const Text('⚙️ 使用者偏好設定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _preferenceController,
                    decoration: const InputDecoration(labelText: '新增偏好'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final value = _preferenceController.text.trim();
                    if (value.isNotEmpty) {
                      setting.addPreference(value);
                      _preferenceController.clear();
                    }
                  },
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: setting.sortedPreference
                  .map((pref) => Chip(
                        label: Text(pref),
                        onDeleted: () => setting.removePreference(pref),
                      ))
                  .toList(),
            ),
            ElevatedButton(
              onPressed: setting.clearPreferences,
              child: const Text('清除所有偏好'),
            ),

            const SizedBox(height: 16),
            _buildSlider("最小成本", setting.minCost, 0, 1000, setting.updateMinCost),
            _buildSlider("最大成本", setting.maxCost, 0, 1000, setting.updateMaxCost),
            _buildSlider("最小距離", setting.minDist, 0, 1000, setting.updateMinDist),
            _buildSlider("最大距離", setting.maxDist, 0, 1000, setting.updateMaxDist),

            const SizedBox(height: 16),
            TextField(
              controller: _requirementsController,
              decoration: const InputDecoration(labelText: '需求'),
              onChanged: setting.updateRequirements,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: '備註'),
              onChanged: setting.updateNotes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    void Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(1)}'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 100,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
