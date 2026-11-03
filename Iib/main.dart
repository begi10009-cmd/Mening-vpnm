import 'package:flutter/material.dart';
import 'package:flutter_vless/flutter_vless.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mening VPN',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: const VpnHomePage(),
    );
  }
}

class VpnHomePage extends StatefulWidget {
  const VpnHomePage({super.key});
  @override
  State<VpnHomePage> createState() => _VpnHomePageState();
}

class _VpnHomePageState extends State<VpnHomePage> {
  final String jsonConfig = r'''
  {
    "remarks": "Telegram",
    "log": { "loglevel": "warning" },
    "dns": { "tag": "dns", "queryStrategy": "UseIPv4", "disableCache": false, "servers": [ { "address": "77.88.8.8", "domains": ["geosite:category-ru", "regexp:.*\\.ru$"], "skipFallback": true }, "1.1.1.1" ] },
    "routing": {
      "domainStrategy": "IPIfNonMatch", "domainMatcher": "hybrid",
      "rules": [
        { "type": "field", "ip": ["geoip:private"], "outboundTag": "direct" },
        { "type": "field", "outboundTag": "direct", "domain": [ "geosite:category-ru", "regexp:.*\\.ru$" ] },
        { "type": "field", "network": "tcp,udp", "outboundTag": "proxy-1" }
      ]
    },
    "inbounds": [
      { "tag": "socks", "listen": "127.0.0.1", "port": 10808, "protocol": "socks", "settings": { "auth": "noauth", "udp": true }, "sniffing": { "enabled": true, "destOverride": ["http", "tls", "quic"], "routeOnly": true } }
    ],
    "outbounds": [
      {
        "tag": "proxy-1", "protocol": "vless",
        "settings": { "vnext": [{ "address": "213.182.203.130", "port": 443, "users": [{ "id": "64a30b1e-f330-4d93-83bf-d78a5344b34e", "encryption": "none", "flow": "" }] }] },
        "streamSettings": {
          "network": "grpc", "security": "tls",
          "grpcSettings": { "serviceName": "api.payments.v3", "multiMode": false },
          "tlsSettings": { "serverName": "api.spbkassa.info", "alpn": ["h2"], "fingerprint": "safari" },
          "sockopt": { "tcpNoDelay": true, "tcpFastOpen": true }
        },
        "mux": { "enabled": true, "concurrency": 8, "xudpConcurrency": 16, "xudpProxyUDP443": "allow" }
      },
      { "tag": "direct", "protocol": "freedom" }
    ]
  }
  ''';

  String status = "Ulanmagan";
  bool isConnected = false;

  Future<void> toggle() async {
    if (isConnected) {
      await FlutterVless.stopVless();
      setState(() { isConnected = false; status = "Ulanmagan"; });
    } else {
      setState(() => status = "Ulanmoqda...");
      try {
        await FlutterVless.initializeVless(config: jsonConfig);
        await FlutterVless.startVless();
        setState(() { isConnected = true; status = "Ulandi va Ishlayapti!"; });
      } catch (e) {
        setState(() { isConnected = false; status = "Xato: $e"; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mening VPN'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isConnected ? Icons.shield : Icons.shield_outlined, size: 120, color: isConnected ? Colors.green : Colors.grey),
            const SizedBox(height: 20),
            Text(status, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected ? Colors.red : Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              onPressed: toggle,
              child: Text(isConnected ? "Uzish" : "Ulanish", style: const TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
