android {
    namespace = "com.example.transdovic_erp" // cámbialo si quieres
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.transdovic_erp"
        minSdk = 23         // <-- SUBIDO A 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
