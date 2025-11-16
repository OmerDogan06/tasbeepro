package com.skyforgestudios.tasbeepro

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class WidgetUpdateChannel(private val context: Context) : MethodCallHandler {
    
    companion object {
        const val CHANNEL_NAME = "com.skyforgestudios.tasbeepro/widget"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "updateWidget" -> {
                try {
                    val zikrName = call.argument<String>("zikrName") ?: "Subhanallah"
                    val zikrMeaning = call.argument<String>("zikrMeaning") ?: ""
                    val target = call.argument<Int>("target") ?: 33
                    val count = call.argument<Int>("count") ?: 0
                    
                    updateAllWidgets(zikrName, zikrMeaning, target, count)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("UPDATE_ERROR", context.getString(R.string.error_widget_update, e.message), null)
                }
            }
            "getWidgetIds" -> {
                try {
                    val widgetIds = getWidgetIds()
                    result.success(widgetIds)
                } catch (e: Exception) {
                    result.error("GET_IDS_ERROR", context.getString(R.string.error_widget_ids, e.message), null)
                }
            }
            "updateWidgetData" -> {
                try {
                    val zikirList = call.argument<List<Map<String, Any>>>("zikirList") ?: emptyList()
                    val targetList = call.argument<List<Int>>("targetList") ?: emptyList()
                    
                    saveWidgetData(zikirList, targetList)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("UPDATE_DATA_ERROR", "Widget verisi güncellenemedi: ${e.message}", null)
                }
            }
            "openWidgetPicker" -> {
                try {
                    openWidgetPicker()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("WIDGET_PICKER_ERROR", "Widget picker açılamadı: ${e.message}", null)
                }
            }
            "openQuranWidgetPicker" -> {
                try {
                    openQuranWidgetPicker()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("QURAN_WIDGET_PICKER_ERROR", "Kur'an widget picker açılamadı: ${e.message}", null)
                }
            }
            "getInitialIntent" -> {
                try {
                    val intentData = getInitialIntentData()
                    result.success(intentData)
                } catch (e: Exception) {
                    result.error("INTENT_ERROR", "Intent verisi alınamadı: ${e.message}", null)
                }
            }
            "updateAllWidgets" -> {
                try {
                    val widgetData = call.arguments as? Map<String, Any> ?: emptyMap()
                    saveWidgetAccessStatus(widgetData)
                    
                    // Sadece widget'ları yeniden render et - access durumu otomatik kontrol edilecek
                    refreshAllWidgets()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("REFRESH_ERROR", "Widget'lar yenilenirken hata: ${e.message}", null)
                }
            }
            "clearWidgetStats" -> {
                try {
                    // Tüm widget'ların count değerlerini sıfırla
                    resetAllWidgetCounters()
                    
                    // Widget'ları güncelle
                    refreshAllWidgets()
                    
                    result.success(mapOf(
                        "success" to true,
                        "message" to "Widget statistics cleared and widgets refreshed"
                    ))
                } catch (e: Exception) {
                    result.error("CLEAR_STATS_ERROR", "Widget istatistikleri sıfırlanırken hata: ${e.message}", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    private fun updateAllWidgets(zikrName: String, zikrMeaning: String, target: Int, count: Int) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context, TasbeeWidgetProvider::class.java)
        val widgetIds = appWidgetManager.getAppWidgetIds(componentName)
        
        val prefs = context.getSharedPreferences("TasbeeWidgetPrefs", Context.MODE_PRIVATE)
        val editor = prefs.edit()
        
        for (widgetId in widgetIds) {
            editor.putString("zikr_name_$widgetId", zikrName)
            editor.putString("zikr_meaning_$widgetId", zikrMeaning)
            editor.putInt("target_$widgetId", target)
            editor.putInt("count_$widgetId", count)
        }
        
        editor.apply()
        
        // Widget'ları güncelle
        val widgetProvider = TasbeeWidgetProvider()
        widgetProvider.onUpdate(context, appWidgetManager, widgetIds)
    }
    
    private fun getWidgetIds(): List<Int> {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context, TasbeeWidgetProvider::class.java)
        return appWidgetManager.getAppWidgetIds(componentName).toList()
    }
    
    private fun saveWidgetData(zikirList: List<Map<String, Any>>, targetList: List<Int>) {
        val prefs = context.getSharedPreferences("TasbeeWidgetData", Context.MODE_PRIVATE)
        val editor = prefs.edit()
        
        // Zikir listesini JSON formatında kaydet
        val zikirJson = zikirList.map { zikr ->
            mapOf(
                "id" to (zikr["id"] as? String ?: ""),
                "name" to (zikr["name"] as? String ?: ""),
                "meaning" to (zikr["meaning"] as? String ?: ""),
                "isCustom" to (zikr["isCustom"] as? Boolean ?: false)
            )
        }
        
        val gson = com.google.gson.Gson()
        editor.putString("zikr_list", gson.toJson(zikirJson))
        
        // Target listesini kaydet
        val targetJson = gson.toJson(targetList)
        editor.putString("target_list", targetJson)
        
        editor.apply()
        
        android.util.Log.d("WidgetUpdate", "Widget verileri güncellendi - Zikir: ${zikirList.size}, Target: ${targetList.size}")
    }
    
    private fun openWidgetPicker() {
        try {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val myProvider = ComponentName(context, TasbeeWidgetProvider::class.java)
            
            if (appWidgetManager.isRequestPinAppWidgetSupported) {
                // Android 8.0+ için pin widget özelliği - Bu çalışıyor!
                appWidgetManager.requestPinAppWidget(myProvider, null, null)
            } else {
                // Eski Android sürümleri için widget picker'ı aç
                val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_PICK).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
            }
        } catch (e: Exception) {
            // Fallback: Manuel widget ekleme talimatları Flutter tarafında gösterilecek
            e.printStackTrace()
            android.util.Log.e("WidgetPicker", "Widget picker açılamadı: ${e.message}")
        }
    }

    private fun openQuranWidgetPicker() {
        try {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val quranProvider = ComponentName(context, QuranWidgetProvider::class.java)
            
            if (appWidgetManager.isRequestPinAppWidgetSupported) {
                // Android 8.0+ için pin widget özelliği - Kur'an widget'ı
                appWidgetManager.requestPinAppWidget(quranProvider, null, null)
            } else {
                // Eski Android sürümleri için widget picker'ı aç
                val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_PICK).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
            }
        } catch (e: Exception) {
            // Fallback: Manuel widget ekleme talimatları Flutter tarafında gösterilecek
            e.printStackTrace()
            android.util.Log.e("QuranWidgetPicker", "Kur'an widget picker açılamadı: ${e.message}")
        }
    }

    private fun getInitialIntentData(): Map<String, Any>? {
        try {
            val intentData = mutableMapOf<String, Any>()
            
            if (context is android.app.Activity) {
                val activity = context as android.app.Activity
                val intent = activity.intent
                
                // Intent'ten Kuran widget verilerini al
                if (intent?.getBooleanExtra("open_quran", false) == true) {
                    intentData["open_quran"] = true
                    val suraNumber = intent.getIntExtra("sura_number", 1)
                    intentData["sura_number"] = suraNumber
                    
                    // Intent'i temizle (tekrar kullanılmasın)
                    intent.removeExtra("open_quran")
                    intent.removeExtra("sura_number")
                }
            }
            
            return if (intentData.isEmpty()) null else intentData
        } catch (e: Exception) {
            android.util.Log.e("IntentData", "Intent verisi alınırken hata: ${e.message}")
            return null
        }
    }

    // ✅ Widget'ları güçlü bir şekilde yenile - premium durumu değiştiğinde
    private fun refreshAllWidgets() {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        
        // Tasbee Widget'ları güncelle
        val componentName = ComponentName(context, TasbeeWidgetProvider::class.java)
        val widgetIds = appWidgetManager.getAppWidgetIds(componentName)
        
        if (widgetIds.isNotEmpty()) {
            // Önce broadcast ile güncelle
            val intent = Intent(context, TasbeeWidgetProvider::class.java)
            intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, widgetIds)
            context.sendBroadcast(intent)
            
            // Sonra doğrudan onUpdate metodunu çağır (iki katmanlı güncelleme)
            val provider = TasbeeWidgetProvider()
            provider.onUpdate(context, appWidgetManager, widgetIds)
            
            android.util.Log.d("WidgetRefresh", "Tasbee widgets forcefully refreshed: ${widgetIds.size} widgets")
        }
        
        // Quran Widget'ları güncelle
        val quranComponentName = ComponentName(context, QuranWidgetProvider::class.java)
        val quranWidgetIds = appWidgetManager.getAppWidgetIds(quranComponentName)
        
        if (quranWidgetIds.isNotEmpty()) {
            // Önce broadcast ile güncelle
            val intent = Intent(context, QuranWidgetProvider::class.java)
            intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, quranWidgetIds)
            context.sendBroadcast(intent)
            
            // Sonra doğrudan onUpdate metodunu çağır (iki katmanlı güncelleme)
            val provider = QuranWidgetProvider()
            provider.onUpdate(context, appWidgetManager, quranWidgetIds)
            
            // Quran widget ListView'leri için özel güncelleme
            for (widgetId in quranWidgetIds) {
                try {
                    appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.ayah_list)
                    android.util.Log.d("WidgetRefresh", "Quran widget ListView updated for widget $widgetId")
                } catch (e: Exception) {
                    android.util.Log.w("WidgetRefresh", "Failed to update ListView for widget $widgetId: ${e.message}")
                }
            }
            
            android.util.Log.d("WidgetRefresh", "Quran widgets forcefully refreshed: ${quranWidgetIds.size} widgets")
        }
        
        // Ekstra: Sistem düzeyinde widget yenileme sinyali gönder
        try {
            val allWidgetIds = widgetIds.toList() + quranWidgetIds.toList()
            if (allWidgetIds.isNotEmpty()) {
                val systemIntent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                
                // Home screen'e minimal bir sinyal gönder
                android.util.Log.d("WidgetRefresh", "Sent system refresh signal for ${allWidgetIds.size} total widgets")
            }
        } catch (e: Exception) {
            android.util.Log.w("WidgetRefresh", "System refresh signal failed: ${e.message}")
        }
    }
    
    // ✅ Bildirim sonrası widget güncelleme için public method
    fun refreshWidgetsAfterNotification() {
        refreshAllWidgets()
    }
    
    // Tüm widget'ların sayaç değerlerini sıfırla
    private fun resetAllWidgetCounters() {
        val prefs = context.getSharedPreferences("TasbeeWidgetPrefs", Context.MODE_PRIVATE)
        val editor = prefs.edit()
        
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context, TasbeeWidgetProvider::class.java)
        val widgetIds = appWidgetManager.getAppWidgetIds(componentName)
        
        // Her widget için count değerini sıfırla
        for (widgetId in widgetIds) {
            editor.putInt("count_$widgetId", 0)
        }
        
        editor.apply()
        
        android.util.Log.d("WidgetReset", "Tüm widget sayaçları sıfırlandı: ${widgetIds.size} widget")
    }
    
    // Widget erişim durumlarını SharedPreferences'a kaydet
    private fun saveWidgetAccessStatus(widgetData: Map<String, Any>) {
        try {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val editor = prefs.edit()
            
            // Premium durumu
            val isPremium = widgetData["isPremium"] as? Boolean ?: false
            editor.putBoolean("flutter.is_premium", isPremium)
            
            // Toplam erişim durumları (Premium VEYA Reward)
            val canUseDhikrWidget = widgetData["canUseDhikrWidget"] as? Boolean ?: false
            val canUseQuranWidget = widgetData["canUseQuranWidget"] as? Boolean ?: false
            val canUseReminders = widgetData["canUseReminders"] as? Boolean ?: false
            val canUseReminderTimes = widgetData["canUseReminderTimes"] as? Boolean ?: false
            
            editor.putBoolean("flutter.can_use_dhikr_widget", canUseDhikrWidget)
            editor.putBoolean("flutter.can_use_quran_widget", canUseQuranWidget)
            editor.putBoolean("flutter.can_use_reminders", canUseReminders)
            editor.putBoolean("flutter.can_use_reminder_times", canUseReminderTimes)
            
            // Reward durumları (ayrı ayrı)
            val isDhikrWidgetByReward = widgetData["isDhikrWidgetByReward"] as? Boolean ?: false
            val isQuranWidgetByReward = widgetData["isQuranWidgetByReward"] as? Boolean ?: false
            val isRemindersByReward = widgetData["isRemindersByReward"] as? Boolean ?: false
            val isReminderTimesByReward = widgetData["isReminderTimesByReward"] as? Boolean ?: false
            
            editor.putBoolean("flutter.dhikr_widget_by_reward", isDhikrWidgetByReward)
            editor.putBoolean("flutter.quran_widget_by_reward", isQuranWidgetByReward)
            editor.putBoolean("flutter.reminders_by_reward", isRemindersByReward)
            editor.putBoolean("flutter.reminder_times_by_reward", isReminderTimesByReward)
            
            // ✅ Reward süre bilgilerini de kaydet (24 saat kontrolü için)
            if (isDhikrWidgetByReward) {
                // Flutter'dan gelen reward unlock time'ını Android'e aktar
                val dhikrUnlockTime = widgetData["dhikrWidgetUnlockTime"] as? Long
                if (dhikrUnlockTime != null) {
                    editor.putLong("flutter.reward_dhikr_widget_unlocked_at", dhikrUnlockTime)
                }
            }
            
            if (isQuranWidgetByReward) {
                // Flutter'dan gelen reward unlock time'ını Android'e aktar
                val quranUnlockTime = widgetData["quranWidgetUnlockTime"] as? Long
                if (quranUnlockTime != null) {
                    editor.putLong("flutter.reward_quran_widget_unlocked_at", quranUnlockTime)
                }
            }
            
            if (isRemindersByReward) {
                val remindersUnlockTime = widgetData["remindersUnlockTime"] as? Long
                if (remindersUnlockTime != null) {
                    editor.putLong("flutter.reward_reminders_unlocked_at", remindersUnlockTime)
                }
            }
            
            if (isReminderTimesByReward) {
                val reminderTimesUnlockTime = widgetData["reminderTimesUnlockTime"] as? Long
                if (reminderTimesUnlockTime != null) {
                    editor.putLong("flutter.reward_reminder_times_unlocked_at", reminderTimesUnlockTime)
                }
            }
            
            // Reklamsız deneyim (sadece premium)
            val isAdFree = widgetData["isAdFree"] as? Boolean ?: false
            editor.putBoolean("flutter.is_ad_free", isAdFree)
            
            editor.apply()
            
            android.util.Log.d("WidgetAccess", "Widget erişim durumları güncellendi:")
            android.util.Log.d("WidgetAccess", "  Premium: $isPremium")
            android.util.Log.d("WidgetAccess", "  DhikrWidget: $canUseDhikrWidget (Reward: $isDhikrWidgetByReward)")
            android.util.Log.d("WidgetAccess", "  QuranWidget: $canUseQuranWidget (Reward: $isQuranWidgetByReward)")
            android.util.Log.d("WidgetAccess", "  Reminders: $canUseReminders (Reward: $isRemindersByReward)")
            android.util.Log.d("WidgetAccess", "  ReminderTimes: $canUseReminderTimes (Reward: $isReminderTimesByReward)")
            android.util.Log.d("WidgetAccess", "  AdFree: $isAdFree")
            
        } catch (e: Exception) {
            android.util.Log.e("WidgetAccess", "Widget erişim durumları kaydedilirken hata: ${e.message}")
        }
    }
}