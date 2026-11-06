import 'package:equatable/equatable.dart';
import 'package:privat_test/core/utils/casting.dart';

class ProductDimensions extends Equatable {
  final double width;
  final double height;
  final double depth;

  const ProductDimensions({
    required this.width,
    required this.height,
    required this.depth,
  });

  factory ProductDimensions.fromMap(Map<String, dynamic> map) {
    return ProductDimensions(
      width: cast<num>(map['width'], orElse: 0).toDouble(),
      height: cast<num>(map['height'], orElse: 0).toDouble(),
      depth: cast<num>(map['depth'], orElse: 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'width': width, 'height': height, 'depth': depth};
  }

  @override
  List<Object?> get props => [width, height, depth];
}
