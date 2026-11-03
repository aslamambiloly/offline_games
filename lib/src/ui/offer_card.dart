import 'package:flutter/material.dart';
import 'theme.dart';

/// Dismissible offer card presented when the device loses internet connectivity.
class OfflineOfferCard extends StatefulWidget {
  /// Creates an [OfflineOfferCard].
  const OfflineOfferCard({
    super.key,
    required this.onPlay,
    required this.onDismiss,
    this.actionLabel = 'Spin',
  });

  /// Action when player taps the primary button (Spin / Play).
  final VoidCallback onPlay;

  /// Action when player dismisses the card.
  final VoidCallback onDismiss;

  /// Button label for the primary action (e.g. 'Spin' or 'Play').
  final String actionLabel;

  @override
  State<OfflineOfferCard> createState() => _OfflineOfferCardState();
}

class _OfflineOfferCardState extends State<OfflineOfferCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!disableAnim) {
      await _controller.reverse();
    }
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = OfflineGamesTheme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    Widget cardContent = Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: theme.borderRadius,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: theme.accentGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text('🕹️', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "You're offline",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Feeling lucky? Play a quick mini-game!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(80, 44),
                ),
                onPressed: _handleDismiss,
                child: const Text('Dismiss'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(100, 44),
                ),
                onPressed: widget.onPlay,
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: Text(widget.actionLabel),
              ),
            ],
          ),
        ],
      ),
    );

    if (disableAnim) {
      return cardContent;
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: cardContent,
      ),
    );
  }
}
