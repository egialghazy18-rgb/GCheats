# ===== Flutter Core =====
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ===== Flutter Overlay Window =====
-keep class flutter.overlay.window.** { *; }

# ===== Shizuku =====
-keep class moe.shizuku.** { *; }
-keep class rikka.shizuku.** { *; }

# ===== SharedPreferences =====
-keep class androidx.preference.** { *; }

# ===== Play Core (WAJIB - fix R8 error) =====
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# ===== Deferred Components Flutter =====
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# ===== Anotasi =====
-keepattributes *Annotation*, Signature, Exception, InnerClasses, EnclosingMethod

# ===== Buang log di release =====
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}
