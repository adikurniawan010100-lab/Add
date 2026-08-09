def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterProjectRoot = rootProject.file('..')
def vars = new Properties()
def varsFile = new File(flutterProjectRoot, 'variables.gradle')
if (varsFile.exists()) {
    varsFile.withReader('UTF-8') { reader ->
        vars.load(reader)
    }
}

def flutterVersionCode = vars.get('FLUTTER_BUILD_VERSION_CODE', '1')
def flutterVersionName = vars.get('FLUTTER_BUILD_VERSION_NAME', '1.0.1')

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.withReader('UTF-8') { reader ->
        keystoreProperties.load(reader)
    }
}

android {
    namespace 'com.example.kasku'
            compileSdk flutter.compileSdkVersion

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
        main.java.srcDirs += 'src/main/java'
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmToolchain 17
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmToolchain 17
    }

    ndkVersion "27.0.1207936"

    defaultConfig {
        applicationId "com.example.kasku"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        manifestPlaceholders = [:]
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
        }
    }
}

flutter {
    source '../'
}
