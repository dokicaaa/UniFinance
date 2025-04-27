import 'dart:math';

String generateUniqueCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return String.fromCharCodes(
    List.generate(8, (index) => chars.codeUnitAt(random.nextInt(chars.length))),
  );
}