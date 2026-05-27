package com.tokenmonitor.android

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.tokenmonitor.android.model.Platform
import com.tokenmonitor.android.service.TokenMonitorService
import com.tokenmonitor.android.service.TokenApiService
import com.tokenmonitor.android.util.PreferenceManager

class MainActivity : AppCompatActivity() {

    private lateinit var preferenceManager: PreferenceManager
    private lateinit var tokenApiService: TokenApiService

    private lateinit var spinnerPlatform: Spinner
    private lateinit var etApiKey: EditText
    private lateinit var btnSave: Button
    private lateinit var btnRefresh: Button
    private lateinit var btnToggleMonitor: Button
    private lateinit var tvBalance: TextView
    private lateinit var tvStatus: TextView

    private var selectedPlatform: Platform = Platform.DEEPSEEK

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        preferenceManager = PreferenceManager(this)
        tokenApiService = TokenApiService()

        initViews()
        setupPlatformSpinner()
        loadSavedApiKey()
        checkNotificationPermission()
    }

    private fun initViews() {
        spinnerPlatform = findViewById(R.id.spinnerPlatform)
        etApiKey = findViewById(R.id.etApiKey)
        btnSave = findViewById(R.id.btnSave)
        btnRefresh = findViewById(R.id.btnRefresh)
        btnToggleMonitor = findViewById(R.id.btnToggleMonitor)
        tvBalance = findViewById(R.id.tvBalance)
        tvStatus = findViewById(R.id.tvStatus)

        btnSave.setOnClickListener { saveApiKey() }
        btnRefresh.setOnClickListener { refreshBalance() }
        btnToggleMonitor.setOnClickListener { toggleMonitoring() }

        updateMonitorButton()
    }

    private fun setupPlatformSpinner() {
        val platforms = Platform.values().map { it.displayName }
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, platforms)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        spinnerPlatform.adapter = adapter

        spinnerPlatform.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: android.view.View?, position: Int, id: Long) {
                selectedPlatform = Platform.values()[position]
                preferenceManager.setSelectedPlatform(selectedPlatform)
                loadSavedApiKey()
            }

            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }

        // 恢复上次选择的平台
        selectedPlatform = preferenceManager.getSelectedPlatform()
        spinnerPlatform.setSelection(selectedPlatform.ordinal)
    }

    private fun loadSavedApiKey() {
        val apiKey = preferenceManager.getApiKey(selectedPlatform)
        etApiKey.setText(apiKey ?: "")
    }

    private fun saveApiKey() {
        val apiKey = etApiKey.text.toString().trim()
        if (apiKey.isEmpty()) {
            Toast.makeText(this, "请输入API Key", Toast.LENGTH_SHORT).show()
            return
        }

        preferenceManager.saveApiKey(selectedPlatform, apiKey)
        Toast.makeText(this, "API Key已保存", Toast.LENGTH_SHORT).show()
    }

    private fun refreshBalance() {
        val apiKey = preferenceManager.getApiKey(selectedPlatform)
        if (apiKey.isNullOrEmpty()) {
            Toast.makeText(this, "请先保存API Key", Toast.LENGTH_SHORT).show()
            return
        }

        tvBalance.text = "加载中..."
        tvStatus.text = ""

        Thread {
            val result = tokenApiService.fetchBalance(selectedPlatform, apiKey)
            runOnUiThread {
                result.onSuccess { balance ->
                    tvBalance.text = "${balance.formattedBalance} ${balance.currency}"
                    tvStatus.text = balance.statusText
                    tvStatus.setTextColor(
                        if (balance.isAvailable) {
                            ContextCompat.getColor(this, R.color.status_green)
                        } else {
                            ContextCompat.getColor(this, R.color.status_red)
                        }
                    )
                }.onFailure { error ->
                    tvBalance.text = "获取失败"
                    tvStatus.text = error.message
                    tvStatus.setTextColor(ContextCompat.getColor(this, R.color.status_red))
                }
            }
        }.start()
    }

    private fun toggleMonitoring() {
        if (preferenceManager.isMonitoringEnabled()) {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }

    private fun startMonitoring() {
        val apiKey = preferenceManager.getApiKey(selectedPlatform)
        if (apiKey.isNullOrEmpty()) {
            Toast.makeText(this, "请先保存API Key", Toast.LENGTH_SHORT).show()
            return
        }

        val intent = Intent(this, TokenMonitorService::class.java).apply {
            action = TokenMonitorService.ACTION_START
        }
        startForegroundService(intent)

        preferenceManager.setMonitoringEnabled(true)
        updateMonitorButton()
        Toast.makeText(this, "监控已启动", Toast.LENGTH_SHORT).show()
    }

    private fun stopMonitoring() {
        val intent = Intent(this, TokenMonitorService::class.java).apply {
            action = TokenMonitorService.ACTION_STOP
        }
        startService(intent)

        preferenceManager.setMonitoringEnabled(false)
        updateMonitorButton()
        Toast.makeText(this, "监控已停止", Toast.LENGTH_SHORT).show()
    }

    private fun updateMonitorButton() {
        if (preferenceManager.isMonitoringEnabled()) {
            btnToggleMonitor.text = getString(R.string.stop_monitor)
            btnToggleMonitor.setBackgroundColor(ContextCompat.getColor(this, R.color.status_red))
        } else {
            btnToggleMonitor.text = getString(R.string.start_monitor)
            btnToggleMonitor.setBackgroundColor(ContextCompat.getColor(this, R.color.purple_500))
        }
    }

    private fun checkNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
                != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    100
                )
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 100) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "通知权限已授予", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "需要通知权限才能显示余额", Toast.LENGTH_LONG).show()
            }
        }
    }
}
