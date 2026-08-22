#!/usr/bin/env python3
"""
convert_godot4_to_3_aggressive.py

Aggressive converter for Godot 4 -> Godot 3.5.

WHAT IT DOES (aggressive):
 - Backs up each .gd/.tscn/.scn file as <file>.bak
 - Applies a set of TEXTUAL replacements (safe + aggressive) across scripts and scene files
 - Rewrites files in-place (when --apply is used)
 - Produces conversion_report.txt with changed files and flagged risky locations

USAGE:
  # dry run, no files changed
  python3 convert_godot4_to_3_aggressive.py --root /path/to/project

  # apply changes (will create backups)
  python3 convert_godot4_to_3_aggressive.py --root /path/to/project --apply

NOTES:
 - This tool performs only TEXT replacements. Many Godot-4-specific APIs need manual code changes after this pass.
 - It WILL rename node types in .tscn/.scn by text replacement (e.g. CharacterBody2D -> KinematicBody2D). Review scenes carefully in Godot 3.5.
 - It does NOT convert await -> yield automatically. It flags occurrences for manual review.
 - Use version control to review and revert changes if needed.

"""
import argparse
import re
from pathlib import Path
from datetime import datetime

REPLACEMENTS = [
    # pattern, repl, description, risk_level
    (r'@onready\s+', 'onready ', '@onready decorator -> onready keyword', 'safe'),
    (r'PackedScene\.instantiate\s*\(', 'PackedScene.instance(', 'PackedScene.instantiate() -> instance()', 'safe'),
    (r'\.instantiate\s*\(', '.instance(', 'instantiate() -> instance()', 'safe'),
    (r'\bCharacterBody2D\b', 'KinematicBody2D', 'CharacterBody2D -> KinematicBody2D', 'risky'),
    (r'\bCharacterBody\b', 'KinematicBody', 'CharacterBody -> KinematicBody', 'risky'),
    (r'->\s*void\b', '', 'Remove return annotation -> void', 'safe'),
    (r'\bVector2i\b', 'Vector2', 'Vector2i -> Vector2 (Godot 3 compatibility)', 'risky'),
]

RISKY_PATTERNS = [
    (r'\bawait\b', 'async/await usage — Godot 3 uses yield(), manual conversion likely required'),
    (r'\bCallable\b', 'Callable usage — may behave differently in Godot 3 (consider Funcref)'),
    (r'\bmove_and_slide\s*\(', 'Movement API — check move_and_slide() signature semantics'),
    (r'\bmove_and_collide\s*\(', 'Movement API — check move_and_collide() signature semantics'),
    (r'\byield\s*\(', 'yield usage — check semantics (cooperative calls)')
]

SCENE_NODE_RENAMES = [
    # node type renames to perform inside .tscn/.scn files
    (r'CharacterBody2D', 'KinematicBody2D'),
    (r'CharacterBody', 'KinematicBody'),
]

IGNORE_PATHS = [
    '.git', '.import', 'third_party', 'addons'
]

FILE_EXTS = ['.gd', '.tscn', '.scn']


def should_ignore(path: Path):
    for part in path.parts:
        if part in IGNORE_PATHS:
            return True
    return False


def apply_replacements(text: str):
    changes = []
    new_text = text
    for pat, repl, desc, risk in REPLACEMENTS:
        new_text, n = re.subn(pat, repl, new_text)
        if n:
            changes.append((desc, risk, n))
    return new_text, changes


def scan_risky(text: str):
    findings = []
    for pat, msg in RISKY_PATTERNS:
        for m in re.finditer(pat, text):
            line_no = text[:m.start()].count('\n') + 1
            snippet = text.splitlines()[line_no-1].strip()
            findings.append((line_no, snippet, msg))
    return findings


def rename_scene_nodes(text: str):
    new_text = text
    renames = []
    for pat, repl in SCENE_NODE_RENAMES:
        new_text, n = re.subn(r"\b" + pat + r"\b", repl, new_text)
        if n:
            renames.append((pat, repl, n))
    return new_text, renames


def process_file(path: Path, apply: bool):
    try:
        text = path.read_text(encoding='utf-8')
    except Exception as e:
        return {'path': str(path), 'error': f'read error: {e}'}

    orig = text
    report = {'path': str(path), 'changed': False, 'replacements': [], 'renames': [], 'risky': [], 'error': None}

    # If scene file, apply scene node renames first
    if path.suffix in ['.tscn', '.scn']:
        text, renames = rename_scene_nodes(text)
        if renames:
            report['renames'].extend(renames)

    text, replacements = apply_replacements(text)
    if replacements:
        report['replacements'].extend(replacements)

    risky = scan_risky(text)
    if risky:
        report['risky'].extend(risky)

    if text != orig:
        report['changed'] = True
        if apply:
            bak = path.with_suffix(path.suffix + '.bak')
            bak.write_text(orig, encoding='utf-8')
            path.write_text(text, encoding='utf-8')
            report['backup'] = str(bak)
    return report


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--root', default='.', help='project root')
    p.add_argument('--apply', action='store_true', help='apply changes (otherwise dry-run)')
    args = p.parse_args()

    root = Path(args.root)
    if not root.exists():
        print('Root does not exist:', root)
        return

    files = list(root.rglob('*'))
    total = 0
    reports = []

    for f in files:
        if f.is_file() and f.suffix in FILE_EXTS and not should_ignore(f):
            total += 1
            rep = process_file(f, args.apply)
            reports.append(rep)

    # Write conversion_report.txt
    now = datetime.utcnow().isoformat() + 'Z'
    lines = [f'Conversion report - {now}', f'Root: {root}', f'Total files scanned: {total}', '']
    changed_count = 0
    for r in reports:
        lines.append(f"FILE: {r['path']}")
        if r.get('error'):
            lines.append('  ERROR: ' + r['error'])
            continue
        if r.get('changed'):
            changed_count += 1
            lines.append('  CHANGED: yes')
            if 'backup' in r:
                lines.append('    backup: ' + r['backup'])
            for desc, risk, n in r['replacements']:
                lines.append(f'    replacement: {desc} (count={n}) risk={risk}')
            for pat, repl, n in r['renames']:
                lines.append(f'    rename in scene: {pat} -> {repl} (count={n})')
        else:
            lines.append('  CHANGED: no')
        if r.get('risky'):
            lines.append('  RISKY PATTERNS:')
            for line_no, snippet, msg in r['risky']:
                lines.append(f'    L{line_no}: {snippet} -> {msg}')
        lines.append('')

    lines.append(f'Total files changed: {changed_count}')
    out = '\n'.join(lines)
    (root / 'conversion_report.txt').write_text(out, encoding='utf-8')
    print('Wrote conversion_report.txt')
    if not args.apply:
        print('Dry run complete. Re-run with --apply to write changes (backups created with .bak).')

if __name__ == '__main__':
    main()
