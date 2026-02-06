/// Pixel-art bottle shapes inspired by Minecraft potions.
///
/// Each bottle is a 2D grid where each cell represents a pixel:
///   0 = empty (transparent)
///   1 = body (glass area, fills with liquid)
///   2 = neck (liquid overflow at high fill)
///   3 = cork/stopper
///   4 = glass highlight pixel
///   5 = decoration/detail pixel
class BottleShapes {
  BottleShapes._();

  /// Select the correct pixel bottle by its string ID.
  static PixelBottle getPixelBottle(String shapeId) {
    switch (shapeId) {
      case 'bottle_tall':
        return tall();
      case 'bottle_flask':
        return flask();
      case 'bottle_potion':
        return potion();
      case 'bottle_heart':
        return heart();
      case 'bottle_diamond':
        return diamond();
      case 'bottle_gourd':
        return gourd();
      case 'bottle_legendary':
        return legendary();
      case 'bottle_celestial':
        return celestial();
      case 'bottle_starforged':
        return starforged();
      case 'bottle_round':
      default:
        return round();
    }
  }

  /// 1. Classic Minecraft Potion Bottle — the iconic round shape.
  /// Thin 2px neck, round bulbous body, flat base.
  static PixelBottle round() {
    // 9w x 13h — compact like actual MC potion sprite
    final grid = <List<int>>[
      //0  1  2  3  4  5  6  7  8
      [0, 0, 0, 3, 3, 3, 0, 0, 0], // 0  cork
      [0, 0, 0, 5, 5, 5, 0, 0, 0], // 1  lip
      [0, 0, 0, 2, 2, 2, 0, 0, 0], // 2  neck
      [0, 0, 0, 2, 2, 2, 0, 0, 0], // 3  neck
      [0, 0, 1, 1, 1, 1, 1, 0, 0], // 4  shoulder
      [0, 1, 1, 4, 1, 1, 1, 1, 0], // 5  body
      [1, 1, 4, 4, 1, 1, 1, 1, 1], // 6  body widest
      [1, 1, 4, 1, 1, 1, 1, 1, 1], // 7  body
      [1, 1, 1, 1, 1, 1, 1, 1, 1], // 8  body
      [1, 1, 1, 1, 1, 1, 1, 1, 1], // 9  body
      [0, 1, 1, 1, 1, 1, 1, 1, 0], // 10 body
      [0, 0, 1, 1, 1, 1, 1, 0, 0], // 11 base
      [0, 0, 5, 5, 5, 5, 5, 0, 0], // 12 foot
    ];
    return PixelBottle(grid: grid, gridWidth: 9, gridHeight: 13);
  }

  /// 2. Tall Vial — narrow elongated test tube.
  static PixelBottle tall() {
    // 7w x 15h
    final grid = <List<int>>[
      //0  1  2  3  4  5  6
      [0, 0, 3, 3, 3, 0, 0], // 0  cork
      [0, 0, 5, 5, 5, 0, 0], // 1  lip
      [0, 0, 2, 2, 2, 0, 0], // 2  neck
      [0, 0, 2, 2, 2, 0, 0], // 3  neck
      [0, 1, 1, 1, 1, 1, 0], // 4  body top
      [0, 1, 4, 1, 1, 1, 0], // 5  body
      [0, 1, 4, 1, 1, 1, 0], // 6  body
      [0, 1, 4, 1, 1, 1, 0], // 7  body
      [0, 1, 1, 1, 1, 1, 0], // 8  body
      [0, 1, 1, 1, 1, 1, 0], // 9  body
      [0, 1, 1, 1, 1, 1, 0], // 10 body
      [0, 1, 1, 1, 1, 1, 0], // 11 body
      [0, 1, 1, 1, 1, 1, 0], // 12 body
      [0, 1, 1, 1, 1, 1, 0], // 13 body bottom
      [0, 5, 5, 5, 5, 5, 0], // 14 base
    ];
    return PixelBottle(grid: grid, gridWidth: 7, gridHeight: 15);
  }

  /// 3. Erlenmeyer Flask — wide triangular base, narrow neck.
  static PixelBottle flask() {
    // 11w x 13h
    final grid = <List<int>>[
      //0  1  2  3  4  5  6  7  8  9 10
      [0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0], // 0  cork
      [0, 0, 0, 0, 5, 5, 5, 0, 0, 0, 0], // 1  lip
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 2  neck
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 3  neck
      [0, 0, 0, 1, 1, 4, 1, 1, 0, 0, 0], // 4  upper
      [0, 0, 1, 1, 4, 4, 1, 1, 1, 0, 0], // 5  widening
      [0, 1, 1, 4, 1, 1, 1, 1, 1, 1, 0], // 6  widening
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], // 7  body
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], // 8  body widest
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], // 9  body
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], // 10 body
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], // 11 body bottom
      [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5], // 12 base
    ];
    return PixelBottle(grid: grid, gridWidth: 11, gridHeight: 13);
  }

  /// 4. Splash Potion — bulbous belly, thin neck (MC splash potion style).
  static PixelBottle potion() {
    // 11w x 13h
    final grid = <List<int>>[
      //0  1  2  3  4  5  6  7  8  9 10
      [0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0], // 0  cork
      [0, 0, 0, 5, 5, 5, 5, 5, 0, 0, 0], // 1  wide lip
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 2  neck
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 3  neck
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0], // 4  shoulder
      [0, 1, 1, 4, 1, 1, 1, 1, 1, 1, 0], // 5  body
      [1, 1, 4, 4, 1, 1, 1, 1, 1, 1, 1], // 6  body widest
      [1, 1, 4, 1, 1, 1, 1, 1, 1, 1, 1], // 7  body
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], // 8  body
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], // 9  body
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0], // 10 narrowing
      [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0], // 11 base
      [0, 0, 5, 5, 5, 5, 5, 5, 5, 0, 0], // 12 pedestal
    ];
    return PixelBottle(grid: grid, gridWidth: 11, gridHeight: 13);
  }

  /// 5. Heart Vial — pixel heart shape.
  static PixelBottle heart() {
    // 11w x 14h
    final grid = <List<int>>[
      //0  1  2  3  4  5  6  7  8  9 10
      [0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0], // 0  cork
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 1  neck
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 2  neck
      [0, 0, 5, 5, 5, 5, 5, 5, 5, 0, 0], // 3  ribbon
      [0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0], // 4  heart top
      [1, 1, 4, 1, 1, 1, 1, 1, 1, 1, 1], // 5  heart wide
      [1, 1, 4, 1, 1, 1, 1, 1, 1, 1, 1], // 6  heart wide
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], // 7  heart
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], // 8  narrowing
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0], // 9  narrowing
      [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0], // 10 narrowing
      [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0], // 11 narrowing
      [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0], // 12 heart tip
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // 13
    ];
    return PixelBottle(grid: grid, gridWidth: 11, gridHeight: 14);
  }

  /// 6. Diamond Flask — diamond/rhombus pixel shape.
  static PixelBottle diamond() {
    // 11w x 14h
    final grid = <List<int>>[
      //0  1  2  3  4  5  6  7  8  9 10
      [0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0], // 0  cork
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 1  neck
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 2  neck
      [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0], // 3  diamond top
      [0, 0, 0, 1, 1, 4, 1, 1, 0, 0, 0], // 4
      [0, 0, 1, 1, 4, 4, 1, 1, 1, 0, 0], // 5
      [0, 1, 1, 4, 1, 1, 1, 1, 1, 1, 0], // 6
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], // 7  widest
      [0, 1, 1, 1, 1, 5, 5, 1, 1, 1, 0], // 8  facet line
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0], // 9
      [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0], // 10
      [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0], // 11 diamond tip
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // 12
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // 13
    ];
    return PixelBottle(grid: grid, gridWidth: 11, gridHeight: 14);
  }

  /// 7. Gourd — two stacked pixel bulbs with narrow waist.
  static PixelBottle gourd() {
    // 9w x 15h
    final grid = <List<int>>[
      //0  1  2  3  4  5  6  7  8
      [0, 0, 0, 3, 3, 3, 0, 0, 0], // 0  cork
      [0, 0, 0, 5, 5, 5, 0, 0, 0], // 1  lip
      [0, 0, 0, 2, 2, 2, 0, 0, 0], // 2  neck
      [0, 0, 1, 1, 1, 1, 1, 0, 0], // 3  upper bulb
      [0, 1, 1, 4, 1, 1, 1, 1, 0], // 4  upper bulb
      [0, 1, 1, 4, 1, 1, 1, 1, 0], // 5  upper bulb
      [0, 0, 1, 1, 1, 1, 1, 0, 0], // 6  waist narrow
      [0, 0, 0, 1, 1, 1, 0, 0, 0], // 7  waist
      [0, 0, 1, 1, 1, 1, 1, 0, 0], // 8  lower expand
      [0, 1, 1, 1, 1, 1, 1, 1, 0], // 9  lower bulb
      [1, 1, 1, 1, 1, 1, 1, 1, 1], // 10 lower widest
      [1, 1, 1, 1, 1, 1, 1, 1, 1], // 11 lower bulb
      [0, 1, 1, 1, 1, 1, 1, 1, 0], // 12 narrowing
      [0, 0, 1, 1, 1, 1, 1, 0, 0], // 13 base
      [0, 0, 5, 5, 5, 5, 5, 0, 0], // 14 foot
    ];
    return PixelBottle(grid: grid, gridWidth: 9, gridHeight: 15);
  }

  /// 8. Legendary — ornate bottle with pixel crown stopper.
  static PixelBottle legendary() {
    // 11w x 15h
    final grid = <List<int>>[
      //0  1  2  3  4  5  6  7  8  9 10
      [0, 0, 3, 0, 3, 0, 3, 0, 3, 0, 0], // 0  crown points
      [0, 0, 3, 3, 3, 3, 3, 3, 3, 0, 0], // 1  crown base
      [0, 0, 0, 5, 5, 5, 5, 5, 0, 0, 0], // 2  lip
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 3  neck
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 4  neck
      [0, 0, 5, 5, 5, 5, 5, 5, 5, 0, 0], // 5  shoulder band
      [0, 1, 1, 4, 1, 1, 1, 1, 1, 1, 0], // 6  body
      [1, 1, 4, 4, 1, 1, 1, 1, 1, 1, 1], // 7  body widest
      [1, 1, 4, 1, 1, 5, 5, 1, 1, 1, 1], // 8  body + center gem
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], // 9  body
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], // 10 body
      [0, 0, 5, 5, 5, 5, 5, 5, 5, 0, 0], // 11 base band
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0], // 12 base
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], // 13 base flare
      [0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0], // 14 pedestal
    ];
    return PixelBottle(grid: grid, gridWidth: 11, gridHeight: 15);
  }

  /// 9. Celestial Vessel — elegant star-themed bottle (subscriber exclusive).
  static PixelBottle celestial() {
    // 11w x 15h
    final grid = <List<int>>[
      //0  1  2  3  4  5  6  7  8  9 10
      [0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0], // 0  star points
      [0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0], // 1  star center
      [0, 0, 0, 0, 5, 5, 5, 0, 0, 0, 0], // 2  lip
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 3  neck
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 4  neck
      [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0], // 5  shoulder
      [0, 0, 1, 1, 4, 1, 1, 1, 1, 0, 0], // 6  body
      [0, 1, 1, 4, 4, 1, 1, 5, 1, 1, 0], // 7  body + star accent
      [0, 1, 1, 4, 1, 1, 1, 1, 1, 1, 0], // 8  body
      [0, 1, 1, 1, 1, 5, 1, 1, 1, 1, 0], // 9  body + accent
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0], // 10 narrowing
      [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0], // 11 narrowing
      [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0], // 12 base
      [0, 0, 5, 5, 5, 5, 5, 5, 5, 0, 0], // 13 decorative band
      [0, 0, 0, 5, 5, 5, 5, 5, 0, 0, 0], // 14 foot
    ];
    return PixelBottle(grid: grid, gridWidth: 11, gridHeight: 15);
  }

  /// 10. Starforged Vial — angular cosmic flask (subscriber exclusive).
  static PixelBottle starforged() {
    // 11w x 15h
    final grid = <List<int>>[
      //0  1  2  3  4  5  6  7  8  9 10
      [0, 0, 3, 3, 0, 3, 0, 3, 3, 0, 0], // 0  angular crown
      [0, 0, 0, 3, 3, 3, 3, 3, 0, 0, 0], // 1  crown base
      [0, 0, 0, 5, 5, 5, 5, 5, 0, 0, 0], // 2  band
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 3  neck
      [0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0], // 4  neck
      [0, 0, 5, 1, 1, 1, 1, 1, 5, 0, 0], // 5  angular shoulder
      [0, 1, 1, 4, 1, 5, 1, 1, 1, 1, 0], // 6  body + gem
      [1, 1, 4, 4, 1, 1, 1, 1, 1, 1, 1], // 7  widest
      [1, 1, 4, 1, 1, 1, 1, 1, 5, 1, 1], // 8  body + accent
      [1, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1], // 9  body + gem
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], // 10 body
      [0, 0, 5, 5, 5, 5, 5, 5, 5, 0, 0], // 11 mid band
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0], // 12 lower body
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], // 13 flared base
      [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5], // 14 ornate pedestal
    ];
    return PixelBottle(grid: grid, gridWidth: 11, gridHeight: 15);
  }
}

/// Holds the pixel grid data for a bottle shape.
class PixelBottle {
  /// 2D grid of cell types (0=empty, 1=body, 2=neck, 3=cork, 4=highlight, 5=decoration).
  final List<List<int>> grid;
  final int gridWidth;
  final int gridHeight;

  const PixelBottle({
    required this.grid,
    required this.gridWidth,
    required this.gridHeight,
  });
}
