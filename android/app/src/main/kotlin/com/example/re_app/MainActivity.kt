package com.example.re_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.telecom.TelecomManager
import android.telephony.TelephonyManager
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.re_app/tripper"
    private var telecomManager: TelecomManager? = null

    private val musicReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val title = intent?.getStringExtra("title")
            val artist = intent?.getStringExtra("artist")
            
            // Send to Flutter UI
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("onMusicUpdate", mapOf(
                "title" to title,
                "artist" to artist
            ))
            
            // Here we would also send to Bluetooth characteristic
            // sendToTripper(TripperProtocol.createTextPacket("$title - $artist"))
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "answerCall" -> {
                    answerCall()
                    result.success(null)
                }
                "endCall" -> {
                    endCall()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        registerReceiver(musicReceiver, IntentFilter("com.example.re_app.MUSIC_UPDATE"))
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(musicReceiver)
    }

    private fun answerCall() {
        try {
            if (telecomManager != null) {
                telecomManager!!.acceptRingingCall()
            }
        } catch (e: Exception) {
            Log.e("RE_Tripper", "Failed to answer call", e)
        }
    }

    private fun endCall() {
        try {
            if (telecomManager != null) {
                telecomManager!!.endCall()
            }
        } catch (e: Exception) {
            Log.e("RE_Tripper", "Failed to end call", e)
        }
    }
}
