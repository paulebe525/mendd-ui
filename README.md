# mendd-ui

The Mendd design system for the **Mendd** (customer) and **Mendd Partner** Flutter apps:
brand colour tokens, the app theme, and shared widgets.

- **Colours are sampled from the brand files** in `mend-website/brand/` (most common opaque,
  saturated pixel), not estimated. See `lib/src/tokens.dart` for each value and its source.
  - Customer green `#015F4E` (logo tile), dark `#015444` (logo wordmark)
  - Partner purple `#540191` (partner logo wordmark), dark `#43027D` (partner icon)
  - Orange `#FE6802` (logo's second "d"): **non-text accent only** (star ratings), never text or buttons.
    It is 2.92:1 on white, so stars get a dark-green outline (8.9:1).
- **Accessibility built in:** body text ≥ 16, small print ≥ 14, AA contrast for every text pair
  (tested), 48 dp minimum touch targets for all buttons and the rating input (tested with
  Flutter's tap-target and contrast guidelines).
- **Widgets:** `BusyButton`, `SaveRunner` (one save at a time, waits for the server, clear result),
  `showMessage`, `friendlyError`, `StateView` (loading / empty / error / success), `StatusPill`,
  `KeyValue`, `SectionHeader`, `RatingStars`, `TestModeBanner`.
- Text inside widgets is passed in by the apps, so it can be translated (Tamil-ready).

This repository is public. It contains **no logos, keys or user data**; logos stay in each app,
copied byte for byte from `brand/`.

## Use

Apps pin a tagged version:

```yaml
dependencies:
  mendd_ui:
    git:
      url: https://github.com/paulebe525/mendd-ui.git
      ref: v0.1.0
```

```dart
MaterialApp(theme: menddTheme(MenddBrand.customer), ...)
```

## Develop

`flutter analyze && flutter test`. Changes go through a pull request; CI must pass. Release by
tagging `vX.Y.Z`, then bump the `ref` in each app in its own PR.

Copyright © 2026 the Mendd owners. No licence is granted.
