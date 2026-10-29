import 'dart:typed_data';

import 'package:eerl_app/shared/widgets/app_image_preview_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens a zoomable image over a translucent black background', (
    tester,
  ) async {
    const onePixelPng = <int>[
      0x89,
      0x50,
      0x4e,
      0x47,
      0x0d,
      0x0a,
      0x1a,
      0x0a,
      0x00,
      0x00,
      0x00,
      0x0d,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1f,
      0x15,
      0xc4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0d,
      0x49,
      0x44,
      0x41,
      0x54,
      0x08,
      0xd7,
      0x63,
      0xf8,
      0xcf,
      0xc0,
      0xf0,
      0x1f,
      0x00,
      0x05,
      0x00,
      0x01,
      0xff,
      0x89,
      0x99,
      0x3d,
      0x1d,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4e,
      0x44,
      0xae,
      0x42,
      0x60,
      0x82,
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => AppImagePreviewDialog.show(
              context,
              imageProvider: MemoryImage(Uint8List.fromList(onePixelPng)),
            ),
            child: const Text('Preview'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-image-preview-dialog')), findsOneWidget);
    expect(find.byKey(const Key('app-image-preview-zoom')), findsOneWidget);
    expect(find.byKey(const Key('app-image-preview-image')), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-image-preview-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-image-preview-dialog')), findsNothing);
  });
}
