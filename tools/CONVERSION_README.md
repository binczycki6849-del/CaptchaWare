Aggressive Godot 4 -> 3.5 conversion script and instructions.

Files added on branch godot4-to-3.5-automated:
- tools/convert_godot4_to_3_aggressive.py

How to use (recommended):
1) Clone the repo and checkout the branch:
   git clone https://github.com/binczycki6849-del/CaptchaWare.git
   cd CaptchaWare
   git checkout godot4-to-3.5-automated

2) Dry run (no files changed):
   python3 tools/convert_godot4_to_3_aggressive.py --root .
   # This writes conversion_report.txt in repo root summarizing changes and risky locations.

3) Apply changes (creates .bak backups for edited files):
   python3 tools/convert_godot4_to_3_aggressive.py --root . --apply

4) Review conversion_report.txt and the .bak files. Test the project in Godot 3.5.

Notes:
- This script performs TEXTUAL replacements only and may not fully fix runtime incompatibilities.
- Review movement code (move_and_slide/move_and_collide), await/yield uses, Callables, and physics-related logic.
- If you want me to perform the edits myself and commit them to this branch, reply here and I will proceed (I will need to fetch and modify many files programmatically and commit them).