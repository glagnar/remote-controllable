# remote-controllable

[![Twitter: @thomasbjgilbert](https://img.shields.io/badge/contact-@thomasbjgilbert-blue.svg?style=flat)](https://twitter.com/thomasbjgilbert)
[![Language: Swift](https://img.shields.io/badge/lang-Swift-yellow.svg?style=flat)](https://developer.apple.com/swift/)
[![License: Mit](https://img.shields.io/badge/license-AGPL-lightgrey.svg?style=flat)](http://opensource.org/licenses/AGPL-3.0)

## What is remote-controllable?
This library is written to allow an app to be supported remotely. Think 'teamviewer' inside your app. Once the app is connected, screenshots are streamed to the server, and in turn, the server can draw dots at specific locations on the screen. Thanks to remote-controllable you can offer remote support in your app, with only a couple of lines of code.

The library is maintained by [@glagnar](https://github.com/glagnar) under [remote-controllable](https://github.com/swiftreactive). You can reach me at [thomas.gilbert@alexandra.dk](mailto://thomas.gilbert@alexandra.dk) for help or if you have a comment about the library.

## Features
- Swift 2.1 compatible (Xcode 7.1).
- For **beginners**
- Built for iOS
- Actively supported

## Setup

### [Cocoapods](https://cocoapods.org)

1. Install [CocoaPods](https://cocoapods.org). You can do it with `gem install cocoapods`
2. Edit your `Podfile` file and add the following line `pod 'remote-controllable'
3. Update your pods with the command `pod install`
4. Open the project from the generated workspace (`.xcworkspace` file).

*Note: You can also test the past commits by specifying it directly in the Podfile line*

#### Requirements
- You need a service set up to run this library. 
- Try this one at [DockerHub](https://hub.docker.com/r/glagnar/remote-coordinator/)

#### How to use in your program
The library will connect to a server on request. Once connected, it will send a screenshot to the server at intervals, and allow the server to draw on the iOS device. The first step to start using remote-controllable is connecting to the server. In fact, the whole thing is so easy - there are only three methods. `isConnected()`, `startConnection(url: String)`, `stopConnection()`.

```swift
// Example using all three methods
import remote_controllable

func yourFunction() {
  RemoteControllableApp.sharedInstance.isConnected() ?
    RemoteControllableApp.sharedInstance.stopConnection() :
    RemoteControllableApp.sharedInstance.startConnection("yourserver.com:8006")
}

// Another perhaps more realistic function
func yourFunction2() {
  let myConnector = RemoteControllableApp.sharedInstance

  if somethingImportatnt == somethingElse {
    myConnector.stopConnection()
  }
}
```
## Thanks
This could not be possible if it were'nt for the guy's behind [socket.io](http://www.socket.io)

#### Note
This library can be made available on different licensing terms. Contact me for more information.
