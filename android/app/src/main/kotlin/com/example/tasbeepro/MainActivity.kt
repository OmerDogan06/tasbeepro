package com.example.tasbeepro

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    
    private val WIDGET_CHANNEL = "com.example.tasbeepro/widget"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Widget update channel'ını kaydet
        val widgetChannel = WidgetUpdateChannel(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WidgetUpdateChannel.CHANNEL_NAME
        ).setMethodCallHandler(widgetChannel)
        
        // Widget database channel'ını kaydet
        val widgetDatabaseChannel = WidgetDatabaseChannel(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "widget_database"
        ).setMethodCallHandler(widgetDatabaseChannel)
        
        // Widget picker channel'ını kaydet
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WIDGET_CHANNEL
        ).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "openWidgetPicker" -> {
                    openWidgetPicker()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun openWidgetPicker() {
        try {
            val appWidgetManager = AppWidgetManager.getInstance(this)
            val myProvider = ComponentName(this, TasbeeWidgetProvider::class.java)
            
            if (appWidgetManager.isRequestPinAppWidgetSupported) {
                // Android 8.0+ için pin widget özelliği
                appWidgetManager.requestPinAppWidget(myProvider, null, null)
            } else {
                // Eski Android sürümleri için widget picker'ı aç
                val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_PICK)
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
                startActivity(intent)
            }
        } catch (e: Exception) {
            // Fallback: Manuel widget ekleme talimatları Flutter tarafında gösterilecek
            e.printStackTrace()
        }
    }
}
