# iOS communication library [beta]

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

To integrate **Calldrive iOS Communication** into your Xcode project using Carthage, specify it in your `Cartfile`:

```
github "calldrive/ios-communication-library" "master"
```

Run `carthage update` to build the framework and drag the built `CDCommunication.framework` into your Xcode project.

### Manual

To add **Calldrive iOS Communication** to your app without Carthage, clone this repo and place it somewhere in your project folder. 
Then, add `CDCommunication.xcodeproj` to your project, select your app target and add the CDCommunication framework as an embedded binary under `General` and as a target dependency under `Build Phases`.
