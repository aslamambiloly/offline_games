import 'package:flutter/material.dart';

/// Floating banner shown when internet connectivity is restored during an active game.
class BackOnlineBanner extends StatelessWidget {
  /// Creates a [BackOnlineBanner].
  const BackOnlineBanner({
    super.key,
    required this.onKeepPlaying,
    required this.onBackToApp,
  });

  /// Callback when user decides to continue playing.
  final VoidCallback onKeepPlaying;

  /// Callback when user decides to exit the arcade and return to the host app.
  final VoidCallback onBackToApp;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: "Connection restored notification banner. You're back online.",
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "You're back online!",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(88, 44),
                  ),
                  onPressed: onKeepPlaying,
                  child: const Text('Keep playing'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(88, 44),
                  ),
                  onPressed: onBackToApp,
                  child: const Text('Back to app'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
