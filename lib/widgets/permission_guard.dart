import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

/// A widget that guards its child by ensuring necessary permissions are granted.
///
/// Refined for Android 12/13+ to avoid unnecessary Location permission prompts.
class PermissionGuard extends StatefulWidget {
  final Widget child;

  const PermissionGuard({super.key, required this.child});

  @override
  State<PermissionGuard> createState() => _PermissionGuardState();
}

class _PermissionGuardState extends State<PermissionGuard>
    with WidgetsBindingObserver {
  bool _hasPermissions = false;
  bool _isLoading = true;
  static const _channel = MethodChannel('com.decodedfaith.flutter_chess/info');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    if (!mounted) return;

    if (!Platform.isAndroid && !Platform.isIOS) {
      setState(() {
        _hasPermissions = true;
        _isLoading = false;
      });
      return;
    }

    final requiredPermissions = await _getRequiredPermissions();
    bool allGranted = true;

    for (var permission in requiredPermissions) {
      final status = await permission.status;
      debugPrint('[PermissionGuard] Checking $permission: $status');

      // On some Android 12+ devices, Location might be 'denied' but not required if Nearby is granted.
      // However, for simplicity and reliability, we check all that the SDK-version-logic deemed required.
      if (!status.isGranted && !status.isLimited) {
        allGranted = false;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _hasPermissions = allGranted;
        _isLoading = false;
      });
      debugPrint('[PermissionGuard] All permissions granted: $allGranted');
    }
  }

  Future<List<Permission>> _getRequiredPermissions() async {
    if (Platform.isAndroid) {
      int sdkVersion = 0;
      try {
        sdkVersion = await _channel.invokeMethod<int>('getSdkVersion') ?? 0;
      } catch (e) {
        debugPrint('[PermissionGuard] Error getting SDK version: $e');
      }

      debugPrint('[PermissionGuard] Android SDK Version: $sdkVersion');

      if (sdkVersion >= 33) {
        // Android 13+: Nearby Wifi is the primary requirement.
        // Location is NOT strictly required for P2P discovery anymore.
        return [
          Permission.nearbyWifiDevices,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ];
      } else if (sdkVersion >= 31) {
        // Android 12: Bluetooth Scan/Connect with Location.
        return [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ];
      } else {
        // Older Android: Location is the only way to scan for Wifi/BT.
        return [
          Permission.location,
        ];
      }
    }
    return [];
  }

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);

    final permissions = await _getRequiredPermissions();
    debugPrint('[PermissionGuard] Requesting: $permissions');

    final statuses = await permissions.request();

    // Log the results for debugging
    statuses
        .forEach((p, s) => debugPrint('[PermissionGuard] Result for $p: $s'));

    // Re-check systematically
    await _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Scaffold(
        key: ValueKey('loading'),
        backgroundColor: Color(0xFF262421),
        body: SizedBox.shrink(),
      );
    }

    if (_hasPermissions) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF262421),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_tethering_off,
                size: 64, color: Colors.orangeAccent),
            const SizedBox(height: 24),
            Text(
              'Permissions Required',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To play multiplayer with nearby devices, we need to discover other players using WiFi and Bluetooth.\n\nModern devices won\'t even ask for your location! On older devices, please ensure Location Services are ON.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _requestPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF81B64C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Grant Permissions',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _checkPermissions,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'I already granted them (Refresh)',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: Text(
                'Open App Settings',
                style: GoogleFonts.inter(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
