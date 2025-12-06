import java.util.Properties
import java.io.FileInputStream

plugins {
id("com.android.application")
id("kotlin-android")
id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
namespace = "com.example.weather_app"
compileSdk = flutter.compileSdkVersion
ndkVersion = flutter.ndkVersion


defaultConfig {
    applicationId = "com.example.weather_app"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}

signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"]?.toString() ?: ""
        keyPassword = keystoreProperties["keyPassword"]?.toString() ?: ""
        storeFile = file(keystoreProperties["storeFile"]?.toString() ?: "")
        storePassword = keystoreProperties["storePassword"]?.toString() ?: ""
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = false     // code shrinking off
        isShrinkResources = false   // resource shrinking off
    }
}

compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

kotlinOptions {
    jvmTarget = JavaVersion.VERSION_17.toString()
}


}

flutter {
source = "../.."
}
