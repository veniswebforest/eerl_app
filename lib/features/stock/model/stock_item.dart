enum StockStage {
  rawMaterial,
  sortedRawMaterial,
  workInProgress,
  finishedGoods,
}

class StockMaterialItem {
  const StockMaterialItem({
    required this.name,
    required this.weight,
    required this.bin,
    required this.image,
    required this.updated,
  });

  final String name;
  final String weight;
  final String bin;
  final String image;
  final String updated;
}
