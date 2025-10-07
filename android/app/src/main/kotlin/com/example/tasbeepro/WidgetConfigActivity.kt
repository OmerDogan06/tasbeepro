package com.example.tasbeepro

import android.app.Activity
import android.app.AlertDialog
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.*

class WidgetConfigActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private lateinit var zikrSpinner: Spinner
    private lateinit var targetSpinner: Spinner
    private lateinit var previewZikrName: TextView
    private lateinit var previewTarget: TextView
    private lateinit var saveButton: Button
    private lateinit var cancelButton: Button

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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.widget_config_activity)

        // Result'u başta CANCELED olarak ayarla
        setResult(RESULT_CANCELED)

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
        previewTarget.text = "Hedef: $selectedTarget"
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
}