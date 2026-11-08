"""Stream allowlisted FP32 packages to a connected debug test installation.

Requires an explicit --model selection, matching catalog SHA and sufficient
device storage. Never installs demo/INT8 and never touches user audit storage.
Golden image tensors must already have been verified by verify_model_packages.
"""
import argparse
import hashlib
import json
import pathlib
import shlex
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--adb', required=True)
parser.add_argument('--model', required=True, choices=['consent_nli', 'dark_pattern', 'privacy_classifier'])
parser.add_argument('--fixtures', default='/tmp/opencode/phase06-golden-tensors')
args = parser.parse_args()
models = json.loads(pathlib.Path('assets/models/catalog.json').read_text())['models']
model = next(m for m in models if m['id'] == args.model)
root = pathlib.Path(model['sourceDirectory'])
variant = model['variants'][0]
file = root / variant['file']
with file.open('rb') as stream:
    assert hashlib.file_digest(stream, 'sha256').hexdigest() == variant['sha256']
# Reserve 2x model bytes + 256 MB, including runtime headroom for temporary files.
df = subprocess.check_output([args.adb, 'shell', 'df', '-k', '/data'], text=True)
available = int(df.strip().splitlines()[-1].split()[3]) * 1024
assert available > file.stat().st_size * 2 + 256 * 1024 * 1024, 'Insufficient device space'
base = f'files/model_qa/{args.model}'
subprocess.run([args.adb, 'shell', 'run-as', 'id.konsena.ai', 'mkdir', '-p', base + '/golden_tensors'], check=True)


def copy(source, destination):
    with source.open('rb') as stream:
        subprocess.run([args.adb, 'shell', 'run-as', 'id.konsena.ai', 'sh', '-c',
                        shlex.quote('cat > ' + destination)], stdin=stream, check=True)


try:
    remote_hash = subprocess.check_output([args.adb, 'shell', 'run-as', 'id.konsena.ai',
        'sha256sum', base + '/model.onnx'], text=True, stderr=subprocess.DEVNULL).split()[0]
except (subprocess.CalledProcessError, IndexError):
    remote_hash = None
if remote_hash != variant['sha256']:
    copy(file, base + '/model.onnx')
copy(root / 'golden_cases.json', base + '/golden_cases.json')
copy(root / 'model_contract.json', base + '/model_contract.json')
copy(root / 'labels.json', base + '/labels.json')
if (root / 'tokenizer.json').exists():
    copy(root / 'tokenizer.json', base + '/tokenizer.json')
for case in json.loads((root / 'golden_cases.json').read_text()):
    if 'tensor_file' in case:
        tensor = pathlib.Path(args.fixtures) / case['tensor_file']
        assert hashlib.sha256(tensor.read_bytes()).hexdigest() == case['tensor_sha256']
        copy(tensor, base + '/' + case['tensor_file'])
print(f'QA_ONLY package prepared in private test storage: {args.model}')
