package com.skyforgestudios.tasbeepro

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.view.Gravity
import android.widget.RemoteViews
import android.widget.RemoteViewsService

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
        // Veri güncellendiğinde çağrılır
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val currentSura = prefs.getInt(KEY_CURRENT_SURA + appWidgetId, 1)
        
        // QuranDatabase'den ayetleri al
        val quranDatabase = QuranDatabase(context)
        val suraData = quranDatabase.getSuraData(currentSura)
        ayahs = suraData.ayahs
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
            val ayahText = ayahs[position].trim()
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
}