<?php
/**
 * Lab-only insecure overrides — removed in hardened image.
 * Loaded via wp-config.php require if present in vulnerable stack.
 */
define('DISALLOW_FILE_EDIT', false);
define('WP_DEBUG', true);
define('WP_DEBUG_DISPLAY', true);
