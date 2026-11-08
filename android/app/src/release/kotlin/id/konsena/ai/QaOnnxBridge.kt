package id.konsena.ai

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/** Production never registers the QA channel and contains no ONNX runtime. */
class QaOnnxBridge(activity: Activity, messenger: BinaryMessenger)
