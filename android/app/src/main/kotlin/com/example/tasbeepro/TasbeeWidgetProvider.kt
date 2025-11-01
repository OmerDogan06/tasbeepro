package com.skyforgestudios.tasbeepro

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
import android.util.Log
import android.media.AudioManager
import android.media.ToneGenerator
import android.content.res.Configuration
import java.util.Locale
import com.skyforgestudios.tasbeepro.R

class TasbeeWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "TasbeeWidget"
        private const val ACTION_COUNTER_CLICK = "ACTION_COUNTER_CLICK"
        private const val ACTION_RESET_CLICK = "ACTION_RESET_CLICK"
        private const val ACTION_SETTINGS_CLICK = "ACTION_SETTINGS_CLICK"
        private const val PREF_NAME = "TasbeeWidgetPrefs"
        private const val KEY_COUNT = "count_"
        private const val KEY_TARGET = "target_"
        private const val KEY_ZIKR_NAME = "zikr_name_"
        private const val KEY_ZIKR_MEANING = "zikr_meaning_"
        private const val KEY_ZIKR_ID = "zikr_id_"
        
        // Desteklenen diller - Flutter tarafıyla aynı
        private val SUPPORTED_LANGUAGES = setOf("tr", "en", "ar", "id", "ur", "ms", "bn", "fr", "hi", "fa", "uz", "ru", "es", "pt", "de", "it", "zh", "sw", "ja", "ko", "th")
    }

    private lateinit var database: WidgetZikrDatabase

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        database = WidgetZikrDatabase(context)
        
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(getLocalizedContext(context), appWidgetManager, appWidgetId)
        }
    }
    
    // Desteklenen dillere göre context'i ayarla
    private fun getLocalizedContext(context: Context): Context {
        val currentLocale = context.resources.configuration.locales[0]
        val currentLanguage = currentLocale.language
        
        // Eğer mevcut dil desteklenen diller arasında değilse İngilizce'ye düş
        val targetLanguage = if (SUPPORTED_LANGUAGES.contains(currentLanguage)) {
            currentLanguage
        } else {
            "en" // Varsayılan İngilizce
        }
        
        // Eğer zaten doğru dildeyse context'i olduğu gibi döndür
        if (currentLanguage == targetLanguage) {
            return context
        }
        
        // Yeni locale ile context oluştur
        val locale = when (targetLanguage) {
            "tr" -> Locale("tr", "TR")
            "ar" -> Locale("ar", "SA")
            "id" -> Locale("id", "ID")
            "ur" -> Locale("ur", "PK")
            "ms" -> Locale("ms", "MY")
            "bn" -> Locale("bn", "BD")
            "fr" -> Locale("fr", "FR")
            "hi" -> Locale("hi", "IN")
            "fa" -> Locale("fa", "IR")
            "uz" -> Locale("uz", "UZ")
            "ru" -> Locale("ru", "RU")
            "es" -> Locale("es", "ES")
            "pt" -> Locale("pt", "BR")
            "de" -> Locale("de", "DE")
            "it" -> Locale("it", "IT")
            "zh" -> Locale("zh", "CN")
            "sw" -> Locale("sw", "KE")
            "ja" -> Locale("ja", "JP")
            "ko" -> Locale("ko", "KR")
            "th" -> Locale("th", "TH")
            else -> Locale("en", "GB")
        }
        
        val config = Configuration(context.resources.configuration)
        config.setLocale(locale)
        
        return context.createConfigurationContext(config)
    }
    
    // Localized zikir adını al
    private fun getLocalizedZikirName(context: Context, zikirKey: String): String {
        val resourceName = "zikir_$zikirKey"
        val resourceId = context.resources.getIdentifier(resourceName, "string", context.packageName)
        return if (resourceId != 0) {
            context.getString(resourceId)
        } else {
            // Fallback to English names
            when (zikirKey) {
                "subhanallah" -> "Subhanallah"
                "alhamdulillah" -> "Alhamdulillah"
                "allahu_akbar" -> "Allahu Akbar"
                "la_ilaha_illallah" -> "La ilaha illAllah"
                "estaghfirullah" -> "Astaghfirullah"
                "la_hawle_wala_quwwate" -> "La hawla wa la quwwata illa billah"
                "hasbi_allahu" -> "HasbiyAllahu wa ni'mal wakeel"
                "rabbana_atina" -> "Rabbana Atina"
                "allahume_salli" -> "Allahumma Salli"
                "rabbi_zidni_ilmen" -> "Rabbi Zidni Ilm"
                "bismillah" -> "Bismillah"
                "innallaha_maas_sabirin" -> "Innalaha ma'as sabirin"
                "allahu_latif" -> "Allahu Latif"
                "ya_rahman" -> "Ya Rahman Ya Rahim"
                "tabarak_allah" -> "Tabarak Allah"
                "mashallah" -> "MashaAllah"
                else -> "Unknown Zikr"
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        database = WidgetZikrDatabase(context)
        val localizedContext = getLocalizedContext(context)
        
        when (intent.action) {
            ACTION_COUNTER_CLICK -> {
                val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, -1)
                if (appWidgetId != -1) {
                    incrementCounter(localizedContext, appWidgetId)
                }
            }
            ACTION_RESET_CLICK -> {
                val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, -1)
                if (appWidgetId != -1) {
                    resetCounter(localizedContext, appWidgetId)
                }
            }
            ACTION_SETTINGS_CLICK -> {
                val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, -1)
                if (appWidgetId != -1) {
                    openWidgetSettings(context, appWidgetId) // Settings için orijinal context kullan
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
        val zikrId = prefs.getString(KEY_ZIKR_ID + appWidgetId, "subhanallah") ?: "subhanallah"
        
        // Zikir adını her zaman güncel dilden al (sistem dili değişikliği için)
        val zikrName = getLocalizedZikirName(context, zikrId)
        
        val zikrMeaning = prefs.getString(KEY_ZIKR_MEANING + appWidgetId, "") ?: ""

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
        val zikrId = prefs.getString(KEY_ZIKR_ID + appWidgetId, "subhanallah") ?: "subhanallah"
        
        // Zikir adını her zaman güncel dilden al
        val zikrName = getLocalizedZikirName(context, zikrId)
        
        // Widget'ın kendi ayarlarını kontrol et ve ses/titreşim efekti uygula
        playWidgetFeedback(context)
        
        // Sayaç her zaman artırılabilir - hedef sınırlaması yok
        val newCount = currentCount + 1
        
        prefs.edit().putInt(KEY_COUNT + appWidgetId, newCount).apply()
        
        // **ÖNEMLİ: Widget'tan yapılan zikri veritabanına kaydet (kalıcı kayıt)**
        try {
            val recordId = database.addWidgetZikrRecord(zikrId, zikrName, 1)
            Log.d(TAG, "Widget zikir kaydedildi: $zikrName (ID: $zikrId) - Record ID: $recordId")
        } catch (e: Exception) {
            Log.e(TAG, "Veritabanına kaydetme hatası: ${e.message}")
        }
        
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
        
        // **ÖNEMLİ: Sadece widget'taki sayacı sıfırla, veritabanındaki kayıtları ASLA silme!**
        prefs.edit().putInt(KEY_COUNT + appWidgetId, 0).apply()
        
        Log.d(TAG, "Widget sayacı sıfırlandı (veritabanı kayıtları korundu)")
        
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
                context.getString(R.string.target_completed_toast_main, target), 
                android.widget.Toast.LENGTH_LONG
            )
            toast.show()
            
            // Notification da göster
            showNotification(
                context, 
                context.getString(R.string.target_completed_title), 
                context.getString(R.string.target_completed_message, target),
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
                context.getString(R.string.target_completed_toast, target), 
                android.widget.Toast.LENGTH_SHORT
            )
            toast.show()
            
            // Notification da göster
            showNotification(
                context, 
                context.getString(R.string.target_exceeded_title), 
                context.getString(R.string.target_exceeded_message, target),
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
                    context.getString(R.string.notification_channel_name),
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = context.getString(R.string.notification_channel_description)
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
        // **ÖNEMLİ: Veritabanındaki kayıtları silme! Sadece widget ayarlarını temizle**
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        
        for (appWidgetId in appWidgetIds) {
            editor.remove(KEY_COUNT + appWidgetId)
            editor.remove(KEY_TARGET + appWidgetId)
            editor.remove(KEY_ZIKR_NAME + appWidgetId)
            editor.remove(KEY_ZIKR_MEANING + appWidgetId)
            editor.remove(KEY_ZIKR_ID + appWidgetId)
        }
        
        editor.apply()
        Log.d(TAG, "Widget ayarları temizlendi (veritabanı kayıtları korundu)")
    }

    override fun onEnabled(context: Context) {
        // İlk widget eklendiğinde
        database = WidgetZikrDatabase(context)
        Log.d(TAG, "Widget etkinleştirildi, veritabanı hazır")
    }

    override fun onDisabled(context: Context) {
        // Son widget kaldırıldığında
        // **ÖNEMLİ: Veritabanını silme! Sadece log yaz**
        Log.d(TAG, "Widget devre dışı bırakıldı (veritabanı korundu)")
    }
    
    // Widget'ın kendi ayarlarını okuyarak ses efekti uygula
    private fun playWidgetFeedback(context: Context) {
        try {
            // Flutter'dan bağımsız - Widget'ın kendi SharedPreferences'larını al
            val widgetPrefs = context.getSharedPreferences("TasbeeWidgetSettings", Context.MODE_PRIVATE)
            
            // Ses ayarını kontrol et (varsayılan: açık)
            val soundEnabled = widgetPrefs.getBoolean("widget_sound_enabled", true)
            Log.d(TAG, "Widget sound enabled: $soundEnabled")
            if (soundEnabled) {
                playClickSound(context)
            }
            
        } catch (e: Exception) {
            // Hata durumunda ses çalmayı atla
            Log.e(TAG, "Widget ayarları okunamadı: ${e.message}")
        }
    }
    
    // Ses efekti çal
    private fun playClickSound(context: Context) {
        try {
            val toneGenerator = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 30) // Düşük ses seviyesi
            toneGenerator.startTone(ToneGenerator.TONE_PROP_BEEP, 50) // 50ms süre
            
            // Ton generator'ı temizle
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                toneGenerator.release()
            }, 100)
        } catch (e: Exception) {
            Log.e(TAG, "Ses çalınamadı: ${e.message}")
        }
    }
    
    // Flutter uygulamasından çağrılabilecek yardımcı metodlar
    fun updateWidgetFromFlutter(
        context: Context,
        appWidgetId: Int,
        zikrId: String,
        zikrName: String,
        zikrMeaning: String,
        target: Int
    ) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit()
            .putString(KEY_ZIKR_ID + appWidgetId, zikrId)
            .putString(KEY_ZIKR_NAME + appWidgetId, zikrName)
            .putString(KEY_ZIKR_MEANING + appWidgetId, zikrMeaning)
            .putInt(KEY_TARGET + appWidgetId, target)
            .apply()
        
        val appWidgetManager = AppWidgetManager.getInstance(context)
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }
}