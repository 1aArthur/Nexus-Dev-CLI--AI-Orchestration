/**
 * Nexus Dev Orchestrator - Android Build Configuration
 * Release build with signing and security hardening
 */

// android/app/build.gradle.kts
/*
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.com.google.gms.google.services)
}

android {
    namespace = "com.nexus.dev.orchestrator"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.nexus.dev.orchestrator"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        
        // Security
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        
        // Native libs
        ndk {
            abiFilters = ["arm64-v8a", "armeabi-v7a", "x86_64"]
        }
    }

    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("KEYSTORE_PATH") ?: "../keystore/release.jks"
            storeFile = file(keystorePath)
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = System.getenv("KEY_ALIAS") ?: "release"
            keyPassword = System.getenv("KEY_PASSWORD")
            
            // Enable v1, v2, v3 signing
            enableV1Signing = true
            enableV2Signing = true
            enableV3Signing = true
            enableV4Signing = true
        }
        
        create("debug") {
            storeFile = file("../keystore/debug.jks")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
            
            // Security hardening
            isDebuggable = false
            isJniDebuggable = false
            renderscriptDebuggable = false
            
            // Build config
            buildConfigField("boolean", "IS_RELEASE", "true")
            buildConfigField("String", "BUILD_TYPE", "\"release\"")
        }
        
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
            buildConfigField("boolean", "IS_RELEASE", "false")
            buildConfigField("String", "BUILD_TYPE", "\"debug\"")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
        freeCompilerArgs += [
            "-Xopt-in=kotlin.RequiresOptIn",
            "-Xopt-in=kotlinx.coroutines.ExperimentalCoroutinesApi",
        ]
    }

    buildFeatures {
        compose = true
        buildConfig = true
        viewBinding = true
    }

    // Security: Network security config
    // networkSecurityConfig = "@xml/network_security_config"
    
    // Packaging options
    packagingOptions {
        resources {
            excludes += [
                "META-INF/*.kotlin_module",
                "META-INF/INDEX.LIST",
                "META-INF/DEPENDENCIES",
            ]
        }
        jniLibs {
            pickFirsts += [
                "lib/**/libc++_shared.so",
            ]
        }
    }

    // Splits for smaller APKs
    splits {
        abi {
            enable = true
            reset()
            include("arm64-v8a", "armeabi-v7a", "x86_64")
            universalApk = false
        }
    }
}

dependencies {
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.lifecycle.runtime.compose)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.androidx.navigation.compose)
    implementation(libs.androidx.room.runtime)
    implementation(libs.kotlinx.coroutines.android)
    implementation(libs.kotlinx.coroutines.core)
    implementation(libs.okhttp)
    implementation(libs.retrofit)
    implementation(libs.moshi.kotlin)
    implementation(libs.converter.moshi)
    implementation(libs.coil.compose)
    implementation(libs.permission_handler)
    implementation(libs.flutter_tts)
    implementation(libs.web_socket_channel)
    implementation(libs.shared_preferences)
    implementation(libs.hive)
    implementation(libs.hive_flutter)
    implementation(libs.uuid)
    implementation(libs.crypto)
    implementation(libs.logger)
    implementation(libs.flutter_secure_storage)
    implementation(libs.permission_handler)
    
    ksp(libs.androidx.room.compiler)
    ksp(libs.moshi.kotlin.codegen)
    
    testImplementation(libs.junit)
    testImplementation(libs.kotlinx.coroutines.test)
    testImplementation(libs.androidx.compose.ui.test.junit4)
    
    androidTestImplementation(platform(libs.androidx.compose.bom))
    androidTestImplementation(libs.androidx.compose.ui.test.junit4)
    androidTestImplementation(libs.androidx.espresso.core)
}
*/

// android/gradle.properties
/*
org.gradle.jvmargs=-Xmx4g -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
android.nonTransitiveRClass=true
kotlin.code.style=official

# Build performance
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configureondemand=true

# Flutter
flutter.sdk=/path/to/flutter
flutter.buildMode=release
flutter.versionName=1.0.0
flutter.versionCode=1

# Signing
KEYSTORE_PATH=../keystore/release.jks
KEYSTORE_PASSWORD=your_keystore_password
KEY_ALIAS=release
KEY_PASSWORD=your_key_password
*/

// android/keystore/generate_keystore.sh
/*
#!/bin/bash
# Generate release keystore
# Run this once to create the keystore

KEYSTORE_DIR="../keystore"
mkdir -p "$KEYSTORE_DIR"

keytool -genkeypair \
    -alias release \
    -keyalg RSA \
    -keysize 4096 \
    -validity 10000 \
    -keystore "$KEYSTORE_DIR/release.jks" \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=Nexus Dev Orchestrator, OU=Engineering, O=Nexus Dev, L=San Francisco, ST=CA, C=US" \
    -ext "SAN=dns:nexus.dev,dns:api.nexus.dev"

echo "Keystore generated at $KEYSTORE_DIR/release.jks"
echo "IMPORTANT: Backup this keystore securely!"
*/

// android/app/proguard-rules.pro
/*
# Flutter/Compose rules
-keep class io.flutter.** { *; }
-keep class androidx.compose.** { *; }
-keep class kotlinx.coroutines.** { *; }

# Riverpod
-keep class dev.freetime.** { *; }

# Hive
-keep class com.hivedb.** { *; }
-keepclassmembers class * extends com.hivedb.HiveObject { *; }

# Network security
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Serialization
-keep class com.squareup.moshi.** { *; }
-keep @com.squareup.moshi.JsonClass class * { *; }

# Native
-keep class com.nexus.dev.orchestrator.native.** { *; }

# Obfuscation
-dontoptimize
-dontobfuscate
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes EnclosingMethod

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
}
*/

// android/app/src/main/res/xml/network_security_config.xml
/*
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.x.ai</domain>
        <domain includeSubdomains="true">api.exa.ai</domain>
        <domain includeSubdomains="true">generativelanguage.googleapis.com</domain>
        <pin-set expiration="2026-01-01">
            <!-- Add certificate pins here -->
        </pin-set>
    </domain-config>
    
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    
    <debug-overrides>
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </debug-overrides>
</network-security-config>
*/

// android/app/src/main/AndroidManifest.xml (additional security)
/*
<manifest ...>
    <!-- Security features -->
    <application
        android:allowBackup="false"
        android:fullBackupContent="@xml/backup_rules"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:usesCleartextTraffic="false"
        android:networkSecurityConfig="@xml/network_security_config"
        android:extractNativeLibs="true"
        android:hardwareAccelerated="true"
        android:requestLegacyExternalStorage="false">
        
        <!-- Security metadata -->
        <meta-data
            android:name="com.google.android.gms.version"
            android:value="@integer/google_play_services_version" />
        
        <!-- Disable debug in release -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
*/

// Backup rules
// android/app/src/main/res/xml/backup_rules.xml
/*
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <exclude domain="sharedpref" path="."/>
    <exclude domain="database" path="."/>
    <exclude domain="file" path="."/>
</full-backup-content>
*/

// Data extraction rules
// android/app/src/main/res/xml/data_extraction_rules.xml
/*
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <exclude domain="sharedpref" path="."/>
        <exclude domain="database" path="."/>
        <exclude domain="file" path="."/>
    </cloud-backup>
    <device-transfer>
        <exclude domain="sharedpref" path="."/>
        <exclude domain="database" path="."/>
        <exclude domain="file" path="."/>
    </device-transfer>
</data-extraction-rules>
*/
