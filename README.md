# liquid_tab_bar

A floating glass tab bar for Flutter. It supports a moving selection lens,
search, action buttons, badges, and a compact shape while scrolling.

Package version in this repository: `2.0.0`

[![pub package](https://img.shields.io/pub/v/liquid_tab_bar.svg)](https://pub.dev/packages/liquid_tab_bar)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## iOS simulator preview

The current Basic example on an iPhone 17 Pro Max simulator:

<img src="doc/images/ios_simulator_basic.png" alt="Current LiquidTabBar Basic example running in the iOS simulator" width="360" />

---

## Features

- **Animated selection**: Tap or drag across tabs; the glass lens follows and
  settles on the selected tab.
- **Glass with fallbacks**: Uses shader glass where supported, backdrop blur
  elsewhere, and an opaque mode when needed.
- **Search and actions**: Add an expandable search field or a separate action
  button beside the tabs.
- **Icons and badges**: Use Flutter icons or your own widgets, plus unread
  dots, counts, or text badges.
- **Scroll folding**: The bar can shrink to a small pill while you scroll and
  expand again when you return.
- **Accessibility**: Supports screen readers, right-to-left layouts, and
  reduced motion settings.

---

## Installation

For a published `2.0.0` release, add this to your app's `pubspec.yaml`:

```yaml
dependencies:
  liquid_tab_bar: ^2.0.0
```

To try this repository before that version is published, use a local path
instead. Adjust the path to where you cloned this repository:

```yaml
dependencies:
  liquid_tab_bar:
    path: ../liquid_tab_bar
```

Then run `flutter pub get`. Import the package in your Dart file:

```dart
import 'package:liquid_tab_bar/liquid_tab_bar.dart';
```

The glass shaders are bundled with the package. Your app does not need to
declare them as assets.

> [!NOTE]
> SVG support is optional. If you use SVG icons, add an SVG package such as
> `flutter_svg` to your app. Standard Flutter icons work without it.

## Quick Start

This complete `lib/main.dart` example shows three tabs and a scrollable page:

```dart
import 'package:flutter/material.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlass.load();
  runApp(const DemoApp());
}

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const tabLabels = ['Home', 'Explore', 'Profile'];
    return MaterialApp(
      home: LiquidTabBarScaffold(
        appBar: AppBar(title: const Text('Liquid Tab Bar')),
        body: ListView.builder(
          itemCount: 30,
          itemBuilder: (context, index) => ListTile(
            title: Text('${tabLabels[selectedIndex]} item ${index + 1}'),
          ),
        ),
        tabBar: LiquidTabBar(
          selectedIndex: selectedIndex,
          onSelected: (index) => setState(() => selectedIndex = index),
          items: const [
            LiquidTabItem.icon(label: 'Home', icon: Icons.home_outlined),
            LiquidTabItem.icon(label: 'Explore', icon: Icons.explore_outlined),
            LiquidTabItem.icon(label: 'Profile', icon: Icons.person_outline),
          ],
        ),
      ),
    );
  }
}
```

Save the file and run `flutter run`.

`selectedIndex` tells the bar which tab is active. `onSelected` updates your
app state when the user chooses a tab. Replace the sample `ListView` with your
own content. `LiquidTabBarScaffold` lets the page draw behind the floating bar,
adds bottom space so the last list item stays visible, and handles scroll
folding. `LiquidGlass.load()` prepares the shader; the bar falls back to blur
when shader glass is unavailable.

---

## Custom Icons

`LiquidTabBar` supports both standard Material/Cupertino `IconData` and arbitrary custom Flutter `Widget`s (such as SVGs, raster images, custom painters, and animated widgets).

### Standard Icons (`IconData`)

For standard glyphs, use the compile-time `const` constructor `LiquidTabItem.icon`:

```dart
const LiquidTabItem.icon(
  label: 'Home',
  icon: Icons.home_outlined,
  activeIcon: Icons.home_rounded,
)
```

`LiquidTabItem.icon` remains the default, first-class workflow for standard icons.

### Custom Widget Icons

Use `LiquidTabItem.custom` to render custom widgets, such as vector icons via `flutter_svg`, raster artwork via `Image.asset`, or custom painters:

```dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';

LiquidTabItem.custom(
  label: 'Explore',
  icon: SvgPicture.asset(
    'assets/icons/explore.svg',
  ),
)
```

> [!NOTE]
> `liquid_tab_bar` does **not** depend on or bundle `flutter_svg` or any specific image library. The package receives a standard Flutter `Widget`; the host application owns its asset packages and widget construction.

Arbitrary Flutter widgets are fully supported:

```dart
LiquidTabItem.custom(
  label: 'Photos',
  icon: Image.asset('assets/photos.png'),
)
```

### Custom Active Icons

Supply `activeIcon` to specify an alternate widget when the tab becomes selected:

```dart
LiquidTabItem.custom(
  label: 'Profile',
  icon: SvgPicture.asset('assets/icons/profile_outline.svg'),
  activeIcon: SvgPicture.asset('assets/icons/profile_filled.svg'),
)
```

Custom active icons follow the exact same selection threshold (`coverage >= 0.5`) and animated spring transitions as standard `IconData` items.

### Theme Color Tinting (`useThemeColor`)

By default, `useThemeColor: true` is enabled. For custom widgets, this dynamically tints the artwork using the bar's resolved theme colors:

```text
inactiveColor
   ↓ (spring droplet interpolation)
activeColor
```

```dart
LiquidTabItem.custom(
  label: 'Favorite',
  icon: SvgPicture.asset('assets/icons/heart.svg'),
  useThemeColor: true, // Default: tints with activeColor/inactiveColor
)
```

### Preserving Multi-Color Artwork

When `useThemeColor: true`, custom artwork is tinted uniformly via `BlendMode.srcIn`. For multi-color logos, badges, or brand artwork, set `useThemeColor: false` to preserve the original colors in both selected and unselected states:

```dart
LiquidTabItem.custom(
  label: 'Brand',
  icon: SvgPicture.asset('assets/icons/brand_multicolor.svg'),
  useThemeColor: false, // Preserves original multi-color artwork
)
```

> [!TIP]
> - **`useThemeColor: true`**: Recommended for monochrome vector icons that should follow your bar's active and inactive theme colors.
> - **`useThemeColor: false`**: Recommended for multi-color logos, user avatars, or artwork whose distinct color regions must remain intact.
> 
> Even with `useThemeColor: false`, the tab item still fully participates in layout, droplet movement, fold transitions, badges, and optical refraction.

### Custom Icon Sizing

Control glyph layout size with `iconSize:` (defaults to `23.0`):

```dart
LiquidTabItem.custom(
  label: 'Explore',
  icon: SvgPicture.asset('assets/icons/explore.svg'),
  iconSize: 20.0,
)
```

Tab items center the glyph within the bar's standard icon slot (`24.0`), with `FittedBox` containing and scaling artwork cleanly within the logical slot bounds without overflowing tab layout.

### Mixed Tab Bar Example

You can seamlessly combine standard icons, custom SVG tabs, and custom search actions in a single bar:

```dart
LiquidTabBar(
  selectedIndex: selectedIndex,
  onSelected: (index) => setState(() => selectedIndex = index),
  items: [
    const LiquidTabItem.icon(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    LiquidTabItem.custom(
      label: 'Explore',
      icon: SvgPicture.asset('assets/icons/explore.svg'),
    ),
    LiquidTabItem.custom(
      label: 'Profile',
      icon: SvgPicture.asset('assets/icons/profile_outline.svg'),
      activeIcon: SvgPicture.asset('assets/icons/profile_filled.svg'),
    ),
  ],
  separateAction: LiquidTabAction.search(
    customIcon: SvgPicture.asset('assets/icons/search.svg'),
  ),
)
```

*(This example assumes your host application has imported its chosen SVG renderer, such as `flutter_svg`.)*

### Keyboard Behavior

By default, the bar moves above the onscreen keyboard. Set
`liftAboveKeyboard: false` to keep it at the bottom while ordinary text fields
are focused. Also set the host `Scaffold`'s `resizeToAvoidBottomInset: false`
so the keyboard can cover the bar. The built-in search action still moves the
bar above the keyboard while searching.

```dart
Scaffold(
  resizeToAvoidBottomInset: false,
  bottomNavigationBar: LiquidTabBar(
    liftAboveKeyboard: false,
    // ...
  ),
)
```

---

## Styling & Optics

Customize outer materials, brand accents, and droplet fills using `LiquidTabBarTheme`. When omitted, styling automatically adapts to ambient light/dark brightness:

```dart
LiquidTabBar(
  theme: LiquidTabBarTheme.adaptive(context).copyWith(
    activeColor: const Color(0xFF007AFF),
  ),
  // ...
)
```

The default light and dark themes use a translucent capsule, neutral gray
selection, and a soft reflective rim. Motion-only droplet refraction bends the
icons and labels underneath the moving lens; its RGB dispersion creates fine
color fringes at high contrast edges. The blur fallback keeps the same surface
palette and selection styling, while high-contrast mode uses the opaque tier.

`const LiquidTabBarTheme()` follows the ambient light/dark brightness, including
when only some style fields are supplied. Use
`const LiquidTabBarTheme(brightness: Brightness.light)` to pin light styling or
`const LiquidTabBarTheme.dark()` to pin dark styling. `adaptive(context)` also
uses your app's primary color for the selected icon and label.

### Material Tiers

`LiquidTabBar` supports three rendering tiers, selectable via `material:`:

| Tier | Description |
|:---|:---|
| **`auto`** *(default)* | Uses `glass` when Impeller is active and performance is smooth; falls back to `blur` on legacy renderers or when the frame governor detects slow frames. |
| **`glass`** | GPU fragment shader with Snell's-law refraction, specular rim caustics, and backdrop sampling (requires Impeller). |
| **`blur`** | Cross-platform frosted glass with dual-pass backdrop filtering and rim highlights. |
| **`opaque`** | High-contrast solid-fill capsule for accessibility or power saving. |

### Presets

#### Glossy capsule

`LiquidBarStyle.glossy()` follows the ambient light/dark brightness. Passing
`brightness:` pins a specific glossy palette.

Opt into a brighter neutral bevel, luminous tint, and clearer backdrop colors:

```dart
theme: LiquidTabBarTheme(barStyle: LiquidBarStyle.glossy()),
```

The preset styles the bar and separate action buttons with matching light/dark
palettes and a blur fallback. Light Glossy has brighter white reflections and
less frost; Dark Glossy keeps its translucent charcoal finish.
Try **Glossy** in the **Styling & Refraction** demo.

#### Refraction presets

```dart
DropletRefractionStyle.none()
DropletRefractionStyle.subtle()
DropletRefractionStyle.medium() // default
DropletRefractionStyle.strong()
```

Medium and Strong bend content more deeply, with thin motion-only color fringes
where the curved lens crosses icons and labels. The effect is sampled from the
backdrop and the resting droplet remains unchanged. Set `dispersion: 0` to keep
the bend without RGB separation.

Example:

```dart
theme: const LiquidTabBarTheme(
  dropletRefraction: DropletRefractionStyle.strong(),
),
```

#### Outer glass presets

```dart
GlassStyle.frosted
GlassStyle.prismaticCaustics
GlassStyle.clearCrystal
GlassStyle.deepRefraction
```

Use an outer glass preset through `LiquidBarStyle`:

```dart
theme: LiquidTabBarTheme(
  barStyle: LiquidBarStyle.light.copyWith(
    glass: GlassStyle.prismaticCaustics,
  ),
),
```

#### Light and dark presets

```dart
LiquidTabBarTheme()
LiquidTabBarTheme.dark()
LiquidTabBarTheme.adaptive(context)

LiquidBarStyle.light
LiquidBarStyle.dark

LiquidDropletSurfaceStyle.light
LiquidDropletSurfaceStyle.dark

LiquidTabActionStyle.light
LiquidTabActionStyle.dark
```

The normal default is:

```dart
LiquidTabBarTheme()
```

For most applications, use the theme that follows the surrounding app theme:

```dart
theme: LiquidTabBarTheme.adaptive(context),
```

#### Material modes

```dart
LiquidTabBarMaterial.auto    // default
LiquidTabBarMaterial.glass
LiquidTabBarMaterial.blur
LiquidTabBarMaterial.opaque
```

#### Folded shapes

```dart
LiquidFoldedShape.circle // default
LiquidFoldedShape.oval
```

### Glass & Droplet Surfaces

Outer bar glass is configured via `GlassStyle`. Curated presets include:
- `GlassStyle.frosted`: Balanced diffusion and gentle rim specular (default).
- `GlassStyle.prismaticCaustics`: Vivid chromatic dispersion (`0.32`) with boosted specular highlights (`0.65`).
- `GlassStyle.clearCrystal`: Zero-blur transparent crystal.
- `GlassStyle.deepRefraction`: Heavy optical slab with deep displacement.

```dart
barStyle: LiquidBarStyle.light.copyWith(
  glass: GlassStyle.prismaticCaustics,
)
```

The visible surface appearance of the moving droplet (gradient, border, shadow, and opaque fill) is configured via `LiquidDropletSurfaceStyle`:

```dart
dropletSurfaceStyle: LiquidDropletSurfaceStyle.light.copyWith(
  borderWidth: 1.0,
)
```

Droplet shadow rendering consumes `color`, `blurRadius`, and `offset`.

### Optical Refraction

The moving droplet features physical optical refraction that dynamically distorts underlying icons and labels during motion. At rest, refraction displacement returns strictly to `0.0` to preserve crisp text and icon legibility.

Curated presets:
- `DropletRefractionStyle.none()`: Disables optical displacement completely.
- `DropletRefractionStyle.subtle()`: Gentle boundary displacement.
- `DropletRefractionStyle.medium()`: Balanced default refraction.
- `DropletRefractionStyle.strong()`: Pronounced curvature and deeper displacement.

```dart
dropletRefraction: const DropletRefractionStyle.medium(),
```

**Advanced optical controls**:

| Parameter | Purpose |
|:---|:---|
| **`thickness`** | Optical rim bevel width in logical pixels. |
| **`refractiveIndex`** | Snell optical index of refraction (1.50 = standard glass). |
| **`baseHeight`** | Optical standoff depth for ray projection. |
| **`dispersion`** | Chromatic dispersion (RGB wavelength split). |
| **`specularStrength`** | Highlight intensity along the moving refractive boundary rim. |
| **`refractionStrength`** | Master displacement multiplier (`0.0` disables, `1.0` standard). |

---

## Actions & Placement

Attach a standalone circular button (such as Create, Filter, or Search) alongside the navigation capsule:

```dart
separateAction: LiquidTabAction.icon(
  icon: Icons.add_rounded,
  tooltip: 'Create',
  onTap: handleCreate,
),
separateActionPlacement: LiquidTabActionPlacement.together, // or .split
```

- **`LiquidTabActionPlacement.together`** *(default)*: Groups the action circle adjacent to the main capsule.
- **`LiquidTabActionPlacement.split`**: Pins the main capsule to the leading margin and the action button to the trailing margin.
- **Action styling**: Customize the selected action background marker via `actionStyle: const LiquidTabActionStyle(selectedFill: ...)`.

---

## Notification Badges

`LiquidTabItem` includes integrated notification badges with four display modes:

```dart
// 1. Unread dot
LiquidTabItem.icon(
  icon: Icons.mail_rounded,
  label: 'Inbox',
  badge: true,
),

// 2. Count pill (auto-formats 99+ above 99)
LiquidTabItem.icon(
  icon: Icons.notifications_rounded,
  label: 'Alerts',
  badge: true,
  badgeCount: 4,
),
```

- **Text pill**: Pass `badgeText: 'PRO'` for custom string badges.
- **Custom widget**: Supply `badgeWidget` for custom indicator layouts.
- **Styling**: Configure colors, borders, typography, and offsets via `LiquidBadgeStyle`.
- **Optical interaction**: Normal tab badges participate in droplet refraction when overlapped by the moving lens.

---

## Expandable Search

Transform the navigation bar into an edge-to-edge floating search field:

```dart
separateAction: LiquidTabAction.search(
  hintText: 'Search notes, files...',
  clearOnClose: true,
  onChanged: (query) => onFilter(query),
  onSubmitted: (query) => performSearch(query),
  onClose: () => onSearchClosed(),
),
```

- **Keyboard-aware**: Automatically floats above the on-screen software keyboard without artificial layout height jumps.
- **Programmatic & gesture control**: Dismisses on close tap or Android back button, and can be driven programmatically via `controller.openSearch()` and `controller.closeSearch()`.

### Custom Search Icon

Pass `customIcon` to supply a custom widget (e.g. SVG or image) for the Search action:

```dart
separateAction: LiquidTabAction.search(
  hintText: 'Search notes, files...',
  customIcon: SvgPicture.asset('assets/icons/search.svg'),
  clearOnClose: true,
  onChanged: (query) => onFilter(query),
),
```

The custom icon source is shared across both Search presentation states:
- **Closed circular action**: Displays the custom widget with standard tap scale animations and theme color tinting.
- **Expanded Search field**: Displays the exact same custom widget as the leading icon in the search input field rather than reverting to `Icons.search_rounded`.

#### Search Theme Tinting & Original Colors

Like custom tab items, `LiquidTabAction.search` supports `useThemeColor`:

```dart
// Theme-tinted (default): tints with button color when closed, inactiveColor when expanded
LiquidTabAction.search(
  customIcon: SvgPicture.asset('assets/icons/search.svg'),
  useThemeColor: true,
)

// Original colors: preserves multi-color artwork while maintaining smooth open/close fade
LiquidTabAction.search(
  customIcon: SvgPicture.asset('assets/icons/search_multicolor.svg'),
  useThemeColor: false,
)
```

#### Action Geometry (`size`) vs Glyph Dimensions (`iconSize`)

`LiquidTabAction.search` strictly separates outer button geometry from glyph dimensions:

| Property | Purpose | Default |
|:---|:---|:---|
| **`size`** | Outer capsule width & height of the circular Search button. | `64.0` |
| **`iconSize`** | Dimensions of the visual glyph / custom widget container. | `24.0` (closed) / `22.0` (expanded) |

Specifying `iconSize` resizes only the glyph layout without altering the outer button geometry:

```dart
LiquidTabAction.search(
  customIcon: SvgPicture.asset('assets/icons/search.svg'),
  iconSize: 28.0, // 28×28 glyph layout inside the standard 64×64 circular capsule
)
```

---

## Adaptive Folding

### Automatic Folding (Recommended)

When using `LiquidTabBarScaffold`, vertical scrolling in primary body scrollables automatically folds the bar into a compact pill showing only the active tab:

```dart
LiquidTabBarScaffold(
  body: ListView.builder(
    itemCount: 50,
    itemBuilder: (context, i) => ListTile(title: Text('Item $i')),
  ),
  tabBar: LiquidTabBar(
    shrinkOnScroll: true,                  // Set false to keep permanently expanded
    foldedShape: LiquidFoldedShape.circle, // .circle or .oval
    // ...
  ),
)
```

`LiquidTabBarScaffold` automatically observes primary vertical body scrolling; no `NotificationListener` or controller management is required for normal layouts. Scrolling back up, reaching the top of content, or tapping the folded capsule smoothly unfolds the bar.

### Manual integration

For custom `Scaffold` layouts, multiple independent vertical scroll sources, or complex nested scrolling, forward notifications explicitly:

```dart
final controller = LiquidTabBarController();

NotificationListener<ScrollNotification>(
  onNotification: controller.handleScroll,
  child: myScrollView,
)

LiquidTabBar(
  controller: controller,
  shrinkOnScroll: true,
  // ...
)
```

---

## Controller

Use `LiquidTabBarController` to coordinate folding, search, and performance monitoring programmatically:

| Capability | Methods & Properties |
|:---|:---|
| **Folding** | `minimize()`, `expand()`, `minimized` |
| **Search** | `openSearch()`, `closeSearch({clearText})`, `isSearching` |
| **Manual Scroll** | `handleScroll(notification, {allowNested})` |
| **Performance** | `armGovernor()`, `isGovernorArmed`, `isDegraded` |

> [!NOTE]
> Tab selection is owned by your Flutter state via `selectedIndex` and `onSelected`.

---

## Scroll Padding

Because `LiquidTabBar` floats above content, underlying scroll views must reserve bottom padding so the final items are not obscured:

| Layout Architecture | Recommended Strategy |
|:---|:---|
| **`LiquidTabBarScaffold`** | **Automatic (Recommended)** — applies bottom padding and enables `extendBody: true`. |
| **Standard `Scaffold`** | Wrap scrollable in `LiquidScrollPadding(child: ...)`. |
| **Custom Box/List** | Set `padding: LiquidTabBar.reservedPadding(context)`. |
| **`CustomScrollView` Slivers** | Append `const SliverLiquidScrollPadding()` as the trailing sliver. |

If a `Scaffold` has `extendBody: true` but the scroll view lacks reserved padding, `LiquidTabBar` emits an actionable warning in debug mode (silence via `warnOnMissingExtendBodyPadding: false` or `LiquidTabBar.disableExtendBodyWarning = true`).

---

## RTL & Bidirectionality

`LiquidTabBar` automatically follows the app's ambient `Directionality`. RTL layouts (such as Arabic, Hebrew, and Persian) mirror tab ordering, gestures, and action placements with zero package-specific configuration.

---

## Accessibility & Reduced Motion

- **Screen Readers**: Exposes accessible `Semantics` for all tab items, active states, notification counts, search fields, and folded expand triggers.
- **Reduced Motion**: Respects `MediaQuery.disableAnimationsOf(context)` by snapping spring simulations and search transitions to target values without delay or organic stretch.

---

## Advanced Governor Tuning

When armed at startup via `LiquidTabBarController.shared.armGovernor()`, the governor monitors GPU raster timings during glass shader execution and automatically downgrades to backdrop blur if slow frames exceed default thresholds (`rasterThresholdMs: 24`, `maxSlowFrames: 12`).

For custom performance budgets, configure explicit thresholds on your controller:

```dart
final controller = LiquidTabBarController(
  governorConfig: const LiquidGovernorConfig(
    rasterThresholdMs: 20,
    maxSlowFrames: 8,
  ),
);
controller.armGovernor();
```

---

## Example Application

The repository includes interactive demonstrations:

- **4-Style Comparison**: Normal and Glossy bars in light and dark themes.
- **Basic Navigation**: Standard bottom bar with fluid spring droplet.
- **Styling & Refraction**: Custom materials, light/dark themes, and refraction presets.
- **Action Buttons**: Together and Split action placements.
- **Search & Folding**: Expandable search morphing, circle/oval folding, and live RTL layout.
- **Custom Icons Demo**: Standard `IconData`, custom SVG widgets, activeIcon switching, theme tinting vs original multi-color artwork, custom Search glyphs, and Search glyph sizing.
- **Text Form Field**: Keyboard behavior with the bar visible.

```sh
cd example
flutter run
```

---

## License

This package is licensed under the MIT License. See [LICENSE](LICENSE) for details.
