package com.skyforgestudios.tasbeepro

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    
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
    }
}
