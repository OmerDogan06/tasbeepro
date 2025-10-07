package com.example.tasbeepro

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import com.example.tasbeepro.R

class TasbeeWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val ACTION_COUNTER_CLICK = "ACTION_COUNTER_CLICK"
        private const val ACTION_RESET_CLICK = "ACTION_RESET_CLICK"
        private const val ACTION_SETTINGS_CLICK = "ACTION_SETTINGS_CLICK"
        private const val PREF_NAME = "TasbeeWidgetPrefs"
        private const val KEY_COUNT = "count_"
        private const val KEY_TARGET = "target_"
        private const val KEY_ZIKR_NAME = "zikr_name_"
        private const val KEY_ZIKR_MEANING = "zikr_meaning_"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        when (intent.action) {
            ACTION_COUNTER_CLICK -> {
                val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, -1)
                if (appWidgetId != -1) {
                    incrementCounter(context, appWidgetId)
                }
            }
            ACTION_RESET_CLICK -> {
                val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, -1)
                if (appWidgetId != -1) {
                    resetCounter(context, appWidgetId)
                }
            }
            ACTION_SETTINGS_CLICK -> {
                val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, -1)
                if (appWidgetId != -1) {
                    openWidgetSettings(context, appWidgetId)
                }
            }
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.tasbee_widget)
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)

        // Verileri SharedPreferences'tan al
        val count = prefs.getInt(KEY_COUNT + appWidgetId, 0)
        val target = prefs.getInt(KEY_TARGET + appWidgetId, 33)
        val zikrName = prefs.getString(KEY_ZIKR_NAME + appWidgetId, "Subhanallah") ?: "Subhanallah"
        val zikrMeaning = prefs.getString(KEY_ZIKR_MEANING + appWidgetId, "Allah'tan münezzeh ve mukaddestir") ?: ""

        // UI güncelle
        views.setTextViewText(R.id.zikr_name, zikrName)
        views.setTextViewText(R.id.current_count, count.toString())
        views.setTextViewText(R.id.target_count, target.toString())
        
        // Counter button içine sayaç değerini her zaman göster
        views.setTextViewText(R.id.counter_text, count.toString())

        // Progress hesapla (hedef aşılabilir)
        val progress = if (target > 0) {
            val calculated = (count * 100) / target
            minOf(calculated, 100) // Progress bar max 100 olsun
        } else 0
        
        views.setProgressBar(R.id.progress_bar, 100, progress, false)
        
        // Progress yüzdesini de max 100% göster
        val displayProgress = if (target > 0) {
            val calculated = (count * 100) / target
            minOf(calculated, 100) // Yüzde de max 100 olsun
        } else 0
        views.setTextViewText(R.id.progress_percentage, "$displayProgress%")

        // Click intent'ler ayarla
        setClickIntents(context, views, appWidgetId)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun setClickIntents(context: Context, views: RemoteViews, appWidgetId: Int) {
        // Counter button click
        val counterIntent = Intent(context, TasbeeWidgetProvider::class.java).apply {
            action = ACTION_COUNTER_CLICK
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        val counterPendingIntent = PendingIntent.getBroadcast(
            context, appWidgetId * 10 + 1, counterIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.counter_button, counterPendingIntent)

        // Reset button click
        val resetIntent = Intent(context, TasbeeWidgetProvider::class.java).apply {
            action = ACTION_RESET_CLICK
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        val resetPendingIntent = PendingIntent.getBroadcast(
            context, appWidgetId * 10 + 2, resetIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.reset_button, resetPendingIntent)

        // Settings button click
        val settingsIntent = Intent(context, TasbeeWidgetProvider::class.java).apply {
            action = ACTION_SETTINGS_CLICK
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        val settingsPendingIntent = PendingIntent.getBroadcast(
            context, appWidgetId * 10 + 3, settingsIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.settings_button, settingsPendingIntent)
    }

    private fun incrementCounter(context: Context, appWidgetId: Int) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val currentCount = prefs.getInt(KEY_COUNT + appWidgetId, 0)
        val target = prefs.getInt(KEY_TARGET + appWidgetId, 33)
        
        // Sayaç her zaman artırılabilir - hedef sınırlaması yok
        val newCount = currentCount + 1
        
        prefs.edit().putInt(KEY_COUNT + appWidgetId, newCount).apply()
        
        // Widget'ı güncelle
        val appWidgetManager = AppWidgetManager.getInstance(context)
        updateAppWidget(context, appWidgetManager, appWidgetId)
        
        // Hedef ilk kez tamamlandıysa bildirim göster
        if (newCount == target && currentCount < target) {
            showTargetCompleteNotification(context, target)
        }
        
        // Hedef aşıldıysa uyarı göster (sadece ilk aşımda)
        if (newCount == target + 1) {
            showTargetExceededNotification(context, target)
        }
    }

    private fun resetCounter(context: Context, appWidgetId: Int) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit().putInt(KEY_COUNT + appWidgetId, 0).apply()
        
        // Widget'ı güncelle
        val appWidgetManager = AppWidgetManager.getInstance(context)
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    private fun openWidgetSettings(context: Context, appWidgetId: Int) {
        val intent = Intent(context, WidgetConfigActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        context.startActivity(intent)
    }
    
    private fun showTargetCompleteNotification(context: Context, target: Int) {
        try {
            // Toast göster
            val toast = android.widget.Toast.makeText(
                context, 
                "🎉 Maşallah! $target zikrini tamamladınız!", 
                android.widget.Toast.LENGTH_LONG
            )
            toast.show()
            
            // Notification da göster
            showNotification(
                context, 
                "Hedef Tamamlandı! 🎉", 
                "Maşallah! $target zikir sayısına ulaştınız. Allah kabul etsin!",
                1
            )
        } catch (e: Exception) {
            // Hata durumunda sessizce devam et
        }
    }
    
    private fun showTargetExceededNotification(context: Context, target: Int) {
        try {
            val toast = android.widget.Toast.makeText(
                context, 
                "✨ Hedefi aştınız! ($target+) Devam edin!", 
                android.widget.Toast.LENGTH_SHORT
            )
            toast.show()
            
            // Notification da göster
            showNotification(
                context, 
                "Hedef Aşıldı! ✨", 
                "Maşallah! $target hedefini aştınız. Zikirleriniz devam ediyor!",
                2
            )
        } catch (e: Exception) {
            // Hata durumunda sessizce devam et
        }
    }
    
    private fun showNotification(context: Context, title: String, message: String, notificationId: Int) {
        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channelId = "tasbee_notifications"
            
            // Android 8.0+ için notification channel oluştur
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    channelId,
                    "Tasbee Bildirimleri",
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "Zikir hedefi bildirimlerini gösterir"
                }
                notificationManager.createNotificationChannel(channel)
            }
            
            // Notification oluştur
            val notification = NotificationCompat.Builder(context, channelId)
                .setSmallIcon(android.R.drawable.star_on)
                .setContentTitle(title)
                .setContentText(message)
                .setStyle(NotificationCompat.BigTextStyle().bigText(message))
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setAutoCancel(true)
                .build()
            
            notificationManager.notify(notificationId, notification)
        } catch (e: Exception) {
            // Notification gösterilemezse sessizce devam et
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        // Widget silindiğinde preferences'ları temizle
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        
        for (appWidgetId in appWidgetIds) {
            editor.remove(KEY_COUNT + appWidgetId)
            editor.remove(KEY_TARGET + appWidgetId)
            editor.remove(KEY_ZIKR_NAME + appWidgetId)
            editor.remove(KEY_ZIKR_MEANING + appWidgetId)
        }
        
        editor.apply()
    }

    // Flutter uygulamasından çağrılabilecek yardımcı metodlar
    fun updateWidgetFromFlutter(
        context: Context,
        appWidgetId: Int,
        zikrName: String,
        zikrMeaning: String,
        target: Int
    ) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit()
            .putString(KEY_ZIKR_NAME + appWidgetId, zikrName)
            .putString(KEY_ZIKR_MEANING + appWidgetId, zikrMeaning)
            .putInt(KEY_TARGET + appWidgetId, target)
            .apply()
        
        val appWidgetManager = AppWidgetManager.getInstance(context)
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }
}