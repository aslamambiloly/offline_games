import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all games adhere to 100% pure pixel vector guidelines', () {
    final result = Process.runSync('dart', ['run', 'tool/check_pixel_theme.dart']);
    expect(
      result.exitCode,
      equals(0),
      reason: 'check_pixel_theme failed:\n${result.stdout}\n${result.stderr}',
    );
  });
}
