package com.skyforgestudios.tasbeepro

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.content.ContentValues
import android.database.Cursor

class WidgetZikrDatabase(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "widget_zikr.db"
        private const val DATABASE_VERSION = 1
        
        private const val TABLE_WIDGET_ZIKR = "widget_zikr_records"
        private const val COLUMN_ID = "id"
        private const val COLUMN_ZIKR_ID = "zikr_id"
        private const val COLUMN_ZIKR_NAME = "zikr_name"
        private const val COLUMN_COUNT = "count"
        private const val COLUMN_TIMESTAMP = "timestamp"
        
        private const val CREATE_WIDGET_ZIKR_TABLE = """
            CREATE TABLE $TABLE_WIDGET_ZIKR (
                $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_ZIKR_ID TEXT NOT NULL,
                $COLUMN_ZIKR_NAME TEXT NOT NULL,
                $COLUMN_COUNT INTEGER NOT NULL,
                $COLUMN_TIMESTAMP INTEGER NOT NULL
            )
        """
    }

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(CREATE_WIDGET_ZIKR_TABLE)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        // Veri kaybını önlemek için upgrade stratejisi
        // Şimdilik basit drop/create yapıyoruz
        db.execSQL("DROP TABLE IF EXISTS $TABLE_WIDGET_ZIKR")
        onCreate(db)
    }

    /**
     * Widget'tan zikir kaydı ekle (kalıcı - asla silinmez)
     */
    fun addWidgetZikrRecord(zikrId: String, zikrName: String, count: Int): Long {
        val db = writableDatabase
        val values = ContentValues().apply {
            put(COLUMN_ZIKR_ID, zikrId)
            put(COLUMN_ZIKR_NAME, zikrName)
            put(COLUMN_COUNT, count)
            put(COLUMN_TIMESTAMP, System.currentTimeMillis())
        }
        return db.insert(TABLE_WIDGET_ZIKR, null, values)
    }

    /**
     * Tüm widget zikir kayıtlarını al
     */
    fun getAllWidgetZikrRecords(): List<WidgetZikrRecord> {
        val records = mutableListOf<WidgetZikrRecord>()
        val db = readableDatabase
        val cursor: Cursor = db.query(
            TABLE_WIDGET_ZIKR,
            null,
            null,
            null,
            null,
            null,
            "$COLUMN_TIMESTAMP DESC"
        )

        with(cursor) {
            while (moveToNext()) {
                val record = WidgetZikrRecord(
                    id = getLong(getColumnIndexOrThrow(COLUMN_ID)),
                    zikrId = getString(getColumnIndexOrThrow(COLUMN_ZIKR_ID)),
                    zikrName = getString(getColumnIndexOrThrow(COLUMN_ZIKR_NAME)),
                    count = getInt(getColumnIndexOrThrow(COLUMN_COUNT)),
                    timestamp = getLong(getColumnIndexOrThrow(COLUMN_TIMESTAMP))
                )
                records.add(record)
            }
        }
        cursor.close()
        return records
    }

    /**
     * Belirli tarih aralığındaki kayıtları al
     */
    fun getRecordsInDateRange(startTimestamp: Long, endTimestamp: Long): List<WidgetZikrRecord> {
        val records = mutableListOf<WidgetZikrRecord>()
        val db = readableDatabase
        val selection = "$COLUMN_TIMESTAMP >= ? AND $COLUMN_TIMESTAMP <= ?"
        val selectionArgs = arrayOf(startTimestamp.toString(), endTimestamp.toString())
        
        val cursor: Cursor = db.query(
            TABLE_WIDGET_ZIKR,
            null,
            selection,
            selectionArgs,
            null,
            null,
            "$COLUMN_TIMESTAMP DESC"
        )

        with(cursor) {
            while (moveToNext()) {
                val record = WidgetZikrRecord(
                    id = getLong(getColumnIndexOrThrow(COLUMN_ID)),
                    zikrId = getString(getColumnIndexOrThrow(COLUMN_ZIKR_ID)),
                    zikrName = getString(getColumnIndexOrThrow(COLUMN_ZIKR_NAME)),
                    count = getInt(getColumnIndexOrThrow(COLUMN_COUNT)),
                    timestamp = getLong(getColumnIndexOrThrow(COLUMN_TIMESTAMP))
                )
                records.add(record)
            }
        }
        cursor.close()
        return records
    }

    /**
     * Widget veritabanı istatistikleri
     */
    fun getWidgetStats(): Map<String, Any> {
        val db = readableDatabase
        val stats = mutableMapOf<String, Any>()
        
        // Toplam kayıt sayısı
        val totalCursor = db.rawQuery("SELECT COUNT(*) FROM $TABLE_WIDGET_ZIKR", null)
        if (totalCursor.moveToFirst()) {
            stats["totalRecords"] = totalCursor.getInt(0)
        }
        totalCursor.close()
        
        // Toplam zikir sayısı
        val countCursor = db.rawQuery("SELECT SUM($COLUMN_COUNT) FROM $TABLE_WIDGET_ZIKR", null)
        if (countCursor.moveToFirst()) {
            stats["totalZikrCount"] = countCursor.getInt(0)
        }
        countCursor.close()
        
        // En çok yapılan zikir
        val mostUsedCursor = db.rawQuery(
            "SELECT $COLUMN_ZIKR_NAME, SUM($COLUMN_COUNT) as total FROM $TABLE_WIDGET_ZIKR GROUP BY $COLUMN_ZIKR_ID ORDER BY total DESC LIMIT 1",
            null
        )
        if (mostUsedCursor.moveToFirst()) {
            stats["mostUsedZikr"] = mostUsedCursor.getString(0)
            stats["mostUsedCount"] = mostUsedCursor.getInt(1)
        }
        mostUsedCursor.close()
        
        return stats
    }

    /**
     * Tüm widget kayıtlarını sil
     */
    fun clearAllRecords(): Int {
        val db = writableDatabase
        return db.delete(TABLE_WIDGET_ZIKR, null, null)
    }
}

/**
 * Widget Zikir kaydı data class'ı
 */
data class WidgetZikrRecord(
    val id: Long,
    val zikrId: String,
    val zikrName: String,
    val count: Int,
    val timestamp: Long
)