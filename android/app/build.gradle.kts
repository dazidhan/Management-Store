plugins {
    id("com.android.application")
    id("kotlin-android")
    // Pastikan plugin Flutter ini sesuai dengan versi Flutter kamu (biasanya sudah default)
    id("dev.flutter.flutter-gradle-plugin")
    // Plugin Google Services (hanya jika pakai Firebase)
    id("com.google.gms.google-services")
}

import java.util.Properties
import java.io.FileInputStream

// Memuat file key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.kasirly.id"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.kasirly.id"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Mengambil data dari key.properties dengan aman
            keyAlias = keystoreProperties["keyAlias"] as String? ?: ""
            keyPassword = keystoreProperties["keyPassword"] as String? ?: ""
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String? ?: ""
        }
    }

    buildTypes {
<<<<<<< HEAD
        release {
            signingConfig = signingConfigs.getByName("release")
            
            // SAYA UBAH KE FALSE AGAR AMAN SAAT DEMO
            // Jika true, aplikasi bisa crash kalau konfigurasi ProGuard belum sempurna.
            isMinifyEnabled = false
            isShrinkResources = false
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
=======
    release {
        signingConfig = signingConfigs.getByName("release")
        
        // UBAH DUA BARIS INI JADI FALSE
        isMinifyEnabled = false 
        isShrinkResources = false 
        
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
>>>>>>> ce082ac984111b7d734f78ba804c05a6f9193be9
    }
}
}

flutter {
    source = "../.."
}