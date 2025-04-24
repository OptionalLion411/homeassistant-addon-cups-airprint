SCRIPTS_DIR=$(dirname "$0")/noarch

# load 'scripting' run-time support utility functions
. "${SCRIPTS_DIR}/scripting_utils"
script_log_init $(basename "$0" ".sh")

# load 'package' run-time support utility functions
. "${SCRIPTS_DIR}/package_utils"
environment_init $(basename "$0" ".sh")

sh "$SCRIPTS_DIR/package_install.sh" "printer-meta"
sh "$SCRIPTS_DIR/post_install.sh" "$@"
