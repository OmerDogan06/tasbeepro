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

# Android Alarm Manager Plus
-keep class dev.fluttercommunity.plus.androidalarmmanager.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep entry point methods for alarm callbacks
-keep class ** {
    @io.flutter.embedding.engine.dart.DartExecutor$DartEntrypoint public *;
}

# Keep Flutter entry points
-keep class io.flutter.embedding.engine.dart.DartExecutor$DartEntrypoint { *; }
-keep @interface io.flutter.embedding.engine.dart.DartExecutor$DartEntrypoint

# Prevent obfuscation of alarm callback methods
-keepclassmembers class ** {
    @io.flutter.embedding.engine.dart.DartExecutor$DartEntrypoint <methods>;
}

# Google Play Core (for Split APKs)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter Play Store Split
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# General rules for Play Core
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**