import 'package:flutter/material.dart';

enum PriceMaterialKind { pet, hdpe, pp, cardboard }

enum PriceRequestState { waiting, approved, rejected }

@immutable
class PriceMaterialUiModel {
  const PriceMaterialUiModel({
    required this.kind,
    required this.amount,
    required this.accent,
    required this.background,
    required this.iconAsset,
    required this.openIconAsset,
    this.waitingAmount,
  });

  final PriceMaterialKind kind;
  final String? amount;
  final String? waitingAmount;
  final Color accent;
  final Color background;
  final String iconAsset;
  final String openIconAsset;
}

@immutable
class PriceRequestUiModel {
  const PriceRequestUiModel({
    required this.kind,
    required this.oldRate,
    required this.newRate,
    required this.percent,
    required this.state,
  });

  final PriceMaterialKind kind;
  final String oldRate;
  final String newRate;
  final String percent;
  final PriceRequestState state;
}
