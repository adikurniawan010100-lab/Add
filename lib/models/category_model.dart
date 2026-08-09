class CategoryModel {
  final int? id;
  final String name;
  final String icon;
  final int colorValue;

  CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] as int?,
    name: json['name'] as String,
    icon: json['icon'] as String,
    colorValue: json['colorValue'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'colorValue': colorValue,
  };
}
