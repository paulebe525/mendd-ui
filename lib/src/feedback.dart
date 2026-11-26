import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// How long a save waits for the server before telling the person.
const saveTimeout = Duration(seconds: 25);

/// Texts the feedback helpers show. English defaults; apps pass translated ones.
class MenddFeedbackText {
  const MenddFeedbackText({
    this.notConfirmed = 'Not confirmed by the server yet. Check your internet connection, then try again.',
    this.refused = 'The server refused this change. Please check the details and try again.',
    this.offline = 'No internet connection. Please try again.',
    this.signedOut = 'Your sign-in expired. Please sign in again.',
    this.cancelled = 'Cancelled.',
    this.generic = 'Something went wrong.',
  });
  final String notConfirmed, refused, offline, signedOut, cancelled, generic;
}

/// Plain-English error text. Keeps the error code in brackets so problems can be
/// reported. Works with any error that has a `code` (Firebase errors) without
/// depending on Firebase.
String friendlyError(Object e, [MenddFeedbackText t = const MenddFeedbackText()]) {
  if (e is ArgumentError) return '${e.message}';
  String? code;
  try {
    code = (e as dynamic).code as String?;
  } catch (_) {}
  if (code != null) {
    final msg = switch (code) {
      'permission-denied' || 'unauthorized' => t.refused,
      'unavailable' || 'network-request-failed' || 'retry-limit-exceeded' => t.offline,
      'unauthenticated' || 'user-token-expired' => t.signedOut,
      'canceled' || 'web-context-canceled' => t.cancelled,
      _ => t.generic,
    };
    return '$msg ($code)';
  }
  return '${t.generic} ($e)';
}

/// Success or error snackbar. Errors stay longer and can be closed.
void showMessage(BuildContext context, String text, {bool error = false}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(text, style: TextStyle(color: error ? scheme.onErrorContainer : null, fontSize: MenddA11y.minBody)),
      backgroundColor: error ? scheme.errorContainer : null,
      duration: Duration(seconds: error ? 6 : 3),
      showCloseIcon: error,
      closeIconColor: error ? scheme.onErrorContainer : null,
    ));
}

/// One save at a time per screen: spinner, extra taps ignored, waits for the
/// server, then a clear success or error. ("A button press is not proof of success.")
mixin SaveRunner<T extends StatefulWidget> on State<T> {
  bool busy = false;
  MenddFeedbackText get feedbackText => const MenddFeedbackText();

  /// Returns true only if the server confirmed the write.
  Future<bool> runSave(Future<void> Function() action, {required String success}) async {
    if (busy) return false; // double-tap guard
    setState(() => busy = true);
    try {
      await action().timeout(saveTimeout);
      if (mounted) showMessage(context, success);
      return true;
    } on TimeoutException {
      if (mounted) showMessage(context, feedbackText.notConfirmed, error: true);
    } catch (e) {
      if (mounted) showMessage(context, friendlyError(e, feedbackText), error: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
    return false;
  }
}

enum BusyButtonStyle { filled, outlined }

/// A full-width, 48 dp button that shows a spinner and is disabled while [busy].
class BusyButton extends StatelessWidget {
  const BusyButton({
    super.key,
    required this.busy,
    required this.onPressed,
    required this.label,
    this.busyLabel,
    this.icon,
    this.style = BusyButtonStyle.filled,
  });
  final bool busy;
  final VoidCallback? onPressed;
  final String label;
  final String? busyLabel;
  final IconData? icon;
  final BusyButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final child = Text(busy ? (busyLabel ?? label) : label);
    final leading = busy
        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : (icon == null ? null : Icon(icon));
    final onTap = busy ? null : onPressed;
    final button = switch (style) {
      BusyButtonStyle.filled => leading == null
          ? FilledButton(onPressed: onTap, child: child)
          : FilledButton.icon(onPressed: onTap, icon: leading, label: child),
      BusyButtonStyle.outlined => leading == null
          ? OutlinedButton(onPressed: onTap, child: child)
          : OutlinedButton.icon(onPressed: onTap, icon: leading, label: child),
    };
    return SizedBox(width: double.infinity, child: button);
  }
}
