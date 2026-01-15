#pragma once

#include <cstdint>
#include <functional>

#ifdef __cplusplus
extern "C" {
#endif

// ==================== LIFECYCLE ====================

/**
 * aegis_flutter_init
 * Flutter-optimized initialization with callback support.
 * 
 * @param db_path Path to SQLite database file
 * @param client_id Unique identifier for this client
 * @param port WebSocket server port (0 = disabled)
 * @param use_ssl Enable TLS/WSS
 * @param enc_key Encryption key (empty = no encryption)
 * @param enable_mesh Enable P2P mesh discovery
 * @return true if initialization succeeded
 */
bool aegis_flutter_init(
    const char* db_path,
    const char* client_id,
    int port,
    bool use_ssl,
    const char* enc_key,
    bool enable_mesh
);

/**
 * aegis_flutter_start_network
 * Starts network services (WebSocket server + Mesh discovery)
 */
void aegis_flutter_start_network();

/**
 * aegis_flutter_stop_network
 * Gracefully stops all network services
 */
void aegis_flutter_stop_network();

/**
 * aegis_flutter_shutdown
 * Cleanup and shutdown the SDK
 */
void aegis_flutter_shutdown();

// ==================== DATABASE CRUD ====================

/**
 * aegis_flutter_put
 * Stores binary data in the local database
 * 
 * @param key Document key/ID
 * @param data Binary data buffer
 * @param len Length of data in bytes
 * @return true if write succeeded
 */
bool aegis_flutter_put(const char* key, const uint8_t* data, int32_t len);

/**
 * aegis_flutter_put_batch
 * Stores multiple documents in a single atomic transaction.
 * 
 * @param json_items JSON string array of objects: [{"id":"k1","data":"base64..."}, ...]
 * @return true if all succeeded
 */
bool aegis_flutter_put_batch(const char* json_items);

/**
 * aegis_flutter_get
 * Retrieves binary data from local database
 * 
 * @param key Document key/ID
 * @param out_len Output parameter for data length
 * @return Pointer to data buffer (caller must call aegis_flutter_free_buffer)
 */
const uint8_t* aegis_flutter_get(const char* key, int32_t* out_len);

/**
 * aegis_flutter_delete
 * Removes a document from local database
 */
bool aegis_flutter_delete(const char* key);

/**
 * aegis_flutter_free_buffer
 * Frees memory allocated by aegis_flutter_get
 */
void aegis_flutter_free_buffer(const uint8_t* buffer);

// ==================== QUERY ENGINE & ATTACHMENTS (Phase 13) ====================

/**
 * aegis_flutter_query
 * Executes a structured JSON query against the database.
 * 
 * @param json_query Null-terminated JSON string specifying filters and value
 * @param out_len Output parameter for result JSON length
 * @return Pointer to result data (UTF-8 JSON string). Caller must free with aegis_flutter_free_buffer.
 */
const char* aegis_flutter_query(const char* json_query, int32_t* out_len);

/**
 * aegis_flutter_put_attachment
 * Stores a binary attachment (e.g. receipt image).
 * 
 * @param doc_id ID of the document to attach to
 * @param data Binary data pointer
 * @param len Length of data
 * @return true if successful
 */
bool aegis_flutter_put_attachment(const char* doc_id, const uint8_t* data, int32_t len);

/**
 * aegis_flutter_get_attachment
 * Retrieves a binary attachment.
 * 
 * @param doc_id ID of the document
 * @param out_len Output parameter for data length
 * @return Pointer to data. Caller must free with aegis_flutter_free_buffer.
 */
const uint8_t* aegis_flutter_get_attachment(const char* doc_id, int32_t* out_len);

// ==================== CALLBACKS ====================

// Callback type for data change events
typedef void (*AegisDataChangeCallback)(const char* key, const uint8_t* data, int32_t len);

// Callback type for peer discovery events
typedef void (*AegisPeerDiscoveredCallback)(const char* peer_name, const char* ip, int port);

/**
 * aegis_flutter_set_data_change_callback
 * Register a callback to be notified when remote data changes arrive
 */
void aegis_flutter_set_data_change_callback(AegisDataChangeCallback callback);

/**
 * aegis_flutter_set_peer_discovered_callback
 * Register a callback for P2P peer discovery events
 */
void aegis_flutter_set_peer_discovered_callback(AegisPeerDiscoveredCallback callback);

// ==================== STATUS ====================

/**
 * aegis_flutter_is_network_active
 * @return true if network services are running
 */
bool aegis_flutter_is_network_active();

/**
 * aegis_flutter_get_connected_peers_count
 * @return Number of currently connected P2P peers
 */
int32_t aegis_flutter_get_connected_peers_count();

/**
 * aegis_flutter_get_pending_mutations_count
 * @return Number of unsynced mutations in the queue
 */
int32_t aegis_flutter_get_pending_mutations_count();

// ==================== SYNC CONTROL ====================

/**
 * aegis_flutter_connect_to_peer
 * Manually connect to a specific peer
 */
void aegis_flutter_connect_to_peer(const char* ip, int port);

/**
 * aegis_flutter_trigger_sync
 * Force immediate sync attempt with all connected peers
 */
void aegis_flutter_trigger_sync();

// ==================== PAIRING & SECURITY (Phase 20) ====================

/**
 * aegis_flutter_start_pairing
 * Initiates SPAKE2+ pairing process.
 * @param role 0 = INITIATOR, 1 = RESPONDER
 * @param pin 6-digit numeric PIN
 */
void aegis_flutter_start_pairing(int role, const char* pin);

/**
 * aegis_flutter_confirm_pairing
 * Confirm multi-step pairing if needed.
 */
void aegis_flutter_confirm_pairing();

/**
 * aegis_flutter_cancel_pairing
 * Abort current pairing session.
 */
void aegis_flutter_cancel_pairing();

/**
 * aegis_flutter_get_pairing_status
 * 0=IDLE, 1=WAITING, 2=NEGOTIATING, 3=CONFIRMED, 4=FAILED
 */
int aegis_flutter_get_pairing_status();

void aegis_flutter_pin_peer(const char* peerId, const char* fingerprint);

// ==================== PRESENCE & TYPING (Phase 25/26) ====================

/**
 * aegis_flutter_get_online_peers
 * Returns a JSON array of active peers: [{"clientId":"...", "status":"...", "lastSeen":...}]
 */
const char* aegis_flutter_get_online_peers(int32_t* out_len);

/**
 * aegis_flutter_set_presence_status
 * Broadcasts local status to the mesh.
 */
void aegis_flutter_set_presence_status(const char* status, const char* current_doc);

/**
 * aegis_flutter_set_typing_status
 * Broadcasts whether the user is "thinking" or "typing".
 */
void aegis_flutter_set_typing_status(bool is_typing);

// Callback for peer typing events
typedef void (*AegisPeerTypingCallback)(const char* client_id, bool is_typing);

/**
 * aegis_flutter_set_peer_typing_callback
 * Register a callback to be notified when peers change their typing/thinking status.
 */
void aegis_flutter_set_peer_typing_callback(AegisPeerTypingCallback callback);

// ==================== OBSERVABILITY (Phase 28) ====================

/**
 * aegis_flutter_get_bandwidth_stats
 * Returns JSON: {"bytesSent": 0, "bytesReceived": 0}
 */
const char* aegis_flutter_get_bandwidth_stats(int32_t* out_len);

#ifdef __cplusplus
}
#endif
