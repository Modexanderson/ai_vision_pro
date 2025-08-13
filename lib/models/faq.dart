// models/faq.dart

class FAQ {
  final String question;
  final String answer;
  final String? category;
  final int? order;
  final bool isExpanded;

  FAQ(
    this.question,
    this.answer, {
    this.category,
    this.order,
    this.isExpanded = false,
  });

  FAQ copyWith({
    String? question,
    String? answer,
    String? category,
    int? order,
    bool? isExpanded,
  }) {
    return FAQ(
      question ?? this.question,
      answer ?? this.answer,
      category: category ?? this.category,
      order: order ?? this.order,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'category': category,
      'order': order,
      'isExpanded': isExpanded,
    };
  }

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      json['question'],
      json['answer'],
      category: json['category'],
      order: json['order'],
      isExpanded: json['isExpanded'] ?? false,
    );
  }

  // Common FAQ categories
  static const String categoryGeneral = 'General';
  static const String categoryBilling = 'Billing';
  static const String categoryTechnical = 'Technical';
  static const String categoryPrivacy = 'Privacy';
  static const String categorySupport = 'Support';

  // Helper method to get category color
  String get categoryDisplayName {
    switch (category?.toLowerCase()) {
      case 'general':
        return 'General';
      case 'billing':
        return 'Billing & Payment';
      case 'technical':
        return 'Technical';
      case 'privacy':
        return 'Privacy & Security';
      case 'support':
        return 'Support';
      default:
        return category ?? 'General';
    }
  }

  // Helper method to check if FAQ matches search query
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;

    final queryLower = query.toLowerCase();
    return question.toLowerCase().contains(queryLower) ||
        answer.toLowerCase().contains(queryLower) ||
        (category?.toLowerCase().contains(queryLower) ?? false);
  }

  @override
  String toString() {
    return 'FAQ(question: $question, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FAQ &&
        other.question == question &&
        other.answer == answer &&
        other.category == category;
  }

  @override
  int get hashCode {
    return Object.hash(question, answer, category);
  }
}
