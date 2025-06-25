#!/usr/bin/env bash
set -eu -o pipefail
cd $APP_ROOT

# Create required composer.json and composer.lock files.
composer create-project -n --no-plugins --no-install phenaproxima/xb-demo --stability=dev
cp -r xb-demo/* ./
rm -rf xb-demo patches.lock.json

# Scaffold settings.php.
composer config --no-plugins -jm extra.drupal-scaffold.file-mapping '{
    "[web-root]/sites/default/settings.php": {
        "path": "web/core/assets/scaffold/files/default.settings.php",
        "overwrite": false
    }
}'
composer config --no-plugins scripts.post-drupal-scaffold-cmd \
    'cd web/sites/default && (test -n "$(grep '\''include \$devpanel_settings;'\'' settings.php)" || patch -Np1 -r /dev/null < $APP_ROOT/.devpanel/drupal-settings.patch || :)'

# Update Recipe Installer Kit.
composer update -n --no-plugins --no-install drupal/recipe_installer_kit
