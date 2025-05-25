import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../widgets/title_text.dart';
import '../services/navigation.dart';

class ComplexCastPage extends StatefulWidget {
  const ComplexCastPage({super.key});
  @override
  State<ComplexCastPage> createState() => _ComplexCastPageState();
}

class _ComplexCastPageState extends State<ComplexCastPage> {
  double _money = 200;
  double _distance = 1.5;
  DateTime _selected = DateTime.now();
  final _foodCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  /* identical helpers used by ResultPage */
  double _titleY(BuildContext c) {
    final s = MediaQuery.of(c).size;
    final top = MediaQuery.of(c).padding.top;
    return 2 * (top + 16 + 15) / s.height - 1;
  }

  double _castY(BuildContext c) {
    final s = MediaQuery.of(c).size;
    final bot = MediaQuery.of(c).padding.bottom;
    return 2 * (s.height - bot - 16 - 30) / s.height - 1;
  }

  /* –– tiny icon + label –– */
  Widget _iconLabel(IconData icon, String label) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      );

  /* –– row that keeps icon & selector close –– */
  Widget _selectorRow({
    required IconData icon,
    required String label,
    required Widget selector,
  }) {
    const double lane = 110; // width reserved for icon+label
    return Row(
      children: [
        SizedBox(
          width: lane,
          child: Align(
              alignment: Alignment.centerRight, child: _iconLabel(icon, label)),
        ),
        const SizedBox(width: 50),
        Expanded(
          child: Align(alignment: Alignment.centerLeft, child: selector),
        ),
      ],
    );
  }

  /* –– money / distance selectors –– */
  Widget _moneySelector() => Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 40),
            onPressed: () => setState(() {
              if (_money > 100) _money -= 100;
            }),
          ),
          SizedBox(
            width: 80,
            child: Center(
              child: Text('${_money.toInt()}',
                  style: const TextStyle(fontSize: 30)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 40),
            onPressed: () => setState(() => _money += 100),
          ),
        ],
      );

  Widget _distanceSelector() => Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 40),
            onPressed: () => setState(() {
              if (_distance > 0.5) _distance -= 0.5;
            }),
          ),
          SizedBox(
            width: 80,
            child: Center(
              child: Text(_distance.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 30)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 40),
            onPressed: () => setState(() => _distance += 0.5),
          ),
        ],
      );

  Widget _timeSelector() => SizedBox(
        height: 110,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: _selected,
          onDateTimeChanged: (d) => setState(() => _selected = d),
        ),
      );

  Widget _input(String hint, TextEditingController c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: TextField(
          controller: c,
          maxLines: 7, // Allow up to 3 lines of text
          minLines: 7, // Minimum of 2 lines shown
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10), // Increased vertical padding
          ),
        ),
      );

  Widget _castBtn() => ElevatedButton(
        onPressed: () => context.read<NavigationService>().goResult(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
          textStyle: const TextStyle(fontSize: 28),
        ),
        child: const Text('Cast!', style: TextStyle(color: Colors.white)),
      );

  @override
  void dispose() {
    _foodCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  /* –– UI –– */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /* Scrollable form */
          Padding(
            padding: const EdgeInsets.only(
                top: 80), // Increased top padding to avoid overlap
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(
                        height: 20), // Reduced since we have top padding
                    _selectorRow(
                      icon: Icons.attach_money,
                      label: '價格(元)',
                      selector: _moneySelector(),
                    ),
                    const SizedBox(height: 24),
                    _selectorRow(
                      icon: Icons.directions_walk,
                      label: '距離(公里)',
                      selector: _distanceSelector(),
                    ),
                    const SizedBox(height: 24),
                    _selectorRow(
                      icon: Icons.access_time,
                      label: '預計用餐時間',
                      selector: _timeSelector(),
                    ),
                    const SizedBox(height: 24),
                    _input('我想吃…', _foodCtrl),
                    const SizedBox(height: 16),
                    _input('備註…', _noteCtrl),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),

          /* Title and Settings (on top of scroll view) */
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => context.read<NavigationService>().goPreference(),
              child: const CircleAvatar(
                backgroundColor: Colors.black12,
                child: Icon(Icons.settings, color: Colors.black),
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, _titleY(context)),
            child: const TitleText(fontSize: 30),
          ),

          /* Cast button */
          Align(
            alignment: Alignment(0, _castY(context)),
            child: _castBtn(),
          ),
        ],
      ),
    );
  }
}
