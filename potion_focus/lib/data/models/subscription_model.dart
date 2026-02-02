import 'package:isar/isar.dart';

part 'subscription_model.g.dart';

@collection
class SubscriptionModel {
  Id id = Isar.autoIncrement;

  late String tier; // 'none', 'basic', 'premium'
  DateTime? expiresAt;
  late String features; // JSON list of feature keys
  DateTime? purchasedAt;

  SubscriptionModel({
    this.tier = 'none',
    this.expiresAt,
    this.features = '[]',
    this.purchasedAt,
  });

  bool get isActive {
    if (tier == 'none') return false;
    if (expiresAt == null) return false;
    return expiresAt!.isAfter(DateTime.now());
  }
}
