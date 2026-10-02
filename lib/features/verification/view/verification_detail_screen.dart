import 'package:flutter/material.dart';

import 'package:eerl_app/features/records/view/collection_detail_screen.dart';

/// Supervisor detail uses the same SQLite-backed collection graph as Records.
/// Verification actions can update that graph without creating a second UI
/// model or consuming a Bootstrap response directly.
class VerificationDetailScreen extends StatelessWidget {
  const VerificationDetailScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context) =>
      CollectionDetailScreen(collectionId: collectionId);
}
