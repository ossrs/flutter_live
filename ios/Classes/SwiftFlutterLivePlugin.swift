import Flutter
import UIKit
import AVFoundation

public class SwiftFlutterLivePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_live", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterLivePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
    case "setSpeakerphoneOn":
        let args = call.arguments as! Dictionary<String,Bool>
        if !args.keys.contains("enabled") {
            break
        }
        let enabled = args["enabled"]!

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(AVAudioSession.Category.playAndRecord)
        try? session.setMode(AVAudioSession.Mode.voiceChat)
        if enabled {
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } else {
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
        }
        try? session.setActive(true)
        
        result(nil)
    default:
        break
    }
  }
}
