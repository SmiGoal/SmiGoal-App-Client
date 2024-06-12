# Gson 라이브러리용 ProGuard 규칙
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class **$Gson$Types { *; }
-keep class **$Json$Types { *; }
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken { *; }
-keep class **$Gson$Preconditions { *; }
-keep class com.google.gson.internal.** { *; }
-keep class com.google.gson.internal.bind.** { *; }

# Gson에서 사용할 수 있는 모든 클래스 유지
-keep class com.example.smigoal.** { *; }
-keepclassmembers class com.example.smigoal.** { *; }

# Kotlin 코루틴을 위한 추가 규칙
-keepclassmembers class kotlinx.coroutines.** { *; }
-keepclassmembers class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keep class kotlin.jvm.internal.** { *; }
-keepclassmembers class kotlin.jvm.internal.** { *; }
-keep class kotlin.coroutines.** { *; }
-keepclassmembers class kotlin.coroutines.** { *; }

# 사용 중인 Retrofit을 위한 추가 규칙
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }