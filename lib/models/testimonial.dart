// models/testimonial.dart

class Testimonial {
  final String name;
  final String role;
  final String message;
  final int rating;
  final String avatar;
  final DateTime? date;

  Testimonial({
    required this.name,
    required this.role,
    required this.message,
    required this.rating,
    required this.avatar,
    this.date,
  });

  Testimonial copyWith({
    String? name,
    String? role,
    String? message,
    int? rating,
    String? avatar,
    DateTime? date,
  }) {
    return Testimonial(
      name: name ?? this.name,
      role: role ?? this.role,
      message: message ?? this.message,
      rating: rating ?? this.rating,
      avatar: avatar ?? this.avatar,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'message': message,
      'rating': rating,
      'avatar': avatar,
      'date': date?.toIso8601String(),
    };
  }

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      name: json['name'],
      role: json['role'],
      message: json['message'],
      rating: json['rating'],
      avatar: json['avatar'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  bool get hasValidRating => rating >= 1 && rating <= 5;

  String get displayDate {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date!);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays > 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Recently';
    }
  }

  @override
  String toString() {
    return 'Testimonial(name: $name, role: $role, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Testimonial &&
        other.name == name &&
        other.role == role &&
        other.message == message &&
        other.rating == rating &&
        other.avatar == avatar;
  }

  @override
  int get hashCode {
    return Object.hash(name, role, message, rating, avatar);
  }
}
