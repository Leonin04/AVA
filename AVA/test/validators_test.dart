import 'package:flutter_test/flutter_test.dart';

import 'package:ava/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email válido', () => expect(Validators.email('a@b.com'), isNull));
    test('email inválido', () => expect(Validators.email('abc'), isNotNull));
    test('password corta', () => expect(Validators.password('123'), isNotNull));
    test('password válida', () => expect(Validators.password('123456'), isNull));
  });
}
