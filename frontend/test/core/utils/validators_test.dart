import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('devuelve error cuando el email está vacío', () {
      expect(Validators.email(''), 'Introduce un email');
    });

    test('devuelve error cuando el email no tiene formato válido', () {
      expect(Validators.email('correo-invalido'), 'Introduce un email válido');
    });

    test('devuelve null cuando el email es válido', () {
      expect(Validators.email('usuario@test.com'), isNull);
    });

    test('ignora espacios al principio y al final del email', () {
      expect(Validators.email('  usuario@test.com  '), isNull);
    });
  });

  group('Validators.password', () {
    test('devuelve error cuando la contraseña está vacía', () {
      expect(Validators.password(''), 'Introduce una contraseña');
    });

    test('devuelve null cuando la contraseña tiene contenido', () {
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.repeatPassword', () {
    test('devuelve error cuando la repetición está vacía', () {
      expect(
        Validators.repeatPassword('', password: '123456'),
        'Debes repetir la contraseña',
      );
    });

    test('devuelve error cuando las contraseñas no coinciden', () {
      expect(
        Validators.repeatPassword('abcdef', password: '123456'),
        'Las contraseñas no coinciden',
      );
    });

    test('devuelve null cuando las contraseñas coinciden', () {
      expect(
        Validators.repeatPassword('123456', password: '123456'),
        isNull,
      );
    });
  });
}