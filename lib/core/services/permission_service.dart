import 'package:flutter/services.dart';

class PermissionService {
  static const MethodChannel _channel = MethodChannel('com.reap/native');

  static PermissionService? _instance;
  static PermissionService get instance => _instance ??= PermissionService._();

  PermissionService._();

  Future<int> getAndroidVersion() async {
    try {
      final result = await _channel.invokeMethod('getAndroidVersion');
      return result as int? ?? 0;
    } on PlatformException {
      return 0;
    }
  }

  Future<bool> hasStoragePermission() async {
    try {
      final result = await _channel.invokeMethod('hasStoragePermission');
      return result as bool? ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> requestStoragePermission() async {
    try {
      final result = await _channel.invokeMethod('requestStoragePermission');
      return result as bool? ?? false;
    } on PlatformException {
      return false;
    }
  }

  String getPermissionMessage(int androidVersion) {
    if (androidVersion >= 33) {
      return 'O REAP precisa de acesso aos seus arquivos para analisar '
             'vídeos, imagens, downloads e documentos.\n\n'
             'No Android 13+, conceda a permissão de "Arquivos e mídias" nas configurações do app.';
    } else if (androidVersion >= 30) {
      return 'O REAP precisa de acesso ao armazenamento para analisar '
             'seus arquivos.\n\n'
             'Conceda a permissão de "Armazenamento" nas configurações do app.\n'
             'No Android 11+, selecione "Permitir acesso a todos os arquivos".';
    } else {
      return 'O REAP precisa de acesso ao armazenamento para analisar '
             'seus arquivos.\n\n'
             'Conceda a permissão de "Armazenamento" nas configurações do app.';
    }
  }
}
