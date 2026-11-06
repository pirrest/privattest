import 'package:equatable/equatable.dart';
import 'package:privat_test/core/utils/casting.dart';

class ProductReview extends Equatable {
  final int rating;
  final String comment;
  final String date;
  final String reviewerName;
  final String reviewerEmail;

  const ProductReview({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  factory ProductReview.fromMap(Map<String, dynamic> map) {
    return ProductReview(
      rating: cast<num>(map['rating'], orElse: 0).toInt(),
      comment: cast<String>(map['comment'], orElse: ''),
      date: cast<String>(map['date'], orElse: ''),
      reviewerName: cast<String>(map['reviewerName'], orElse: ''),
      reviewerEmail: cast<String>(map['reviewerEmail'], orElse: ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'comment': comment,
      'date': date,
      'reviewerName': reviewerName,
      'reviewerEmail': reviewerEmail,
    };
  }

  @override
  List<Object?> get props => [
    rating,
    comment,
    date,
    reviewerName,
    reviewerEmail,
  ];
}
