"""Compile, execute and compare the six companion programs. Python 3.10+."""
import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import sys

PROJECT = Path(__file__).resolve().parents[1]
BUILD = PROJECT / '.build'
RESULTS = PROJECT / 'test_results'
INTERACTIVE_CASES = {
  "campus_fare_pass": [
    [
      "normal",
      "2000\n",
      "Base fare in centavos (2000 = PHP 20):\nRegular fare: 2000 centavos\nStudent fare: 1600 centavos\n"
    ],
    [
      "rounding",
      "3\n",
      "Base fare in centavos (2000 = PHP 20):\nRegular fare: 3 centavos\nStudent fare: 2 centavos\n"
    ],
    [
      "zero",
      "0\n",
      "Base fare in centavos (2000 = PHP 20):\nRegular fare: 0 centavos\nStudent fare: 0 centavos\n"
    ],
    [
      "maximum",
      "9223372036854775807\n",
      "Base fare in centavos (2000 = PHP 20):\nRegular fare: 9223372036854775807 centavos\nStudent fare: 7378697629483820646 centavos\n"
    ],
    [
      "invalid_-1",
      "-1\n",
      "Base fare in centavos (2000 = PHP 20):\nEnter a whole number from 0 to 9223372036854775807.\n"
    ],
    [
      "invalid_1.5",
      "1.5\n",
      "Base fare in centavos (2000 = PHP 20):\nEnter a whole number from 0 to 9223372036854775807.\n"
    ],
    [
      "invalid_abc",
      "abc\n",
      "Base fare in centavos (2000 = PHP 20):\nEnter a whole number from 0 to 9223372036854775807.\n"
    ],
    [
      "invalid_blank",
      "\n",
      "Base fare in centavos (2000 = PHP 20):\nEnter a whole number from 0 to 9223372036854775807.\n"
    ],
    [
      "invalid_9223372036854775808",
      "9223372036854775808\n",
      "Base fare in centavos (2000 = PHP 20):\nEnter a whole number from 0 to 9223372036854775807.\n"
    ],
    [
      "eof",
      "",
      "Base fare in centavos (2000 = PHP 20):\nInput ended.\n"
    ]
  ],
  "study_room_seat_counter": [
    [
      "sequence",
      "1\n1\n1\n2\n2\n2\n3\n4\n",
      "1 Reserve | 2 Cancel | 3 Status | 4 Exit\nReserve: accepted; occupied=1; available=1\n1 Reserve | 2 Cancel | 3 Status | 4 Exit\nReserve: accepted; occupied=2; available=0\n1 Reserve | 2 Cancel | 3 Status | 4 Exit\nReserve: rejected; occupied=2; available=0\n1 Reserve | 2 Cancel | 3 Status | 4 Exit\nCancel: accepted; occupied=1; available=1\n1 Reserve | 2 Cancel | 3 Status | 4 Exit\nCancel: accepted; occupied=0; available=2\n1 Reserve | 2 Cancel | 3 Status | 4 Exit\nCancel: rejected; occupied=0; available=2\n1 Reserve | 2 Cancel | 3 Status | 4 Exit\nStatus: occupied=0; available=2\n1 Reserve | 2 Cancel | 3 Status | 4 Exit\nGoodbye.\n"
    ],
    [
      "invalid",
      "bad\n\n4\n",
      "1 Reserve | 2 Cancel | 3 Status | 4 Exit\nChoose 1, 2, 3, or 4.\n1 Reserve | 2 Cancel | 3 Status | 4 Exit\nChoose 1, 2, 3, or 4.\n1 Reserve | 2 Cancel | 3 Status | 4 Exit\nGoodbye.\n"
    ],
    [
      "eof",
      "",
      "1 Reserve | 2 Cancel | 3 Status | 4 Exit\nGoodbye.\n"
    ]
  ],
  "lost_and_found_matcher": [
    [
      "multiple",
      "2\numbrella\nlibrary\n4\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nCategory:\nLocation:\nBlue umbrella\nBlack umbrella\n1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ],
    [
      "single",
      "2\nbottle\nlibrary\n4\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nCategory:\nLocation:\nSteel bottle\n1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ],
    [
      "none",
      "2\nkeys\nlibrary\n4\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nCategory:\nLocation:\nNo matches.\n1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ],
    [
      "and",
      "2\nbottle\ncanteen\n4\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nCategory:\nLocation:\nNo matches.\n1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ],
    [
      "case",
      "2\nUmbrella\nlibrary\n4\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nCategory:\nLocation:\nNo matches.\n1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ],
    [
      "inventory",
      "3\n4\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nBlue umbrella | umbrella | library\nBlack umbrella | umbrella | library\nRed umbrella | umbrella | canteen\nSteel bottle | bottle | library\nNotebook | stationery | lobby\n1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ],
    [
      "register_search_inventory",
      "1\nGreen cap\nclothing\nlobby\n2\nclothing\nlobby\n3\n4\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nItem name:\nCategory:\nLocation:\nItem registered.\n1 Register | 2 Search | 3 Inventory | 4 Exit\nCategory:\nLocation:\nGreen cap\n1 Register | 2 Search | 3 Inventory | 4 Exit\nBlue umbrella | umbrella | library\nBlack umbrella | umbrella | library\nRed umbrella | umbrella | canteen\nSteel bottle | bottle | library\nNotebook | stationery | lobby\nGreen cap | clothing | lobby\n1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ],
    [
      "duplicate",
      "1\nBlue umbrella\numbrella\nlibrary\n2\numbrella\nlibrary\n4\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nItem name:\nCategory:\nLocation:\nItem registered.\n1 Register | 2 Search | 3 Inventory | 4 Exit\nCategory:\nLocation:\nBlue umbrella\nBlack umbrella\nBlue umbrella\n1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ],
    [
      "blank_registration",
      "1\n\nkeys\nlibrary\n3\n4\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nItem name:\nCategory:\nLocation:\nFields must not be blank.\n1 Register | 2 Search | 3 Inventory | 4 Exit\nBlue umbrella | umbrella | library\nBlack umbrella | umbrella | library\nRed umbrella | umbrella | canteen\nSteel bottle | bottle | library\nNotebook | stationery | lobby\n1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ],
    [
      "whitespace_registration",
      "1\nKeys\n \t\nlibrary\n3\n4\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nItem name:\nCategory:\nLocation:\nFields must not be blank.\n1 Register | 2 Search | 3 Inventory | 4 Exit\nBlue umbrella | umbrella | library\nBlack umbrella | umbrella | library\nRed umbrella | umbrella | canteen\nSteel bottle | bottle | library\nNotebook | stationery | lobby\n1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ],
    [
      "invalid_menu",
      "bad\n\n4\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nChoose 1, 2, 3, or 4.\n1 Register | 2 Search | 3 Inventory | 4 Exit\nChoose 1, 2, 3, or 4.\n1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ],
    [
      "eof",
      "",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ],
    [
      "registration_eof",
      "1\nKeys\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nItem name:\nCategory:\nInput ended.\n"
    ],
    [
      "search_eof",
      "2\numbrella\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nCategory:\nLocation:\nInput ended.\n"
    ],
    [
      "fresh_session",
      "2\nclothing\nlobby\n4\n",
      "1 Register | 2 Search | 3 Inventory | 4 Exit\nCategory:\nLocation:\nNo matches.\n1 Register | 2 Search | 3 Inventory | 4 Exit\nGoodbye.\n"
    ]
  ]
}


def run(command, allow_linker_note=False, input_text=""):
    result = subprocess.run(command, cwd=PROJECT, text=True, encoding='utf-8',
                            errors='replace', capture_output=True, timeout=90, input=input_text)
    diagnostics = result.stderr.strip()
    if allow_linker_note and re.fullmatch(r'Creating library .+ and object .+', diagnostics):
        diagnostics = ''  # Normal MSVC linker progress, not a compiler warning.
    if result.returncode != 0 or diagnostics:
        raise RuntimeError(f'Command failed or wrote diagnostics: {command}\n'
                           f'exit={result.returncode}\n{result.stdout}\n{result.stderr}')
    return result.stdout.replace('\r\n', '\n')


def linux_path(path):
    drive, tail = os.path.splitdrive(str(path.resolve()))
    if not drive:
        raise RuntimeError('The WSL launcher requires a local drive path.')
    return '/mnt/' + drive[0].lower() + tail.replace('\\', '/')


def smalltalk_command(source=None):
    gst = shutil.which('gst')
    if gst:
        return [gst] + (['-f', str(source)] if source else [])
    launcher = PROJECT / 'tools' / 'gst-local.sh'
    image_path = 'tmp/smalltalk-runtime/root/usr/lib/gnu-smalltalk/gst.im'
    has_image = any((base / image_path).is_file() for base in
                    (PROJECT.parent, PROJECT.parent.parent))
    if sys.platform == 'win32' and shutil.which('wsl') and has_image:
        return ['wsl', '-d', 'Ubuntu', '--', 'bash', linux_path(launcher)] + (
            ['-f', linux_path(source)] if source else [])
    if sys.platform != 'win32' and has_image:
        return ['bash', str(launcher)] + (['-f', str(source)] if source else [])
    raise RuntimeError('GNU Smalltalk not found. See README runtime setup instructions.')


def main():
    swiftc = shutil.which('swiftc')
    swift = shutil.which('swift')
    if not swiftc or not swift:
        raise RuntimeError('swift and swiftc must be available on PATH.')
    BUILD.mkdir(exist_ok=True)
    RESULTS.mkdir(exist_ok=True)
    report = {
        'swift_version': run([swift, '--version']).strip(),
        'smalltalk_version': run(smalltalk_command() + ['--version']).strip(),
        'programs': {},
    }
    for name in INTERACTIVE_CASES:
        executable = BUILD / (name + ('.exe' if sys.platform == 'win32' else ''))
        source_lines = {}
        for language, extension in [('swift', 'swift'), ('smalltalk', 'st')]:
            source = PROJECT / language / (name + '.' + extension)
            count = len(source.read_text(encoding='utf-8').splitlines())
            if count >= 50:
                raise RuntimeError(f'{source.name}: {count} lines exceeds the below-50 limit')
            source_lines[language] = count
        compile_command = [swiftc, '-swift-version', '6', '-warnings-as-errors',
                           str(PROJECT / 'swift' / (name + '.swift')), '-o', str(executable)]
        run(compile_command, allow_linker_note=True)
        commands = {
            'swift': [str(executable)],
            'smalltalk': smalltalk_command(PROJECT / 'smalltalk' / (name + '.st')),
        }
        record = {}
        for language, command in commands.items():
            marker = run(command + ['--test']).strip()
            if marker != name + ' tests passed':
                raise RuntimeError(f'{language}/{name}: unexpected smoke-test output: {marker!r}')
            transcripts = []
            for case_name, input_text, expected_output in INTERACTIVE_CASES[name]:
                output = run(command, input_text=input_text)
                if output != expected_output:
                    raise RuntimeError(f'{language}/{name}/{case_name}: unexpected output: {output!r}')
                transcripts.append({'case': case_name, 'input': input_text, 'output': output})
            (RESULTS / (name + '.' + language + '.txt')).write_text(
                '\n'.join('CASE ' + case['case'] + '\n' + case['output'] for case in transcripts),
                encoding='utf-8')
            record[language] = {'test_marker': marker, 'interactive_cases': transcripts, 'status': 'PASS', 'source_lines': source_lines[language]}
        report['programs'][name] = record
        print(f'PASS {name}: both languages matched all expected sessions')
    report['status'] = 'PASS'
    (RESULTS / 'verification.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print('PASS all 6 programs; all interactive cases match the specification.')


if __name__ == '__main__':
    try:
        main()
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        print(f'FAIL: {error}', file=sys.stderr)
        sys.exit(1)
