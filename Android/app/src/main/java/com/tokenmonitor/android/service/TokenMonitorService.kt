package com.tokenmonitor.android.service

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.tokenmonitor.android.MainActivity
import com.tokenmonitor.android.R
import com.tokenmonitor.android.model.BalanceInfo
import com.tokenmonitor.android.model.Platform
import com.tokenmonitor.android.util.PreferenceManager
import java.util.*
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

class TokenMonitorService : Service() {

    companion object {
        const val NOTIFICATION_CHANNEL_ID = "token_monitor_channel"
        const val NOTIFICATION_ID = 1001
        const val ACTION_START = "com.tokenmonitor.android.START"
        const val ACTION_STOP = "com.tokenmonitor.android.STOP"
        const val ACTION_REFRESH = "com.tokenmonitor.android.REFRESH"
    }

    private lateinit var preferenceManager: PreferenceManager
    private lateinit var tokenApiService: TokenApiService
    private var scheduler: ScheduledExecutorService? = null
    private var currentBalance: BalanceInfo? = null

    override fun onCreate() {
        super.onCreate()
        preferenceManager = PreferenceManager(this)
        tokenApiService = TokenApiService()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startMonitoring()
            ACTION_STOP -> stopMonitoring()
            ACTION_REFRESH -> refreshBalance()
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            NOTIFICATION_CHANNEL_ID,
            getString(R.string.notification_channel_name),
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = getString(R.string.notification_channel_desc)
            setShowBadge(false)
        }

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(channel)
    }

    private fun startMonitoring() {
        preferenceManager.setMonitoringEnabled(true)

        // 立即刷新一次
        refreshBalance()

        // 设置定时刷新
        val interval = preferenceManager.getRefreshInterval()
        scheduler = Executors.newSingleThreadScheduledExecutor()
        scheduler?.scheduleAtFixedRate(
            { refreshBalance() },
            interval,
            interval,
            TimeUnit.MILLISECONDS
        )

        // 启动前台服务
        startForeground(NOTIFICATION_ID, buildNotification(null))
    }

    private fun stopMonitoring() {
        preferenceManager.setMonitoringEnabled(false)
        scheduler?.shutdown()
        scheduler = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun refreshBalance() {
        val platform = preferenceManager.getSelectedPlatform()
        val apiKey = preferenceManager.getApiKey(platform)

        if (apiKey.isNullOrEmpty()) {
            updateNotification(null, "未配置API Key")
            return
        }

        Thread {
            val result = tokenApiService.fetchBalance(platform, apiKey)
            result.onSuccess { balance ->
                currentBalance = balance
                updateNotification(balance, null)
            }.onFailure { error ->
                updateNotification(null, "获取失败: ${error.message}")
            }
        }.start()
    }

    private fun buildNotification(balance: BalanceInfo?, error: String?): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val platform = preferenceManager.getSelectedPlatform()

        val title = "${platform.displayName} Token余额"
        val content = when {
            error != null -> error
            balance != null -> "余额: ${balance.formattedBalance} ${balance.currency} | ${balance.statusText}"
            else -> getString(R.string.not_configured)
        }

        val builder = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(content)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setShowWhen(false)

        // 添加刷新动作
        val refreshIntent = Intent(this, TokenMonitorService::class.java).apply {
            action = ACTION_REFRESH
        }
        val refreshPendingIntent = PendingIntent.getService(
            this, 1, refreshIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        builder.addAction(R.drawable.ic_refresh, getString(R.string.refresh), refreshPendingIntent)

        // 添加停止动作
        val stopIntent = Intent(this, TokenMonitorService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 2, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        builder.addAction(R.drawable.ic_stop, getString(R.string.stop_monitor), stopPendingIntent)

        return builder.build()
    }

    private fun updateNotification(balance: BalanceInfo?, error: String?) {
        val notification = buildNotification(balance, error)
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    override fun onDestroy() {
        super.onDestroy()
        scheduler?.shutdown()
    }
}
