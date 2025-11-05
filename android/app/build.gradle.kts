plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.projecho"
    compileSdk = 35 // ✅ Must be at least 35 for flutter_local_notifications v10+
    ndkVersion = "27.0.12077973"

    compileOptions {
        // ✅ Enable Java 17 + desugaring support
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.projecho"
        minSdk = 23
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Add this line for backward compatibility (required)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.2.0"))

    // Add the Firebase Authentication library
    implementation("com.google.firebase:firebase-auth")

    // (Optional) If you need other Firebase products, add them here:
    // implementation("com.google.firebase:firebase-firestore")
    // implementation("com.google.firebase:firebase-analytics")
}
