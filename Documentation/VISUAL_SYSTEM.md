# Visual System

All visuals in Potion Focus are **procedural** -- drawn with Flutter's `CustomPaint` API. No image assets are used for bottles, effects, or backgrounds.

---

## VisualConfig JSON Spec

Every potion stores its appearance as a JSON string in `PotionModel.visualConfig`.

```json
{
  "bottle": "bottle_round",
  "liquid": "liquid_0",
  "effect": "none",
  "rarity": "common"
}
```

| Key | Type | Description |
|-----|------|-------------|
| `bottle` | String | Bottle shape ID (see catalog below) |
| `liquid` | String | Liquid color ID (`liquid_0` through `liquid_9`, or `muddy_brown`) |
| `effect` | String | Effect overlay ID (see effects below) |
| `rarity` | String | Rarity tier: `common`, `uncommon`, `rare`, `epic`, `legendary`, `muddy` |

Parsed by `VisualConfig.fromJson(jsonString)` in `lib/core/models/visual_config.dart`.

---

## Bottle Catalog

8 bottle shapes, each defined as a `Path` in `lib/presentation/shared/painting/bottle_shapes.dart`.

| ID | Name | Description | Default For | Availability |
|----|------|-------------|-------------|--------------|
| `bottle_round` | Round Flask | Classic round-bottom with short neck | Common | Free (default) |
| `bottle_tall` | Tall Vial | Narrow test-tube style | Uncommon | Free |
| `bottle_flask` | Erlenmeyer | Wide base, tapered neck | Rare | Essence |
| `bottle_potion` | Classic Potion | Bulbous body, thin neck, wide lip | Epic | Essence |
| `bottle_heart` | Heart Vial | Heart-shaped body (cubic bezier) | -- | Coins |
| `bottle_diamond` | Diamond Flask | Angular diamond shape (4 points) | -- | Coins |
| `bottle_gourd` | Gourd | Double-bubble shape (two circles) | -- | Coins |
| `bottle_legendary` | Ornate Bottle | Decorative flared base with crown stopper | Legendary | Coins |

### Bottle Path Structure (`BottlePaths`)

Each shape generates:
- `body` -- interior path used for liquid clipping
- `outline` -- full outline including neck/stopper
- `neckRect` -- rectangle connecting cork to body
- `corkRect` -- cork bounding box
- `customCork` -- optional custom cork path (legendary has a crown)

---

## Liquid Colors

10 liquid colors indexed 0--9, defined in `AppColors.potionLiquids`:

| Index | Hex | Color |
|-------|-----|-------|
| 0 | `#8B4789` | Purple |
| 1 | `#4A7BA7` | Blue |
| 2 | `#45B69C` | Teal |
| 3 | `#73A24E` | Green |
| 4 | `#E07A5F` | Coral |
| 5 | `#D4A574` | Gold |
| 6 | `#C76B98` | Pink |
| 7 | `#6A5ACD` | Slate Blue |
| 8 | `#8FBC8F` | Sea Green |
| 9 | `#BC8F8F` | Rosy Brown |

Special: `muddy_brown` (`#8B7355`) for cancelled sessions.

---

## Effects

Defined in `lib/presentation/shared/painting/effect_painter.dart`. Each effect is driven by a repeating 3-second `AnimationController`.

| ID | Name | Rarity | Description |
|----|------|--------|-------------|
| `none` | None | Common | No overlay |
| `effect_glow` | Gentle Glow | Uncommon | Pulsing radial glow around bottle center |
| `effect_sparkles` | Sparkles | Rare | 8 twinkling dots at fixed positions (seed 42) |
| `effect_smoke` | Smoke | Epic | 4 rising, waving wisps above the bottle |
| `effect_legendary_glow` | Legendary Aura | Legendary | Intense golden glow + 6 rotating sparkles in elliptical ring |

---

## PotionRenderer Widget

`PotionRenderer` in `lib/presentation/shared/painting/potion_renderer.dart` is the main widget that composes all layers.

**Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `config` | `VisualConfig` | required | Bottle shape, liquid, effect, rarity |
| `size` | `double` | 150 | Widget dimensions |
| `fillPercent` | `double` | 1.0 | Liquid level (0.0 = empty, 1.0 = full) |
| `isBrewing` | `bool` | false | Show rising bubbles |
| `showGlow` | `bool` | true | Show rarity glow shadow |

**Rendering stack (bottom to top):**
1. Rarity glow shadow (pulsing, colored by rarity)
2. Bottle glass + liquid fill (`BottlePainter`)
3. Brewing bubbles (6 bubbles in 3 columns, only during brewing)
4. Effect overlay (`EffectPainter`, only when fillPercent > 0.3)

### Liquid Fill Behavior

- `fillPercent` drives liquid height inside the bottle body path
- Liquid is clipped to the body path (fills naturally regardless of shape)
- Gradient: darker at bottom, lighter at top
- When `fillPercent > 0.85`, liquid also fills the neck area
- During brewing: 6 semi-transparent bubbles rise through the liquid

---

## Background Themes

6 themes defined in `lib/presentation/shared/painting/background_themes.dart`.

| ID | Name | Description | Availability |
|----|------|-------------|--------------|
| `theme_default` | Dark Gradient | Deep blue gradient (`#1A1A2E` to `#0F3460`) | Free |
| `theme_parchment` | Parchment | Warm beige with 80 subtle texture dots | Free |
| `theme_forest` | Enchanted Forest | Green gradient with 12 leaf silhouettes | Coins |
| `theme_night_sky` | Night Sky | Deep blue radial gradient with 40 twinkling stars | Coins |
| `theme_alchemy_lab` | Alchemy Lab | Warm amber with bottom glow and shelf silhouette | Coins |
| `theme_ocean_depths` | Ocean Depths | Teal gradient with 15 animated rising bubbles | Coins |

---

## Rarity Colors

| Rarity | Hex | Color |
|--------|-----|-------|
| Common | `#9E9E9E` | Gray |
| Uncommon | `#4CAF50` | Green |
| Rare | `#2196F3` | Blue |
| Epic | `#9C27B0` | Purple |
| Legendary | `#FF9800` | Orange/Gold |

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/core/models/visual_config.dart` | VisualConfig data class, JSON parsing |
| `lib/presentation/shared/painting/bottle_shapes.dart` | 8 bottle Path generators |
| `lib/presentation/shared/painting/bottle_painter.dart` | Glass, liquid, cork rendering |
| `lib/presentation/shared/painting/effect_painter.dart` | Rarity-based animated overlays |
| `lib/presentation/shared/painting/potion_renderer.dart` | Main composition widget |
| `lib/presentation/shared/painting/background_themes.dart` | 6 background painters |
| `lib/core/theme/app_colors.dart` | Liquid colors, rarity colors |
