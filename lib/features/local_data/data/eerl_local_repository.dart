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
  Future<void> saveItemConfiguration({
    String? centerId,
    required String channel,
    required List<ItemModel> items,
  }) => _local.saveItemConfiguration(
    centerId: centerId,
    channel: channel,
    items: items,
  );
  Future<List<VehicleModel>> getVehicles({
    String? centerId,
    bool activeOnly = true,
  }) => _local.getVehicles(centerId: centerId, activeOnly: activeOnly);
  Future<List<VehicleTypeModel>> getVehicleTypes() => _local.getVehicleTypes();
  Future<void> saveVehicle(VehicleModel vehicle) => _local.saveVehicle(vehicle);
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
  Future<void> saveRagpicker(RagpickerModel ragpicker) =>
      _local.saveRagpicker(ragpicker);
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
    bool drafts = false,
    String? channel,
    String search = '',
  }) => _local.getAgentCollections(
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
  Future<List<CashRequestModel>> getCashRequests({bool supervisor = false}) =>
      _local.getCashRequests(supervisor: supervisor);
  Future<List<CategoryRequestModel>> getCategoryRequests({
    bool supervisor = false,
  }) => _local.getCategoryRequests(supervisor: supervisor);
  Future<List<TransferModel>> getTransfers({
    bool supervisor = false,
    String? status,
  }) => _local.getTransfers(supervisor: supervisor, status: status);
  Future<List<TransferItemModel>> getTransferItems(String id) =>
      _local.getTransferItems(id);
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
  Future<List<AgentStatusModel>> getAgentStatus() => _local.getAgentStatus();
  Future<SyncStatusModel> getSyncStatus() => _local.getSyncStatus();
  Future<List<FailedOutboxItemModel>> getFailedOutboxItems() =>
      _local.getFailedOutboxItems();
}
