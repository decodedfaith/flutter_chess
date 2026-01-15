#include "AegisFlutterSDK.h"
#include "Aegis.h"
#include <iostream>
#include <cstring>
#include <cstring>
#include <mutex>
#include <nlohmann/json.hpp>

// Global callback storage
static AegisDataChangeCallback g_data_change_callback = nullptr;
static AegisPeerDiscoveredCallback g_peer_discovered_callback = nullptr;
static std::mutex g_callback_mutex;

// Internal triggers
void aegis_flutter_internal_trigger_data_change(const char* key, const std::vector<uint8_t>& data);

// ==================== LIFECYCLE ====================

bool aegis_flutter_init(
    const char* db_path,
    const char* client_id,
    int port,
    bool use_ssl,
    const char* enc_key,
    bool enable_mesh
) {
    try {
        aegis::AegisConfig config;
        config.dbPath = db_path ? db_path : "aegis.db";
        config.clientId = client_id ? client_id : "flutter_client";
        config.port = static_cast<uint16_t>(port);
        config.useSSL = use_ssl;
        config.encryptionKey = enc_key ? enc_key : "";
        config.enableMesh = enable_mesh;
        
        bool success = aegis::Aegis::instance().init(config);
        if (success) {
            // Wire up callbacks
            aegis::Aegis::instance().setOnDataChange([](const std::string& key, const std::vector<uint8_t>& data) {
                aegis_flutter_internal_trigger_data_change(key.c_str(), data);
            });
        }
        return success;
    } catch (const std::exception& e) {
        std::cerr << "[AegisFlutterSDK] Init failed: " << e.what() << std::endl;
        return false;
    }
}

void aegis_flutter_start_network() {
    try {
        aegis::Aegis::instance().startNetwork();
    } catch (const std::exception& e) {
        std::cerr << "[AegisFlutterSDK] Start network failed: " << e.what() << std::endl;
    }
}

void aegis_flutter_stop_network() {
    try {
        aegis::Aegis::instance().stopNetwork();
    } catch (const std::exception& e) {
        std::cerr << "[AegisFlutterSDK] Stop network failed: " << e.what() << std::endl;
    }
}

void aegis_flutter_shutdown() {
    try {
        aegis::Aegis::instance().reset();
        
        // Clear callbacks
        std::lock_guard<std::mutex> lock(g_callback_mutex);
        g_data_change_callback = nullptr;
        g_peer_discovered_callback = nullptr;
    } catch (const std::exception& e) {
        std::cerr << "[AegisFlutterSDK] Shutdown failed: " << e.what() << std::endl;
    }
}

// ==================== DATABASE CRUD ====================

bool aegis_flutter_put(const char* key, const uint8_t* data, int32_t len) {
    if (!key || !data || len <= 0) return false;
    
    try {
        std::vector<uint8_t> buffer(data, data + len);
        aegis::Aegis::instance().db().put(key, buffer);
        return true;
    } catch (const std::exception& e) {
        std::cerr << "[AegisFlutterSDK] Put failed: " << e.what() << std::endl;
        return false;
    }
}



// Helper: Base64 Decode
std::vector<uint8_t> base64_decode(const std::string& in) {
    static const std::string base64_chars = 
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz"
        "0123456789+/";

    auto is_base64 = [](unsigned char c) {
        return (isalnum(c) || (c == '+') || (c == '/'));
    };

    int in_len = static_cast<int>(in.size());
    int i = 0;
    int j = 0;
    int in_ = 0;
    unsigned char char_array_4[4], char_array_3[3];
    std::vector<uint8_t> ret;

    while (in_len-- && ( in[in_] != '=') && is_base64(in[in_])) {
        char_array_4[i++] = in[in_]; in_++;
        if (i ==4) {
            for (i = 0; i <4; i++)
                char_array_4[i] = (unsigned char)base64_chars.find(char_array_4[i]);

            char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
            char_array_3[1] = ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
            char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];

            for (i = 0; (i < 3); i++)
                ret.push_back(char_array_3[i]);
            i = 0;
        }
    }

    if (i) {
        for (j = i; j <4; j++)
            char_array_4[j] = 0;

        for (j = 0; j <4; j++)
            char_array_4[j] = (unsigned char)base64_chars.find(char_array_4[j]);

        char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
        char_array_3[1] = ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
        char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];

        for (j = 0; (j < i - 1); j++) ret.push_back(char_array_3[j]);
    }

    return ret;
}

bool aegis_flutter_put_batch(const char* json_items) {
    if (!json_items) return false;
    
    try {
        auto j = nlohmann::json::parse(json_items);
        if (!j.is_array()) return false;
        
        std::vector<std::pair<std::string, std::vector<uint8_t>>> batch;
        batch.reserve(j.size());
        
        for (const auto& item : j) {
            if (item.contains("id") && item.contains("data")) {
                std::string id = item["id"];
                std::string b64 = item["data"];
                batch.emplace_back(id, base64_decode(b64));
            }
        }
        
        return aegis::Aegis::instance().db().putBatch(batch);
    } catch (const std::exception& e) {
        std::cerr << "[SDK] PutBatch Failed: " << e.what() << std::endl;
        return false;
    }
}

const uint8_t* aegis_flutter_get(const char* key, int32_t* out_len) {
    if (!key || !out_len) return nullptr;
    
    try {
        auto maybeData = aegis::Aegis::instance().db().get(key);
        
        // Check if optional has value
        if (!maybeData.has_value()) {
            *out_len = 0;
            return nullptr;
        }
        
        // Get the actual vector from optional
        const auto& data = maybeData.value();
        
        if (data.empty()) {
            *out_len = 0;
            return nullptr;
        }
        
        // Allocate buffer for Dart (caller must free)
        uint8_t* buffer = new uint8_t[data.size()];
        std::memcpy(buffer, data.data(), data.size());
        *out_len = static_cast<int32_t>(data.size());
        
        return buffer;
    } catch (const std::exception& e) {
        std::cerr << "[AegisFlutterSDK] Get failed: " << e.what() << std::endl;
        *out_len = 0;
        return nullptr;
    }
}

bool aegis_flutter_delete(const char* key) {
    if (!key) return false;
    
    try {
        aegis::Aegis::instance().db().del(key);
        return true;
    } catch (const std::exception& e) {
        std::cerr << "[AegisFlutterSDK] Delete failed: " << e.what() << std::endl;
        return false;
    }
}

void aegis_flutter_free_buffer(const uint8_t* buffer) {
    if (buffer) {
        delete[] buffer;
    }
}

// ==================== QUERY ENGINE & ATTACHMENTS (Phase 13) ====================

#include "db/query.h"
#include <nlohmann/json.hpp>

// Helper to parse query JSON into Query struct
aegis::db::Query parse_query_json(const char* json_str) {
    aegis::db::Query q;
    try {
        auto j = nlohmann::json::parse(json_str);
        
        // Parse filters
        if (j.contains("filters") && j["filters"].is_object()) {
            for (auto& [key, val] : j["filters"].items()) {
                aegis::db::QueryFilter filter;
                filter.field = key;
                
                // Simplified dynamic filter parsing for MVP
                // Expecting object: { "op": "EQ", "val": ... }
                // Or simple value (implies EQ)
                if (val.is_object() && val.contains("op") && val.contains("val")) {
                    std::string opStr = val["op"];
                    if (opStr == "EQ") filter.op = aegis::db::FilterOp::EQ;
                    else if (opStr == "GT") filter.op = aegis::db::FilterOp::GT;
                    else if (opStr == "LT") filter.op = aegis::db::FilterOp::LT;
                    else if (opStr == "CONTAINS") filter.op = aegis::db::FilterOp::CONTAINS;
                    
                    auto v = val["val"];
                    if (v.is_number_float()) filter.value = v.get<double>();
                    else if (v.is_number_integer()) filter.value = v.get<int64_t>();
                    else if (v.is_string()) filter.value = v.get<std::string>();
                } else {
                    // Default EQ
                    filter.op = aegis::db::FilterOp::EQ;
                    if (val.is_number_float()) filter.value = val.get<double>();
                    else if (val.is_number_integer()) filter.value = val.get<int64_t>();
                    else if (val.is_string()) filter.value = val.get<std::string>();
                }
                q.filters.push_back(filter);
            }
        }
        
        // Parse Sort
        if (j.contains("sort_by") && j["sort_by"].is_string()) {
            q.sort_by = j["sort_by"].get<std::string>();
        }
        if (j.contains("sort_ascending") && j["sort_ascending"].is_boolean()) {
            q.sort_ascending = j["sort_ascending"].get<bool>();
        }

        // Parse Limit
        if (j.contains("limit") && j["limit"].is_number_integer()) {
            q.limit = j["limit"].get<int>();
        }
        
    } catch (const std::exception& e) {
        std::cerr << "[SDK] Query Parse Error: " << e.what() << std::endl;
    }
    return q;
}

const char* aegis_flutter_query(const char* json_query, int32_t* out_len) {
    if (!json_query || !out_len) return nullptr;
    
    try {
        auto query = parse_query_json(json_query);
        auto results = aegis::Aegis::instance().db().query(query);
        
        // Serialize results to JSON array
        nlohmann::json j_results = nlohmann::json::array();
        for (const auto& doc : results) {
            try {
                // Parse the raw doc bytes as JSON to embed directly
                auto doc_json = nlohmann::json::parse(reinterpret_cast<const char*>(doc.data()), 
                                                    reinterpret_cast<const char*>(doc.data() + doc.size()));
                j_results.push_back(doc_json);
            } catch (...) {
                // Skip invalid docs
            }
        }
        
        std::string res_str = j_results.dump();
        
        // Allocate buffer (caller frees via free_buffer? No, this is char*... we need a specific free for string or reuse free_buffer)
        // Reusing free_buffer but casting to uint8_t* is safe given standard allocators.
        char* buffer = new char[res_str.size() + 1];
        std::memcpy(buffer, res_str.c_str(), res_str.size() + 1);
        
        *out_len = static_cast<int32_t>(res_str.size());
        return buffer;
        
    } catch (const std::exception& e) {
        std::cerr << "[SDK] Query Failed: " << e.what() << std::endl;
        *out_len = 0;
        return nullptr;
    }
}

bool aegis_flutter_put_attachment(const char* doc_id, const uint8_t* data, int32_t len) {
    if (!doc_id || !data || len <= 0) return false;
    try {
        std::vector<uint8_t> buffer(data, data + len);
        return aegis::Aegis::instance().db().putAttachment(doc_id, buffer);
    } catch (...) { return false; }
}

const uint8_t* aegis_flutter_get_attachment(const char* doc_id, int32_t* out_len) {
    if (!doc_id || !out_len) return nullptr;
    try {
        auto maybeData = aegis::Aegis::instance().db().getAttachment(doc_id);
        if (!maybeData.has_value() || maybeData->empty()) {
            *out_len = 0;
            return nullptr;
        }
        const auto& data = maybeData.value();
        uint8_t* buffer = new uint8_t[data.size()];
        std::memcpy(buffer, data.data(), data.size());
        *out_len = static_cast<int32_t>(data.size());
        return buffer;
    } catch (...) {
        *out_len = 0;
        return nullptr;
    }
}

// ==================== CALLBACKS ====================

void aegis_flutter_set_data_change_callback(AegisDataChangeCallback callback) {
    std::lock_guard<std::mutex> lock(g_callback_mutex);
    g_data_change_callback = callback;
}

void aegis_flutter_set_peer_discovered_callback(AegisPeerDiscoveredCallback callback) {
    std::lock_guard<std::mutex> lock(g_callback_mutex);
    g_peer_discovered_callback = callback;
}

// Helper to trigger data change callback (called internally when sync receives data)
void aegis_flutter_internal_trigger_data_change(const char* key, const std::vector<uint8_t>& data) {
    std::lock_guard<std::mutex> lock(g_callback_mutex);
    if (g_data_change_callback) {
        g_data_change_callback(key, data.data(), static_cast<int32_t>(data.size()));
    }
}

// Helper to trigger peer discovered callback
void aegis_flutter_internal_trigger_peer_discovered(const char* peer_name, const char* ip, int port) {
    std::lock_guard<std::mutex> lock(g_callback_mutex);
    if (g_peer_discovered_callback) {
        g_peer_discovered_callback(peer_name, ip, port);
    }
}

// ==================== STATUS ====================

bool aegis_flutter_is_network_active() {
    try {
        return aegis::Aegis::instance().isNetworkActive();
    } catch (const std::exception& e) {
        std::cerr << "[AegisFlutterSDK] Status check failed: " << e.what() << std::endl;
        return false;
    }
}

int32_t aegis_flutter_get_connected_peers_count() {
    try {
        return aegis::Aegis::instance().getConnectedPeersCount();
    } catch (...) { return 0; }
}

int32_t aegis_flutter_get_pending_mutations_count() {
    try {
        return aegis::Aegis::instance().getPendingMutationsCount();
    } catch (...) { return 0; }
}

// ==================== SYNC CONTROL ====================

void aegis_flutter_connect_to_peer(const char* ip, int port) {
    if (!ip) return;
    
    try {
        aegis::Aegis::instance().connectToPeer(ip, port);
    } catch (const std::exception& e) {
        std::cerr << "[AegisFlutterSDK] Connect to peer failed: " << e.what() << std::endl;
    }
}

void aegis_flutter_trigger_sync() {
    try {
        aegis::Aegis::instance().triggerSync();
    } catch (...) {}
}

// ==================== PAIRING & SECURITY (Phase 20) ====================

void aegis_flutter_start_pairing(int role, const char* pin) {
    if (!pin) return;
    try {
        aegis::Aegis::instance().startPairing(role, pin);
    } catch (...) {}
}

void aegis_flutter_confirm_pairing() {
    try {
        aegis::Aegis::instance().confirmPairing();
    } catch (...) {}
}

void aegis_flutter_cancel_pairing() {
     try {
        aegis::Aegis::instance().cancelPairing();
    } catch (...) {}
}

int aegis_flutter_get_pairing_status() {
     try {
        return static_cast<int>(aegis::Aegis::instance().getPairingStatus());
    } catch (...) { return 0; }
}

void aegis_flutter_pin_peer(const char* peerId, const char* fingerprint) {
}

// ==================== PRESENCE & TYPING (Phase 25/26) ====================

static AegisPeerTypingCallback g_peer_typing_callback = nullptr;

const char* aegis_flutter_get_online_peers(int32_t* out_len) {
    if (!out_len) return nullptr;
    try {
        auto peers = aegis::Aegis::instance().getOnlinePeers();
        nlohmann::json j_peers = nlohmann::json::array();
        for (const auto& p : peers) {
            j_peers.push_back({
                {"clientId", p.clientId},
                {"status", p.status},
                {"currentDoc", p.currentDocId},
                {"lastSeen", p.lastSeen}
            });
        }
        std::string res = j_peers.dump();
        char* buffer = new char[res.size() + 1];
        std::memcpy(buffer, res.c_str(), res.size() + 1);
        *out_len = static_cast<int32_t>(res.size());
        return buffer;
    } catch (...) {
        *out_len = 0;
        return nullptr;
    }
}

void aegis_flutter_set_presence_status(const char* status, const char* current_doc) {
    if (!status) return;
    try {
        aegis::Aegis::instance().setPresenceStatus(status, current_doc ? current_doc : "");
    } catch (...) {}
}

void aegis_flutter_set_typing_status(bool is_typing) {
    try {
        aegis::Aegis::instance().setTypingStatus(is_typing);
    } catch (...) {}
}

void aegis_flutter_set_peer_typing_callback(AegisPeerTypingCallback callback) {
    std::lock_guard<std::mutex> lock(g_callback_mutex);
    g_peer_typing_callback = callback;
}

// ==================== OBSERVABILITY (Phase 28) ====================

const char* aegis_flutter_get_bandwidth_stats(int32_t* out_len) {
    if (!out_len) return nullptr;
    *out_len = 0;
    return nullptr;
}
