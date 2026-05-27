package com.tokenmonitor.android.model

enum class Platform(val displayName: String, val iconName: String) {
    DEEPSEEK("DeepSeek", "ic_deepseek"),
    MIMO("小米MiMo", "ic_mimo");

    companion object {
        fun fromString(value: String): Platform {
            return when (value) {
                "DEEPSEEK" -> DEEPSEEK
                "MIMO" -> MIMO
                else -> DEEPSEEK
            }
        }
    }
}
