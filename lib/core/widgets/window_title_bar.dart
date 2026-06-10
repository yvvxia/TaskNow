import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../l10n/app_localizations.dart';
import '../theme/semantic_colors.dart';

/// Whether the app is running as a Windows desktop build.
bool get isWindowsDesktop => !kIsWeb && Platform.isWindows;

/// Minimize / maximize / close buttons for the frameless Windows title bar.
class WindowCaptionButtons extends StatefulWidget {
  const WindowCaptionButtons({super.key, this.forceVisible = false});

  /// When true, renders caption buttons even off Windows (for widget tests).
  final bool forceVisible;

  @override
  State<WindowCaptionButtons> createState() => _WindowCaptionButtonsState();
}

class _WindowCaptionButtonsState extends State<WindowCaptionButtons>
    with WindowListener {
  bool _isMaximized = false;

  bool get _visible => widget.forceVisible || isWindowsDesktop;

  @override
  void initState() {
    super.initState();
    if (_visible && !widget.forceVisible) {
      windowManager.addListener(this);
      windowManager.isMaximized().then((value) {
        if (mounted) setState(() => _isMaximized = value);
      });
    }
  }

  @override
  void dispose() {
    if (_visible && !widget.forceVisible) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final palette = SemanticColors.paletteOf(context);

    Widget captionButton({
      required Key key,
      required IconData icon,
      required String tooltip,
      required VoidCallback onPressed,
      bool hoverClose = false,
    }) {
      return Tooltip(
        message: tooltip,
        child: SizedBox(
          width: 46,
          height: 32,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: key,
              onTap: onPressed,
              hoverColor: hoverClose
                  ? const Color(0xFFE81123)
                  : palette.onSurface.withValues(alpha: 0.08),
              child: Icon(icon, size: 16, color: palette.onSurface),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        captionButton(
          key: const Key('window-minimize'),
          icon: Icons.remove,
          tooltip: l10n?.windowMinimize ?? 'Minimize',
          onPressed: () => windowManager.minimize(),
        ),
        captionButton(
          key: const Key('window-maximize'),
          icon: _isMaximized
              ? Icons.filter_none_outlined
              : Icons.crop_square_outlined,
          tooltip: _isMaximized
              ? (l10n?.windowRestore ?? 'Restore')
              : (l10n?.windowMaximize ?? 'Maximize'),
          onPressed: () async {
            if (_isMaximized) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
        ),
        captionButton(
          key: const Key('window-close'),
          icon: Icons.close,
          tooltip: l10n?.windowClose ?? 'Close',
          hoverClose: true,
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }
}

/// Wraps [child] in a drag-to-move region on Windows desktop.
class WindowDragRegion extends StatelessWidget {
  const WindowDragRegion({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isWindowsDesktop) return child;
    return DragToMoveArea(child: child);
  }
}

/// Full-width invisible drag region for the shell app bar background.
class WindowAppBarDragRegion extends StatelessWidget {
  const WindowAppBarDragRegion({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isWindowsDesktop) return const SizedBox.shrink();
    return const DragToMoveArea(child: SizedBox.expand());
  }
}
