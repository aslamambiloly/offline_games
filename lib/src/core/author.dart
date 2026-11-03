/// Represents an author or contributor of an offline game.
class GameAuthor {
  /// Creates a [GameAuthor].
  const GameAuthor({
    required this.name,
    this.github,
    this.url,
  });

  /// The author's display name shown inside the UI.
  final String name;

  /// Optional GitHub handle (e.g. `aslamambiloly`).
  final String? github;

  /// Optional website or profile URL (rendered as text/selectable; never auto-opened).
  final String? url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAuthor &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          github == other.github &&
          url == other.url;

  @override
  int get hashCode => Object.hash(name, github, url);

  @override
  String toString() => 'GameAuthor(name: $name, github: $github, url: $url)';
}
