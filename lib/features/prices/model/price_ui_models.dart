import 'package:flutter/material.dart';

enum PriceMaterialKind { pet, hdpe, pp, cardboard }

enum PriceRequestState { waiting, approved, rejected }

@immutable
class PriceMaterialUiModel {
  const PriceMaterialUiModel({
    required this.kind,
    required this.itemId,
    required this.name,
    required this.categoryName,
    required this.unitCode,
    required this.rate,
    required this.source,
    required this.accent,
    required this.background,
    required this.iconAsset,
    required this.openIconAsset,
    this.waitingRate,
  });

  final PriceMaterialKind kind;
  final String itemId;
  final String name;
  final String categoryName;
  final String unitCode;
  final double? rate;
  final String source;
  final double? waitingRate;
  final Color accent;
  final Color background;
  final String iconAsset;
  final String openIconAsset;
}

@immutable
class PriceRequestContext {
  const PriceRequestContext({
    required this.itemId,
    required this.itemName,
    required this.unitCode,
    this.currentRate,
    this.fromName,
    this.fromLevel,
  });

  final String itemId;
  final String itemName;
  final String unitCode;
  final double? currentRate;
  final String? fromName;
  final String? fromLevel;
}
