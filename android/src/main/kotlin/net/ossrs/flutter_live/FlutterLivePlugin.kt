package net.ossrs.flutter_live

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.content.Context
import android.media.AudioManager

/** FlutterLivePlugin */
class FlutterLivePlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private var audioManager: AudioManager? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_live")
    channel.setMethodCallHandler(this)

    val context: Context = flutterPluginBinding.applicationContext
    audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "setSpeakerphoneOn") {
      val enabled: Boolean? = call.argument("enabled")
      if (enabled == null) {
        audioManager?.setSpeakerphoneOn(true)
      } else if (enabled != audioManager?.isSpeakerphoneOn()) {
        audioManager?.setSpeakerphoneOn(enabled)
      }
      result.success(null)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
