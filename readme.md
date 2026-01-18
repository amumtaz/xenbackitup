🗂️ Simple Dated Backup Script (tar + gzip)

A robust Bash script that archives multiple project folders into date-stamped .tgz files, while excluding heavy or unnecessary directories like node_modules, venv, and .git.

Designed to work on both macOS (BSD tar) and Linux (GNU tar).

⸻

✨ Features
	•	✅ Backup multiple folders in one run
	•	✅ Date-stamped archive names
	•	✅ Exclude common heavy directories (configurable)
	•	✅ Safe handling of paths with spaces
	•	✅ Works on macOS and Linux
	•	✅ Cron-friendly
	•	✅ Stops on errors but continues to next folder

⸻

📦 Example Output

project_a_2026-01-17.tgz
project_b_2026-01-17.tgz
project_c_2026-01-17.tgz


⸻

⚙️ Requirements
	•	Bash 4+
	•	tar
	•	gzip

(All are available by default on most macOS and Linux systems.)

⸻

🚀 Usage

1. Clone the repo

git clone https://github.com/your-username/dated-backup-script.git
cd dated-backup-script

2. Make the script executable

chmod +x backup.sh

3. Configure folders and output path

Edit these sections in the script:

SOURCE_FOLDERS=(
  "/absolute/path/to/project1"
  "/absolute/path/to/project2"
)

OUTPUT_DIR="/absolute/path/to/backups"

Exclude patterns:

GLOBAL_EXCLUDES=(
  "node_modules"
  "venv"
  ".git"
  ".DS_Store"
)


⸻

4. Run the backup

./backup.sh


⸻

⏱️ Optional: Run with Cron

Example: daily backup at 2:00 AM

0 2 * * * /path/to/backup.sh >> /path/to/backup.log 2>&1

Make sure all paths in the script are absolute when using cron.

⸻

🔐 Safety Notes
	•	Script uses set -euo pipefail for strict error handling.
	•	Each folder is archived independently, so failure in one does not stop others.
	•	Paths are handled safely using argument arrays (no string-based eval).

⸻

📜 License

MIT License — free for personal and commercial use.
See LICENSE file for full text.

⸻

🙌 Contributions

Pull requests are welcome for:
	•	retention policies (delete backups older than N days)
	•	cloud upload options (S3, GDrive, etc.)
	•	config-file based setup instead of inline editing

Keep it simple and shell-native where possible.
