class Peer {
  final String id;
  final String userName;
  final String ip;

  Peer({
    required this.id,
    required this.userName,
    required this.ip,
  });

  factory Peer.fromJson(Map<String, dynamic> json) {
    return Peer(
      id: json['id'] ?? json['clientId'] ?? '',
      userName: json['userName'] ?? json['name'] ?? 'Unknown Player',
      ip: json['ip'] ?? '0.0.0.0',
    );
  }
}
