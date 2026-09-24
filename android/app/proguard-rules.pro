# Firebase / gRPC (dipakai Firestore)
-keep class io.grpc.** { *; }
-dontwarn io.grpc.**
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# ML Kit Pose Detection & Selfie Segmentation
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_pose_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_pose_internal.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_segmentation_selfie.** { *; }
-dontwarn com.google.mlkit.**

# Dio / OkHttp
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn okhttp3.**
-dontwarn okio.**
