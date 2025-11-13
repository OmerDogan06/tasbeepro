package com.skyforgestudios.tasbeepro

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.*
import android.view.View
import com.skyforgestudios.tasbeepro.R

class QuranWidgetConfigActivity : Activity() {

    companion object {
        private const val PREF_NAME = "QuranWidgetPrefs"
        private const val KEY_CURRENT_SURA = "current_sura_"
        private const val KEY_FONT_SIZE = "font_size_"
    }

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private lateinit var suraSpinner: Spinner
    private lateinit var fontSizeSeekBar: SeekBar
    private lateinit var fontSizeLabel: TextView
    private lateinit var saveButton: Button
    private lateinit var cancelButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.quran_widget_config_activity)

        // Result için varsayılan olarak CANCELED ayarla
        setResult(RESULT_CANCELED)

        // Widget ID'sini al
        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        initViews()
        setupSpinners()
        setupSeekBar()
        setupButtons()
        loadExistingSettings()
    }

    private fun initViews() {
        suraSpinner = findViewById(R.id.sura_spinner)
        fontSizeSeekBar = findViewById(R.id.font_size_seekbar)
        fontSizeLabel = findViewById(R.id.font_size_label)
        saveButton = findViewById(R.id.save_button)
        cancelButton = findViewById(R.id.cancel_button)
    }

    private fun setupSpinners() {
        // Sure listesi oluştur
        val suraList = mutableListOf<String>()
        for (i in 1..114) {
            val suraName = getSuraName(i)
            suraList.add("$i. $suraName")
        }

        val suraAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, suraList)
        suraAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        suraSpinner.adapter = suraAdapter

        suraSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                // Sure seçimi yapıldı
            }
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
    }

    private fun setupSeekBar() {
        fontSizeSeekBar.min = 12
        fontSizeSeekBar.max = 24
        fontSizeSeekBar.progress = 16

        fontSizeSeekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                fontSizeLabel.text = getString(R.string.font_size_label, progress)
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
    }

    private fun setupButtons() {
        saveButton.setOnClickListener {
            saveConfiguration()
        }

        cancelButton.setOnClickListener {
            finish()
        }
    }

    private fun loadExistingSettings() {
        val prefs = getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        
        // Mevcut ayarları yükle
        val currentSura = prefs.getInt(KEY_CURRENT_SURA + appWidgetId, 1)
        val fontSize = prefs.getFloat(KEY_FONT_SIZE + appWidgetId, 16.0f)

        // Spinner'ı ayarla
        suraSpinner.setSelection(currentSura - 1)
        
        // Font boyutunu ayarla
        fontSizeSeekBar.progress = fontSize.toInt()
    }

    private fun saveConfiguration() {
        val selectedSura = suraSpinner.selectedItemPosition + 1
        val fontSize = fontSizeSeekBar.progress.toFloat()

        // Ayarları kaydet
        val prefs = getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit().apply {
            putInt(KEY_CURRENT_SURA + appWidgetId, selectedSura)
            putFloat(KEY_FONT_SIZE + appWidgetId, fontSize)
            apply()
        }

        // Widget'ı güncelle
        val appWidgetManager = AppWidgetManager.getInstance(this)
        QuranWidgetProvider().onUpdate(this, appWidgetManager, intArrayOf(appWidgetId))

        // Sonucu ayarla ve kapat
        val resultValue = Intent().apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        setResult(RESULT_OK, resultValue)
        finish()
    }

    private fun getSuraName(suraNumber: Int): String {
        return if (suraNumber in 1..114) {
            // Direct resource access ile dene
            when (suraNumber) {
                1 -> getString(R.string.sura_name_001)
                2 -> getString(R.string.sura_name_002)
                3 -> getString(R.string.sura_name_003)
                4 -> getString(R.string.sura_name_004)
                5 -> getString(R.string.sura_name_005)
                6 -> getString(R.string.sura_name_006)
                7 -> getString(R.string.sura_name_007)
                8 -> getString(R.string.sura_name_008)
                9 -> getString(R.string.sura_name_009)
                10 -> getString(R.string.sura_name_010)
                11 -> getString(R.string.sura_name_011)
                12 -> getString(R.string.sura_name_012)
                13 -> getString(R.string.sura_name_013)
                14 -> getString(R.string.sura_name_014)
                15 -> getString(R.string.sura_name_015)
                16 -> getString(R.string.sura_name_016)
                17 -> getString(R.string.sura_name_017)
                18 -> getString(R.string.sura_name_018)
                19 -> getString(R.string.sura_name_019)
                20 -> getString(R.string.sura_name_020)
                21 -> getString(R.string.sura_name_021)
                22 -> getString(R.string.sura_name_022)
                23 -> getString(R.string.sura_name_023)
                24 -> getString(R.string.sura_name_024)
                25 -> getString(R.string.sura_name_025)
                26 -> getString(R.string.sura_name_026)
                27 -> getString(R.string.sura_name_027)
                28 -> getString(R.string.sura_name_028)
                29 -> getString(R.string.sura_name_029)
                30 -> getString(R.string.sura_name_030)
                31 -> getString(R.string.sura_name_031)
                32 -> getString(R.string.sura_name_032)
                33 -> getString(R.string.sura_name_033)
                34 -> getString(R.string.sura_name_034)
                35 -> getString(R.string.sura_name_035)
                36 -> getString(R.string.sura_name_036)
                37 -> getString(R.string.sura_name_037)
                38 -> getString(R.string.sura_name_038)
                39 -> getString(R.string.sura_name_039)
                40 -> getString(R.string.sura_name_040)
                41 -> getString(R.string.sura_name_041)
                42 -> getString(R.string.sura_name_042)
                43 -> getString(R.string.sura_name_043)
                44 -> getString(R.string.sura_name_044)
                45 -> getString(R.string.sura_name_045)
                46 -> getString(R.string.sura_name_046)
                47 -> getString(R.string.sura_name_047)
                48 -> getString(R.string.sura_name_048)
                49 -> getString(R.string.sura_name_049)
                50 -> getString(R.string.sura_name_050)
                51 -> getString(R.string.sura_name_051)
                52 -> getString(R.string.sura_name_052)
                53 -> getString(R.string.sura_name_053)
                54 -> getString(R.string.sura_name_054)
                55 -> getString(R.string.sura_name_055)
                56 -> getString(R.string.sura_name_056)
                57 -> getString(R.string.sura_name_057)
                58 -> getString(R.string.sura_name_058)
                59 -> getString(R.string.sura_name_059)
                60 -> getString(R.string.sura_name_060)
                61 -> getString(R.string.sura_name_061)
                62 -> getString(R.string.sura_name_062)
                63 -> getString(R.string.sura_name_063)
                64 -> getString(R.string.sura_name_064)
                65 -> getString(R.string.sura_name_065)
                66 -> getString(R.string.sura_name_066)
                67 -> getString(R.string.sura_name_067)
                68 -> getString(R.string.sura_name_068)
                69 -> getString(R.string.sura_name_069)
                70 -> getString(R.string.sura_name_070)
                71 -> getString(R.string.sura_name_071)
                72 -> getString(R.string.sura_name_072)
                73 -> getString(R.string.sura_name_073)
                74 -> getString(R.string.sura_name_074)
                75 -> getString(R.string.sura_name_075)
                76 -> getString(R.string.sura_name_076)
                77 -> getString(R.string.sura_name_077)
                78 -> getString(R.string.sura_name_078)
                79 -> getString(R.string.sura_name_079)
                80 -> getString(R.string.sura_name_080)
                81 -> getString(R.string.sura_name_081)
                82 -> getString(R.string.sura_name_082)
                83 -> getString(R.string.sura_name_083)
                84 -> getString(R.string.sura_name_084)
                85 -> getString(R.string.sura_name_085)
                86 -> getString(R.string.sura_name_086)
                87 -> getString(R.string.sura_name_087)
                88 -> getString(R.string.sura_name_088)
                89 -> getString(R.string.sura_name_089)
                90 -> getString(R.string.sura_name_090)
                91 -> getString(R.string.sura_name_091)
                92 -> getString(R.string.sura_name_092)
                93 -> getString(R.string.sura_name_093)
                94 -> getString(R.string.sura_name_094)
                95 -> getString(R.string.sura_name_095)
                96 -> getString(R.string.sura_name_096)
                97 -> getString(R.string.sura_name_097)
                98 -> getString(R.string.sura_name_098)
                99 -> getString(R.string.sura_name_099)
                100 -> getString(R.string.sura_name_100)
                101 -> getString(R.string.sura_name_101)
                102 -> getString(R.string.sura_name_102)
                103 -> getString(R.string.sura_name_103)
                104 -> getString(R.string.sura_name_104)
                105 -> getString(R.string.sura_name_105)
                106 -> getString(R.string.sura_name_106)
                107 -> getString(R.string.sura_name_107)
                108 -> getString(R.string.sura_name_108)
                109 -> getString(R.string.sura_name_109)
                110 -> getString(R.string.sura_name_110)
                111 -> getString(R.string.sura_name_111)
                112 -> getString(R.string.sura_name_112)
                113 -> getString(R.string.sura_name_113)
                114 -> getString(R.string.sura_name_114)
                else -> getSuraNameFallback(suraNumber)
            }
        } else {
            "Unknown"
        }
    }
    
    private fun getSuraNameFallback(suraNumber: Int): String {
        // İngilizce sure isimleri fallback
        val englishSuraNames = arrayOf(
            "Al-Fatihah", "Al-Baqarah", "Aal-Imran", "An-Nisa", "Al-Ma'idah", "Al-An'am", "Al-A'raf", "Al-Anfal", "At-Tawbah", "Yunus",
            "Hud", "Yusuf", "Ar-Ra'd", "Ibrahim", "Al-Hijr", "An-Nahl", "Al-Isra", "Al-Kahf", "Maryam", "Taha",
            "Al-Anbiya", "Al-Hajj", "Al-Mu'minun", "An-Nur", "Al-Furqan", "Ash-Shu'ara", "An-Naml", "Al-Qasas", "Al-Ankabut", "Ar-Rum",
            "Luqman", "As-Sajdah", "Al-Ahzab", "Saba", "Fatir", "Ya-Sin", "As-Saffat", "Sad", "Az-Zumar", "Ghafir",
            "Fussilat", "Ash-Shura", "Az-Zukhruf", "Ad-Dukhan", "Al-Jathiyah", "Al-Ahqaf", "Muhammad", "Al-Fath", "Al-Hujurat", "Qaf",
            "Adh-Dhariyat", "At-Tur", "An-Najm", "Al-Qamar", "Ar-Rahman", "Al-Waqi'ah", "Al-Hadid", "Al-Mujadila", "Al-Hashr", "Al-Mumtahanah",
            "As-Saff", "Al-Jumu'ah", "Al-Munafiqun", "At-Taghabun", "At-Talaq", "At-Tahrim", "Al-Mulk", "Al-Qalam", "Al-Haqqah", "Al-Ma'arij",
            "Nuh", "Al-Jinn", "Al-Muzzammil", "Al-Muddaththir", "Al-Qiyamah", "Al-Insan", "Al-Mursalat", "An-Naba", "An-Nazi'at", "Abasa",
            "At-Takwir", "Al-Infitar", "Al-Mutaffifin", "Al-Inshiqaq", "Al-Buruj", "At-Tariq", "Al-A'la", "Al-Ghashiyah", "Al-Fajr", "Al-Balad",
            "Ash-Shams", "Al-Layl", "Ad-Duha", "Ash-Sharh", "At-Tin", "Al-Alaq", "Al-Qadr", "Al-Bayyinah", "Az-Zalzalah", "Al-Adiyat",
            "Al-Qari'ah", "At-Takathur", "Al-Asr", "Al-Humazah", "Al-Fil", "Quraysh", "Al-Ma'un", "Al-Kawthar", "Al-Kafirun", "An-Nasr",
            "Al-Masad", "Al-Ikhlas", "Al-Falaq", "An-Nas"
        )

        return if (suraNumber in 1..114) {
            englishSuraNames[suraNumber - 1]
        } else {
            "Sura $suraNumber"
        }
    }
}