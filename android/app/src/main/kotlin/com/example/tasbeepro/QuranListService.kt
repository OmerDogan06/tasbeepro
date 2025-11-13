package com.skyforgestudios.tasbeepro

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.view.Gravity
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import android.util.Log

class QuranListService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return QuranListViewFactory(this.applicationContext, intent)
    }
}

class QuranListViewFactory(
    private val context: Context,
    intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private val appWidgetId = intent.getIntExtra(
        AppWidgetManager.EXTRA_APPWIDGET_ID,
        AppWidgetManager.INVALID_APPWIDGET_ID
    )
    
    private var ayahs: List<String> = emptyList()
    
    companion object {
        private const val PREF_NAME = "QuranWidgetPrefs"
        private const val KEY_CURRENT_SURA = "current_sura_"
        private const val KEY_FONT_SIZE = "font_size_"
    }

    override fun onCreate() {
        // Initialization
    }

    override fun onDataSetChanged() {
        // Widget erişim kontrolü (Premium VEYA Reward)
        if (!canUseWidget()) {
            ayahs = emptyList()
            return
        }
        
        // Veri güncellendiğinde çağrılır
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val currentSura = prefs.getInt(KEY_CURRENT_SURA + appWidgetId, 1)
        
        Log.d("QuranListService", "Loading sura $currentSura for widget $appWidgetId")
        
        // QuranDatabase'den ayetleri al
        val quranDatabase = QuranDatabase(context)
        val suraData = quranDatabase.getSuraData(currentSura)
        ayahs = suraData.ayahs
        
        Log.d("QuranListService", "Loaded ${ayahs.size} ayahs for sura $currentSura")
    }

    override fun onDestroy() {
        ayahs = emptyList()
    }

    override fun getCount(): Int {
        return ayahs.size
    }

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_ayah_item)
        
        if (position < ayahs.size) {
            var ayahText = ayahs[position].trim()
            
            // ۞ işaretini kontrol et ve işle (Flutter kodundaki ile aynı mantık)
            if (ayahText.contains("۞")) {
                // ۞ işaretini kaldır ve sonuna ekle
                ayahText = "${ayahText.replace("۞", "").trim()} ۞"
            }
            
            views.setTextViewText(R.id.ayah_text, ayahText)
            
            // Ayet numarasını göster (1'den başlayarak)
            val ayahNumber = (position + 1).toString()
            views.setTextViewText(R.id.ayah_number, ayahNumber)
            
            // Font size ayarla
            val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
            val fontSize = prefs.getFloat(KEY_FONT_SIZE + appWidgetId, 16.0f)
            views.setTextViewTextSize(R.id.ayah_text, android.util.TypedValue.COMPLEX_UNIT_SP, fontSize)
            
            // Sadece RIGHT kullan (eski Android uyumlu)
            views.setInt(R.id.ayah_text, "setGravity", Gravity.RIGHT)
        }
        
        return views
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }
    
    // Premium durumu kontrol et (eski metot - artık kullanılmıyor)
    private fun checkPremiumStatus(): Boolean {
        return try {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            prefs.getBoolean("flutter.is_premium", false)
        } catch (e: Exception) {
            Log.e("QuranListService", "Premium durum kontrol hatası: ${e.message}")
            false
        }
    }
    
    // Widget erişim kontrolü - Premium VEYA Reward (24 saat süresi ile)
    private fun canUseWidget(): Boolean {
        return try {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val isPremium = prefs.getBoolean("flutter.is_premium", false)
            
            if (isPremium) {
                Log.d("QuranListService", "Widget erişim kontrolü - Premium aktif")
                return true
            }
            
            // Reward süresi kontrolü
            val rewardUnlockedAt = prefs.getLong("flutter.reward_quran_widget_unlocked_at", 0)
            if (rewardUnlockedAt > 0) {
                val unlockedTime = rewardUnlockedAt
                val currentTime = System.currentTimeMillis()
                val hoursPassed = (currentTime - unlockedTime) / (1000 * 60 * 60)
                
                val isStillValid = hoursPassed < 24
                Log.d("QuranListService", "Widget erişim kontrolü - Reward: $isStillValid (${hoursPassed.toInt()}/24 saat geçti)")
                return isStillValid
            }
            
            Log.d("QuranListService", "Widget erişim kontrolü - Erişim yok")
            return false
        } catch (e: Exception) {
            Log.e("QuranListService", "Widget erişim kontrol hatası: ${e.message}")
            false
        }
    }
}