import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UnwantedList(unwantedIds: []),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UnwantedList Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UnwantedListScreen(),
    );
  }
}

class UnwantedListScreen extends StatefulWidget {
  const UnwantedListScreen({super.key});

  @override
  State<UnwantedListScreen> createState() => _UnwantedListScreenState();
}

class _UnwantedListScreenState extends State<UnwantedListScreen> {
  final TextEditingController _controller = TextEditingController();

  void _addPlaceId(BuildContext context) {
    final input = _controller.text.trim();
    if (input.isNotEmpty) {
      Provider.of<UnwantedList>(context, listen: false).addToUnwanted(input);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final unwantedList = Provider.of<UnwantedList>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('黑名單')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '輸入 Place ID',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addPlaceId(context),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _addPlaceId(context),
              child: const Text('加入黑名單'),
            ),
            const SizedBox(height: 20),
            const Text('目前黑名單：'),
            Expanded(
              child: ListView.builder(
                itemCount: unwantedList.unwantedIds.length,
                itemBuilder: (_, index) {
                  final id = unwantedList.unwantedIds[index];
                  return ListTile(
                    title: Text(id),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        unwantedList.removeFromUnwanted(id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UnwantedList extends ChangeNotifier {
  List<String> unwantedIds;

  UnwantedList({required this.unwantedIds});

  void addToUnwanted(String placeId) {
    if (!unwantedIds.contains(placeId)) {
      unwantedIds.add(placeId);
      notifyListeners();
    }
  }

  void removeFromUnwanted(String placeId) {
    unwantedIds.remove(placeId);
    notifyListeners();
  }

  bool isUnwanted(String placeId) {
    return unwantedIds.contains(placeId);
  }
}
