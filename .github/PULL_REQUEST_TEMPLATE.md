## Description

<!--- Describe your changes in detail -->

## Type of Change

- [ ] `feat`: New feature / enhancement
- [ ] `feat(game)`: New mini-game contribution
- [ ] `fix`: Bug fix
- [ ] `docs`: Documentation update
- [ ] `test`: Test suite update
- [ ] `chore`: Maintenance / dependencies

## Game Contribution Checklist (if adding/modifying a game)

- [ ] Pure-Dart logic separated from UI (no `BuildContext` in logic)
- [ ] Unit tests for all game rules and edge cases
- [ ] Game honours `session.paused`
- [ ] Injected `session.random` used (never raw `Random()`)
- [ ] Reports score via `session.reportScore`
- [ ] Accessible by default (Semantics labels, 44dp tap targets)
- [ ] Pure offline: zero network, telemetry, or external assets
- [ ] Original name and artwork (no trademarked clones)
- [ ] `GameMeta.authors` populated with contributor name(s)

## Quality Verification

- [ ] `dart format .` passed
- [ ] `flutter analyze` passed with no issues
- [ ] `flutter test` passed
