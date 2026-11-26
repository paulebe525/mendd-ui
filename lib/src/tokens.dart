import 'package:material_ui/material_ui.dart';

/// Which app the theme is for. Green = customer app, purple = partner app.
enum MenddBrand { customer, partner }

/// Brand colours SAMPLED FROM THE BRAND FILES (most common opaque, saturated pixel),
/// not estimated. Sources are in mend-website `brand/` (26 Nov 2026):
///
/// | token          | value     | sampled from                                  |
/// |----------------|-----------|-----------------------------------------------|
/// | green          | #015F4E   | mendd-logo.png, house tile                    |
/// | greenDark      | #015444   | mendd-logo.png, "mend" wordmark               |
/// | orange         | #FE6802   | mendd-logo.png, second "d"                    |
/// | purple         | #540191   | mendd-partner-logo.png, wordmark              |
/// | purpleDark     | #43027D   | mendd-partner-icon.png                        |
/// | partnerGreen   | #016050   | mendd-partner-logo.png, second "d"            |
///
/// The website currently uses #006354 for green; the apps use the logo value (#015F4E).
abstract final class MenddColors {
  static const green = Color(0xFF015F4E);
  static const greenDark = Color(0xFF015444);
  static const orange = Color(0xFFFE6802);
  static const purple = Color(0xFF540191);
  static const purpleDark = Color(0xFF43027D);
  static const partnerGreen = Color(0xFF016050);

  /// Neutrals (same as the website's ink/muted/line/surface).
  static const ink = Color(0xFF10251F);
  static const muted = Color(0xFF4F6159);
  static const line = Color(0xFFDCE5E0);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceTint = Color(0xFFF4F7F5);

  /// Status colours (text on white ≥ 4.5:1).
  static const danger = Color(0xFFB3261E);
  static const testMode = Color(0xFFB3261E);

  static Color primary(MenddBrand b) => b == MenddBrand.customer ? green : purple;
  static Color primaryDark(MenddBrand b) => b == MenddBrand.customer ? greenDark : purpleDark;

  /// Orange is a NON-TEXT accent only (star ratings). Never for text or buttons:
  /// on white it is 2.92:1, so stars also get a [greenDark] outline (8.9:1).
  static const accent = orange;
  static const accentOutline = greenDark;
}

/// 4-point spacing scale.
abstract final class MenddSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class MenddRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const pill = 999.0;
}

/// Accessibility minimums the design system guarantees.
abstract final class MenddA11y {
  /// Every tappable control is at least 48×48 dp.
  static const minTouch = 48.0;

  /// Body text ≥ 16, small print ≥ 14 (logical pixels).
  static const minBody = 16.0;
  static const minSmall = 14.0;
}

/// WCAG 2.x contrast ratio between two opaque colours (1–21).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
