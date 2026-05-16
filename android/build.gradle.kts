allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }
}

subprojects {
    val applyNamespaceFix = {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android != null && (android as? com.android.build.gradle.BaseExtension)?.namespace == null) {
                (android as? com.android.build.gradle.BaseExtension)?.namespace = "com.example.${project.name.replace(":", "_").replace("-", "_")}"
            }

            // Force JVM target 17 for all plugins to match the app and AGP 8 requirements
            if (android != null && android is com.android.build.gradle.BaseExtension) {
                android.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
            
            project.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
                kotlinOptions {
                    jvmTarget = "17"
                }
            }

            // Fix for AGP 8.0+ manifest package conflict
            // Dynamically removes 'package' attribute from library manifests during build
            project.tasks.matching { it.name.contains("process") && it.name.contains("Manifest") }.configureEach {
                doFirst {
                    val manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val content = manifestFile.readText()
                        if (content.contains("package=")) {
                            manifestFile.writeText(content.replace(Regex("""package="[^"]*""""), ""))
                        }
                    }
                }
            }
        }
    }

    if (project.state.executed) {
        applyNamespaceFix()
    } else {
        afterEvaluate { applyNamespaceFix() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


