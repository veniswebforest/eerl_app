class ConfigurableMaterialItem {
  const ConfigurableMaterialItem({
    required this.id,
    required this.nameKey,
    required this.selected,
  });

  final String id;
  final String nameKey;
  final bool selected;

  ConfigurableMaterialItem copyWith({bool? selected}) =>
      ConfigurableMaterialItem(
        id: id,
        nameKey: nameKey,
        selected: selected ?? this.selected,
      );
}
