# Simple Dated Backup Script (tar + gzip)

A small, robust Bash script that archives multiple project folders into date-stamped `.tgz` files while excluding heavy or unnecessary directories (for example `node_modules`, virtual environments, and `.git`). Designed to work on both macOS (BSD tar) and Linux (GNU tar).

Works well for one-off runs, cron jobs, or simple scheduled backups.

---

## ✨ Features

- ✅ Backup multiple folders in one run  
- ✅ Date-stamped archive names (YYYY-MM-DD)  
- ✅ Exclude common heavy directories (configurable)  
- ✅ Safe handling of paths with spaces  
- ✅ Works on macOS and Linux  
- ✅ Cron-friendly  
- ✅ Each folder archived independently — failures in one archive do not stop the rest

---

## 📦 Example output

After running the script you might see:

```
project_a_2026-01-17.tgz
project_b_2026-01-17.tgz
project_c_2026-01-17.tgz
```

---

## ⚙️ Requirements

- Bash 4+ (the script checks the Bash version and warns if older)
- `tar`
- `gzip`

(All are available by default on most Linux systems. On macOS you may need Homebrew `bash` to get Bash 4+ if you rely on features absent in the system Bash.)

---

## ��� Installation

1. Clone the repo (if applicable)

```bash
git clone https://github.com/your-username/dated-backup-script.git
cd dated-backup-script
```

2. Make the script executable

```bash
chmod +x backup.sh
```

3. Edit the script to configure your source folders, output directory, and excludes (see Configuration below).

---

## ⚙️ Configuration (inside `backup.sh`)

- SOURCE_FOLDERS: an array of absolute paths to back up
- OUTPUT_DIR: absolute path where `.tgz` files are written
- GLOBAL_EXCLUDES: array of filename/directory patterns to exclude (applies to every archive)
- DATE format: set to `YYYY-MM-DD` by default

Example variables in the script:

```bash
SOURCE_FOLDERS=(
  "/absolute/path/to/project1"
  "/absolute/path/to/project 2 with spaces"
)

OUTPUT_DIR="/absolute/path/to/backups"

GLOBAL_EXCLUDES=(
  "node_modules"
  "venv"
  ".git"
  ".DS_Store"
)
```

---

## backup.sh (example script)

This script is POSIX-friendly where possible and uses Bash arrays for safety with spaces.

```bash
#!/usr/bin/env bash
# backup.sh — Simple dated backup script (tar + gzip)
# Requirements: Bash 4+, tar, gzip

set -u
# Note: we intentionally avoid `set -e` globally so we can handle per-archive errors.
# We'll treat failures per-archive using `|| { ...; continue; }`.
set -o pipefail

# -------------- CONFIG --------------
SOURCE_FOLDERS=(
  "/absolute/path/to/project1"
  "/absolute/path/to/project 2 with spaces"
)

OUTPUT_DIR="/absolute/path/to/backups"

GLOBAL_EXCLUDES=(
  "node_modules"
  "venv"
  ".git"
  ".DS_Store"
)

DATE=$(date '+%F') # YYYY-MM-DD
# -------------- END CONFIG --------------

# Check bash version (Bash 4+ recommended)
if [[ -z "${BASH_VERSINFO:-}" ]] || (( BASH_VERSINFO[0] < 4 )); then
  echo "Warning: Bash 4+ is recommended. Current bash major version: ${BASH_VERSINFO[0]:-unknown}" >&2
fi

mkdir -p -- "$OUTPUT_DIR"

# Build exclude arguments for tar
exclude_args=()
for pat in "${GLOBAL_EXCLUDES[@]}"; do
  # Exclude both the named entry and any children under it, anywhere in the tree.
  exclude_args+=("--exclude=$pat")
  exclude_args+=("--exclude=$pat/*")
  exclude_args+=("--exclude=*/$pat")
  exclude_args+=("--exclude=*/$pat/*")
done

# Iterate over each source folder
for src in "${SOURCE_FOLDERS[@]}"; do
  # Normalize and ensure no trailing slash
  src="${src%/}"

  if [[ ! -e "$src" ]]; then
    echo "Skipping: '$src' does not exist." >&2
    continue
  fi

  base="$(basename "$src")"
  timestamped_name="${base}_${DATE}.tgz"
  output_file="${OUTPUT_DIR%/}/$timestamped_name"

  echo "Backing up: '$src' -> '$output_file'"

  # Use dirname + basename so the archive contains the folder, not the full absolute path.
  src_dir="$(dirname "$src")"
  src_base="$(basename "$src")"

  # Run tar. If tar fails, print an error and continue to next folder.
  # We pass exclude_args as an array to safely handle spaces / special characters.
  tar -C "$src_dir" -czf "$output_file" "${exclude_args[@]}" -- "$src_base" \
    || { echo "Error: failed to archive '$src'"; rm -f -- "$output_file"; continue; }

  echo "Created: $output_file"
done

echo "Backup run complete."
```

---

## ✅ Usage

Run the script directly:

```bash
./backup.sh
```

Make sure all paths in `SOURCE_FOLDERS` and `OUTPUT_DIR` are absolute paths when using cron.

---

## ⏱️ Cron example

Daily backup at 2:00 AM, logging output and errors:

```
0 2 * * * /path/to/backup.sh >> /path/to/backup.log 2>&1
```

Important: Cron runs with a minimal environment — always use absolute paths inside the script.

---

## 🔐 Safety & behavior notes

- The script uses strict handling for unset variables (`set -u`) and `pipefail`.
- Each folder is archived independently. Failures in one archive do not stop others.
- Paths are handled safely using arrays and `--` where appropriate to avoid word-splitting or injection.
- If an archive fails, any partially-created archive will be removed.

---

## 🧰 Troubleshooting tips

- Permission errors: ensure the user running the script can read the source directories and write to the output directory.
- Disk space: check free disk space — compression still needs temporary space for tar operations.
- If macOS uses the system Bash (3.2) and you rely on Bash 4+ features, install newer Bash via Homebrew (`brew install bash`) and run the script with `/usr/local/bin/bash backup.sh` (path may differ).
- To test behavior manually, run a single archive with `set -x` or echo the generated tar command.

---

## 🔁 Optional improvements / contributions

Pull requests welcome for enhancements such as:
- Retention policies (delete backups older than N days)
- Cloud upload options (S3, GDrive, etc.)
- Config-file based setup (YAML/INI) instead of inline editing
- Incremental/differential backups (rsync-based)
- Parallel archives for faster runs (careful with IO)

---

## 📜 License

MIT License — free for personal and commercial use. See the `LICENSE` file for full text.

---

## 🙌 Contributing

If you make improvements, please open a PR or issue. Small, focused PRs with tests or clear instructions are appreciated.

---

If you’d like, I can:
- Add a retention-section to automatically delete backups older than N days,
- Add an S3 upload step,
- Or generate a sample `crontab` entry and systemd timer to manage scheduling.