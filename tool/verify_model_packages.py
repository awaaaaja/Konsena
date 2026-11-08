"""Local, offline QA only. Does not activate or distribute any model.

Run with a venv containing onnx, onnxruntime, numpy, tokenizers.
FP32 golden tolerance is predeclared as 1e-3 absolute logit (not a quality gate).
Dark tensors are reconstructed only if the exact published SHA-256 matches.
ConsentGap is diagnosed separately and never promoted by golden inference.
"""
import argparse
import hashlib
import json
import pathlib
import time

import numpy as np
import onnx
import onnxruntime as ort
from tokenizers import Tokenizer


def read(path):
    return json.loads(path.read_text())


def main():
    ort.disable_telemetry_events()
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', required=True)
    parser.add_argument('--fixtures', default='/tmp/opencode/phase06-golden-tensors')
    args = parser.parse_args()
    catalog = read(pathlib.Path('assets/models/catalog.json'))
    results = {'runtime': ort.__version__, 'golden_absolute_logit_tolerance': 0.001,
               'scope': 'host authored contract probes; NOT Android or evaluation dataset', 'models': []}
    for model in catalog['models']:
        root = pathlib.Path(model['sourceDirectory'])
        contract = read(root / 'model_contract.json')
        golden = read(root / 'golden_cases.json')
        labels = read(root / 'labels.json')['labels']
        record = {'id': model['id'], 'versions': model['version'], 'variants': [], 'cases': []}
        results['models'].append(record)
        for variant in model['variants']:
            path = root / variant['file']
            with path.open('rb') as stream:
                digest = hashlib.file_digest(stream, 'sha256').hexdigest()
            record['variants'].append({'file': path.name, 'sha256': digest,
                                       'hash_match': digest == variant['sha256'],
                                       'catalog_validation': variant['validation']})
        fp32 = root / model['variants'][0]['file']
        if not all(v['hash_match'] for v in record['variants']):
            record['status'] = 'FAIL_HASH'
            continue
        graph = onnx.load(fp32, load_external_data=False)
        onnx.checker.check_model(graph)
        record['graph'] = {'inputs': [{'name': t.name, 'dtype': t.type.tensor_type.elem_type,
                                      'shape': [d.dim_value or d.dim_param for d in t.type.tensor_type.shape.dim]}
                                     for t in graph.graph.input],
                           'outputs': [{'name': t.name, 'dtype': t.type.tensor_type.elem_type,
                                        'shape': [d.dim_value or d.dim_param for d in t.type.tensor_type.shape.dim]}
                                       for t in graph.graph.output],
                           'opset': [(o.domain, o.version) for o in graph.opset_import]}
        del graph
        options = ort.SessionOptions()
        options.intra_op_num_threads = 2
        session = ort.InferenceSession(str(fp32), options, providers=['CPUExecutionProvider'])
        tokenizer = None
        if (root / 'tokenizer.json').exists():
            tokenizer = Tokenizer.from_file(str(root / 'tokenizer.json'))
            tokenizer.enable_padding(length=256, pad_id=0, pad_token='[PAD]')
            tokenizer.enable_truncation(max_length=256, strategy='longest_first')
        for index, case in enumerate(golden):
            check = {'id': case.get('id', index)}
            if tokenizer:
                ids = case['input_ids']
                mask = case['attention_mask']
                if 'text' in case:
                    encoded = tokenizer.encode(case['text'], case.get('text_pair'))
                    check['token_ids_exact'] = encoded.ids == ids
                    check['mask_exact'] = encoded.attention_mask == mask
                else:
                    check['tokenizer_status'] = 'NOT_RUN_NO_SOURCE_TEXT'
                inputs = {'input_ids': np.array([ids], dtype=np.int64),
                          'attention_mask': np.array([mask], dtype=np.int64)}
            else:
                # Generator string permits two common float32 casting orders;
                # exact SHA alone decides whether the fixture is recoverable.
                seed = case['procedural_uniform_seed']
                array = np.random.default_rng(seed).uniform(-1, 1, case['shape']).astype('<f4')
                digest = hashlib.sha256(array.tobytes()).hexdigest()
                if digest != case['tensor_sha256']:
                    check['status'] = 'NOT_RUN_FIXTURE_HASH_MISMATCH'
                    check['generated_sha256'] = digest
                    record['cases'].append(check)
                    continue
                target = pathlib.Path(args.fixtures) / str(case['tensor_file'])
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(array.tobytes())
                check['tensor_sha256_match'] = True
                inputs = {'pixel_values': array}
            start = time.perf_counter()
            logits = session.run(['logits'], inputs)[0]
            check['latency_ms'] = (time.perf_counter() - start) * 1000
            expected = np.array(case.get('expected_logits', case.get('logits')), dtype=np.float32).reshape(1, -1)
            check['finite'] = bool(np.isfinite(logits).all())
            check['shape'] = list(logits.shape)
            check['max_abs_logit_difference'] = float(np.max(np.abs(logits - expected)))
            calibration = contract.get('calibration', {})
            temp = calibration.get('temperature', contract.get('calibration_temperature', 1))
            if contract['activation'] == 'sigmoid':
                probs = 1 / (1 + np.exp(-logits[0] / temp))
                decoded = [labels[i] for i, (p, threshold) in enumerate(zip(probs, calibration['thresholds'])) if p >= threshold]
            else:
                decoded = [labels[int(np.argmax(logits[0] / temp))]]
            check['decoded_labels'] = decoded
            check['decode_exact'] = decoded == case.get('expected_decoded_labels', decoded)
            check['status'] = 'PASS' if (check['finite'] and check['max_abs_logit_difference'] <= 0.001
                and check['decode_exact'] and check.get('token_ids_exact', True) and check.get('mask_exact', True)) else 'FAIL'
            record['cases'].append(check)
        del session
        record['status'] = 'QA_ONLY' if all(c['status'] == 'PASS' for c in record['cases']) else 'FAIL_OR_NOT_RUN'
        if model['id'] == 'consentgap':
            record['status'] = 'QUARANTINED'
            record['reason'] = 'Synthetic demo; original PyTorch export parity fails. Golden parity cannot override that gate.'
    pathlib.Path(args.output).write_text(json.dumps(results, indent=2) + '\n')
    print(json.dumps({m['id']: {'status': m.get('status'), 'cases': len(m['cases'])} for m in results['models']}, indent=2))


if __name__ == '__main__':
    main()
