package com.tokenmonitor.android.service

import com.tokenmonitor.android.model.BalanceInfo
import com.tokenmonitor.android.model.Platform
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class TokenApiService {

    private val client = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(10, TimeUnit.SECONDS)
        .build()

    fun fetchBalance(platform: Platform, apiKey: String): Result<BalanceInfo> {
        return try {
            val url = when (platform) {
                Platform.DEEPSEEK -> "https://api.deepseek.com/user/balance"
                Platform.MIMO -> "https://api.mimo.xiaomi.com/user/balance" // 需要根据实际API调整
            }

            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $apiKey")
                .get()
                .build()

            val response = client.newCall(request).execute()

            if (response.isSuccessful) {
                val body = response.body?.string() ?: "{}"
                val json = JSONObject(body)

                val balanceInfo = BalanceInfo(
                    isAvailable = json.optBoolean("is_available", false),
                    balance = json.optString("balance", "0").toDoubleOrNull() ?: 0.0,
                    totalBalance = json.optString("total_balance", "0").toDoubleOrNull() ?: 0.0,
                    currency = json.optString("currency", "CNY")
                )

                Result.success(balanceInfo)
            } else {
                Result.failure(Exception("请求失败: ${response.code}"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
