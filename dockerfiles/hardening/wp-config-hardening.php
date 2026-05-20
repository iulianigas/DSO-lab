
/* === Hardened WordPress configuration (DevSecOps lab) === */
define('DISALLOW_FILE_EDIT', true);
define('DISALLOW_FILE_MODS', true);
define('FORCE_SSL_ADMIN', true);
define('WP_DEBUG', false);
define('WP_DEBUG_DISPLAY', false);
define('AUTOMATIC_UPDATER_DISABLED', false);
/* Block direct PHP execution in uploads via config awareness */
if (!defined('ABSPATH')) {
    exit;
}
