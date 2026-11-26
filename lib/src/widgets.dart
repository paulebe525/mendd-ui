import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Empty / loading / error / success: one consistent look for every screen state.
class StateView extends StatelessWidget {
  const StateView._({super.key, required this.kind, this.title, this.message, this.icon, this.action});

  const StateView.loading({Key? key, String? message}) : this._(key: key, kind: StateKind.loading, message: message);

  const StateView.empty({Key? key, required String title, String? message, IconData icon = Icons.inbox_outlined, Widget? action})
      : this._(key: key, kind: StateKind.empty, title: title, message: message, icon: icon, action: action);

  const StateView.error({Key? key, required String title, String? message, Widget? action})
      : this._(key: key, kind: StateKind.error, title: title, message: message, icon: Icons.cloud_off_outlined, action: action);

  const StateView.success({Key? key, required String title, String? message, Widget? action})
      : this._(key: key, kind: StateKind.success, title: title, message: message, icon: Icons.check_circle, action: action);

  final StateKind kind;
  final String? title, message;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    if (kind == StateKind.loading) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          if (message != null) ...[const SizedBox(height: MenddSpace.md), Text(message!, style: text.bodyMedium)],
        ]),
      );
    }
    final color = switch (kind) {
      StateKind.error => scheme.error,
      StateKind.success => scheme.primary,
      _ => scheme.outline,
    };
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(MenddSpace.xxl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: kind == StateKind.success ? 72 : 48, color: color),
          const SizedBox(height: MenddSpace.md),
          Text(title!, style: text.titleMedium, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: MenddSpace.xs),
            Text(message!, style: text.bodyMedium?.copyWith(color: MenddColors.muted), textAlign: TextAlign.center),
          ],
          if (action != null) ...[const SizedBox(height: MenddSpace.lg), action!],
        ]),
      ),
    );
  }
}

enum StateKind { loading, empty, error, success }

enum PillTone { active, neutral, success, danger }

/// Small rounded status label ("Finding partners", "Completed").
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, this.tone = PillTone.neutral});
  final String label;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      PillTone.active => (scheme.primaryContainer, scheme.onPrimaryContainer),
      PillTone.success => (scheme.primary, scheme.onPrimary),
      PillTone.danger => (scheme.errorContainer, scheme.onErrorContainer),
      PillTone.neutral => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MenddSpace.md, vertical: MenddSpace.xs),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(MenddRadius.pill)),
      child: Text(label, style: TextStyle(fontSize: MenddA11y.minSmall, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

/// Label above value, for detail screens.
class KeyValue extends StatelessWidget {
  const KeyValue({super.key, required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: MenddSpace.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: text.labelMedium?.copyWith(color: MenddColors.muted)),
        const SizedBox(height: 2),
        Text(value, style: text.bodyLarge),
      ]),
    );
  }
}

/// Section title with optional supporting line.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: MenddSpace.sm),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: text.titleMedium),
        if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: text.bodyMedium?.copyWith(color: MenddColors.muted))],
      ]),
    );
  }
}

/// Star rating. Orange is a non-text accent; each star also has a dark-green
/// outline so it meets 3:1 against white, and the value is spoken/labelled in
/// words, never by colour alone. Pass [onChanged] for input (48 dp per star).
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.value, this.onChanged, this.size = 32, this.semanticsLabel});
  final int value;
  final ValueChanged<int>? onChanged;
  final double size;

  /// e.g. "4 of 5 stars". Defaults to English.
  final String Function(int value)? semanticsLabel;

  Widget _star(bool filled) => Stack(alignment: Alignment.center, children: [
        if (filled) Icon(Icons.star, size: size, color: MenddColors.accent),
        Icon(filled ? Icons.star_outline : Icons.star_border, size: size, color: MenddColors.accentOutline),
      ]);

  @override
  Widget build(BuildContext context) {
    final label = semanticsLabel?.call(value) ?? '$value of 5 stars';
    if (onChanged == null) {
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: Row(mainAxisSize: MainAxisSize.min, children: [for (var s = 1; s <= 5; s++) _star(s <= value)]),
      );
    }
    return Semantics(
      label: label,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var s = 1; s <= 5; s++)
          SizedBox.square(
            dimension: size + 16 < MenddA11y.minTouch ? MenddA11y.minTouch : size + 16,
            child: InkResponse(
              onTap: () => onChanged!(s),
              radius: MenddA11y.minTouch / 2,
              child: Semantics(button: true, label: '$s', child: Center(child: _star(s <= value))),
            ),
          ),
      ]),
    );
  }
}

/// Red strip at the top of EVERY screen while an app talks to the local
/// emulators, so a test build can never be mistaken for the real app.
class TestModeBanner extends StatelessWidget {
  const TestModeBanner({super.key, required this.child, required this.enabled, this.host = '127.0.0.1'});
  final Widget child;
  final bool enabled;
  final String host;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Column(children: [
      Material(
        color: MenddColors.testMode, // white on this red: 6.5:1
        child: SafeArea(
          bottom: false,
          child: Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MenddSpace.md, vertical: MenddSpace.sm),
              child: Row(children: [
                const Icon(Icons.science_outlined, color: Colors.white, size: 20),
                const SizedBox(width: MenddSpace.sm),
                Expanded(
                  child: Text('TEST MODE · local emulators ($host) · not real data',
                      style: const TextStyle(color: Colors.white, fontSize: MenddA11y.minSmall, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
          ),
        ),
      ),
      Expanded(child: MediaQuery.removePadding(context: context, removeTop: true, child: child)),
    ]);
  }
}
