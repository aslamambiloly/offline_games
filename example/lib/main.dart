import 'dart:async';
import 'package:flutter/material.dart';
import 'package:offline_games/offline_games.dart';

void main() {
  runApp(const OfflineGamesDemoApp());
}

/// A simulated connectivity source allowing instant toggling in the demo app.
class SimulatedConnectivitySource implements ConnectivitySource {
  final _controller = StreamController<bool>.broadcast();
  bool _online = true;

  @override
  Stream<bool> get onlineStream => _controller.stream;

  @override
  Future<bool> isOnline() async => _online;

  bool get currentStatus => _online;

  void toggle() {
    _online = !_online;
    _controller.add(_online);
  }

  void setOnline(bool value) {
    if (_online == value) return;
    _online = value;
    _controller.add(_online);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

class OfflineGamesDemoApp extends StatefulWidget {
  const OfflineGamesDemoApp({super.key});

  @override
  State<OfflineGamesDemoApp> createState() => _OfflineGamesDemoAppState();
}

class _OfflineGamesDemoAppState extends State<OfflineGamesDemoApp> {
  final SimulatedConnectivitySource _connectivity =
      SimulatedConnectivitySource();
  final OfflineGamesController _controller = OfflineGamesController();
  GamesMode _mode = const GamesMode.spin();

  @override
  void dispose() {
    _connectivity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Games Arcade Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Plug-and-play builder integration
      builder: (context, child) => OfflineGames(
        connectivity: _connectivity,
        controller: _controller,
        mode: _mode,
        offlineDelay: const Duration(seconds: 1), // Fast 1s delay for demo
        child: child!,
      ),
      home: DemoHomeScreen(
        connectivity: _connectivity,
        controller: _controller,
        currentMode: _mode,
        onModeChanged: (mode) => setState(() => _mode = mode),
      ),
    );
  }
}

class DemoHomeScreen extends StatefulWidget {
  final SimulatedConnectivitySource connectivity;
  final OfflineGamesController controller;
  final GamesMode currentMode;
  final ValueChanged<GamesMode> onModeChanged;

  const DemoHomeScreen({
    super.key,
    required this.connectivity,
    required this.controller,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  late bool _isOnline;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.connectivity.currentStatus;
    _sub = widget.connectivity.onlineStream.listen((status) {
      if (mounted) setState(() => _isOnline = status);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _openStandaloneModal() {
    showOfflineGames(
      context,
      mode: widget.currentMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🕹️ Offline Games Demo'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Manual Open',
            icon: const Icon(Icons.videogame_asset_rounded),
            onPressed: () => widget.controller.open(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Simulated Network Banner
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Network Simulation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isOnline
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor:
                                  _isOnline ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: _isOnline ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isOnline
                        ? 'Device is currently online. Toggle below to simulate an offline drop.'
                        : 'Simulating offline state. An offer card will slide in after 1 second.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          _isOnline ? Colors.redAccent : Colors.green,
                    ),
                    icon: Icon(_isOnline
                        ? Icons.wifi_off_rounded
                        : Icons.wifi_rounded),
                    label: Text(_isOnline
                        ? 'Simulate Connection Drop'
                        : 'Simulate Connection Restored'),
                    onPressed: () => widget.connectivity.toggle(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Arcade Mode Selection
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arcade Mode',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'spin',
                        label: Text('Spin Wheel'),
                        icon: Icon(Icons.casino_rounded),
                      ),
                      ButtonSegment<String>(
                        value: 'picker',
                        label: Text('Catalog'),
                        icon: Icon(Icons.grid_view_rounded),
                      ),
                      ButtonSegment<String>(
                        value: 'single',
                        label: Text('Single'),
                        icon: Icon(Icons.sports_esports_rounded),
                      ),
                    ],
                    selected: {
                      if (widget.currentMode is SpinMode) 'spin',
                      if (widget.currentMode is PickerMode) 'picker',
                      if (widget.currentMode is SingleMode) 'single',
                    },
                    onSelectionChanged: (selected) {
                      final val = selected.first;
                      if (val == 'spin') {
                        widget.onModeChanged(const GamesMode.spin());
                      } else if (val == 'picker') {
                        widget.onModeChanged(const GamesMode.picker());
                      } else {
                        widget.onModeChanged(
                          const GamesMode.single(SnakeGame()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Direct Launcher Controls
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manual Arcade Triggers',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trigger the arcade overlay programmatically or push a modal route:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_browser_rounded),
                        label: const Text('Controller.open()'),
                        onPressed: () => widget.controller.open(),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.fullscreen_rounded),
                        label: const Text('showOfflineGames()'),
                        onPressed: _openStandaloneModal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Built-in Games Roster
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bundled Games (${GameCatalog.builtIn.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final game in GameCatalog.builtIn)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(
                          game.meta.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        game.meta.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'by ${game.meta.authors.map((a) => a.name).join(', ')} • ${game.meta.description}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow_rounded),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => Scaffold(
                                body: GamePlayer(
                                  game: game,
                                  onExit: () => Navigator.of(context).pop(),
                                ),
                              ),
                              settings:
                                  const RouteSettings(name: 'game_player'),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
