String formatCollectionQuantity({
  required double kilograms,
  required double pieces,
  double fallbackKilograms = 0,
}) {
  final effectiveKg = kilograms > 0
      ? kilograms
      : (pieces == 0 ? fallbackKilograms : 0.0);
  final hasKg = effectiveKg > 0;
  final hasPieces = pieces > 0;
  final kgText = '${effectiveKg.toStringAsFixed(2)}kg';
  final piecesText = pieces % 1 == 0
      ? '${pieces.toInt()}pcs'
      : '${pieces.toStringAsFixed(2)}pcs';

  if (hasKg && hasPieces) return '$kgText / $piecesText';
  if (hasPieces) return piecesText;
  if (hasKg) return kgText;
  return '0.00kg';
}
