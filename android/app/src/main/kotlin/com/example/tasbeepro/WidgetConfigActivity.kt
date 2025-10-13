package com.skyforgestudios.tasbeepro

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.*
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build
import android.graphics.Color
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import android.content.res.Configuration
import java.util.Locale

class WidgetConfigActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private lateinit var zikrSpinner: Spinner
    private lateinit var targetSpinner: Spinner
    private lateinit var previewZikrName: TextView
    private lateinit var previewTarget: TextView
    private lateinit var saveButton: Button
    private lateinit var cancelButton: Button
    
    // Ses kontrolü
    private lateinit var soundSwitch: Switch
    
    // SharedPreferences
    private lateinit var prefs: SharedPreferences
    
    // Ses ayarı
    private var soundEnabled = true
    
    // Desteklenen diller - Flutter tarafıyla aynı
    private val SUPPORTED_LANGUAGES = setOf("tr", "en", "ar", "id", "ur", "ms", "bn", "fr", "hi")

    // 16 Zikir türü
    private val zikrList = listOf(
        "Subhanallah" to "Allah'tan münezzeh ve mukaddestir",
        "Alhamdulillah" to "Hamd Allah'a mahsustur",
        "Allahu Akbar" to "Allah en büyüktür",
        "La ilahe illallah" to "Allah'tan başka ilah yoktur",
        "Estağfirullah" to "Allah'tan mağfiret dilerim",
        "La hawle vela kuvvete" to "Güç ve kuvvet ancak Allah'tandır",
        "Hasbiyallahu" to "Allah bana yeter, O ne güzel vekildir",
        "Rabbena Atina" to "Rabbimiz! Bize dünyada iyilik ver",
        "Allahumme Salli" to "Allah'ım, Muhammed'e salat eyle",
        "Rabbi Zidni İlmen" to "Rabbim! İlmimi artır",
        "Bismillah" to "Rahman ve Rahim olan Allah'ın adıyla",
        "İnnallaha maas sabirin" to "Şüphesiz Allah sabredenlerle beraberdir",
        "Allahu Latif" to "Allah kullarına karşı çok merhametlidir",
        "Ya Rahman Ya Rahim" to "Ey Rahman, Ey Rahim",
        "Tabarak Allah" to "Allah mübarektir",
        "Maşallah" to "Allah'ın dilediği oldu"
    )

    // Hedef seçenekleri (1000'e kadar)
    private val targetOptions = listOf(33, 99, 100, 250, 500, 1000)

    override fun attachBaseContext(newBase: Context?) {
        super.attachBaseContext(newBase?.let { getLocalizedContext(it) })
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Edge-to-edge modu aktif et
        enableEdgeToEdge()
        
        setContentView(R.layout.widget_config_activity)
        
        // Status bar'ı şeffaf yap ve içeriği altına kaydır
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Status bar ikonlarını koyu yap (açık arkaplan için)
        WindowInsetsControllerCompat(window, window.decorView).apply {
            isAppearanceLightStatusBars = true
            isAppearanceLightNavigationBars = true
        }
        
        // Status bar rengini ayarla (opsiyonel - şeffaf yapmak için)
        window.statusBarColor = Color.TRANSPARENT
        window.navigationBarColor = Color.TRANSPARENT

        // Result'u başta CANCELED olarak ayarla
        setResult(RESULT_CANCELED)

        // SharedPreferences'ı başlat
        prefs = getSharedPreferences("TasbeeWidgetPrefs", Context.MODE_PRIVATE)

        // Intent'ten widget ID'sini al
        val intent = intent
        val extras = intent.extras
        if (extras != null) {
            appWidgetId = extras.getInt(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
        }

        // Geçersiz ID ise aktiviteyi kapat
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        findViews()
        loadSettings()
        setupSpinners()
        setupClickListeners()
        updatePreview()
    }

    private fun findViews() {
        zikrSpinner = findViewById(R.id.zikr_spinner)
        targetSpinner = findViewById(R.id.target_spinner)
        previewZikrName = findViewById(R.id.preview_zikr_name)
        previewTarget = findViewById(R.id.preview_target)
        saveButton = findViewById(R.id.save_button)
        cancelButton = findViewById(R.id.cancel_button)
        
        // Ses kontrolü
        soundSwitch = findViewById(R.id.sound_switch)
    }
    
    private fun loadSettings() {
        // Flutter'dan bağımsız olarak widget'ın kendi ayarlarını yükle
        val widgetPrefs = getSharedPreferences("TasbeeWidgetSettings", Context.MODE_PRIVATE)
        soundEnabled = widgetPrefs.getBoolean("widget_sound_enabled", true) // varsayılan: açık
        
        android.util.Log.d("TasbeeWidget", "Widget ayarları yüklendi - Ses: $soundEnabled")
        
        // UI'yi güncelle
        soundSwitch.isChecked = soundEnabled
    }

    private fun setupSpinners() {
        // Zikir spinner setup
        val zikrNames = zikrList.map { it.first }
        val zikrAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, zikrNames)
        zikrAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        zikrSpinner.adapter = zikrAdapter

        // Target spinner setup
        val targetAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, targetOptions)
        targetAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        targetSpinner.adapter = targetAdapter

    }

    private fun setupClickListeners() {
        saveButton.setOnClickListener {
            saveWidgetConfiguration()
        }

        cancelButton.setOnClickListener {
            finish()
        }
        
        // Ses switch'i
        soundSwitch.setOnCheckedChangeListener { _, isChecked ->
            soundEnabled = isChecked
            saveSettings()
            if (isChecked) {
                playTestSound()
            }
        }
        
        // Spinner değişiklik dinleyicileri
        zikrSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                updatePreview()
            }
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }

        targetSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                updatePreview()
            }
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
    }

    private fun updatePreview() {
        val selectedZikr = zikrList[zikrSpinner.selectedItemPosition].first
        val selectedTarget = targetOptions[targetSpinner.selectedItemPosition]

        previewZikrName.text = selectedZikr
        previewTarget.text = getString(R.string.preview_target_text, selectedTarget)
    }

    private fun saveWidgetConfiguration() {
        val selectedZikr = zikrList[zikrSpinner.selectedItemPosition]
        val selectedTarget = targetOptions[targetSpinner.selectedItemPosition]

        // Zikir ID'sini oluştur (Türkçe karakterleri normalize et)
        val zikrId = selectedZikr.first.lowercase()
            .replace("ı", "i")
            .replace("ğ", "g")
            .replace("ü", "u")
            .replace("ş", "s")
            .replace("ö", "o")
            .replace("ç", "c")
            .replace(" ", "_")
            .replace("-", "_")

        // SharedPreferences'a kaydet
        val prefs: SharedPreferences = getSharedPreferences("TasbeeWidgetPrefs", Context.MODE_PRIVATE)
        val editor = prefs.edit()
        editor.putString("zikr_name_$appWidgetId", selectedZikr.first)
        editor.putString("zikr_meaning_$appWidgetId", selectedZikr.second)
        editor.putString("zikr_id_$appWidgetId", zikrId) // Zikir ID'sini de kaydet
        editor.putInt("target_$appWidgetId", selectedTarget)
        editor.putInt("count_$appWidgetId", 0) // Başlangıç sayısı 0
        editor.apply()

        // Widget'ı güncelle
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val widgetProvider = TasbeeWidgetProvider()
        widgetProvider.onUpdate(this, appWidgetManager, intArrayOf(appWidgetId))

        // Sonucu ayarla ve aktiviteyi kapat
        val resultValue = Intent()
        resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        setResult(RESULT_OK, resultValue)
        finish()
    }
    
    // Ses ayarları metodları
    private fun saveSettings() {
        // Flutter'dan bağımsız olarak widget'ın kendi ayarlarını sakla
        val widgetPrefs = getSharedPreferences("TasbeeWidgetSettings", Context.MODE_PRIVATE)
        val editor = widgetPrefs.edit()
        editor.putBoolean("widget_sound_enabled", soundEnabled)
        editor.apply()
        
        android.util.Log.d("TasbeeWidget", "Widget ayarları kaydedildi - Ses: $soundEnabled")
    }
    
    private fun playTestSound() {
        try {
            val toneGenerator = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 30)
            toneGenerator.startTone(ToneGenerator.TONE_PROP_BEEP, 50)
            
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                toneGenerator.release()
            }, 100)
        } catch (e: Exception) {
            // Ses çalınamazsa sessizce devam et
        }
    }
    
    // Edge-to-edge fonksiyonu
    private fun enableEdgeToEdge() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
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
            else -> Locale("en", "GB")
        }
        
        val config = Configuration(context.resources.configuration)
        config.setLocale(locale)
        
        return context.createConfigurationContext(config)
    }
}