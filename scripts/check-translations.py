#!/usr/bin/env python3
"""Validate translation placeholders and keep protocol IDs out of QML catalogs."""
import re
import xml.etree.ElementTree as ET
from pathlib import Path

root = Path(__file__).resolve().parents[1]
for path in (root / 'i18n').glob('*.ts'):
    catalog = ET.parse(path).getroot()
    for context in catalog.findall('context'):
        seen = set()
        for message in context.findall('message'):
            source = message.findtext('source', '')
            key = (source, message.findtext('comment', ''))
            assert key not in seen, (path, context.findtext('name'), key)
            seen.add(key)
            translation = message.find('translation')
            if translation is None or translation.get('type') in {'unfinished', 'vanished', 'obsolete'}:
                continue
            for text in translation.findall('numerusform') or [translation]:
                value = ''.join(text.itertext())
                assert value, (path, source, 'empty finished translation')
                assert sorted(re.findall(r'%(?:L?\d+|n)', source)) == sorted(re.findall(r'%(?:L?\d+|n)', value)), (path, source, 'placeholder mismatch')
for path in [root/'Main.qml', *(root/'views').rglob('*.qml'), *(root/'modules').rglob('*.qml')]:
    assert not re.search(r'\b(?:id|key|type|action|__action|language)\s*:\s*qsTr\(', path.read_text()), (path, 'translated protocol identifier')
print('PASS: catalog XML, placeholders and untranslated QML protocol identifiers')
