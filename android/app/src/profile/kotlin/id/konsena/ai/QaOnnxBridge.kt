package id.konsena.ai

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/** Profiling the offline app does not include the debug-only ONNX harness. */
class QaOnnxBridge(activity: Activity, messenger: BinaryMessenger)
