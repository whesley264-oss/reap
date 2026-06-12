import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/services.dart';

class PermissionHandlerWidget extends ConsumerStatefulWidget {
  final Widget child;
  final String permissionType;

  const PermissionHandlerWidget({
    super.key,
    required this.child,
    this.permissionType = 'storage',
  });

  @override
  ConsumerState<PermissionHandlerWidget> createState() => _PermissionHandlerWidgetState();
}

class _PermissionHandlerWidgetState extends ConsumerState<PermissionHandlerWidget> {
  bool _isChecking = true;
  bool _hasPermission = false;
  int _androidVersion = 0;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permissionService = PermissionService.instance;
    
    final hasStorage = await permissionService.hasStoragePermission();
    final version = await permissionService.getAndroidVersion();
    
    if (mounted) {
      setState(() {
        _hasPermission = hasStorage;
        _androidVersion = version;
        _isChecking = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final permissionService = PermissionService.instance;
    await permissionService.requestStoragePermission();
    
    // Wait a bit and check again
    await Future.delayed(const Duration(seconds: 1));
    await _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_hasPermission) {
      return _buildPermissionRequest();
    }

    return widget.child;
  }

  Widget _buildPermissionRequest() {
    final permissionService = PermissionService.instance;
    final message = permissionService.getPermissionMessage(_androidVersion);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Permissão Necessária',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _requestPermission,
              icon: const Icon(Icons.lock_open),
              label: const Text('Conceder Permissão'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _checkPermissions,
              child: const Text('Já concedi, tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}