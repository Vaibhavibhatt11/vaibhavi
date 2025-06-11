plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.chat_app"
    compileSdk = 34 // You can change based on your Flutter SDK compatibility
    ndkVersion = "25.1.8937393" // Or your specific Flutter/NDK version

    defaultConfig {
        applicationId = "com.example.chat_app"
        minSdk = 21 // Or: flutter.minSdkVersion
        targetSdk = 34 // Or: flutter.targetSdkVersion
        versionCode = 1 // Or: flutter.versionCode
        versionName = "1.0.0" // Or: flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            // Use the debug signing config temporarily for release builds
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Flutter handles source sets
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))
    implementation("com.google.firebase:firebase-analytics")
    // Add other Firebase modules as needed, e.g.
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
}

flutter {
    source = "../.."
}
