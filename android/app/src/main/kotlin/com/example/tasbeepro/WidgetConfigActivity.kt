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
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

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

    // Zikir ve hedef listelerini Flutter'dan yükle
    private var zikrList = mutableListOf<Pair<String, String>>()
    private var targetOptions = mutableListOf<Int>()

    // Varsayılan veriler (fallback)
    private fun getLocalizedZikirList(): List<Pair<String, String>> {
        return listOf(
            getLocalizedZikirName("subhanallah") to getLocalizedZikirName("subhanallah"),
            getLocalizedZikirName("alhamdulillah") to getLocalizedZikirName("alhamdulillah"), 
            getLocalizedZikirName("allahu_akbar") to getLocalizedZikirName("allahu_akbar"),
            getLocalizedZikirName("la_ilahe_illallah") to getLocalizedZikirName("la_ilahe_illallah"),
            getLocalizedZikirName("estaghfirullah") to getLocalizedZikirName("estaghfirullah"),
            getLocalizedZikirName("la_hawle_wela_kuvvete") to getLocalizedZikirName("la_hawle_wela_kuvvete"),
            getLocalizedZikirName("hasbiyallahu") to getLocalizedZikirName("hasbiyallahu"),
            getLocalizedZikirName("rabbena_atina") to getLocalizedZikirName("rabbena_atina"),
            getLocalizedZikirName("allahume_salli") to getLocalizedZikirName("allahume_salli"),
            getLocalizedZikirName("rabbi_zidni_ilmen") to getLocalizedZikirName("rabbi_zidni_ilmen"),
            getLocalizedZikirName("bismillah") to getLocalizedZikirName("bismillah"),
            getLocalizedZikirName("innallaha_maas_sabirin") to getLocalizedZikirName("innallaha_maas_sabirin"),
            getLocalizedZikirName("allahu_latif") to getLocalizedZikirName("allahu_latif"),
            getLocalizedZikirName("ya_rahman") to getLocalizedZikirName("ya_rahman"),
            getLocalizedZikirName("tabarak_allah") to getLocalizedZikirName("tabarak_allah"),
            getLocalizedZikirName("mashallah") to getLocalizedZikirName("mashallah")
        )
    }
    
    private fun getLocalizedZikirName(zikirKey: String): String {
        val resourceName = "zikir_$zikirKey"
        val resourceId = resources.getIdentifier(resourceName, "string", packageName)
        return if (resourceId != 0) {
            getString(resourceId)
        } else {
            // Fallback to English names
            when (zikirKey) {
                "subhanallah" -> "Subhanallah"
                "alhamdulillah" -> "Alhamdulillah"
                "allahu_akbar" -> "Allahu Akbar"
                "la_ilahe_illallah" -> "La ilaha illAllah"
                "estaghfirullah" -> "Astaghfirullah"
                "la_hawle_wala_quwwate" -> getString(resources.getIdentifier("zikir_la_hawle_wela_kuvvete", "string", packageName))
                "hasbi_allahu" -> getString(resources.getIdentifier("zikir_hasbiyallahu", "string", packageName))
                "rabbana_atina" -> getString(resources.getIdentifier("zikir_rabbena_atina", "string", packageName))
                "allahume_salli" -> getString(resources.getIdentifier("zikir_allahume_salli", "string", packageName))
                "rabbi_zidni_ilmen" -> "Rabbi Zidni Ilm"
                "bismillah" -> "Bismillah"
                "innallaha_maal_sabirin" -> getString(resources.getIdentifier("zikir_innallaha_maas_sabirin", "string", packageName))
                "allahu_latif" -> "Allahu Latif"
                "ya_rahman" -> "Ya Rahman Ya Rahim"
                "tabarak_allah" -> "Tabarak Allah"
                "mashallah" -> "MashaAllah"
                else -> "Unknown Zikr"
            }
        }
    }

    private val defaultTargetOptions = listOf(33, 99, 100, 250, 500, 1000)

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
        loadWidgetData() // Flutter'dan veri yükle
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
    
    private fun loadWidgetData() {
        try {
            val prefs = getSharedPreferences("TasbeeWidgetData", Context.MODE_PRIVATE)
            val gson = Gson()
            
            // Zikir listesini yükle
            val zikirJsonString = prefs.getString("zikr_list", null)
            if (zikirJsonString != null) {
                val zikirListType = object : TypeToken<List<Map<String, Any>>>() {}.type
                val zikirMapList: List<Map<String, Any>> = gson.fromJson(zikirJsonString, zikirListType)
                
                zikrList.clear()
                for (zikirMap in zikirMapList) {
                    val id = zikirMap["id"] as? String ?: ""
                    val name = zikirMap["name"] as? String ?: ""
                    val meaning = zikirMap["meaning"] as? String ?: ""
                    val isCustom = zikirMap["isCustom"] as? Boolean ?: false
                    
                    // Eğer custom değilse, Android tarafında yerelleştir
                    val localizedName = if (!isCustom && id.isNotEmpty()) {
                        getLocalizedZikirName(id)
                    } else {
                        name // Custom zikirler için Flutter'dan gelen ismi kullan
                    }
                    
                    zikrList.add(localizedName to meaning)
                }
                
                android.util.Log.d("WidgetConfig", "Flutter'dan ${zikrList.size} zikir yüklendi")
            } else {
                // Varsayılan liste kullan (localized)
                zikrList.addAll(getLocalizedZikirList())
                android.util.Log.d("WidgetConfig", "Varsayılan zikir listesi kullanılıyor")
            }
            
            // Target listesini yükle
            val targetJsonString = prefs.getString("target_list", null)
            if (targetJsonString != null) {
                val targetListType = object : TypeToken<List<Int>>() {}.type
                val loadedTargets: List<Int> = gson.fromJson(targetJsonString, targetListType)
                
                targetOptions.clear()
                targetOptions.addAll(loadedTargets.sorted())
                
                android.util.Log.d("WidgetConfig", "Flutter'dan ${targetOptions.size} hedef yüklendi")
            } else {
                // Varsayılan liste kullan
                targetOptions.addAll(defaultTargetOptions)
                android.util.Log.d("WidgetConfig", "Varsayılan hedef listesi kullanılıyor")
            }
            
        } catch (e: Exception) {
            android.util.Log.e("WidgetConfig", "Widget verileri yüklenirken hata: ${e.message}")
            // Hata durumunda varsayılan listeleri kullan
            zikrList.clear()
            zikrList.addAll(getLocalizedZikirList())
            targetOptions.clear()
            targetOptions.addAll(defaultTargetOptions)
        }
    }

    private fun setupSpinners() {
        // Zikir spinner setup - dinamik liste
        val zikrNames = zikrList.map { it.first }
        val zikrAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, zikrNames)
        zikrAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        zikrSpinner.adapter = zikrAdapter

        // Target spinner setup - dinamik liste
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