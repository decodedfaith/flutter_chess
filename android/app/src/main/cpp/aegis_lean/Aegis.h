#pragma once

#include "db/ILocalDB.h"
#include "db/local_db.h"
#include "storage/storage_manager.h"
#include "sync/mutation_queue.h"
#include "sync/sync_manager.h"
// REMOVED: network, mesh, security includes
#include "sync/presence.h"
#include <memory>
#include <string>
#include <map>
#include <mutex>

namespace aegis {

struct AegisConfig {
    std::string dbPath = "aegis.db";
    std::string clientId = "unknown_client";
    uint16_t port = 8080;
    bool enableWAL = true;
    bool useSSL = false;
    std::string encryptionKey = ""; 
    bool enableMesh = false; 
    // REMOVED: NetworkChaosConfig chaos;
    std::string certPath = "aegis_identity.crt";
    std::string keyPath = "aegis_identity.key";
};

class Aegis {
public:
    static Aegis& instance() {
        static Aegis inst;
        return inst;
    }

    bool init(const AegisConfig& config = AegisConfig());

    db::ILocalDB& db() { return *m_db; }
    sync::SyncManager& syncManager() { return *m_sync; }

    // Stubs
    void startNetwork() {}
    void stopNetwork() {}
    void reset() {
        m_storage.reset();
        m_queue.reset();
        m_sync.reset();
        m_db.reset();
        m_networkActive = false;
    }

    bool isNetworkActive() const { return m_networkActive; }
    int getConnectedPeersCount() const { return 0; }
    int getPendingMutationsCount() const { 
        return m_queue ? static_cast<int>(m_queue->getAllPending().size()) : 0; 
    }
    
    void triggerSync() { if(m_sync) m_sync->replayMutations(); }
    void connectToPeer(const std::string& ip, int port) {}
    
    // REMOVED: CertManager access

    using DataChangeCallback = std::function<void(const std::string& key, const std::vector<uint8_t>& data)>;
    void setOnDataChange(DataChangeCallback callback) { m_onDataChangeCallback = callback; }

    enum class PairingStatus { IDLE, WAITING_FOR_PEER, NEGOTIATING, CONFIRMED, FAILED };

    void startPairing(int role, const std::string& pin) {} // Simplified role
    void confirmPairing() {} 
    void cancelPairing() {}
    PairingStatus getPairingStatus() const { return PairingStatus::IDLE; }

    std::vector<sync::Presence> getOnlinePeers(int64_t windowMs = 30000) { return {}; }
    void setPresenceStatus(const std::string& status, const std::string& currentDoc = "") {}
    void startPresenceHeartbeat(int intervalSeconds = 10) {}
    void stopPresenceHeartbeat() {}

    void setTypingStatus(bool isTyping) {}
    void setOnPeerTyping(std::function<void(const std::string& clientId, bool isTyping)> callback) {}

private:
    Aegis() = default;
    
    std::shared_ptr<storage::StorageManager> m_storage;
    std::shared_ptr<sync::MutationQueue> m_queue;
    std::shared_ptr<sync::SyncManager> m_sync;
    std::unique_ptr<db::LocalDB> m_db;

    DataChangeCallback m_onDataChangeCallback;
    AegisConfig m_config;
    bool m_networkActive = false;
};

} // namespace aegis
