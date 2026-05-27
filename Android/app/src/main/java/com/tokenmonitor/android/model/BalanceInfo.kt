package com.tokenmonitor.android.model

data class BalanceInfo(
    val isAvailable: Boolean,
    val balance: Double,
    val totalBalance: Double,
    val currency: String
) {
    val formattedBalance: String
        get() = String.format("%.2f", balance)

    val statusText: String
        get() = if (isAvailable) "正常" else "余额不足"
}
