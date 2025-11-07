# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class androidx.** { *; }

# Keep notification classes
-keep class * extends android.app.IntentService
-keep class * extends android.content.BroadcastReceiver

# Foreground Services
-keep class * extends android.app.Service
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Timezone data
-keep class org.threeten.bp.** { *; }

# Google Play Core
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**

# Google Play Billing
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# Google Play Services Tasks
-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.android.gms.tasks.**

# Google Mobile Ads SDK and AD_ID permission
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
-dontwarn com.google.ads.**

# Google Play Services Ads Identifier
-keep class com.google.android.gms.ads.identifier.** { *; }
-dontwarn com.google.android.gms.ads.identifier.**

# Flutter engine - R8 compatibility
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

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

