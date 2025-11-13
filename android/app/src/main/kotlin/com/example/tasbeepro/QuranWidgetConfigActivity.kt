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

        return if (suraNumber in 1..114) {
            turkishSuraNames[suraNumber - 1]
        } else {
            "Unknown"
        }
    }
}