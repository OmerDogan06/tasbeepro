# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class androidx.** { *; }

# Keep notification classes
-keep class * extends android.app.IntentService
-keep class * extends android.content.BroadcastReceiver

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Timezone data
-keep class org.threeten.bp.** { *; }

