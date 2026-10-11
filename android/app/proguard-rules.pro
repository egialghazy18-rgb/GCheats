# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Overlay Window
-keep class flutter.overlay.window.** { *; }

# Shizuku
-keep class moe.shizuku.** { *; }
-keep class rikka.shizuku.** { *; }

# SharedPreferences
-keep class androidx.preference.** { *; }

# Jangan hapus anotasi
-keepattributes *Annotation*, Signature, Exception

# Hapus log di release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}
