package com.skyforgestudios.tasbeepro

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.media.AudioManager
import android.media.ToneGenerator
import android.view.SoundEffectConstants
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
        
        // Widget intent channel'ını kaydet
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.skyforgestudios.tasbeepro/widget"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialIntent" -> {
                    val intentData = mutableMapOf<String, Any>()
                    
                    // Intent'ten Kuran widget verilerini al
                    if (intent?.getBooleanExtra("open_quran", false) == true) {
                        intentData["open_quran"] = true
                        val suraNumber = intent?.getIntExtra("sura_number", 1) ?: 1
                        intentData["sura_number"] = suraNumber
                        
                        // Intent'i temizle (tekrar kullanılmasın)
                        intent?.removeExtra("open_quran")
                        intent?.removeExtra("sura_number")
                    }
                    
                    result.success(if (intentData.isEmpty()) null else intentData)
                }
                else -> result.notImplemented()
            }
        }
        
        // Sound channel'ını kaydet
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.skyforgestudios.tasbeepro/sound"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "playClickSound" -> {
                    try {
                        val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
                        
                        // Flutter'dan gelen ses seviyesi parametresi (0=Düşük, 1=Orta, 2=Yüksek)
                        val volumeLevel = call.argument<Int>("volume") ?: 2
                        
                        // Notification stream kullan - genellikle daha yüksek ses
                        val stream = AudioManager.STREAM_NOTIFICATION
                        val currentVolume = audioManager.getStreamVolume(stream)
                        val maxVolume = audioManager.getStreamMaxVolume(stream)
                        
                        // Ses seviyesine göre ToneGenerator volume ayarla
                        val toneVolume = when (volumeLevel) {
                            0 -> 60  // Düşük (artırıldı: 30 -> 60)
                            1 -> 80  // Orta (artırıldı: 70 -> 80)
                            2 -> ToneGenerator.MAX_VOLUME // Yüksek
                            else -> ToneGenerator.MAX_VOLUME
                        }
                        
                        // Sistem ses seviyesini ayarla
                        val targetVolume = when (volumeLevel) {
                            0 -> (maxVolume * 0.4).toInt()  // %40 (artırıldı: %30 -> %40)
                            1 -> (maxVolume * 0.6).toInt()  // %60 (artırıldı: %50 -> %60)
                            2 -> (maxVolume * 0.85).toInt() // %85
                            else -> (maxVolume * 0.85).toInt()
                        }
                        
                        audioManager.setStreamVolume(stream, targetVolume, 0)
                        
                        // ToneGenerator ile ayarlanabilir ses seviyesi
                        val toneGenerator = ToneGenerator(stream, toneVolume)
                        toneGenerator.startTone(ToneGenerator.TONE_PROP_BEEP, 120)
                        
                        // Temizlik ve ses seviyesini geri yükle
                        Thread {
                            Thread.sleep(180)
                            toneGenerator.release()
                            // Orijinal ses seviyesini geri yükle
                            audioManager.setStreamVolume(stream, currentVolume, 0)
                        }.start()
                        
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SOUND_ERROR", "Could not play sound: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
