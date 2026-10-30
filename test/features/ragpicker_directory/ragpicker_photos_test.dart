import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eerl_app/features/ragpicker_directory/widgets/ragpicker_photo_section.dart';
import 'package:eerl_app/features/ragpicker_directory/widgets/ragpicker_details_cards.dart';

void main() {
  group('RagpickerPhotoSection', () {
    testWidgets('renders capture box and helper when empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RagpickerPhotoSection(
              label: 'ID Proof Photo',
              captureLabel: 'Capture Photo',
              helperText: 'Capture up to 2 photos (Front & Back)',
              photoSources: const [],
              onCapture: () {},
              onRemove: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('ID Proof Photo'), findsOneWidget);
      expect(find.text('Capture Photo'), findsOneWidget);
      expect(
        find.text('Capture up to 2 photos (Front & Back)'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('ragpicker-photo-0')), findsNothing);
    });

    testWidgets('renders 1 photo tile and capture box when 1 photo present', (
      tester,
    ) async {
      var captureCalled = false;
      int? removedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RagpickerPhotoSection(
              label: 'ID Proof Photo',
              captureLabel: 'Capture Photo',
              helperText: 'Capture up to 2 photos (Front & Back)',
              photoSources: const ['https://example.com/photo1.jpg'],
              onCapture: () => captureCalled = true,
              onRemove: (index) => removedIndex = index,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey('ragpicker-photo-0')), findsOneWidget);
      expect(find.text('Capture Photo'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('ragpicker-photo-remove-0')));
      expect(removedIndex, 0);

      await tester.tap(find.text('Capture Photo'));
      expect(captureCalled, true);
    });

    testWidgets('renders 2 photo tiles and disables capture box when 2 photos present', (
      tester,
    ) async {
      var captureCalled = false;
      int? removedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RagpickerPhotoSection(
              label: 'ID Proof Photo',
              captureLabel: 'Capture Photo',
              helperText: 'Capture up to 2 photos (Front & Back)',
              photoSources: const [
                'https://example.com/photo1.jpg',
                'https://example.com/photo2.jpg',
              ],
              onCapture: () => captureCalled = true,
              onRemove: (index) => removedIndex = index,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey('ragpicker-photo-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('ragpicker-photo-1')), findsOneWidget);

      // Tapping capture when 2 photos are present should be disabled
      await tester.tap(find.byKey(const Key('ragpicker-photo-capture')));
      expect(captureCalled, false);

      await tester.tap(find.byKey(const ValueKey('ragpicker-photo-remove-1')));
      expect(removedIndex, 1);
    });
  });

  group('RagpickerProofCard', () {
    testWidgets('displays placeholder dash when no photos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RagpickerProofCard(
              title: 'Proof of Identity',
              photoUrl: null,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Proof of Identity'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('displays multiple photos from JSON string photoUrl', (tester) async {
      final jsonPhotos = jsonEncode([
        'https://example.com/front.jpg',
        'https://example.com/back.jpg',
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RagpickerProofCard(
              title: 'Proof of Identity',
              photoUrl: jsonPhotos,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Proof of Identity'), findsOneWidget);
      expect(find.text('—'), findsNothing);
    });

    testWidgets('displays multiple photos from photoUrls list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RagpickerProofCard(
              title: 'Proof of Identity',
              photoUrls: [
                'https://example.com/front.jpg',
                'https://example.com/back.jpg',
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Proof of Identity'), findsOneWidget);
      expect(find.text('—'), findsNothing);
    });
  });
}
