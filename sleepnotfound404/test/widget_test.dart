import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleepnotfound404/features/home/presentation/home_screen.dart';
import 'package:sleepnotfound404/features/chat_guidance/presentation/chat_screen.dart';

void main() {
  testWidgets('HomeScreen shows cards', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Check that HomeScreen has two ListTiles (chat + admission)
    expect(find.byType(ListTile), findsNWidgets(2));

    // Tap the chat counselor card and navigate
    await tester.tap(find.text("Career Counselor (AI Chat)"));
    await tester.pumpAndSettle();

    // ChatScreen opens
    expect(find.byType(ChatScreen), findsOneWidget);
  });

  testWidgets('ChatScreen sends message', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

    final textField = find.byType(TextField);
    final sendButton = find.byIcon(Icons.send);

    expect(textField, findsOneWidget);
    expect(sendButton, findsOneWidget);

    await tester.enterText(textField, 'Hello AI');
    await tester.tap(sendButton);

    await tester.pump(const Duration(seconds: 2)); // wait for dummy AI response

    expect(find.textContaining('AI Response for'), findsOneWidget);
  });
}
