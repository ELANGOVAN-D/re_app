package com.example.re_app

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.content.Intent
import android.media.MediaMetadata
import android.util.Log

class MusicNotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        val extras = sbn.notification.extras
        
        // Filter for music apps (usually have MediaMetadata)
        val title = extras.getString("android.title")
        val artist = extras.getString("android.text")
        
        if (title != null && artist != null) {
            Log.d("RE_Tripper", "Music detected: $title by $artist")
            
            val intent = Intent("com.example.re_app.MUSIC_UPDATE")
            intent.putExtra("title", title)
            intent.putExtra("artist", artist)
            sendBroadcast(intent)
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        // Handle stop
    }
}
