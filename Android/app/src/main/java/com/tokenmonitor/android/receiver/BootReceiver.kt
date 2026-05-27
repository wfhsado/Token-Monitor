package com.tokenmonitor.android.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.tokenmonitor.android.service.TokenMonitorService
import com.tokenmonitor.android.util.PreferenceManager

class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val preferenceManager = PreferenceManager(context)
            if (preferenceManager.isMonitoringEnabled()) {
                val serviceIntent = Intent(context, TokenMonitorService::class.java).apply {
                    action = TokenMonitorService.ACTION_START
                }
                context.startForegroundService(serviceIntent)
            }
        }
    }
}
