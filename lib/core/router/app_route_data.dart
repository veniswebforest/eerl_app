import 'dart:convert';

import 'package:eerl_app/features/collection/model/collection_entry_state.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/stock/model/stock_item.dart';
import 'package:eerl_app/features/supervisor_tasks/model/supervisor_task_detail_status.dart';
import 'package:eerl_app/features/wallet/model/cash_request_detail_status.dart';
import 'package:eerl_app/features/wallet/model/expense_claim_detail_status.dart';

/// Typed input for the dashboard route after a successful login.
class HomeRouteData {
  const HomeRouteData({
    required this.role,
    this.showInitialLoginLoader = false,
  });

  final DashboardUserRole role;
  final bool showInitialLoginLoader;
}

/// Typed input for the multi-step Add Collection route.
class AddCollectionRouteData {
  const AddCollectionRouteData({
    this.initialStep = CollectionEntryStep.items,
    this.initialType,
    this.initialSelectedItems = const <int>{},
    this.collectionId,
  });

  final CollectionEntryStep initialStep;
  final CollectionType? initialType;
  final Set<int> initialSelectedItems;
  final String? collectionId;
}

/// Values displayed after an expense is committed locally.
class ExpenseSubmittedRouteData {
  const ExpenseSubmittedRouteData({
    required this.amount,
    this.remainingBalance,
  });

  final double amount;
  final double? remainingBalance;
}

/// Serializes route extras so Flutter can restore the open screen after
/// Android terminates the process while an external camera activity is open.
class AppRouteExtraCodec extends Codec<Object?, Object?> {
  const AppRouteExtraCodec();

  @override
  Converter<Object?, Object?> get encoder => const _AppRouteExtraEncoder();

  @override
  Converter<Object?, Object?> get decoder => const _AppRouteExtraDecoder();
}

class _AppRouteExtraEncoder extends Converter<Object?, Object?> {
  const _AppRouteExtraEncoder();

  @override
  Object? convert(Object? input) => switch (input) {
    null || String() || bool() || num() => input,
    DashboardUserRole value => ['DashboardUserRole', value.name],
    HomeRouteData value => [
      'HomeRouteData',
      value.role.name,
      value.showInitialLoginLoader,
    ],
    AddCollectionRouteData value => [
      'AddCollectionRouteData',
      value.initialStep.name,
      value.initialType?.name,
      value.initialSelectedItems.toList(),
      value.collectionId,
    ],
    ExpenseSubmittedRouteData value => [
      'ExpenseSubmittedRouteData',
      value.amount,
      value.remainingBalance,
    ],
    TaskModel value => [
      'TaskModel',
      {...value.toMap(), 'center_name': value.centerName},
    ],
    RequestModel value => [
      'RequestModel',
      {
        ...value.toMap(),
        'supervisor_name': value.supervisorName,
        'overdue': value.overdue ? 1 : 0,
      },
    ],
    ExpenseModel value => [
      'ExpenseModel',
      {...value.toMap(), 'category_name': value.categoryName},
    ],
    CashRequestModel value => ['CashRequestModel', value.toMap()],
    SupervisorTaskDetailStatus value => [
      'SupervisorTaskDetailStatus',
      value.name,
    ],
    ExpenseClaimDetailStatus value => ['ExpenseClaimDetailStatus', value.name],
    CashRequestDetailStatus value => ['CashRequestDetailStatus', value.name],
    StockStage value => ['StockStage', value.name],
    _ => throw FormatException(
      'Cannot restore route extra ${input.runtimeType}',
    ),
  };
}

class _AppRouteExtraDecoder extends Converter<Object?, Object?> {
  const _AppRouteExtraDecoder();

  @override
  Object? convert(Object? input) {
    if (input == null || input is String || input is bool || input is num) {
      return input;
    }
    final values = input as List<Object?>;
    final type = values.first as String;
    return switch (type) {
      'DashboardUserRole' => DashboardUserRole.values.byName(
        values[1]! as String,
      ),
      'HomeRouteData' => HomeRouteData(
        role: DashboardUserRole.values.byName(values[1]! as String),
        showInitialLoginLoader: values[2]! as bool,
      ),
      'AddCollectionRouteData' => AddCollectionRouteData(
        initialStep: CollectionEntryStep.values.byName(values[1]! as String),
        initialType: values[2] == null
            ? null
            : CollectionType.values.byName(values[2]! as String),
        initialSelectedItems: (values[3]! as List<Object?>)
            .whereType<num>()
            .map((value) => value.toInt())
            .toSet(),
        collectionId: values[4] as String?,
      ),
      'ExpenseSubmittedRouteData' => ExpenseSubmittedRouteData(
        amount: (values[1]! as num).toDouble(),
        remainingBalance: (values[2] as num?)?.toDouble(),
      ),
      'TaskModel' => TaskModel.fromMap(_dbMap(values[1])),
      'RequestModel' => RequestModel.fromMap(_dbMap(values[1])),
      'ExpenseModel' => ExpenseModel.fromMap(_dbMap(values[1])),
      'CashRequestModel' => CashRequestModel.fromMap(_dbMap(values[1])),
      'SupervisorTaskDetailStatus' => SupervisorTaskDetailStatus.values.byName(
        values[1]! as String,
      ),
      'ExpenseClaimDetailStatus' => ExpenseClaimDetailStatus.values.byName(
        values[1]! as String,
      ),
      'CashRequestDetailStatus' => CashRequestDetailStatus.values.byName(
        values[1]! as String,
      ),
      'StockStage' => StockStage.values.byName(values[1]! as String),
      _ => throw FormatException('Unknown restored route extra $type'),
    };
  }

  static DbMap _dbMap(Object? value) =>
      Map<String, Object?>.from(value! as Map<Object?, Object?>);
}
