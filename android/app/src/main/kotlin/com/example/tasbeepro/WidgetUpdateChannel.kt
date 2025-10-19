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
                // Android 8.0+ için pin widget özelliği
                appWidgetManager.requestPinAppWidget(myProvider, null, null)
            } else {
                // Eski Android sürümleri için widget picker'ı aç
                val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_PICK)
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
                context.startActivity(intent)
            }
        } catch (e: Exception) {
            // Fallback: Manuel widget ekleme talimatları Flutter tarafında gösterilecek
            e.printStackTrace()
        }
    }
}