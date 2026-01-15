#include "Aegis.h"
#include <iostream>

namespace aegis {

bool Aegis::init(const AegisConfig& config) {
    m_config = config;

    // 1. Storage
    m_storage = std::make_shared<storage::StorageManager>();
    if (!m_storage->init(m_config.dbPath, m_config.encryptionKey)) {
        return false;
    }

    // 2. Queue
    m_queue = std::make_shared<sync::MutationQueue>(m_storage);
    
    // 3. Sync Manager
    m_sync = std::make_shared<sync::SyncManager>(m_queue);
    
    // Wire Notification: Queue -> SyncManager (Essential for local logic)
    m_queue->setOnMutationAdded([this](const storage::Mutation& mutation) {
        if (m_sync) {
            m_sync->onMutationAdded(mutation);
        }
    });

    // 4. Local DB API
    m_db = std::make_unique<db::LocalDB>(m_storage, m_queue, m_config.clientId);

    // Wire Incoming Updates (Local Only for Lean)
    m_sync->setOnRemoteUpdate([this](const std::string& key, const std::vector<uint8_t>& data, const storage::SyncMetadata& meta) {
        if (m_db && m_db->applyRemoteUpdate(key, data, meta)) {
            if (m_onDataChangeCallback) {
                m_onDataChangeCallback(key, data);
            }
        }
    });

    std::cout << "[Aegis-Lean] Engine initialized (Network Stubbed). DB: " << m_config.dbPath << std::endl;
    return true;
}

} // namespace aegis
