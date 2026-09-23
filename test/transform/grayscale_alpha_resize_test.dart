import 'package:image/image.dart';
import 'package:test/test.dart';

Image _la100Alpha255({Format format = Format.uint8}) {
  final src = Image(width: 8, height: 8, numChannels: 2, format: format);
  for (final p in src) {
    p
      ..r = 100
      ..a = 255;
  }
  return src;
}

void _expectLa100Alpha255(Image image) {
  expect(image.numChannels, 2);
  for (final p in image) {
    expect(p.r, 100);
    expect(p.a, 255);
  }
}

void main() {
  group('Transform', () {
    for (final format in [Format.uint8, Format.uint16]) {
      for (final interpolation in Interpolation.values) {
        test(
            'copyResize ${interpolation.name} preserves grayscale alpha '
            'in $format', () {
          final resized = copyResize(_la100Alpha255(format: format),
              width: 4, interpolation: interpolation);
          expect(resized.width, 4);
          expect(resized.height, 4);
          _expectLa100Alpha255(resized);
        });
      }
    }

    for (final format in [Format.uint8, Format.uint16]) {
      for (final interpolation in [
        Interpolation.nearest,
        Interpolation.average
      ]) {
        test(
            'resize ${interpolation.name} preserves grayscale alpha samples '
            'in-place in $format', () {
          final src = _la100Alpha255(format: format);
          final resized = resize(src, width: 4, interpolation: interpolation);
          expect(identical(resized, src), isTrue);
          expect(resized.width, 4);
          expect(resized.height, 4);
          _expectLa100Alpha255(resized);
        });
      }
    }

    test('copyResize after PNG round-trip preserves opaque grayscale alpha',
        () {
      final bytes = encodePng(_la100Alpha255());
      final decoded = decodePng(bytes)!;
      _expectLa100Alpha255(decoded);
      final resized = copyResize(decoded, width: 4);
      _expectLa100Alpha255(resized);
    });
  });
}
