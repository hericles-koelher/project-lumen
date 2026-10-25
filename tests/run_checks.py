"""Run domain checks without starting the development project's MCP autoload."""

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=shutil.which("godot") or shutil.which("godot4"))
    args = parser.parse_args()
    if not args.godot:
        parser.error("Provide the Godot 4.7.2 executable with --godot.")

    repository = Path(__file__).resolve().parents[1]
    work = repository / "work"
    work.mkdir(exist_ok=True)
    (work / ".gdignore").touch()
    with tempfile.TemporaryDirectory(prefix="isolated-checks-", dir=work) as directory:
        project = Path(directory)
        display_settings = (
            (repository / "project.godot").read_text(encoding="utf-8")
            .split("[display]\n", 1)[1].split("\n[", 1)[0]
        )
        (project / "project.godot").write_text(
            'config_version=5\n[application]\nconfig/name="Lumen isolated checks"\n'
            + "[display]\n" + display_settings
            + '\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n',
            encoding="utf-8",
        )
        for folder in ("src", "tests", "assets"):
            (project / folder).symlink_to(repository / folder, target_is_directory=True)
        environment = os.environ.copy()
        environment["XDG_DATA_HOME"] = str(project / "user-data")
        imported = subprocess.run(
            [args.godot, "--headless", "--path", str(project), "--editor", "--import", "--quit"],
            check=False,
            env=environment,
        )
        if imported.returncode:
            return imported.returncode
        for script in (
            "run_core.gd",
            "run_generation.gd",
            "run_input.gd",
            "run_gamepad.gd",
            "run_action_guard.gd",
            "run_preferences.gd",
            "run_flow.gd",
        ):
            result = subprocess.run(
                [args.godot, "--headless", "--path", str(project), "--script", f"res://tests/{script}"],
                check=False,
                env=environment,
            )
            if result.returncode:
                return result.returncode
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
