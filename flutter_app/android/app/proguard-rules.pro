# ==============================================================================
# Al-Furkan Zen Hifz - ProGuard & R8 Optimization / Obfuscation Rules
# Target: Android Release APK (Flutter 3.x / AGP 8.x)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Flutter Core & Engine
# ------------------------------------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Preserve native JNI methods for Flutter engine
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve Flutter annotations & generated bindings
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes Exceptions
-keepattributes SourceFile,LineNumberTable

# ------------------------------------------------------------------------------
# 2. Hive / Hive CE Local Storage
# ------------------------------------------------------------------------------
-keep class io.hive.** { *; }
-dontwarn io.hive.**
-keep class * implements io.hive.TypeAdapter { *; }
-keepclassmembers class * {
    @io.hive.** <fields>;
    @io.hive.** <methods>;
}
-keep @interface io.hive.** { *; }

# Keep model classes stored in Hive boxes
-keep class com.idrisium.alfurkan.zen.models.** { *; }

# ------------------------------------------------------------------------------
# 3. Just Audio & AudioService (ExoPlayer / Media3)
# ------------------------------------------------------------------------------
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audioservice.** { *; }
-dontwarn com.ryanheise.just_audio.**
-dontwarn com.ryanheise.audioservice.**

# AndroidX Media & ExoPlayer internal reflection
-keep class androidx.media.** { *; }
-keep class androidx.media3.** { *; }
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn androidx.media.**
-dontwarn androidx.media3.**
-dontwarn com.google.android.exoplayer2.**

# Audio focus and media session callbacks
-keepclassmembers class * extends androidx.media.MediaBrowserServiceCompat {
    *;
}

# ------------------------------------------------------------------------------
# 4. LiveKit & WebRTC (Friends Halaqa Rooms)
# ------------------------------------------------------------------------------
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**
-keep class io.livekit.android.** { *; }
-dontwarn io.livekit.android.**

# Keep WebRTC JNI native callbacks
-keepclasseswithmembers class org.webrtc.** {
    native <methods>;
}
-keep class org.webrtc.AudioTrack { *; }
-keep class org.webrtc.VideoTrack { *; }
-keep class org.webrtc.PeerConnection** { *; }

# ------------------------------------------------------------------------------
# 5. Recite Quran (Sherpa-ONNX Local ASR Engine)
# ------------------------------------------------------------------------------
-keep class com.k2fsa.sherpa.onnx.** { *; }
-dontwarn com.k2fsa.sherpa.onnx.**
-keep class ai.onnxruntime.** { *; }
-dontwarn ai.onnxruntime.**

-keepclasseswithmembernames class com.k2fsa.sherpa.onnx.** {
    native <methods>;
}
-keepclasseswithmembernames class ai.onnxruntime.** {
    native <methods>;
}

# ------------------------------------------------------------------------------
# 6. Alarm Package (Escalating Alarms & Notifications)
# ------------------------------------------------------------------------------
-keep class com.gdelataillade.alarm.** { *; }
-dontwarn com.gdelataillade.alarm.**
-keep class com.gdelataillade.alarm.services.** { *; }
-keep class com.gdelataillade.alarm.receivers.** { *; }

# Ensure Alarm receivers and notification services remain un-obfuscated
-keep class * extends android.app.Service
-keep class * extends android.content.BroadcastReceiver

# ------------------------------------------------------------------------------
# 7. AndroidX Multidex & Kotlin Coroutines
# ------------------------------------------------------------------------------
-keep class androidx.multidex.** { *; }
-dontwarn androidx.multidex.**
-keepclassmembers class androidx.multidex.** {
    *;
}

-dontwarn kotlinx.coroutines.**
-keep class kotlinx.coroutines.** { *; }
