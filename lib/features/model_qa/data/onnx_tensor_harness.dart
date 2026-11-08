import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Internal tensor parity seam. Not an AnalysisEngine and never a UI finding.
/// Runtime is debugImplementation only; release has no channel/model activation.
class OnnxTensorHarness {
  const OnnxTensorHarness();
  static const channel = MethodChannel('id.konsena/onnx_qa');
  static const enabled = kDebugMode && bool.fromEnvironment('ENABLE_MODEL_QA');

  Future<Map<Object?, Object?>> run({
    required String modelId,
    List<int>? inputIds,
    List<int>? attentionMask,
    Uint8List? pixels,
  }) async {
    if (!enabled) throw StateError('QA is disabled');
    if (!{
      'consent_nli',
      'dark_pattern',
      'privacy_classifier',
    }.contains(modelId)) {
      throw ArgumentError('Quarantined model');
    }
    final result = await channel.invokeMapMethod<Object?, Object?>(
      'runTensor',
      {
        'modelId': modelId,
        'input_ids': inputIds,
        'attention_mask': attentionMask,
        'pixels': pixels,
      },
    );
    if (result == null) throw StateError('QA unavailable');
    return result;
  }
}
