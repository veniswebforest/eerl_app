import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';

class EerlLocalRepository {
  EerlLocalRepository({EerlLocalDataSource? localDataSource})
    : _local = localDataSource ?? EerlLocalDataSource();

  static final EerlLocalRepository instance = EerlLocalRepository();
  final EerlLocalDataSource _local;

  Future<String?> get currentUserId => _local.currentUserId;
  Future<String?> get activeCenterId => _local.activeCenterId;
  Future<void> selectCenter(String id) => _local.selectCenter(id);
  Future<List<MyRoleModel>> getRoles() => _local.getRoles();
  Future<List<CenterModel>> getCenters() => _local.getCenters();
  Future<ProfileModel> getProfile() => _local.getProfile();
  Future<AgentHomeSummaryModel> getAgentHomeSummary() =>
      _local.getAgentHomeSummary();
  Future<SupervisorHomeSummaryModel> getSupervisorHomeSummary() =>
      _local.getSupervisorHomeSummary();
  Future<List<CenterChannelModel>> getChannels({String? centerId}) =>
      _local.getChannels(centerId: centerId);
  Future<List<ItemModel>> getItems({
    String? centerId,
    required String channel,
    bool selectedOnly = false,
  }) => _local.getItems(
    centerId: centerId,
    channel: channel,
    selectedOnly: selectedOnly,
  );
  Future<List<ItemModel>> getCollectionMaterials({
    String? centerId,
    required String channel,
  }) => _local.getCollectionMaterials(centerId: centerId, channel: channel);
  Future<void> saveItemConfiguration({
    String? centerId,
    required String channel,
    required String tab,
    required List<ItemModel> items,
  }) => _local.saveItemConfiguration(
    centerId: centerId,
    channel: channel,
    tab: tab,
    items: items,
  );
  Future<List<VehicleModel>> getVehicles({
    String? centerId,
    bool activeOnly = true,
  }) => _local.getVehicles(centerId: centerId, activeOnly: activeOnly);
  Future<List<VehicleTypeModel>> getVehicleTypes() => _local.getVehicleTypes();
  Future<void> saveVehicle(VehicleModel vehicle, {required bool isNew}) =>
      _local.saveVehicle(vehicle, isNew: isNew);
  Future<void> setVehicleActive(VehicleModel vehicle, bool active) =>
      _local.setVehicleActive(vehicle, active);
  Future<List<MrfPersonModel>> getMrfPeople({
    String? centerId,
    String? role,
    bool activeOnly = true,
  }) => _local.getMrfPeople(
    centerId: centerId,
    role: role,
    activeOnly: activeOnly,
  );
  Future<List<RagpickerModel>> getRagpickers({
    String? centerId,
    String search = '',
    bool activeOnly = false,
  }) => _local.getRagpickers(
    centerId: centerId,
    search: search,
    activeOnly: activeOnly,
  );
  Future<void> saveRagpicker(
    RagpickerModel ragpicker, {
    String? localPhotoPath,
  }) => _local.saveRagpicker(ragpicker, localPhotoPath: localPhotoPath);
  Future<void> setRagpickerActive(RagpickerModel ragpicker, bool active) =>
      _local.setRagpickerActive(ragpicker, active);
  Future<List<ExpenseCategoryModel>> getExpenseCategories({String? centerId}) =>
      _local.getExpenseCategories(centerId: centerId);
  Future<List<CenterPersonModel>> getCenterPeople({
    String? centerId,
    bool agentsOnly = false,
  }) => _local.getCenterPeople(centerId: centerId, agentsOnly: agentsOnly);
  Future<List<DestinationModel>> getDestinations() => _local.getDestinations();
  Future<List<CollectionModel>> getAgentCollections({
    String? centerId,
    bool drafts = false,
    String? channel,
    String search = '',
  }) => _local.getAgentCollections(
    centerId: centerId,
    drafts: drafts,
    channel: channel,
    search: search,
  );
  Future<List<CollectionModel>> getVerificationCollections({
    required bool pending,
    String? channel,
    String search = '',
  }) => _local.getVerificationCollections(
    pending: pending,
    channel: channel,
    search: search,
  );
  Future<CollectionModel?> getCollection(String id) => _local.getCollection(id);
  Future<List<CollectionItemModel>> getCollectionItems(String collectionId) =>
      _local.getCollectionItems(collectionId);
  Future<void> approveCollection(String collectionId) =>
      _local.approveCollection(collectionId);
  Future<void> rejectCollection(String collectionId, String reason) =>
      _local.rejectCollection(collectionId, reason);
  Future<void> saveCollection({
    required CollectionModel collection,
    required List<CollectionItemModel> items,
    required bool submit,
  }) => _local.saveCollection(
    collection: collection,
    items: items,
    submit: submit,
  );
  Future<void> discardDraft(String id) => _local.discardDraft(id);
  Future<List<ExpenseModel>> getExpenses({
    bool supervisor = false,
    String? status,
  }) => _local.getExpenses(supervisor: supervisor, status: status);
  Future<List<String>> getExpenseReceiptSources(String expenseId) =>
      _local.getExpenseReceiptSources(expenseId);
  Future<String> saveExpense({
    required String categoryId,
    required double amount,
    required List<String> receiptPaths,
    String? note,
    String? collectionId,
  }) => _local.saveExpense(
    categoryId: categoryId,
    amount: amount,
    receiptPaths: receiptPaths,
    note: note,
    collectionId: collectionId,
  );
  Future<List<CashRequestModel>> getCashRequests({bool supervisor = false}) =>
      _local.getCashRequests(supervisor: supervisor);
  Future<String> saveCashRequest({
    required double amount,
    required String reason,
  }) => _local.saveCashRequest(amount: amount, reason: reason);
  Future<List<CategoryRequestModel>> getCategoryRequests({
    bool supervisor = false,
  }) => _local.getCategoryRequests(supervisor: supervisor);
  Future<String> saveCategoryRequest({required String name, String? reason}) =>
      _local.saveCategoryRequest(name: name, reason: reason);
  Future<List<TransferModel>> getTransfers({
    bool supervisor = false,
    String? status,
    bool allCenters = false,
  }) => _local.getTransfers(
    supervisor: supervisor,
    status: status,
    allCenters: allCenters,
  );
  Future<List<TransferVehicleModel>> getTransferVehicles() =>
      _local.getTransferVehicles();
  Future<void> approveTransfer({
    required String transferId,
    required String destinationId,
    String? transferVehicleId,
    String? vehicleNumber,
    String? transporterName,
    double? transferFee,
    DateTime? vehicleArrivalTime,
    String? note,
  }) => _local.approveTransfer(
    transferId: transferId,
    destinationId: destinationId,
    transferVehicleId: transferVehicleId,
    vehicleNumber: vehicleNumber,
    transporterName: transporterName,
    transferFee: transferFee,
    vehicleArrivalTime: vehicleArrivalTime,
    note: note,
  );
  Future<void> rejectTransfer({
    required String transferId,
    required String reason,
  }) => _local.rejectTransfer(transferId: transferId, reason: reason);
  Future<String> saveTransferRequest({
    required Map<String, double> itemQuantities,
    required double estimatedExpense,
    String? note,
  }) => _local.saveTransferRequest(
    itemQuantities: itemQuantities,
    estimatedExpense: estimatedExpense,
    note: note,
  );
  Future<TransferModel?> getTransfer(String id) => _local.getTransfer(id);
  Future<List<TransferItemModel>> getTransferItems(String id) =>
      _local.getTransferItems(id);
  Future<TransferDispatchDraftModel> getTransferDispatchDraft(String id) =>
      _local.getTransferDispatchDraft(id);
  Future<void> saveTransferDispatchDraft({
    required String transferId,
    required String vehicleNumber,
    required String driverName,
  }) => _local.saveTransferDispatchDraft(
    transferId: transferId,
    vehicleNumber: vehicleNumber,
    driverName: driverName,
  );
  Future<TransferDispatchPhotoModel> addTransferDispatchPhoto({
    required String transferId,
    required String field,
    required String localPath,
  }) => _local.addTransferDispatchPhoto(
    transferId: transferId,
    field: field,
    localPath: localPath,
  );
  Future<void> removeTransferDispatchPhoto(String photoId) =>
      _local.removeTransferDispatchPhoto(photoId);
  Future<void> submitTransferDispatch({
    required String transferId,
    required String vehicleNumber,
    required String driverName,
    required double dispatchedWeight,
    int? baleCount,
    double? piecesLoaded,
  }) => _local.submitTransferDispatch(
    transferId: transferId,
    vehicleNumber: vehicleNumber,
    driverName: driverName,
    dispatchedWeight: dispatchedWeight,
    baleCount: baleCount,
    piecesLoaded: piecesLoaded,
  );
  Future<List<TaskModel>> getTasks({
    bool supervisor = false,
    String search = '',
  }) => _local.getTasks(supervisor: supervisor, search: search);
  Future<List<RequestModel>> getRequests({
    bool supervisor = false,
    String search = '',
  }) => _local.getRequests(supervisor: supervisor, search: search);
  Future<WalletSummaryModel> getWalletSummary({String? centerId}) =>
      _local.getWalletSummary(centerId: centerId);
  Future<List<WalletEntryModel>> getWalletEntries({String? centerId}) =>
      _local.getWalletEntries(centerId: centerId);
  Future<List<DayCloseModel>> getDayCloses({String? centerId}) =>
      _local.getDayCloses(centerId: centerId);
  Future<List<NotificationModel>> getNotifications() =>
      _local.getNotifications();
  Future<void> markNotificationRead(String id) =>
      _local.markNotificationRead(id);
  Future<List<StockModel>> getStock({String? centerId, String? stage}) =>
      _local.getStock(centerId: centerId, stage: stage);
  Future<List<StockModel>> getTransferStockInHand({String? centerId}) =>
      _local.getTransferStockInHand(centerId: centerId);
  Future<List<AgentStatusModel>> getAgentStatus() => _local.getAgentStatus();
  Future<SyncStatusModel> getSyncStatus() => _local.getSyncStatus();
  Future<List<FailedOutboxItemModel>> getFailedOutboxItems() =>
      _local.getFailedOutboxItems();
  Future<void> retryFailedOutboxItem(int seq) =>
      _local.retryFailedOutboxItem(seq);
}
