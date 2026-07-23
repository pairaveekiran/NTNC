# mobile_scanner (CameraX + Google ML Kit Barcode Scanning)
# These keep rules prevent R8 from stripping/obfuscating classes
# accessed via reflection by CameraX and ML Kit.

# Keep mobile_scanner plugin classes
-keep class dev.steenbakker.mobile_scanner.** { *; }

# Keep Google ML Kit barcode scanning classes
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
-keep class com.google.mlkit.vision.barcode.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }

# Keep CameraX classes
-keep class androidx.camera.** { *; }
-keep interface androidx.camera.** { *; }

# Keep Google Play Services / Google Android GMS classes
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }

# Suppress warnings for classes that may not be present in all variants
-dontwarn com.google.mlkit.**
-dontwarn androidx.camera.**
-dontwarn com.google.android.gms.**
