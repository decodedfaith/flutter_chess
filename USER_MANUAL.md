# Flutter Chess: User Instruction Manual

Welcome to the **Flutter Chess** production build, powered by the **AegisCore Decentralized Engine**. This manual provides detailed instructions on how to use the app's features, with a focus on the new P2P mesh networking capabilities.

---

## 1. Getting Started

### Installation
-   **Android**: Locate the `app-release.apk` in the `build/app/outputs/flutter-apk/` directory and install it on your device.

### Permissions
-   **Modern Devices (Android 12/13+)**: You will be asked for **Nearby Devices** and **Bluetooth** permissions. On these newer devices, we **do not** require your location for discovery.
-   **Older Devices**: Location permission is required as a fallback technical requirement for Wifi-Direct and Bluetooth scanning.
-   **Privacy**: These permissions are purely for decentralized discovery; no data is sent to external servers.

---

## 2. P2P Multiplayer (AegisCore)

The headline feature of this build is decentralized, serverless play.

### Entering the Mesh Lobby
1.  On the **Landing Page**, tap **P2P Multiplayer**.
2.  The **Mesh Lobby** will open, and you'll see a **Radar Animation** indicating that the app is scanning for nearby rivals.

### Discovering & Challenging Peers
-   **Nearby List**: Any player on the same local network or within Bluetooth/Wifi proximity will appear in the "NEARBY PLAYERS" list.
-   **Challenge**: Tap on a player's name to send a challenge and immediately enter a synchronized game session.

### Private Pairing (PIN Flow)
If you want to connect securely with a specific friend:
1.  Tap **Generate Pairing PIN** in the lobby.
2.  Share the **4-digit PIN** displayed on your screen with your friend.
3.  This ensures an end-to-end encrypted (SPAKE2+) connection between your two devices.

### Real-time Gameplay Features
-   **Thinking Indicators**: When your opponent is selecting a piece or dragging it on their screen, you will see a subtle **three-dot "Thinking..." animation** next to their name in the HUD.
-   **Auto-Sync**: Moves are synchronized across the mesh in under 500ms. If one player makes a move, it updates on the other screen automatically.

---

## 3. Local Play

For playing with someone in person on a single device:
1.  Tap **Play Local**.
2.  Select your **Time Control** (e.g., 10 min, 3 min Blitz).
3.  Enter player names and tap **PLAY**.

---

## 4. In-Game Controls

-   **Flag Icon (Top Left)**: Resign the game.
-   **Flip Icon (Top Right)**: Flip the board perspective (useful for Local Play).
-   **captured Pieces**: View the material advantage at a glance in the HUD.
-   **Review Mode**: Once a game ends, tap **Review Game** to step through the move history and analyze your play.

---

## 5. Troubleshooting & FAQ

-   **"No Players Found"**: Ensure both devices have Wifi and Bluetooth enabled. If on a managed network (like a corporate office), ensure P2P discovery isn't blocked by the firewall.
-   **"Thinking" indicator stuck?**: This can happen if a peer loses connection mid-drag. Simply wait for the next move to refresh the state.
-   **Battery Usage**: P2P Mesh discovery consumes more battery than standard play. It is recommended to close the lobby when not in use.

---

*Enjoy the game! You are now part of the decentralized chess revolution.*
