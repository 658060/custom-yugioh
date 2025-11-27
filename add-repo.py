#!/usr/bin/env python3
"""
this script only works on NixOS, or any other linux machine
where the edopro installation is located at
`~/.local/share/edopro/VERSION_NUMBER`. to modify this script
for your own purposes, change the directory below from
`~/.local/share/edopro` to the parent directory of your local
installation.
"""
import os
import json
import glob


def main():
    # change this if your installation path differs.
    base_dir = os.path.expanduser("~/.local/share/edopro")
    if not os.path.exists(base_dir):
        raise OSError(f"Error: edopro not found at {base_dir}")
    for instance_path in glob.glob(os.path.join(base_dir, "*")):
        if not os.path.isdir(instance_path):
            continue
        config_path = os.path.join(instance_path, "config", "user_configs.json")
        print(f"Processing: {config_path}")
        update_config_file(config_path)


def update_config_file(file_path):
    new_repo_entry = {
        "url": "https://github.com/658060/custom-yugioh",
        "repo_name": "Charlotte's Custom Cards",
        "repo_path": "./repositories/custom-yugioh",
        "data_path": "",
        "script_path": "script",
        "pics_path": "pics",
        "lflist_path": "./lflists",
        "should_update": True,
        "should_read": True,
    }

    data = {"repos": [], "urls": [], "servers": []}

    os.makedirs(os.path.dirname(file_path), exist_ok=True)

    if os.path.exists(file_path):
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read().strip()
                if content:
                    data = json.loads(content)
        except (json.JSONDecodeError, IOError):
            print(
                "  Warning: File invalid or unreadable. Re-initializing with default structure."
            )
    else:
        print("  File does not exist. Initializing new config.")

    for key in ["repos", "urls", "servers"]:
        if key not in data:
            data[key] = []

    repo_exists = any(
        "658060/custom-yugioh" in repo.get("url", "") for repo in data["repos"]
    )

    if not repo_exists:
        data["repos"].append(new_repo_entry)
        try:
            with open(file_path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=4)
            print("  [SUCCESS] Added custom repository.")
        except IOError as e:
            print(f"  [ERROR] Could not write to file: {e}")
    else:
        print("  [SKIP] Repository already exists.")


if __name__ == "__main__":
    main()
