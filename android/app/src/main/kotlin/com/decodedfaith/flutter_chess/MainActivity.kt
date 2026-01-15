package com.decodedfaith.flutter_chess

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.decodedfaith.flutter_chess/info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSdkVersion") {
                result.success(Build.VERSION.SDK_INT)
            } else {
                result.notImplemented()
            }
        }
    }
}
