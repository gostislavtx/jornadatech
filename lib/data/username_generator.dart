import 'dart:math';

/// Gera nomes de usuário aleatórios, no estilo dos videogames
/// ("CorujaAzul42"), para o aluno não precisar informar o nome real.
///
/// O aluno pode pedir outro nome, mas não digita um livre: assim ninguém
/// acaba usando o próprio nome ou um nome impróprio.
class UsernameGenerator {
  UsernameGenerator([Random? random]) : _random = random ?? Random.secure();

  final Random _random;

  static const animals = [
    'Coruja', 'Tigre', 'Lobo', 'Raposa', 'Falcao', 'Panda', 'Golfinho',
    'Tucano', 'Jaguar', 'Capivara', 'Tartaruga', 'Arara', 'Lince', 'Polvo',
    'Pinguim', 'Quati', 'Gaviao', 'Baleia', 'Leao', 'Esquilo',
  ];

  static const traits = [
    'Azul', 'Veloz', 'Sabio', 'Curioso', 'Ligeiro', 'Dourado', 'Valente',
    'Esperto', 'Calmo', 'Brilhante', 'Agil', 'Feliz', 'Gentil', 'Forte',
    'Criativo', 'Atento', 'Leal', 'Rubro', 'Verde', 'Astuto',
  ];

  /// Ex.: "CorujaAzul42". Sem acentos, para digitar fácil no celular.
  String next() {
    final animal = animals[_random.nextInt(animals.length)];
    final trait = traits[_random.nextInt(traits.length)];
    final number = 10 + _random.nextInt(90);
    return '$animal$trait$number';
  }
}

/// Código de recuperação no formato "K7M2-QX9P".
///
/// Sem letras e números que se confundem (0/O, 1/I/L), porque o aluno
/// vai anotar à mão ou tirar print.
String generateRecoveryCode([Random? random]) {
  const alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  final r = random ?? Random.secure();
  String block() =>
      List.generate(4, (_) => alphabet[r.nextInt(alphabet.length)]).join();
  return '${block()}-${block()}';
}

/// Normaliza o que o aluno digitou: maiúsculas, sem espaços, com o hífen.
String normalizeRecoveryCode(String text) {
  final raw = text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  if (raw.length != 8) return raw;
  return '${raw.substring(0, 4)}-${raw.substring(4)}';
}
