// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_app/widgets/forkcast_loading.dart';

// void main() {
//   testWidgets('ForkCastLoading animates', (tester) async {
//     await tester.pumpWidget(const MaterialApp(
//       home: Scaffold(body: ForkCastLoading()),
//     ));

//     final finder = find.text('F');
//     expect(finder, findsOneWidget);

//     final transformFinder = find.ancestor(
//       of: finder,
//       matching: find.byType(Transform),
//     );
//     final Transform initial = tester.widget(transformFinder);
//     final double startY = initial.transform.getTranslation().y;
//     await tester.pump(const Duration(milliseconds: 600));

//     final Transform after = tester.widget(transformFinder);
//     final double endY = after.transform.getTranslation().y;

//     expect(endY, isNot(equals(startY)));
//   });
// }
