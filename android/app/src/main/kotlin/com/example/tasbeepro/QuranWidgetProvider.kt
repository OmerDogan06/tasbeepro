package com.skyforgestudios.tasbeepro

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.util.Log
import android.content.res.Configuration
import java.util.Locale
import com.skyforgestudios.tasbeepro.R

class QuranWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "QuranWidget"
        private const val ACTION_PREVIOUS_SURA = "ACTION_PREVIOUS_SURA"
        private const val ACTION_NEXT_SURA = "ACTION_NEXT_SURA"
        private const val ACTION_OPEN_APP = "ACTION_OPEN_APP"
        private const val ACTION_SETTINGS_CLICK = "ACTION_SETTINGS_CLICK"
        private const val PREF_NAME = "QuranWidgetPrefs"
        private const val KEY_CURRENT_SURA = "current_sura_"
        private const val KEY_FONT_SIZE = "font_size_"
        
        // Desteklenen diller
        private val SUPPORTED_LANGUAGES = setOf("tr", "en", "ar", "id", "ur", "ms", "bn", "fr", "hi", "fa", "uz", "ru", "es", "pt", "de", "it", "zh", "sw", "ja", "ko", "th")
        
        fun getSuraName(context: Context, suraNumber: Int): String {
            val locale = context.resources.configuration.locales[0].language
            
            // Türkçe sure isimleri
            val turkishSuraNames = arrayOf(
                "Fatiha", "Bakara", "Âl-i İmrân", "Nisâ", "Mâide", "En'âm", "A'râf", "Enfâl", "Tevbe", "Yûnus",
                "Hûd", "Yûsuf", "Ra'd", "İbrâhîm", "Hicr", "Nahl", "İsrâ", "Kehf", "Meryem", "Tâhâ",
                "Enbiyâ", "Hac", "Mü'minûn", "Nûr", "Furkân", "Şuarâ", "Neml", "Kasas", "Ankebût", "Rûm",
                "Lokmân", "Secde", "Ahzâb", "Sebe'", "Fâtır", "Yâsîn", "Sâffât", "Sâd", "Zümer", "Mü'min",
                "Fussilet", "Şûrâ", "Zuhruf", "Duhân", "Câsiye", "Ahkâf", "Muhammed", "Fetih", "Hucurât", "Kâf",
                "Zâriyât", "Tûr", "Necm", "Kamer", "Rahmân", "Vâkıa", "Hadîd", "Mücâdele", "Haşr", "Mümtehine",
                "Saff", "Cuma", "Münâfikûn", "Teğâbün", "Talâk", "Tahrîm", "Mülk", "Kalem", "Hâkka", "Meâric",
                "Nûh", "Cin", "Müzzemmil", "Müddessir", "Kıyâme", "İnsân", "Mürselât", "Nebe'", "Nâziât", "Abese",
                "Tekvîr", "İnfitâr", "Mutaffifîn", "İnşikâk", "Burûc", "Târık", "A'lâ", "Ğâşiye", "Fecr", "Beled",
                "Şems", "Leyl", "Duhâ", "İnşirâh", "Tîn", "Alak", "Kadr", "Beyyine", "Zelzele", "Âdiyât",
                "Kâria", "Tekâsür", "Asr", "Hümeze", "Fîl", "Kureyş", "Mâûn", "Kevser", "Kâfirûn", "Nasr",
                "Mesed", "İhlâs", "Felak", "Nâs"
            )

            // İngilizce sure isimleri
            val englishSuraNames = arrayOf(
                "Al-Fatiha", "Al-Baqarah", "Ali 'Imran", "An-Nisa", "Al-Ma'idah", "Al-An'am", "Al-A'raf", "Al-Anfal", "At-Tawbah", "Yunus",
                "Hud", "Yusuf", "Ar-Ra'd", "Ibrahim", "Al-Hijr", "An-Nahl", "Al-Isra", "Al-Kahf", "Maryam", "Ta-Ha",
                "Al-Anbya", "Al-Hajj", "Al-Mu'minun", "An-Nur", "Al-Furqan", "Ash-Shu'ara", "An-Naml", "Al-Qasas", "Al-'Ankabut", "Ar-Rum",
                "Luqman", "As-Sajdah", "Al-Ahzab", "Saba", "Fatir", "Ya-Sin", "As-Saffat", "Sad", "Az-Zumar", "Ghafir",
                "Fussilat", "Ash-Shuraa", "Az-Zukhruf", "Ad-Dukhan", "Al-Jathiyah", "Al-Ahqaf", "Muhammad", "Al-Fath", "Al-Hujurat", "Qaf",
                "Adh-Dhariyat", "At-Tur", "An-Najm", "Al-Qamar", "Ar-Rahman", "Al-Waqi'ah", "Al-Hadid", "Al-Mujadila", "Al-Hashr", "Al-Mumtahanah",
                "As-Saff", "Al-Jumu'ah", "Al-Munafiqun", "At-Taghabun", "At-Talaq", "At-Tahrim", "Al-Mulk", "Al-Qalam", "Al-Haqqah", "Al-Ma'arij",
                "Nuh", "Al-Jinn", "Al-Muzzammil", "Al-Muddaththir", "Al-Qiyamah", "Al-Insan", "Al-Mursalat", "An-Naba", "An-Nazi'at", "'Abasa",
                "At-Takwir", "Al-Infitar", "Al-Mutaffifin", "Al-Inshiqaq", "Al-Buruj", "At-Tariq", "Al-A'la", "Al-Ghashiyah", "Al-Fajr", "Al-Balad",
                "Ash-Shams", "Al-Layl", "Ad-Duhaa", "Ash-Sharh", "At-Tin", "Al-'Alaq", "Al-Qadr", "Al-Bayyinah", "Az-Zalzalah", "Al-'Adiyat",
                "Al-Qari'ah", "At-Takathur", "Al-'Asr", "Al-Humazah", "Al-Fil", "Quraysh", "Al-Ma'un", "Al-Kawthar", "Al-Kafirun", "An-Nasr",
                "Al-Masad", "Al-Ikhlas", "Al-Falaq", "An-Nas"
            )

            return if (suraNumber in 1..114) {
                when (locale) {
                    "tr" -> turkishSuraNames[suraNumber - 1]
                    else -> englishSuraNames[suraNumber - 1]
                }
            } else {
                "Unknown"
            }
        }
    }

    private lateinit var quranDatabase: QuranDatabase

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        try {
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(getLocalizedContext(context), appWidgetManager, appWidgetId)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widget: ${e.message}", e)
        }
    }
    
    // Desteklenen dillere göre context'i ayarla
    private fun getLocalizedContext(context: Context): Context {
        val currentLocale = context.resources.configuration.locales[0]
        val currentLanguage = currentLocale.language
        
        val targetLanguage = if (SUPPORTED_LANGUAGES.contains(currentLanguage)) {
            currentLanguage
        } else {
            "en" // Varsayılan İngilizce
        }
        
        if (currentLanguage == targetLanguage) {
            return context
        }
        
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

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        val localizedContext = getLocalizedContext(context)
        
        when (intent.action) {
            ACTION_PREVIOUS_SURA -> {
                val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, -1)
                if (appWidgetId != -1) {
                    previousSura(localizedContext, appWidgetId)
                }
            }
            ACTION_NEXT_SURA -> {
                val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, -1)
                if (appWidgetId != -1) {
                    nextSura(localizedContext, appWidgetId)
                }
            }
            ACTION_OPEN_APP -> {
                val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, -1)
                if (appWidgetId != -1) {
                    openQuranApp(context, appWidgetId)
                }
            }
            ACTION_SETTINGS_CLICK -> {
                val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, -1)
                if (appWidgetId != -1) {
                    openQuranWidgetSettings(context, appWidgetId)
                }
            }
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.quran_widget)
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)

        // Verileri SharedPreferences'tan al
        val currentSura = prefs.getInt(KEY_CURRENT_SURA + appWidgetId, 1)
        val fontSize = prefs.getFloat(KEY_FONT_SIZE + appWidgetId, 16.0f)

        // Sure bilgilerini güncelle
        val suraName = getSuraName(context, currentSura)
        views.setTextViewText(R.id.sura_name, suraName)
        views.setTextViewText(R.id.sura_info, "$currentSura. Sure")
        
        // ListView için adapter intent'ini ayarla
        val serviceIntent = Intent(context, QuranListService::class.java).apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        views.setRemoteAdapter(R.id.ayah_list, serviceIntent)
        
        // ListView boş view ayarla
        views.setEmptyView(R.id.ayah_list, android.R.id.empty)

        // Buton click intent'lerini ayarla
        setupButtonClicks(context, views, appWidgetId)

        // Widget'ı güncelle
        appWidgetManager.updateAppWidget(appWidgetId, views)
        
        // ListView'i güncelle
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.ayah_list)
    }

    private fun setupButtonClicks(context: Context, views: RemoteViews, appWidgetId: Int) {
        // Önceki sure butonu
        val previousIntent = Intent(context, QuranWidgetProvider::class.java).apply {
            action = ACTION_PREVIOUS_SURA
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        val previousPendingIntent = PendingIntent.getBroadcast(
            context, appWidgetId * 10 + 1, previousIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.previous_sura_button, previousPendingIntent)

        // Sonraki sure butonu
        val nextIntent = Intent(context, QuranWidgetProvider::class.java).apply {
            action = ACTION_NEXT_SURA
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        val nextPendingIntent = PendingIntent.getBroadcast(
            context, appWidgetId * 10 + 2, nextIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.next_sura_button, nextPendingIntent)

        // Uygulamayı aç butonu
        val openAppIntent = Intent(context, QuranWidgetProvider::class.java).apply {
            action = ACTION_OPEN_APP
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        val openAppPendingIntent = PendingIntent.getBroadcast(
            context, appWidgetId * 10 + 3, openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.open_app_button, openAppPendingIntent)

        // Ayarlar butonu
        val settingsIntent = Intent(context, QuranWidgetProvider::class.java).apply {
            action = ACTION_SETTINGS_CLICK
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        val settingsPendingIntent = PendingIntent.getBroadcast(
            context, appWidgetId * 10 + 4, settingsIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.settings_button, settingsPendingIntent)
    }

    private fun previousSura(context: Context, appWidgetId: Int) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val currentSura = prefs.getInt(KEY_CURRENT_SURA + appWidgetId, 1)

        val newSura = if (currentSura > 1) {
            currentSura - 1
        } else {
            114 // Son sureye dön (döngüsel navigasyon)
        }

        // Yeni pozisyonu kaydet
        prefs.edit().apply {
            putInt(KEY_CURRENT_SURA + appWidgetId, newSura)
            apply()
        }

        // Widget'ı güncelle
        val appWidgetManager = AppWidgetManager.getInstance(context)
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    private fun nextSura(context: Context, appWidgetId: Int) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val currentSura = prefs.getInt(KEY_CURRENT_SURA + appWidgetId, 1)

        val newSura = if (currentSura < 114) {
            currentSura + 1
        } else {
            1 // İlk sureye dön (döngüsel navigasyon)
        }

        // Yeni pozisyonu kaydet
        prefs.edit().apply {
            putInt(KEY_CURRENT_SURA + appWidgetId, newSura)
            apply()
        }

        // Widget'ı güncelle
        val appWidgetManager = AppWidgetManager.getInstance(context)
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    private fun openQuranApp(context: Context, appWidgetId: Int) {
        try {
            val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
            val currentSura = prefs.getInt(KEY_CURRENT_SURA + appWidgetId, 1)

            // Flutter app'i aç ve Kuran sayfasına git
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            launchIntent?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("open_quran", true)
                putExtra("sura_number", currentSura)
                context.startActivity(this)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error opening Quran app: ${e.message}")
        }
    }

    private fun openQuranWidgetSettings(context: Context, appWidgetId: Int) {
        try {
            val intent = Intent(context, QuranWidgetConfigActivity::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error opening widget settings: ${e.message}")
        }
    }

    private fun getSuraName(context: Context, suraNumber: Int): String {
        val locale = context.resources.configuration.locales[0].language
        
        // Türkçe sure isimleri
        val turkishSuraNames = arrayOf(
            "Fatiha", "Bakara", "Âl-i İmrân", "Nisâ", "Mâide", "En'âm", "A'râf", "Enfâl", "Tevbe", "Yûnus",
            "Hûd", "Yûsuf", "Ra'd", "İbrâhîm", "Hicr", "Nahl", "İsrâ", "Kehf", "Meryem", "Tâhâ",
            "Enbiyâ", "Hac", "Mü'minûn", "Nûr", "Furkân", "Şuarâ", "Neml", "Kasas", "Ankebût", "Rûm",
            "Lokmân", "Secde", "Ahzâb", "Sebe'", "Fâtır", "Yâsîn", "Sâffât", "Sâd", "Zümer", "Mü'min",
            "Fussilet", "Şûrâ", "Zuhruf", "Duhân", "Câsiye", "Ahkâf", "Muhammed", "Fetih", "Hucurât", "Kâf",
            "Zâriyât", "Tûr", "Necm", "Kamer", "Rahmân", "Vâkıa", "Hadîd", "Mücâdele", "Haşr", "Mümtehine",
            "Saff", "Cuma", "Münâfikûn", "Teğâbün", "Talâk", "Tahrîm", "Mülk", "Kalem", "Hâkka", "Meâric",
            "Nûh", "Cin", "Müzzemmil", "Müddessir", "Kıyâme", "İnsân", "Mürselât", "Nebe'", "Nâziât", "Abese",
            "Tekvîr", "İnfitâr", "Mutaffifîn", "İnşikâk", "Burûc", "Târık", "A'lâ", "Ğâşiye", "Fecr", "Beled",
            "Şems", "Leyl", "Duhâ", "İnşirâh", "Tîn", "Alak", "Kadr", "Beyyine", "Zelzele", "Âdiyât",
            "Kâria", "Tekâsür", "Asr", "Hümeze", "Fîl", "Kureyş", "Mâûn", "Kevser", "Kâfirûn", "Nasr",
            "Mesed", "İhlâs", "Felak", "Nâs"
        )

        // İngilizce sure isimleri
        val englishSuraNames = arrayOf(
            "Al-Fatiha", "Al-Baqarah", "Ali 'Imran", "An-Nisa", "Al-Ma'idah", "Al-An'am", "Al-A'raf", "Al-Anfal", "At-Tawbah", "Yunus",
            "Hud", "Yusuf", "Ar-Ra'd", "Ibrahim", "Al-Hijr", "An-Nahl", "Al-Isra", "Al-Kahf", "Maryam", "Ta-Ha",
            "Al-Anbya", "Al-Hajj", "Al-Mu'minun", "An-Nur", "Al-Furqan", "Ash-Shu'ara", "An-Naml", "Al-Qasas", "Al-'Ankabut", "Ar-Rum",
            "Luqman", "As-Sajdah", "Al-Ahzab", "Saba", "Fatir", "Ya-Sin", "As-Saffat", "Sad", "Az-Zumar", "Ghafir",
            "Fussilat", "Ash-Shuraa", "Az-Zukhruf", "Ad-Dukhan", "Al-Jathiyah", "Al-Ahqaf", "Muhammad", "Al-Fath", "Al-Hujurat", "Qaf",
            "Adh-Dhariyat", "At-Tur", "An-Najm", "Al-Qamar", "Ar-Rahman", "Al-Waqi'ah", "Al-Hadid", "Al-Mujadila", "Al-Hashr", "Al-Mumtahanah",
            "As-Saff", "Al-Jumu'ah", "Al-Munafiqun", "At-Taghabun", "At-Talaq", "At-Tahrim", "Al-Mulk", "Al-Qalam", "Al-Haqqah", "Al-Ma'arij",
            "Nuh", "Al-Jinn", "Al-Muzzammil", "Al-Muddaththir", "Al-Qiyamah", "Al-Insan", "Al-Mursalat", "An-Naba", "An-Nazi'at", "'Abasa",
            "At-Takwir", "Al-Infitar", "Al-Mutaffifin", "Al-Inshiqaq", "Al-Buruj", "At-Tariq", "Al-A'la", "Al-Ghashiyah", "Al-Fajr", "Al-Balad",
            "Ash-Shams", "Al-Layl", "Ad-Duhaa", "Ash-Sharh", "At-Tin", "Al-'Alaq", "Al-Qadr", "Al-Bayyinah", "Az-Zalzalah", "Al-'Adiyat",
            "Al-Qari'ah", "At-Takathur", "Al-'Asr", "Al-Humazah", "Al-Fil", "Quraysh", "Al-Ma'un", "Al-Kawthar", "Al-Kafirun", "An-Nasr",
            "Al-Masad", "Al-Ikhlas", "Al-Falaq", "An-Nas"
        )

        return if (suraNumber in 1..114) {
            when (locale) {
                "tr" -> turkishSuraNames[suraNumber - 1]
                else -> englishSuraNames[suraNumber - 1]
            }
        } else {
            "Unknown"
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        // Widget silindiğinde preferences'ı temizle
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        
        for (appWidgetId in appWidgetIds) {
            editor.remove(KEY_CURRENT_SURA + appWidgetId)
            editor.remove(KEY_FONT_SIZE + appWidgetId)
        }
        
        editor.apply()
    }

    override fun onEnabled(context: Context) {
        // İlk widget eklendiğinde - gerekli başlatma işlemleri
    }

    override fun onDisabled(context: Context) {
        // Son widget kaldırıldığında
    }
}

// Kuran veritabanı sınıfı
data class SuraData(val number: Int, val name: String, val ayahCount: Int, val ayahs: List<String>)

class QuranDatabase(private val context: Context) {
    
    private val suraAyahCounts = arrayOf(
        7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135,
        112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85,
        54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
        14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42,
        29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11,
        11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6
    )
    
    // Tüm sure verisini döndür
    fun getSuraData(suraNumber: Int): SuraData {
        if (suraNumber !in 1..114) {
            return SuraData(1, "Al-Fatiha", 7, listOf("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"))
        }
        
        val suraName = QuranWidgetProvider.getSuraName(context, suraNumber)
        val ayahCount = suraAyahCounts[suraNumber - 1]
        val ayahs = loadSuraFromAssets(suraNumber)
        
        return SuraData(suraNumber, suraName, ayahCount, ayahs)
    }
    
    // Assets'ten sure verilerini yükle
    private fun loadSuraFromAssets(suraNumber: Int): List<String> {
        return try {
            val inputStream = context.assets.open("quran-uthmani-min.txt")
            val lines = inputStream.bufferedReader(Charsets.UTF_8).readLines()
            inputStream.close()
            
            val ayahs = mutableListOf<String>()
            var foundSura = false
            
            for (line in lines) {
                if (line.trim().isEmpty()) continue
                
                // Her satır "sure_number|ayah_number|ayah_text" formatında
                val parts = line.split("|")
                if (parts.size >= 3) {
                    val sura = parts[0].toIntOrNull() ?: continue
                    val ayahText = parts[2].trim()
                    
                    if (sura == suraNumber) {
                        foundSura = true
                        ayahs.add(ayahText)
                    } else if (foundSura) {
                        // Sıradaki sureye geçtiyse dur
                        break
                    }
                }
            }
            
            // Eğer hiç ayet bulunamadıysa, basit örnekler döndür
            if (ayahs.isEmpty()) {
                when (suraNumber) {
                    1 -> listOf(
                        "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                        "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
                        "الرَّحْمَٰنِ الرَّحِيمِ",
                        "مَالِكِ يَوْمِ الدِّينِ",
                        "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
                        "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ",
                        "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ"
                    )
                    else -> listOf("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                }
            } else {
                ayahs
            }
        } catch (e: Exception) {
            Log.e("QuranDatabase", "Error loading sura $suraNumber from assets: ${e.message}")
            // Hata durumunda basit bir ayet döndür
            when (suraNumber) {
                1 -> listOf(
                    "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                    "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
                    "الرَّحْمَٰنِ الرَّحِيمِ",
                    "مَالِكِ يَوْمِ الدِّينِ",
                    "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
                    "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ",
                    "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ"
                )
                2 -> listOf(
                    "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                    "الم",
                    "ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ"
                )
                else -> listOf("سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَٰهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ")
            }
        }
    }
}