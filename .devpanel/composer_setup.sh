#!/usr/bin/env bash
set -eu -o pipefail

cd $APP_ROOT

# Create composer.json.
composer create-project -n --no-plugins --no-install phenaproxima/xb-demo --stability=dev
cp -r xb-demo/* ./
rm -rf xb-demo patches.lock.json

# Programmatically fix Composer 2.2 allow-plugins to avoid errors
composer config --no-plugins allow-plugins.composer/installers true
composer config --no-plugins allow-plugins.cweagans/composer-patches true
composer config --no-plugins allow-plugins.drupal/core-project-message true
composer config --no-plugins allow-plugins.drupal/core-composer-scaffold true
composer config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
composer config --no-plugins allow-plugins.phpstan/extension-installer true
composer config --no-plugins allow-plugins.php-http/discovery true
composer config --no-plugins allow-plugins.tbachert/spi true

# Scaffold settings.php.
composer config --no-plugins -jm extra.drupal-scaffold.file-mapping '{
    "[web-root]/sites/default/settings.php": {
        "path": "web/core/assets/scaffold/files/default.settings.php",
        "overwrite": false
    }
}'
composer config --no-plugins scripts.post-drupal-scaffold-cmd \
    'cd web/sites/default && test -n "$(grep '\''include \$devpanel_settings;'\'' settings.php)" || patch -Np1 -r /dev/null < $APP_ROOT/.devpanel/drupal-settings.patch || :'
