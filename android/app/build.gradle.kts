plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter debe ir después de Android y Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.transdovic_erp"

    // Puedes usar los valores de Flutter o fijarlos explícitamente.
    // compileSdk 34 funciona bien con Flutter 3.32.x
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    // AGP 8 corre sobre Java 17; usa 17 también en el código
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.transdovic_erp"
        // <-- CLAVE: súbelo a 23 por los plugins (google_api_headers, etc.)
        minSdk = 23
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Para release real cambiaremos esto por tu firma; por ahora no afecta
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
