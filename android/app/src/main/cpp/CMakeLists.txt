cmake_minimum_required(VERSION 3.10.2)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. Add AegisCore Source Path
set(AEGIS_ROOT "/Users/dev/development/programming/aegiscore")
set(LOCAL_LEAN "${CMAKE_CURRENT_SOURCE_DIR}/aegis_lean")

# Include paths (Lean first to override Aegis.h if needed)
include_directories("${LOCAL_LEAN}")
include_directories("${AEGIS_ROOT}/core" "${AEGIS_ROOT}/core/vendor")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/include")

# 2. Add Sources (Explicit selection of Lean and Core components)
set(AEGIS_SOURCES
    # Lean Patched SDK/Aegis
    "${LOCAL_LEAN}/Aegis.cpp"
    "${LOCAL_LEAN}/AegisFlutterSDK.cpp"
    
    # Core Components (Safe)
    "${AEGIS_ROOT}/core/db/local_db.cpp"
    "${AEGIS_ROOT}/core/storage/storage_manager.cpp"
    "${AEGIS_ROOT}/core/sync/mutation_queue.cpp"
    "${AEGIS_ROOT}/core/sync/sync_manager.cpp"
    "${AEGIS_ROOT}/core/compression/delta_engine.cpp"
    
    # Bundled Dependencies
    "${CMAKE_CURRENT_SOURCE_DIR}/include/sqlite3.c"
)

# 3. Create Library
add_library(aegis_sdk SHARED ${AEGIS_SOURCES})

# 4. Link Dependencies (Log, Android)
find_library(log-lib log)
target_link_libraries(aegis_sdk ${log-lib})
