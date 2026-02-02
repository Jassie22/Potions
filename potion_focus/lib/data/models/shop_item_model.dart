import 'package:isar/isar.dart';

part 'shop_item_model.g.dart';

@collection
class ShopItemModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String itemId;

  late String name;
  late String category; // bottle, liquid, effect, background, sound
  late String assetKey;
  late int essenceCost;
  late int coinCost;
  late String currencyType; // 'essence', 'coins', 'both'
  late String rarity;
  late bool purchased;
  DateTime? purchasedAt;

  ShopItemModel({
    this.itemId = '',
    this.name = '',
    this.category = '',
    this.assetKey = '',
    this.essenceCost = 0,
    this.coinCost = 0,
    this.currencyType = 'essence',
    this.rarity = 'common',
    this.purchased = false,
    this.purchasedAt,
  });

  @Index()
  String get indexedCategory => category;
}
