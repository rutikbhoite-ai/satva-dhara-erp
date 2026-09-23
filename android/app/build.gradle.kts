import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")

    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration

    // Flutter Gradle Plugin must be applied after
    // Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ============================================================
// RELEASE KEYSTORE
// ============================================================

val keystorePropertiesFile =
    rootProject.file("key.properties")

val keystoreProperties =
    Properties()

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(
        FileInputStream(keystorePropertiesFile)
    )
}

// ============================================================
// ANDROID
// ============================================================

android {
    namespace = "com.example.satva_dhara_erp"

    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ========================================================
    // SIGNING CONFIG
    // ========================================================

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias =
                    keystoreProperties["keyAlias"] as String

                keyPassword =
                    keystoreProperties["keyPassword"] as String

                storePassword =
                    keystoreProperties["storePassword"] as String

                storeFile =
                    file(
                        keystoreProperties["storeFile"] as String
                    )
            }
        }
    }

    // ========================================================
    // DEFAULT CONFIG
    // ========================================================

    defaultConfig {
        applicationId =
            "com.example.satva_dhara_erp"

        minSdk =
            flutter.minSdkVersion

        targetSdk =
            flutter.targetSdkVersion

        versionCode =
            flutter.versionCode

        versionName =
            flutter.versionName
    }

    // ========================================================
    // BUILD TYPES
    // ========================================================

    buildTypes {
        release {
            signingConfig =
                signingConfigs.getByName("release")

            // Production release
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

// ============================================================
// KOTLIN
// ============================================================

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// ============================================================
// FLUTTER
// ============================================================

flutter {
    source = "../.."
}