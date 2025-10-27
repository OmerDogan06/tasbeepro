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

# Google Play Core
-keep class com.google.android.play.core.** { *; }

# Core AndroidX libraries
-keep class androidx.core.** { *; }

# Multidex
-keep class androidx.multidex.** { *; }

# Flutter engine
-keep class io.flutter.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Prevent obfuscation of notification-related classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Don't obfuscate generic types
-keepattributes Signature

# Don't obfuscate exceptions
-keepattributes Exceptions

