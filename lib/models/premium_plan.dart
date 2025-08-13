// models/premium_plan.dart

class PremiumPlan {
  final String id;
  final String title;
  final String description;
  final double price;
  final String period;
  final bool isPopular;
  final List<String> features;
  final int? discountPercent;

  PremiumPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.period,
    this.isPopular = false,
    required this.features,
    this.discountPercent,
  });
}
