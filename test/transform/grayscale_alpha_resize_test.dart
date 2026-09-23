import 'package:image/image.dart';
import 'package:test/test.dart';

Image _opaqueLa8x8({Format format = Format.uint8}) {
  final src = Image(width: 8, height: 8, numChannels: 2, format: format);
  for (final p in src) {
    p
      ..r = 100
      ..a = 255;
  }
  return src;
}

void expectOpaqueLa100(Image image) {
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
          final resized = copyResize(_opaqueLa8x8(format: format),
              width: 4, interpolation: interpolation);
          expect(resized.width, 4);
          expect(resized.height, 4);
          expectOpaqueLa100(resized);
        });
      }
    }

    test('copyResize after PNG round-trip preserves opaque grayscale alpha',
        () {
      final bytes = encodePng(_opaqueLa8x8());
      final decoded = decodePng(bytes)!;
      expectOpaqueLa100(decoded);
      final resized = copyResize(decoded, width: 4);
      expectOpaqueLa100(resized);
    });
  });
}
