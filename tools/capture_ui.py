"""Capture all UI routes with real Godot rendering and isolated player preferences."""

import argparse
from datetime import datetime
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from zoneinfo import ZoneInfo


def main() -> int:
    """Build an isolated capture project without the development MCP autoload."""
    repository = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=shutil.which("godot") or shutil.which("godot4"))
    parser.add_argument("--output", type=Path, default=repository / "docs/screenshots/review")
    args = parser.parse_args()
    if not args.godot:
        parser.error("Provide the Godot 4.7.2 executable with --godot.")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    work = repository / "work"
    work.mkdir(exist_ok=True)
    (work / ".gdignore").touch()
    with tempfile.TemporaryDirectory(prefix="ui-capture-", dir=work) as temporary:
        project = Path(temporary)
        display = (repository / "project.godot").read_text().split("[display]\n", 1)[1].split("\n[", 1)[0]
        (project / "project.godot").write_text(
            'config_version=5\n[application]\nconfig/name="Lumen UI capture"\n'
            + "[display]\n" + display
            + '\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n'
        )
        for folder in ("src", "assets", "tools"):
            (project / folder).symlink_to(repository / folder, target_is_directory=True)
        environment = os.environ.copy()
        environment["XDG_DATA_HOME"] = str(project / "user-data")
        environment["LUMEN_CAPTURE_OUTPUT"] = str(output)
        imported = subprocess.run(
            [args.godot, "--headless", "--editor", "--path", str(project), "--import", "--quit"],
            env=environment, capture_output=True, text=True, check=False,
        )
        (work / "ui-capture-import.log").write_text(imported.stdout + imported.stderr)
        if imported.returncode:
            print((imported.stdout + imported.stderr)[-5000:])
            return imported.returncode
        capture = subprocess.run(
            [args.godot, "--path", str(project), "--script", "res://tools/capture_ui.gd"],
            env=environment, capture_output=True, text=True, check=False,
        )
        log = capture.stdout + capture.stderr
        (work / "ui-capture.log").write_text(log)
        print(log)
        if capture.returncode:
            return capture.returncode
    manifest_path = output / "index.json"
    if not manifest_path.exists():
        raise RuntimeError("Godot did not create the capture manifest.")
    manifest = json.loads(manifest_path.read_text())
    manifest["captured_at"] = datetime.now(ZoneInfo("America/Sao_Paulo")).isoformat()
    manifest["game_revision"] = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=repository, text=True).strip()
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    if len(manifest["captures"]) != 40:
        raise RuntimeError("The capture set is incomplete; expected 40 frames.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
