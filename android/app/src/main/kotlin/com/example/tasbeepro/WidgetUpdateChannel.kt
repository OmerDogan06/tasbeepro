package com.example.tasbeepro

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class WidgetUpdateChannel(private val context: Context) : MethodCallHandler {
    
    companion object {
        const val CHANNEL_NAME = "com.example.tasbeepro/widget"
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
                    result.error("UPDATE_ERROR", "Widget güncellenirken hata oluştu: ${e.message}", null)
                }
            }
            "getWidgetIds" -> {
                try {
                    val widgetIds = getWidgetIds()
                    result.success(widgetIds)
                } catch (e: Exception) {
                    result.error("GET_IDS_ERROR", "Widget ID'leri alınırken hata oluştu: ${e.message}", null)
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
}