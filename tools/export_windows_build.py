"""Build a Windows x86_64 test package without the development MCP autoload."""

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from zipfile import ZIP_DEFLATED, ZipFile


PRESET = '''[preset.0]
name="Windows Desktop"
platform="Windows Desktop"
runnable=true
advanced_options=false
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="build/windows/Project Lumen.exe"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false
script_export_mode=2

[preset.0.options]
custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=false
binary_format/64_bits=true
binary_format/embed_pck=false
application/product_name="Project Lumen"
application/file_description="A little light, a little logic."
'''

TESTER_README = '''PROJECT LUMEN — WINDOWS TEST BUILD

Extract this ZIP into a folder, then double-click "Project Lumen.exe".
Keep "Project Lumen.pck" beside the executable; it contains the game data.

CONTROLS
Mouse: left-click places/removes a bulb; right-click toggles an X note.
Keyboard: arrows/WASD move; Space places/removes a bulb; X toggles a note;
          Escape returns to the main menu.
Xbox-style gamepad: D-pad/left stick move; A places/removes a bulb;
                    X toggles a note; B returns to the main menu.

This private test build is unsigned and may show a Windows SmartScreen notice.
'''


def project_without_editor_addons(source: str) -> str:
    """Remove editor-only MCP sections while preserving all runtime settings."""
    omitted = {"autoload", "editor_plugins"}
    result = []
    skipping = False
    for line in source.splitlines():
        if line.startswith("[") and line.endswith("]"):
            skipping = line[1:-1] in omitted
        if not skipping:
            result.append(line)
    return "\n".join(result) + "\n"


def run(command: list[str], *, cwd: Path, env: dict[str, str]) -> None:
    """Run one Godot export step and surface its full diagnostics on failure."""
    print("$", " ".join(command))
    subprocess.run(command, cwd=cwd, env=env, check=True)


def main() -> int:
    """Stage, export, and zip the x86_64 Windows playtest build."""
    repository = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=shutil.which("godot") or shutil.which("godot4"))
    args = parser.parse_args()
    if not args.godot:
        parser.error("Provide the Godot 4.7.2 executable with --godot.")

    output = repository / "build/windows"
    output.mkdir(parents=True, exist_ok=True)
    work = repository / "work"
    work.mkdir(exist_ok=True)
    (work / ".gdignore").touch()

    with tempfile.TemporaryDirectory(prefix="windows-export-", dir=work) as directory:
        project = Path(directory)
        config = (repository / "project.godot").read_text()
        (project / "project.godot").write_text(project_without_editor_addons(config))
        (project / "export_presets.cfg").write_text(PRESET)
        for folder in ("src", "assets"):
            (project / folder).symlink_to(repository / folder, target_is_directory=True)

        environment = os.environ.copy()
        environment["GODOT_SILENCE_ROOT_WARNING"] = "1"

        run([args.godot, "--headless", "--editor", "--path", str(project), "--import", "--quit"], cwd=repository, env=environment)
        executable = output / "Project Lumen.exe"
        run([args.godot, "--headless", "--path", str(project), "--export-release", "Windows Desktop", str(executable)], cwd=repository, env=environment)

    data_pack = output / "Project Lumen.pck"
    if not executable.is_file() or not data_pack.is_file():
        raise RuntimeError("Godot export did not produce both the Windows executable and its PCK data file.")

    readme_path = output / "README.txt"
    readme_path.write_text(TESTER_README)
    archive = output / "Project-Lumen-Windows-x86_64.zip"
    with ZipFile(archive, "w", ZIP_DEFLATED) as package:
        for file in (executable, data_pack, readme_path):
            package.write(file, arcname=file.name)

    print(f"Windows x86_64 build: {executable} ({executable.stat().st_size:,} bytes)")
    print(f"Game data: {data_pack} ({data_pack.stat().st_size:,} bytes)")
    print(f"Tester package: {archive} ({archive.stat().st_size:,} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
