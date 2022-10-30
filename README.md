# ntx

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## FIX FOR APPLE M1 CHIP 
FOR PROTOBUF/ PROTOC ERROR
#### OPEN TARGET FOLDER ON ANDROID STUDIO -> ON RIGHT MOST SIDE -> OPEN GRADLE TAB -> RIGHT CLICK 
#### FLUTTER_BLUE PLUGIN AND OPEN GRADLE CONFIG -> PROTOBUF WITH THE FOLLOWING
protobuf {
    protoc {
        artifact = 'com.google.protobuf:protoc:3.17.3'
    }
    generateProtoTasks {
        all().each { task ->
            task.builtins {
                java {
                    option "lite"
                }
            }
        }
    }
}
#### Reference : https://github.com/pauldemarco/flutter_blue/issues/947