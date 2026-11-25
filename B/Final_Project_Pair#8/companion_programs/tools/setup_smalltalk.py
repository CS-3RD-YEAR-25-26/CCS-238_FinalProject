"""Prepare workspace-local GNU Smalltalk 3.2.5. No system packages are installed."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
from urllib.request import urlopen

PROJECT = Path(__file__).resolve().parents[1]
RUNTIME = PROJECT.parent / 'tmp' / 'smalltalk-runtime'


def linux_path(path):
    value = path.resolve().as_posix()
    return '/mnt/' + value[0].lower() + value[2:] if sys.platform == 'win32' else value


def main():
    manifest = json.loads((PROJECT / 'tools/smalltalk_runtime.json').read_text())
    packages = RUNTIME / 'packages'
    extracted = RUNTIME / 'root'
    packages.mkdir(parents=True, exist_ok=True)
    extracted.mkdir(exist_ok=True)
    prefix = ['wsl', '-d', 'Ubuntu', '--'] if sys.platform == 'win32' else []
    for package in manifest:
        target = packages / package['filename']
        if not target.exists() or hashlib.sha256(target.read_bytes()).hexdigest() != package['sha256']:
            with urlopen(package['url'], timeout=60) as response:
                content = response.read()
            if hashlib.sha256(content).hexdigest() != package['sha256']:
                raise RuntimeError('Checksum mismatch: ' + package['filename'])
            target.write_bytes(content)
        subprocess.run(prefix + ['dpkg-deb', '-x', linux_path(target), linux_path(extracted)],
                       check=True, timeout=90)
    subprocess.run(prefix + ['bash', linux_path(PROJECT / 'tools/gst-local.sh'), '--version'],
                   check=True, timeout=30)
    print('Workspace-local GNU Smalltalk ready. Run python tools/verify.py.')


if __name__ == '__main__':
    main()
