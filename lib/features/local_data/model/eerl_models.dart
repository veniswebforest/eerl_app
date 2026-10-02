import 'dart:convert';

typedef DbMap = Map<String, Object?>;

double _double(Object? value, [double fallback = 0]) =>
    value is num ? value.toDouble() : fallback;
int _int(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;
bool _bool(Object? value) => value is bool ? value : _int(value) == 1;

List<String> _strings(Object? value) {
  if (value == null) return const [];
  if (value is List) return value.whereType<String>().toList(growable: false);
  if (value is! String || value.isEmpty) return const [];
  try {
    final decoded = jsonDecode(value);
    return decoded is List
        ? decoded.whereType<String>().toList(growable: false)
        : const [];
  } on FormatException {
    return const [];
  }
}

String _jsonStrings(List<String> value) => jsonEncode(value);

class MyRoleModel {
  const MyRoleModel({
    required this.roleKey,
    required this.roleName,
    required this.modules,
  });

  final String roleKey;
  final String roleName;
  final List<String> modules;

  factory MyRoleModel.fromMap(DbMap map) => MyRoleModel(
    roleKey: map['role_key'] as String,
    roleName: map['role_name'] as String,
    modules: _strings(map['modules']),
  );

  DbMap toMap() => {
    'role_key': roleKey,
    'role_name': roleName,
    'modules': _jsonStrings(modules),
  };
}

class MyCenterModel {
  const MyCenterModel({
    required this.centerId,
    required this.isPrimary,
    this.agentNumber,
    this.slipDate,
    required this.slipLastCount,
  });

  final String centerId;
  final bool isPrimary;
  final int? agentNumber;
  final String? slipDate;
  final int slipLastCount;

  factory MyCenterModel.fromMap(DbMap map) => MyCenterModel(
    centerId: map['center_id'] as String,
    isPrimary: _bool(map['is_primary']),
    agentNumber: (map['agent_number'] as num?)?.toInt(),
    slipDate: map['slip_date'] as String?,
    slipLastCount: _int(map['slip_last_count']),
  );

  DbMap toMap() => {
    'center_id': centerId,
    'is_primary': isPrimary ? 1 : 0,
    'agent_number': agentNumber,
    'slip_date': slipDate,
    'slip_last_count': slipLastCount,
  };
}

class CenterModel {
  const CenterModel({
    required this.id,
    required this.name,
    this.code,
    this.address,
    this.eodLockTime,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String? code;
  final String? address;
  final String? eodLockTime;
  final bool isPrimary;

  factory CenterModel.fromMap(DbMap map) => CenterModel(
    id: map['id'] as String,
    name: map['name'] as String,
    code: map['code'] as String?,
    address: map['address'] as String?,
    eodLockTime: map['eod_lock_time'] as String?,
    isPrimary: _bool(map['is_primary']),
  );

  DbMap toMap() => {
    'id': id,
    'name': name,
    'code': code,
    'address': address,
    'eod_lock_time': eodLockTime,
  };
}

class ItemModel {
  const ItemModel({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.materialType,
    this.colour,
    this.hsnCode,
    required this.unitCode,
    required this.unitName,
    this.rate,
    this.isSelected,
    this.sortOrder,
  });

  final String id;
  final String name;
  final String categoryName;
  final String materialType;
  final String? colour;
  final String? hsnCode;
  final String unitCode;
  final String unitName;
  final double? rate;
  final bool? isSelected;
  final int? sortOrder;

  factory ItemModel.fromMap(DbMap map) => ItemModel(
    id: map['id'] as String,
    name: map['name'] as String,
    categoryName: map['category_name'] as String,
    materialType: map['material_type'] as String,
    colour: map['colour'] as String?,
    hsnCode: map['hsn_code'] as String?,
    unitCode: map['unit_code'] as String,
    unitName: map['unit_name'] as String,
    rate: (map['rate'] as num?)?.toDouble(),
    isSelected: map.containsKey('is_selected')
        ? _bool(map['is_selected'])
        : null,
    sortOrder: (map['sort_order'] as num?)?.toInt(),
  );

  DbMap toMap() => {
    'id': id,
    'name': name,
    'category_name': categoryName,
    'material_type': materialType,
    'colour': colour,
    'hsn_code': hsnCode,
    'unit_code': unitCode,
    'unit_name': unitName,
  };
}

class CenterChannelModel {
  const CenterChannelModel({
    required this.centerId,
    required this.channel,
    required this.showPrice,
    required this.takesPayment,
  });

  final String centerId;
  final String channel;
  final bool showPrice;
  final bool takesPayment;

  factory CenterChannelModel.fromMap(DbMap map) => CenterChannelModel(
    centerId: map['center_id'] as String,
    channel: map['channel'] as String,
    showPrice: _bool(map['show_price']),
    takesPayment: _bool(map['takes_payment']),
  );

  DbMap toMap() => {
    'center_id': centerId,
    'channel': channel,
    'show_price': showPrice ? 1 : 0,
    'takes_payment': takesPayment ? 1 : 0,
  };
}

class CenterItemModel {
  const CenterItemModel({
    required this.centerId,
    required this.channel,
    required this.itemId,
    required this.isSelected,
    required this.sortOrder,
    this.rate,
    required this.syncState,
  });

  final String centerId;
  final String channel;
  final String itemId;
  final bool isSelected;
  final int sortOrder;
  final double? rate;
  final String syncState;

  factory CenterItemModel.fromMap(DbMap map) => CenterItemModel(
    centerId: map['center_id'] as String,
    channel: map['channel'] as String,
    itemId: map['item_id'] as String,
    isSelected: _bool(map['is_selected']),
    sortOrder: _int(map['sort_order']),
    rate: (map['rate'] as num?)?.toDouble(),
    syncState: map['sync_state'] as String,
  );

  DbMap toMap() => {
    'center_id': centerId,
    'channel': channel,
    'item_id': itemId,
    'is_selected': isSelected ? 1 : 0,
    'sort_order': sortOrder,
    'rate': rate,
    'sync_state': syncState,
  };
}

class VehicleTypeModel {
  const VehicleTypeModel({required this.id, required this.name});
  final String id;
  final String name;
  factory VehicleTypeModel.fromMap(DbMap map) =>
      VehicleTypeModel(id: map['id'] as String, name: map['name'] as String);
  DbMap toMap() => {'id': id, 'name': name};
}

class VehicleModel {
  const VehicleModel({
    required this.id,
    this.centerId,
    required this.plateNumber,
    required this.typeId,
    required this.typeName,
    this.capacityKg,
    this.driverName,
    required this.isActive,
    required this.syncState,
  });
  final String id;
  final String? centerId;
  final String plateNumber;
  final String typeId;
  final String typeName;
  final double? capacityKg;
  final String? driverName;
  final bool isActive;
  final String syncState;
  factory VehicleModel.fromMap(DbMap map) => VehicleModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String?,
    plateNumber: map['plate_number'] as String,
    typeId: map['type_id'] as String,
    typeName: map['type_name'] as String,
    capacityKg: (map['capacity_kg'] as num?)?.toDouble(),
    driverName: map['driver_name'] as String?,
    isActive: _bool(map['is_active']),
    syncState: map['sync_state'] as String,
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'plate_number': plateNumber,
    'type_id': typeId,
    'type_name': typeName,
    'capacity_kg': capacityKg,
    'driver_name': driverName,
    'is_active': isActive ? 1 : 0,
    'sync_state': syncState,
  };
}

class MrfPersonModel {
  const MrfPersonModel({
    required this.id,
    required this.centerId,
    required this.name,
    this.phone,
    this.idNumber,
    this.photoUrl,
    required this.isActive,
    required this.role,
    required this.syncState,
  });
  final String id;
  final String centerId;
  final String name;
  final String? phone;
  final String? idNumber;
  final String? photoUrl;
  final bool isActive;
  final String role;
  final String syncState;
  factory MrfPersonModel.fromMap(DbMap map) => MrfPersonModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String,
    name: map['name'] as String,
    phone: map['phone'] as String?,
    idNumber: map['id_number'] as String?,
    photoUrl: map['photo_url'] as String?,
    isActive: _bool(map['is_active']),
    role: map['role'] as String,
    syncState: map['sync_state'] as String,
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'name': name,
    'phone': phone,
    'id_number': idNumber,
    'photo_url': photoUrl,
    'is_active': isActive ? 1 : 0,
    'role': role,
    'sync_state': syncState,
  };
}

class RagpickerModel {
  const RagpickerModel({
    required this.id,
    required this.centerId,
    required this.name,
    this.phone,
    this.idNumber,
    this.photoUrl,
    required this.isActive,
    required this.syncState,
  });
  final String id;
  final String centerId;
  final String name;
  final String? phone;
  final String? idNumber;
  final String? photoUrl;
  final bool isActive;
  final String syncState;
  factory RagpickerModel.fromMap(DbMap map) => RagpickerModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String,
    name: map['name'] as String,
    phone: map['phone'] as String?,
    idNumber: map['id_number'] as String?,
    photoUrl: map['photo_url'] as String?,
    isActive: _bool(map['is_active']),
    syncState: map['sync_state'] as String,
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'name': name,
    'phone': phone,
    'id_number': idNumber,
    'photo_url': photoUrl,
    'is_active': isActive ? 1 : 0,
    'sync_state': syncState,
  };
}

class ExpenseCategoryModel {
  const ExpenseCategoryModel({
    required this.id,
    required this.centerId,
    required this.name,
    required this.isActive,
  });
  final String id;
  final String centerId;
  final String name;
  final bool isActive;
  factory ExpenseCategoryModel.fromMap(DbMap map) => ExpenseCategoryModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String,
    name: map['name'] as String,
    isActive: _bool(map['is_active']),
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'name': name,
    'is_active': isActive ? 1 : 0,
  };
}

class CenterPersonModel {
  const CenterPersonModel({
    required this.userId,
    required this.centerId,
    required this.name,
    required this.phone,
    required this.isAgent,
  });
  final String userId;
  final String centerId;
  final String name;
  final String phone;
  final bool isAgent;
  factory CenterPersonModel.fromMap(DbMap map) => CenterPersonModel(
    userId: map['user_id'] as String,
    centerId: map['center_id'] as String,
    name: map['name'] as String,
    phone: map['phone'] as String,
    isAgent: _bool(map['is_agent']),
  );
  DbMap toMap() => {
    'user_id': userId,
    'center_id': centerId,
    'name': name,
    'phone': phone,
    'is_agent': isAgent ? 1 : 0,
  };
}

class DestinationModel {
  const DestinationModel({required this.id, required this.name});
  final String id;
  final String name;
  factory DestinationModel.fromMap(DbMap map) =>
      DestinationModel(id: map['id'] as String, name: map['name'] as String);
  DbMap toMap() => {'id': id, 'name': name};
}

class CollectionModel {
  const CollectionModel({
    required this.id,
    required this.centerId,
    required this.agentId,
    required this.agentName,
    required this.channel,
    required this.status,
    this.slipNumber,
    this.collectedAt,
    this.vehicleId,
    this.mrfPersonId,
    this.ragpickerId,
    this.givenByName,
    this.handedOverBy,
    this.paidBy,
    this.takesPayment,
    this.totalAmount,
    required this.handoverPhotoUrls,
    this.rejectionReason,
    this.verifiedByName,
    this.verifiedAt,
    required this.updatedAt,
    required this.syncState,
    this.totalQty = 0,
    this.itemCount = 0,
    this.centerName,
  });
  final String id;
  final String centerId;
  final String agentId;
  final String agentName;
  final String channel;
  final String status;
  final String? slipNumber;
  final String? collectedAt;
  final String? vehicleId;
  final String? mrfPersonId;
  final String? ragpickerId;
  final String? givenByName;
  final String? handedOverBy;
  final String? paidBy;
  final bool? takesPayment;
  final double? totalAmount;
  final List<String> handoverPhotoUrls;
  final String? rejectionReason;
  final String? verifiedByName;
  final String? verifiedAt;
  final String updatedAt;
  final String syncState;
  final double totalQty;
  final int itemCount;
  final String? centerName;
  factory CollectionModel.fromMap(DbMap map) => CollectionModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String,
    agentId: map['agent_id'] as String,
    agentName: map['agent_name'] as String,
    channel: map['channel'] as String,
    status: map['status'] as String,
    slipNumber: map['slip_number'] as String?,
    collectedAt: map['collected_at'] as String?,
    vehicleId: map['vehicle_id'] as String?,
    mrfPersonId: map['mrf_person_id'] as String?,
    ragpickerId: map['ragpicker_id'] as String?,
    givenByName: map['given_by_name'] as String?,
    handedOverBy: map['handed_over_by'] as String?,
    paidBy: map['paid_by'] as String?,
    takesPayment: map['takes_payment'] == null
        ? null
        : _bool(map['takes_payment']),
    totalAmount: (map['total_amount'] as num?)?.toDouble(),
    handoverPhotoUrls: _strings(map['handover_photo_urls']),
    rejectionReason: map['rejection_reason'] as String?,
    verifiedByName: map['verified_by_name'] as String?,
    verifiedAt: map['verified_at'] as String?,
    updatedAt: map['updated_at'] as String,
    syncState: map['sync_state'] as String,
    totalQty: _double(map['total_qty']),
    itemCount: _int(map['item_count']),
    centerName: map['center_name'] as String?,
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'agent_id': agentId,
    'agent_name': agentName,
    'channel': channel,
    'status': status,
    'slip_number': slipNumber,
    'collected_at': collectedAt,
    'vehicle_id': vehicleId,
    'mrf_person_id': mrfPersonId,
    'ragpicker_id': ragpickerId,
    'given_by_name': givenByName,
    'handed_over_by': handedOverBy,
    'paid_by': paidBy,
    'takes_payment': takesPayment == null ? null : (takesPayment! ? 1 : 0),
    'total_amount': totalAmount,
    'handover_photo_urls': _jsonStrings(handoverPhotoUrls),
    'rejection_reason': rejectionReason,
    'verified_by_name': verifiedByName,
    'verified_at': verifiedAt,
    'updated_at': updatedAt,
    'sync_state': syncState,
  };
}

class CollectionItemModel {
  const CollectionItemModel({
    required this.id,
    required this.collectionId,
    required this.itemId,
    required this.qty,
    this.verifiedQty,
    this.rate,
    this.amount,
    required this.photoUrls,
    required this.sortOrder,
    this.name,
    this.unitCode,
    this.unitName,
  });
  final String id;
  final String collectionId;
  final String itemId;
  final double qty;
  final double? verifiedQty;
  final double? rate;
  final double? amount;
  final List<String> photoUrls;
  final int sortOrder;
  final String? name;
  final String? unitCode;
  final String? unitName;
  factory CollectionItemModel.fromMap(DbMap map) => CollectionItemModel(
    id: map['id'] as String,
    collectionId: map['collection_id'] as String,
    itemId: map['item_id'] as String,
    qty: _double(map['qty']),
    verifiedQty: (map['verified_qty'] as num?)?.toDouble(),
    rate: (map['rate'] as num?)?.toDouble(),
    amount: (map['amount'] as num?)?.toDouble(),
    photoUrls: _strings(map['photo_urls']),
    sortOrder: _int(map['sort_order']),
    name: map['name'] as String?,
    unitCode: map['unit_code'] as String?,
    unitName: map['unit_name'] as String?,
  );
  DbMap toMap() => {
    'id': id,
    'collection_id': collectionId,
    'item_id': itemId,
    'qty': qty,
    'verified_qty': verifiedQty,
    'rate': rate,
    'amount': amount,
    'photo_urls': _jsonStrings(photoUrls),
    'sort_order': sortOrder,
  };
}

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.centerId,
    required this.userId,
    this.userName,
    required this.categoryId,
    required this.amount,
    this.note,
    required this.status,
    this.number,
    required this.receiptPhotoUrls,
    this.decidedByName,
    this.decisionReason,
    required this.createdAt,
    this.updatedAt,
    required this.syncState,
    this.categoryName,
  });
  final String id;
  final String centerId;
  final String userId;
  final String? userName;
  final String categoryId;
  final double amount;
  final String? note;
  final String status;
  final String? number;
  final List<String> receiptPhotoUrls;
  final String? decidedByName;
  final String? decisionReason;
  final String createdAt;
  final String? updatedAt;
  final String syncState;
  final String? categoryName;
  factory ExpenseModel.fromMap(DbMap map) => ExpenseModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String,
    userId: map['user_id'] as String,
    userName: map['user_name'] as String?,
    categoryId: map['category_id'] as String,
    amount: _double(map['amount']),
    note: map['note'] as String?,
    status: map['status'] as String,
    number: map['number'] as String?,
    receiptPhotoUrls: _strings(map['receipt_photo_urls']),
    decidedByName: map['decided_by_name'] as String?,
    decisionReason: map['decision_reason'] as String?,
    createdAt: map['created_at'] as String,
    updatedAt: map['updated_at'] as String?,
    syncState: map['sync_state'] as String,
    categoryName: map['category_name'] as String?,
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'user_id': userId,
    'user_name': userName,
    'category_id': categoryId,
    'amount': amount,
    'note': note,
    'status': status,
    'number': number,
    'receipt_photo_urls': _jsonStrings(receiptPhotoUrls),
    'decided_by_name': decidedByName,
    'decision_reason': decisionReason,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'sync_state': syncState,
  };
}

class CashRequestModel {
  const CashRequestModel({
    required this.id,
    required this.centerId,
    required this.requestedBy,
    this.requestedByName,
    required this.amount,
    this.reason,
    required this.status,
    this.decidedByName,
    this.decisionNote,
    required this.createdAt,
    this.updatedAt,
    required this.syncState,
  });
  final String id;
  final String centerId;
  final String requestedBy;
  final String? requestedByName;
  final double amount;
  final String? reason;
  final String status;
  final String? decidedByName;
  final String? decisionNote;
  final String createdAt;
  final String? updatedAt;
  final String syncState;
  factory CashRequestModel.fromMap(DbMap map) => CashRequestModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String,
    requestedBy: map['requested_by'] as String,
    requestedByName: map['requested_by_name'] as String?,
    amount: _double(map['amount']),
    reason: map['reason'] as String?,
    status: map['status'] as String,
    decidedByName: map['decided_by_name'] as String?,
    decisionNote: map['decision_note'] as String?,
    createdAt: map['created_at'] as String,
    updatedAt: map['updated_at'] as String?,
    syncState: map['sync_state'] as String,
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'requested_by': requestedBy,
    'requested_by_name': requestedByName,
    'amount': amount,
    'reason': reason,
    'status': status,
    'decided_by_name': decidedByName,
    'decision_note': decisionNote,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'sync_state': syncState,
  };
}

class CategoryRequestModel {
  const CategoryRequestModel({
    required this.id,
    required this.centerId,
    required this.requestedBy,
    required this.name,
    this.reason,
    required this.status,
    required this.createdAt,
    required this.syncState,
  });
  final String id;
  final String centerId;
  final String requestedBy;
  final String name;
  final String? reason;
  final String status;
  final String createdAt;
  final String syncState;
  factory CategoryRequestModel.fromMap(DbMap map) => CategoryRequestModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String,
    requestedBy: map['requested_by'] as String,
    name: map['name'] as String,
    reason: map['reason'] as String?,
    status: map['status'] as String,
    createdAt: map['created_at'] as String,
    syncState: map['sync_state'] as String,
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'requested_by': requestedBy,
    'name': name,
    'reason': reason,
    'status': status,
    'created_at': createdAt,
    'sync_state': syncState,
  };
}

class TransferModel {
  const TransferModel({
    required this.id,
    required this.centerId,
    required this.type,
    required this.status,
    this.number,
    this.destinationId,
    this.destinationName,
    this.truckExpectedAt,
    this.fixedQty,
    this.estimatedExpense,
    this.vehiclePlate,
    required this.requestedBy,
    required this.requestedByName,
    required this.requestedAt,
    this.decidedByName,
    this.approvedAt,
    this.rejectionReason,
    this.handedOverAt,
    required this.photoUrls,
    this.updatedAt,
    required this.syncState,
    this.lines = 0,
  });
  final String id;
  final String centerId;
  final String type;
  final String status;
  final String? number;
  final String? destinationId;
  final String? destinationName;
  final String? truckExpectedAt;
  final double? fixedQty;
  final double? estimatedExpense;
  final String? vehiclePlate;
  final String requestedBy;
  final String requestedByName;
  final String requestedAt;
  final String? decidedByName;
  final String? approvedAt;
  final String? rejectionReason;
  final String? handedOverAt;
  final List<String> photoUrls;
  final String? updatedAt;
  final String syncState;
  final int lines;
  factory TransferModel.fromMap(DbMap map) => TransferModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String,
    type: map['type'] as String,
    status: map['status'] as String,
    number: map['number'] as String?,
    destinationId: map['destination_id'] as String?,
    destinationName: map['destination_name'] as String?,
    truckExpectedAt: map['truck_expected_at'] as String?,
    fixedQty: (map['fixed_qty'] as num?)?.toDouble(),
    estimatedExpense: (map['estimated_expense'] as num?)?.toDouble(),
    vehiclePlate: map['vehicle_plate'] as String?,
    requestedBy: map['requested_by'] as String,
    requestedByName: map['requested_by_name'] as String,
    requestedAt: map['requested_at'] as String,
    decidedByName: map['decided_by_name'] as String?,
    approvedAt: map['approved_at'] as String?,
    rejectionReason: map['rejection_reason'] as String?,
    handedOverAt: map['handed_over_at'] as String?,
    photoUrls: _strings(map['photo_urls']),
    updatedAt: map['updated_at'] as String?,
    syncState: map['sync_state'] as String,
    lines: _int(map['lines']),
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'type': type,
    'status': status,
    'number': number,
    'destination_id': destinationId,
    'destination_name': destinationName,
    'truck_expected_at': truckExpectedAt,
    'fixed_qty': fixedQty,
    'estimated_expense': estimatedExpense,
    'vehicle_plate': vehiclePlate,
    'requested_by': requestedBy,
    'requested_by_name': requestedByName,
    'requested_at': requestedAt,
    'decided_by_name': decidedByName,
    'approved_at': approvedAt,
    'rejection_reason': rejectionReason,
    'handed_over_at': handedOverAt,
    'photo_urls': _jsonStrings(photoUrls),
    'updated_at': updatedAt,
    'sync_state': syncState,
  };
}

class TransferItemModel {
  const TransferItemModel({
    required this.id,
    required this.transferId,
    required this.itemId,
    required this.qty,
    this.dispatchedQty,
    this.name,
    this.unitCode,
  });
  final String id;
  final String transferId;
  final String itemId;
  final double qty;
  final double? dispatchedQty;
  final String? name;
  final String? unitCode;
  factory TransferItemModel.fromMap(DbMap map) => TransferItemModel(
    id: map['id'] as String,
    transferId: map['transfer_id'] as String,
    itemId: map['item_id'] as String,
    qty: _double(map['qty']),
    dispatchedQty: (map['dispatched_qty'] as num?)?.toDouble(),
    name: map['name'] as String?,
    unitCode: map['unit_code'] as String?,
  );
  DbMap toMap() => {
    'id': id,
    'transfer_id': transferId,
    'item_id': itemId,
    'qty': qty,
    'dispatched_qty': dispatchedQty,
  };
}

class TaskModel {
  const TaskModel({
    required this.id,
    this.centerId,
    required this.assignedTo,
    this.assignedToName,
    required this.assignedBy,
    this.assignedByName,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.dueAt,
    this.completedAt,
    required this.photoUrls,
    required this.createdAt,
    required this.syncState,
  });
  final String id;
  final String? centerId;
  final String assignedTo;
  final String? assignedToName;
  final String assignedBy;
  final String? assignedByName;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final String? dueAt;
  final String? completedAt;
  final List<String> photoUrls;
  final String createdAt;
  final String syncState;
  factory TaskModel.fromMap(DbMap map) => TaskModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String?,
    assignedTo: map['assigned_to'] as String,
    assignedToName: map['assigned_to_name'] as String?,
    assignedBy: map['assigned_by'] as String,
    assignedByName: map['assigned_by_name'] as String?,
    title: map['title'] as String,
    description: map['description'] as String?,
    priority: map['priority'] as String,
    status: map['status'] as String,
    dueAt: map['due_at'] as String?,
    completedAt: map['completed_at'] as String?,
    photoUrls: _strings(map['photo_urls']),
    createdAt: map['created_at'] as String,
    syncState: map['sync_state'] as String,
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'assigned_to': assignedTo,
    'assigned_to_name': assignedToName,
    'assigned_by': assignedBy,
    'assigned_by_name': assignedByName,
    'title': title,
    'description': description,
    'priority': priority,
    'status': status,
    'due_at': dueAt,
    'completed_at': completedAt,
    'photo_urls': _jsonStrings(photoUrls),
    'created_at': createdAt,
    'sync_state': syncState,
  };
}

class RequestModel {
  const RequestModel({
    required this.id,
    this.centerId,
    required this.createdBy,
    this.createdByName,
    required this.body,
    required this.priority,
    required this.status,
    this.answer,
    this.answeredAt,
    required this.photoUrls,
    required this.createdAt,
    required this.syncState,
  });
  final String id;
  final String? centerId;
  final String createdBy;
  final String? createdByName;
  final String body;
  final String priority;
  final String status;
  final String? answer;
  final String? answeredAt;
  final List<String> photoUrls;
  final String createdAt;
  final String syncState;
  factory RequestModel.fromMap(DbMap map) => RequestModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String?,
    createdBy: map['created_by'] as String,
    createdByName: map['created_by_name'] as String?,
    body: map['body'] as String,
    priority: map['priority'] as String,
    status: map['status'] as String,
    answer: map['answer'] as String?,
    answeredAt: map['answered_at'] as String?,
    photoUrls: _strings(map['photo_urls']),
    createdAt: map['created_at'] as String,
    syncState: map['sync_state'] as String,
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'created_by': createdBy,
    'created_by_name': createdByName,
    'body': body,
    'priority': priority,
    'status': status,
    'answer': answer,
    'answered_at': answeredAt,
    'photo_urls': _jsonStrings(photoUrls),
    'created_at': createdAt,
    'sync_state': syncState,
  };
}

class WalletEntryModel {
  const WalletEntryModel({
    required this.id,
    required this.centerId,
    required this.kind,
    required this.amount,
    this.note,
    this.collectionId,
    this.expenseId,
    this.confirmedAt,
    required this.createdAt,
    required this.syncState,
  });
  final String id;
  final String centerId;
  final String kind;
  final double amount;
  final String? note;
  final String? collectionId;
  final String? expenseId;
  final String? confirmedAt;
  final String createdAt;
  final String syncState;
  factory WalletEntryModel.fromMap(DbMap map) => WalletEntryModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String,
    kind: map['kind'] as String,
    amount: _double(map['amount']),
    note: map['note'] as String?,
    collectionId: map['collection_id'] as String?,
    expenseId: map['expense_id'] as String?,
    confirmedAt: map['confirmed_at'] as String?,
    createdAt: map['created_at'] as String,
    syncState: map['sync_state'] as String,
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'kind': kind,
    'amount': amount,
    'note': note,
    'collection_id': collectionId,
    'expense_id': expenseId,
    'confirmed_at': confirmedAt,
    'created_at': createdAt,
    'sync_state': syncState,
  };
}

class DayCloseModel {
  const DayCloseModel({
    required this.id,
    required this.centerId,
    required this.date,
    this.closedByName,
    required this.closedAt,
  });
  final String id;
  final String centerId;
  final String date;
  final String? closedByName;
  final String closedAt;
  factory DayCloseModel.fromMap(DbMap map) => DayCloseModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String,
    date: map['date'] as String,
    closedByName: map['closed_by_name'] as String?,
    closedAt: map['closed_at'] as String,
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'date': date,
    'closed_by_name': closedByName,
    'closed_at': closedAt,
  };
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.deepLink,
    required this.createdAt,
    this.readAt,
    required this.syncState,
  });
  final String id;
  final String type;
  final String title;
  final String? body;
  final String? deepLink;
  final String createdAt;
  final String? readAt;
  final String syncState;
  factory NotificationModel.fromMap(DbMap map) => NotificationModel(
    id: map['id'] as String,
    type: map['type'] as String,
    title: map['title'] as String,
    body: map['body'] as String?,
    deepLink: map['deep_link'] as String?,
    createdAt: map['created_at'] as String,
    readAt: map['read_at'] as String?,
    syncState: map['sync_state'] as String,
  );
  DbMap toMap() => {
    'id': id,
    'type': type,
    'title': title,
    'body': body,
    'deep_link': deepLink,
    'created_at': createdAt,
    'read_at': readAt,
    'sync_state': syncState,
  };
}

class CenterBalanceModel {
  const CenterBalanceModel({
    required this.centerId,
    required this.balance,
    this.updatedAt,
  });
  final String centerId;
  final double balance;
  final String? updatedAt;
  factory CenterBalanceModel.fromMap(DbMap map) => CenterBalanceModel(
    centerId: map['center_id'] as String,
    balance: _double(map['balance']),
    updatedAt: map['updated_at'] as String?,
  );
  DbMap toMap() => {
    'center_id': centerId,
    'balance': balance,
    'updated_at': updatedAt,
  };
}

class StockModel {
  const StockModel({
    required this.id,
    required this.centerId,
    required this.itemId,
    required this.stage,
    required this.qty,
    this.name,
    this.unitCode,
    this.centerName,
  });
  final String id;
  final String centerId;
  final String itemId;
  final String stage;
  final double qty;
  final String? name;
  final String? unitCode;
  final String? centerName;
  factory StockModel.fromMap(DbMap map) => StockModel(
    id: map['id'] as String,
    centerId: map['center_id'] as String,
    itemId: map['item_id'] as String,
    stage: map['stage'] as String,
    qty: _double(map['qty']),
    name: map['name'] as String?,
    unitCode: map['unit_code'] as String?,
    centerName: map['center_name'] as String?,
  );
  DbMap toMap() => {
    'id': id,
    'center_id': centerId,
    'item_id': itemId,
    'stage': stage,
    'qty': qty,
  };
}

class AgentHomeSummaryModel {
  const AgentHomeSummaryModel({
    required this.collections,
    required this.kg,
    required this.tasks,
    required this.drafts,
    required this.toFix,
  });
  final int collections;
  final double kg;
  final int tasks;
  final int drafts;
  final int toFix;
  factory AgentHomeSummaryModel.fromMap(DbMap map) => AgentHomeSummaryModel(
    collections: _int(map['collections']),
    kg: _double(map['kg']),
    tasks: _int(map['tasks']),
    drafts: _int(map['drafts']),
    toFix: _int(map['to_fix']),
  );
}

class SupervisorHomeSummaryModel {
  const SupervisorHomeSummaryModel({
    required this.collections,
    required this.kg,
    required this.pendingVerification,
    required this.openTasks,
  });
  final int collections;
  final double kg;
  final int pendingVerification;
  final int openTasks;
  factory SupervisorHomeSummaryModel.fromMap(DbMap map) =>
      SupervisorHomeSummaryModel(
        collections: _int(map['collections']),
        kg: _double(map['kg']),
        pendingVerification: _int(map['pending_verification']),
        openTasks: _int(map['open_tasks']),
      );
}

class WalletSummaryModel {
  const WalletSummaryModel({
    required this.balanceNow,
    required this.cashIn,
    required this.paidOut,
    required this.spent,
  });
  final double balanceNow;
  final double cashIn;
  final double paidOut;
  final double spent;
  factory WalletSummaryModel.fromMap(DbMap map) => WalletSummaryModel(
    balanceNow: _double(map['balance_now']),
    cashIn: _double(map['cash_in']),
    paidOut: _double(map['paid_out']),
    spent: _double(map['spent']),
  );
}

class AgentStatusModel {
  const AgentStatusModel({
    required this.userId,
    required this.name,
    required this.phone,
    required this.centerName,
    required this.collectionsToday,
    this.lastCollectionAt,
    required this.waitingReview,
  });
  final String userId;
  final String name;
  final String phone;
  final String centerName;
  final int collectionsToday;
  final String? lastCollectionAt;
  final int waitingReview;
  factory AgentStatusModel.fromMap(DbMap map) => AgentStatusModel(
    userId: map['user_id'] as String,
    name: map['name'] as String,
    phone: map['phone'] as String,
    centerName: map['center_name'] as String,
    collectionsToday: _int(map['collections_today']),
    lastCollectionAt: map['last_collection_at'] as String?,
    waitingReview: _int(map['waiting_review']),
  );
}

class ProfileModel {
  const ProfileModel({
    this.userName,
    this.userPhone,
    this.userPhotoUrl,
    this.supervisorName,
    this.supervisorPhone,
    this.sessionExpiresAt,
  });
  final String? userName;
  final String? userPhone;
  final String? userPhotoUrl;
  final String? supervisorName;
  final String? supervisorPhone;
  final String? sessionExpiresAt;
}

class SyncStatusModel {
  const SyncStatusModel({
    this.lastBootstrapAt,
    required this.queuedCount,
    required this.sendingCount,
    required this.failedCount,
    required this.waitingPhotoCount,
  });
  final String? lastBootstrapAt;
  final int queuedCount;
  final int sendingCount;
  final int failedCount;
  final int waitingPhotoCount;
  factory SyncStatusModel.fromMap(DbMap map) => SyncStatusModel(
    lastBootstrapAt: map['last_bootstrap_at'] as String?,
    queuedCount: _int(map['queued_count']),
    sendingCount: _int(map['sending_count']),
    failedCount: _int(map['failed_count']),
    waitingPhotoCount: _int(map['waiting_photo_count']),
  );
}

class FailedOutboxItemModel {
  const FailedOutboxItemModel({
    required this.seq,
    required this.method,
    required this.path,
    required this.entity,
    required this.entityId,
    required this.attempts,
    this.lastError,
  });
  final int seq;
  final String method;
  final String path;
  final String entity;
  final String entityId;
  final int attempts;
  final String? lastError;
  factory FailedOutboxItemModel.fromMap(DbMap map) => FailedOutboxItemModel(
    seq: _int(map['seq']),
    method: map['method'] as String,
    path: map['path'] as String,
    entity: map['entity'] as String,
    entityId: map['entity_id'] as String,
    attempts: _int(map['attempts']),
    lastError: map['last_error'] as String?,
  );
}
