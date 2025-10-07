package com.example.tasbeepro

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WidgetDatabaseChannel(private val context: Context) : MethodChannel.MethodCallHandler {
    
    private val database: WidgetZikrDatabase by lazy { WidgetZikrDatabase(context) }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getAllRecords" -> {
                getAllRecords(result)
            }
            "getRecordsInDateRange" -> {
                getRecordsInDateRange(call, result)
            }
            "getWidgetStats" -> {
                getWidgetStats(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getAllRecords(result: MethodChannel.Result) {
        try {
            val records = database.getAllWidgetZikrRecords()
            val recordsMap = records.map { record ->
                mapOf(
                    "id" to record.id,
                    "zikrId" to record.zikrId,
                    "zikr_id" to record.zikrId, // Alternative key
                    "zikrName" to record.zikrName,
                    "zikr_name" to record.zikrName, // Alternative key
                    "count" to record.count,
                    "timestamp" to record.timestamp
                )
            }
            result.success(recordsMap)
        } catch (e: Exception) {
            result.error("DATABASE_ERROR", "Failed to get all records: ${e.message}", null)
        }
    }

    private fun getRecordsInDateRange(call: MethodCall, result: MethodChannel.Result) {
        try {
            val startTimestamp = call.argument<Long>("startTimestamp") ?: 0L
            val endTimestamp = call.argument<Long>("endTimestamp") ?: System.currentTimeMillis()
            
            val records = database.getRecordsInDateRange(startTimestamp, endTimestamp)
            val recordsMap = records.map { record ->
                mapOf(
                    "id" to record.id,
                    "zikrId" to record.zikrId,
                    "zikr_id" to record.zikrId, // Alternative key
                    "zikrName" to record.zikrName,
                    "zikr_name" to record.zikrName, // Alternative key
                    "count" to record.count,
                    "timestamp" to record.timestamp
                )
            }
            result.success(recordsMap)
        } catch (e: Exception) {
            result.error("DATABASE_ERROR", "Failed to get records in date range: ${e.message}", null)
        }
    }

    private fun getWidgetStats(result: MethodChannel.Result) {
        try {
            val stats = database.getWidgetStats()
            result.success(stats)
        } catch (e: Exception) {
            result.error("DATABASE_ERROR", "Failed to get widget stats: ${e.message}", null)
        }
    }
}