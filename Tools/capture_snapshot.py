#!/usr/bin/env python3
"""Capture Apple metadata inputs on macOS. Does not copy font artwork or binaries."""
import argparse
import hashlib
import json
from pathlib import Path
import plistlib
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--app', type=Path, default=Path('/Applications/SF Symbols.app'))
    args = parser.parse_args()
    app = args.app.resolve()
    info = plistlib.loads((app / 'Contents/Info.plist').read_bytes())
    version = info['CFBundleShortVersionString']
    build = info['CFBundleVersion']
    if (version, build) != ('27.0', '140'):
        raise SystemExit('Review the private decoder ABI before capturing a different app build.')
    output = ROOT / 'Metadata/Snapshot'
    hashes = {}

    def read(path):
        hashes[str(path.relative_to(app))] = hashlib.sha256(path.read_bytes()).hexdigest()
        if path.suffix == '.json':
            return json.loads(path.read_text())
        if path.suffix == '.strings':
            return json.loads(subprocess.check_output(['plutil', '-convert', 'json', '-o', '-', str(path)]))
        return plistlib.loads(path.read_bytes())

    # Stage a complete capture before replacing any previous snapshot.
    with tempfile.TemporaryDirectory() as temp:
        temp = Path(temp)
        snapshot = temp / 'snapshot'
        snapshot.mkdir()
        metadata = app / 'Contents/Resources/Metadata'
        for filename in ['name_availability.plist', 'name_aliases.strings', 'legacy_aliases.strings',
                         'categories.plist', 'symbol_categories.plist', 'symbol_search.plist',
                         'base_symbols_map.json']:
            data = read(metadata / filename)
            (snapshot / (Path(filename).stem + '.json')).write_text(
                json.dumps(data, ensure_ascii=False, sort_keys=True, indent=2) + '\n')
        enhanced = read(app / 'Contents/Resources/symbols_with_enhanced_keywords.plist')
        (snapshot / 'enhanced_keywords.json').write_text(json.dumps(enhanced, ensure_ascii=False, sort_keys=True, indent=2) + '\n')
        translations = {}
        shared = app / 'Contents/Frameworks/SFSymbolsShared.framework/Versions/A/Resources'
        for path in sorted(shared.glob('*.lproj/CategoryTitles.strings')):
            translations[path.parent.stem.replace('_', '-')] = read(path)
        (snapshot / 'category_titles.json').write_text(json.dumps(translations, ensure_ascii=False, sort_keys=True, indent=2) + '\n')
        font = app / 'Contents/Resources/Fonts/SFSymbolsFallback.otf'
        hashes[str(font.relative_to(app))] = hashlib.sha256(font.read_bytes()).hexdigest()
        executable = temp / 'extract'
        subprocess.run(['swiftc', str(ROOT / 'Tools/ExtractFontMetadata.swift'), '-o', str(executable),
                        '-Xlinker', '-rpath', '-Xlinker', str(app / 'Contents/Frameworks')], check=True)
        subprocess.run([str(executable), str(app), str(snapshot / 'symbols.csv')], check=True)
        provenance = {'sourceVersion': version, 'sourceBuild': build, 'inputSHA256': hashes}
        (snapshot / 'provenance.json').write_text(json.dumps(provenance, sort_keys=True, indent=2) + '\n')
        output.mkdir(parents=True, exist_ok=True)
        for path in sorted(snapshot.iterdir()):
            shutil.copyfile(path, output / path.name)
    print('Captured SF Symbols', version, '(' + build + ')')


if __name__ == '__main__':
    main()
