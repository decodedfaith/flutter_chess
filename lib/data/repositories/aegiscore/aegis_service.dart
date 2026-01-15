// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chess/data/repositories/aegiscore/models/peer.dart';

/// High-level Dart service for AegisCore SDK
///
/// This wraps the low-level FFI bindings with a type-safe, idiomatic Dart API.
class AegisService {
  static AegisService? _instance;
  late final ffi.DynamicLibrary _lib;
  bool _initialized = false;

  // Function pointers
  late final _aegis_flutter_init = _lib.lookupFunction<
      ffi.Bool Function(
        ffi.Pointer<ffi.Char>,
        ffi.Pointer<ffi.Char>,
        ffi.Int32,
        ffi.Bool,
        ffi.Pointer<ffi.Char>,
        ffi.Bool,
      ),
      bool Function(
        ffi.Pointer<ffi.Char>,
        ffi.Pointer<ffi.Char>,
        int,
        bool,
        ffi.Pointer<ffi.Char>,
        bool,
      )>('aegis_flutter_init');

  late final _aegis_flutter_start_network =
      _lib.lookupFunction<ffi.Void Function(), void Function()>(
    'aegis_flutter_start_network',
  );

  late final _aegis_flutter_stop_network =
      _lib.lookupFunction<ffi.Void Function(), void Function()>(
    'aegis_flutter_stop_network',
  );

  late final _aegis_flutter_put = _lib.lookupFunction<
          ffi.Bool Function(
            ffi.Pointer<ffi.Char>,
            ffi.Pointer<ffi.Uint8>,
            ffi.Int32,
          ),
          bool Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Uint8>, int)>(
      'aegis_flutter_put');

  late final _aegis_flutter_get = _lib.lookupFunction<
      ffi.Pointer<ffi.Uint8> Function(
        ffi.Pointer<ffi.Char>,
        ffi.Pointer<ffi.Int32>,
      ),
      ffi.Pointer<ffi.Uint8> Function(
        ffi.Pointer<ffi.Char>,
        ffi.Pointer<ffi.Int32>,
      )>('aegis_flutter_get');

  late final _aegis_flutter_delete = _lib.lookupFunction<
      ffi.Bool Function(ffi.Pointer<ffi.Char>),
      bool Function(ffi.Pointer<ffi.Char>)>('aegis_flutter_delete');

  late final _aegis_flutter_free_buffer = _lib.lookupFunction<
      ffi.Void Function(ffi.Pointer<ffi.Uint8>),
      void Function(ffi.Pointer<ffi.Uint8>)>('aegis_flutter_free_buffer');

  late final _aegis_flutter_is_network_active =
      _lib.lookupFunction<ffi.Bool Function(), bool Function()>(
    'aegis_flutter_is_network_active',
  );

  late final _aegis_flutter_connect_to_peer = _lib.lookupFunction<
      ffi.Void Function(ffi.Pointer<ffi.Char>, ffi.Int32),
      void Function(
          ffi.Pointer<ffi.Char>, int)>('aegis_flutter_connect_to_peer');

  // Phase 15: Batch
  late final _aegis_db_put_batch = _lib.lookupFunction<
      ffi.Bool Function(ffi.Int32, ffi.Pointer<ffi.Pointer<ffi.Char>>,
          ffi.Pointer<ffi.Pointer<ffi.Uint8>>, ffi.Pointer<ffi.Int32>),
      bool Function(
          int,
          ffi.Pointer<ffi.Pointer<ffi.Char>>,
          ffi.Pointer<ffi.Pointer<ffi.Uint8>>,
          ffi.Pointer<ffi.Int32>)>('aegis_db_put_batch');

  // Phase 16: Query (Binary)
  late final _aegis_db_query = _lib.lookupFunction<
      ffi.Pointer<ffi.Uint8> Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Int32>),
      ffi.Pointer<ffi.Uint8> Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Int32>)>('aegis_db_query');

  // Phase 12-16: Attachments
  late final _aegis_db_put_attachment = _lib.lookupFunction<
      ffi.Bool Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Uint8>, ffi.Int32),
      bool Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Uint8>,
          int)>('aegis_db_put_attachment');

  late final _aegis_db_get_attachment = _lib.lookupFunction<
      ffi.Pointer<ffi.Uint8> Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Int32>),
      ffi.Pointer<ffi.Uint8> Function(ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Int32>)>('aegis_db_get_attachment');

  // Phase 17: Watch (Subscription)
  late final _aegis_watch = _lib.lookupFunction<
      ffi.Void Function(
          ffi.Pointer<
              ffi.NativeFunction<
                  ffi.Void Function(ffi.Pointer<ffi.Char>,
                      ffi.Pointer<ffi.Uint8>, ffi.Int32, ffi.Int32)>>),
      void Function(
          ffi.Pointer<
              ffi.NativeFunction<
                  ffi.Void Function(
                      ffi.Pointer<ffi.Char>,
                      ffi.Pointer<ffi.Uint8>,
                      ffi.Int32,
                      ffi.Int32)>>)>('aegis_watch');

  late final _aegis_unwatch = _lib
      .lookupFunction<ffi.Void Function(), void Function()>('aegis_unwatch');

  // Phase 25/26: Presence & Typing
  late final _aegis_flutter_get_online_peers = _lib.lookupFunction<
      ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Int32>),
      ffi.Pointer<ffi.Char> Function(
          ffi.Pointer<ffi.Int32>)>('aegis_flutter_get_online_peers');

  late final _aegis_flutter_set_presence_status = _lib.lookupFunction<
      ffi.Void Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>),
      void Function(ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>)>('aegis_flutter_set_presence_status');

  late final _aegis_flutter_set_typing_status =
      _lib.lookupFunction<ffi.Void Function(ffi.Bool), void Function(bool)>(
          'aegis_flutter_set_typing_status');

  late final _aegis_flutter_set_peer_typing_callback = _lib.lookupFunction<
      ffi.Void Function(
          ffi.Pointer<
              ffi.NativeFunction<
                  ffi.Void Function(ffi.Pointer<ffi.Char>, ffi.Bool)>>),
      void Function(
          ffi.Pointer<
              ffi.NativeFunction<
                  ffi.Void Function(ffi.Pointer<ffi.Char>,
                      ffi.Bool)>>)>('aegis_flutter_set_peer_typing_callback');

  // Phase 28: Observability
  late final _aegis_flutter_get_bandwidth_stats = _lib.lookupFunction<
      ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Int32>),
      ffi.Pointer<ffi.Char> Function(
          ffi.Pointer<ffi.Int32>)>('aegis_flutter_get_bandwidth_stats');

  final _typingController = StreamController<PeerTypingEvent>.broadcast();
  final _peerDiscoveredController = StreamController<Peer>.broadcast();

  /// Stream of peer discovery events
  Stream<Peer> get onPeerDiscovered => _peerDiscoveredController.stream;

  AegisService._() {
    // Load the dynamic library
    if (Platform.isAndroid) {
      _lib = ffi.DynamicLibrary.open('libaegis_sdk.so');
    } else if (Platform.isIOS) {
      _lib = ffi.DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      _lib = ffi.DynamicLibrary.open('build/libaegis_sdk.dylib');
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  /// Singleton instance access
  static AegisService get instance {
    _instance ??= AegisService._();
    return _instance!;
  }

  /// Initialize AegisCore SDK
  ///
  /// Must be called once during app startup before using any other methods.
  Future<bool> init({
    required String dbPath,
    required String clientId,
    int port = 0,
    bool useSSL = false,
    String encryptionKey = '',
    bool enableMesh = false,
  }) async {
    if (_initialized) {
      debugPrint('[AegisService] Already initialized');
      return true;
    }

    final dbPathPtr = dbPath.toNativeUtf8();
    final clientIdPtr = clientId.toNativeUtf8();
    final encKeyPtr = encryptionKey.toNativeUtf8();

    try {
      final result = _aegis_flutter_init(
        dbPathPtr.cast<ffi.Char>(),
        clientIdPtr.cast<ffi.Char>(),
        port,
        useSSL,
        encKeyPtr.cast<ffi.Char>(),
        enableMesh,
      );

      _initialized = result;
      return result;
    } finally {
      malloc.free(dbPathPtr);
      malloc.free(clientIdPtr);
      malloc.free(encKeyPtr);
    }
  }

  /// Start network services (WebSocket server + P2P mesh discovery)
  void startNetwork() {
    if (!_initialized) {
      throw StateError('AegisService not initialized. Call init() first.');
    }
    _aegis_flutter_start_network();
  }

  /// Stop network services
  void stopNetwork() {
    if (!_initialized) return;
    _aegis_flutter_stop_network();
  }

  /// Store binary data in local database
  ///
  /// Returns true if successful. Data is automatically synced to connected peers.
  Future<bool> put(String key, Uint8List data) async {
    if (!_initialized) {
      throw StateError('AegisService not initialized. Call init() first.');
    }

    final keyPtr = key.toNativeUtf8();
    final dataPtr = malloc.allocate<ffi.Uint8>(data.length);

    try {
      // Copy Dart bytes to native memory
      for (var i = 0; i < data.length; i++) {
        dataPtr[i] = data[i];
      }

      return _aegis_flutter_put(keyPtr.cast<ffi.Char>(), dataPtr, data.length);
    } finally {
      malloc.free(keyPtr);
      malloc.free(dataPtr);
    }
  }

  /// Store multiple documents in a single atomic transaction.
  ///
  /// Uses raw C-arrays for maximum performance (no JSON overhead).
  Future<bool> putBatch(Map<String, Uint8List> items) async {
    if (!_initialized) throw StateError('AegisService not initialized');

    final count = items.length;
    // Allocate arrays of pointers
    final idsPtr = malloc.allocate<ffi.Pointer<ffi.Char>>(
        count * ffi.sizeOf<ffi.Pointer<ffi.Char>>());
    final dataPtrs = malloc.allocate<ffi.Pointer<ffi.Uint8>>(
        count * ffi.sizeOf<ffi.Pointer<ffi.Uint8>>());
    final lensPtr = malloc.allocate<ffi.Int32>(count * ffi.sizeOf<ffi.Int32>());

    final allocsToFree = <ffi.Pointer>[];

    try {
      int i = 0;
      for (final entry in items.entries) {
        // ID
        final idUtf8 = entry.key.toNativeUtf8();
        allocsToFree.add(idUtf8);
        idsPtr[i] = idUtf8.cast();

        // Data
        final bytes = entry.value;
        final dPtr = malloc.allocate<ffi.Uint8>(bytes.length);
        allocsToFree.add(dPtr);

        // Copy bytes to C heap
        // Note: asTypedList view is faster but requires care with scope.
        // Here we copy explicitly for safety.
        final dList = dPtr.asTypedList(bytes.length);
        dList.setAll(0, bytes);

        dataPtrs[i] = dPtr;
        lensPtr[i] = bytes.length;
        i++;
      }

      return _aegis_db_put_batch(count, idsPtr, dataPtrs, lensPtr);
    } finally {
      allocsToFree.forEach(malloc.free);
      malloc.free(idsPtr);
      malloc.free(dataPtrs);
      malloc.free(lensPtr);
    }
  }

  /// Retrieve binary data from local database
  ///
  /// Returns null if key doesn't exist.
  Future<Uint8List?> get(String key) async {
    if (!_initialized) {
      throw StateError('AegisService not initialized. Call init() first.');
    }

    final keyPtr = key.toNativeUtf8();
    final lengthPtr = malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());

    try {
      final dataPtr = _aegis_flutter_get(keyPtr.cast<ffi.Char>(), lengthPtr);

      if (dataPtr == ffi.nullptr) {
        return null;
      }

      final length = lengthPtr.value;
      final result = Uint8List(length);

      // Copy native bytes to Dart
      for (var i = 0; i < length; i++) {
        result[i] = dataPtr[i];
      }

      // Free the native buffer
      _aegis_flutter_free_buffer(dataPtr);

      return result;
    } finally {
      malloc.free(keyPtr);
      malloc.free(lengthPtr);
    }
  }

  /// Delete a document from local database
  Future<bool> delete(String key) async {
    if (!_initialized) {
      throw StateError('AegisService not initialized. Call init() first.');
    }

    final keyPtr = key.toNativeUtf8();
    try {
      return _aegis_flutter_delete(keyPtr.cast<ffi.Char>());
    } finally {
      malloc.free(keyPtr);
    }
  }

  /// Check if network services are active
  bool get isNetworkActive {
    if (!_initialized) return false;
    return _aegis_flutter_is_network_active();
  }

  /// Manually connect to a peer by IP address
  void connectToPeer(String ip, int port) {
    if (!_initialized) {
      throw StateError('AegisService not initialized. Call init() first.');
    }

    final ipPtr = ip.toNativeUtf8();
    try {
      _aegis_flutter_connect_to_peer(ipPtr.cast<ffi.Char>(), port);
    } finally {
      malloc.free(ipPtr);
    }
  }

  // ==================== QUERY ENGINE (Phase 13) ====================

  // Legacy Lookups Removed: _aegis_flutter_query, _aegis_flutter_put_attachment, _aegis_flutter_get_attachment

  /// Execute a structured query against the local database.
  ///
  /// Returns List of Maps. Uses efficient binary packing from Core.
  Future<List<Map<String, dynamic>>> query({
    Map<String, dynamic>? filters,
    String? sortBy,
    bool ascending = true,
    int? limit,
  }) async {
    if (!_initialized) throw StateError('AegisService not initialized');

    // 1. Serialize Query to JSON (Input is still JSON for flexibility)
    final queryMap = <String, dynamic>{};
    if (filters != null) queryMap['filters'] = filters;
    if (sortBy != null) {
      queryMap['sort_by'] = sortBy;
      queryMap['sort_ascending'] = ascending;
    }
    if (limit != null) queryMap['limit'] = limit;

    final jsonStr = jsonEncode(queryMap);
    final jsonPtr = jsonStr.toNativeUtf8();
    final lenPtr = malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());

    try {
      // 2. Call FFI
      final resPtr = _aegis_db_query(jsonPtr.cast<ffi.Char>(), lenPtr);
      final totalBytes = lenPtr.value;

      if (totalBytes <= 4 || resPtr == ffi.nullptr) {
        return [];
      }

      // 3. Unpack Binary Protocol: [Total(4)][Len(4)][Data]...
      // Create a view
      final dataView = resPtr.asTypedList(totalBytes).buffer.asByteData();
      int offset = 0;

      final count = dataView.getUint32(
          offset, Endian.host); // Or little? FFI usually matches host.
      offset += 4;

      final results = <Map<String, dynamic>>[];

      for (int i = 0; i < count; i++) {
        if (offset + 4 > totalBytes) break;
        final itemLen = dataView.getUint32(offset, Endian.host);
        offset += 4;

        if (offset + itemLen > totalBytes) break;

        // Extract JSON bytes
        final itemBytes =
            resPtr.asTypedList(totalBytes).sublist(offset, offset + itemLen);
        offset += itemLen;

        // Parse JSON
        try {
          final jsonStr = utf8.decode(itemBytes);
          results.add(jsonDecode(jsonStr));
        } catch (e) {
          debugPrint("Error parsing item $i: $e");
        }
      }

      // Free native buffer
      _aegis_flutter_free_buffer(resPtr);

      return results;
    } finally {
      malloc.free(jsonPtr);
      malloc.free(lenPtr);
    }
  }

  /// Store a binary attachment securely.
  Future<bool> putAttachment(String docId, Uint8List data) async {
    if (!_initialized) throw StateError('AegisService not initialized');

    final idPtr = docId.toNativeUtf8();
    final dataPtr = malloc.allocate<ffi.Uint8>(data.length);

    try {
      // Use asTypedList for faster copy
      final blob = dataPtr.asTypedList(data.length);
      blob.setAll(0, data);

      return _aegis_db_put_attachment(
          idPtr.cast<ffi.Char>(), dataPtr, data.length);
    } finally {
      malloc.free(idPtr);
      malloc.free(dataPtr);
    }
  }

  /// Retrieve a binary attachment.
  Future<Uint8List?> getAttachment(String docId) async {
    if (!_initialized) throw StateError('AegisService not initialized');

    final idPtr = docId.toNativeUtf8();
    final lenPtr = malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());

    try {
      final dataPtr = _aegis_db_get_attachment(idPtr.cast<ffi.Char>(), lenPtr);
      final len = lenPtr.value;

      if (len > 0 && dataPtr != ffi.nullptr) {
        final result = Uint8List(len);
        final src = dataPtr.asTypedList(len);
        result.setAll(0, src);

        _aegis_flutter_free_buffer(dataPtr);
        return result;
      }
      return null;
    } finally {
      malloc.free(idPtr);
      malloc.free(lenPtr);
    }
  }

  // ==================== WATCH (Subscription) ====================
  // Stream for real-time updates
  // _changeController removed (unused).
  // Actually we need a StreamController
  // We can't import async easily without dart:async
  // But standard Stream logic applies.

  // Static callback for FFI
  static void _onDbChange(ffi.Pointer<ffi.Char> idPtr,
      ffi.Pointer<ffi.Uint8> dataPtr, int len, int type) {
    if (_instance == null) return;

    final id = idPtr.cast<Utf8>().toDartString();
    // type: 0=PUT, 1=DELETE

    // Dispatch to instance
    // _instance._dispatchChange(id, ...);
    debugPrint("DB Change: $id type: $type");
  }

  /// Subscribe to changes
  void watch() {
    final nativeCallback = ffi.Pointer.fromFunction<
        ffi.Void Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Uint8>,
            ffi.Int32, ffi.Int32)>(_onDbChange);

    _aegis_watch(nativeCallback);
  }

  void unwatch() {
    _aegis_unwatch();
  }

  // ==================== PRESENCE & TYPING ====================

  /// Get currently online peers from the mesh
  Future<List<Map<String, dynamic>>> getOnlinePeers() async {
    if (!_initialized) return [];
    final lenPtr = malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());
    try {
      final resPtr = _aegis_flutter_get_online_peers(lenPtr);
      if (resPtr == ffi.nullptr) return [];
      final res = resPtr.cast<Utf8>().toDartString();
      _aegis_flutter_free_buffer(resPtr.cast());
      return List<Map<String, dynamic>>.from(jsonDecode(res));
    } finally {
      malloc.free(lenPtr);
    }
  }

  /// Broadcast presence to the mesh
  void setPresenceStatus(String status, {String currentDoc = ''}) {
    if (!_initialized) return;
    final statusPtr = status.toNativeUtf8();
    final docPtr = currentDoc.toNativeUtf8();
    try {
      _aegis_flutter_set_presence_status(
          statusPtr.cast<ffi.Char>(), docPtr.cast<ffi.Char>());
    } finally {
      malloc.free(statusPtr);
      malloc.free(docPtr);
    }
  }

  /// Broadcast if you are thinking/typing
  void setTypingStatus(bool isTyping) {
    if (!_initialized) return;
    _aegis_flutter_set_typing_status(isTyping);
  }

  /// Stream of typing events from peers
  Stream<PeerTypingEvent> get onPeerTyping => _typingController.stream;

  static void _onPeerTyping(ffi.Pointer<ffi.Char> clientIdPtr, bool isTyping) {
    final clientId = clientIdPtr.cast<Utf8>().toDartString();
    _instance?._typingController
        .add(PeerTypingEvent(clientId: clientId, isTyping: isTyping));
  }

  /// Start listening for peer typing events
  void listenToPeerTyping() {
    final nativeCallback = ffi.Pointer.fromFunction<
        ffi.Void Function(ffi.Pointer<ffi.Char>, ffi.Bool)>(_onPeerTyping);
    _aegis_flutter_set_peer_typing_callback(nativeCallback);
  }

  // ==================== OBSERVABILITY ====================

  /// Get cumulative bandwidth stats
  Future<Map<String, dynamic>> getBandwidthStats() async {
    if (!_initialized) return {"bytesSent": 0, "bytesReceived": 0};
    final lenPtr = malloc.allocate<ffi.Int32>(ffi.sizeOf<ffi.Int32>());
    try {
      final resPtr = _aegis_flutter_get_bandwidth_stats(lenPtr);
      if (resPtr == ffi.nullptr) return {"bytesSent": 0, "bytesReceived": 0};
      final res = resPtr.cast<Utf8>().toDartString();
      _aegis_flutter_free_buffer(resPtr.cast());
      return Map<String, dynamic>.from(jsonDecode(res));
    } finally {
      malloc.free(lenPtr);
    }
  }
}

class PeerTypingEvent {
  final String clientId;
  final bool isTyping;
  PeerTypingEvent({required this.clientId, required this.isTyping});
}
