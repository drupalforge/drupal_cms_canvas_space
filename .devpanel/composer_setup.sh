#!/usr/bin/env bash
set -eu -o pipefail
cd $APP_ROOT

# Create required composer.json and composer.lock files.
composer create-project --no-install ${PROJECT:=phenaproxima/xb-demo} --stability=dev
cp -r "${PROJECT#*/}"/* ./
rm -rf "${PROJECT#*/}" patches.lock.json

# Scaffold settings.php.
composer config -jm extra.drupal-scaffold.file-mapping '{
    "[web-root]/sites/default/settings.php": {
        "path": "web/core/assets/scaffold/files/default.settings.php",
        "overwrite": false
    }
}'
composer config scripts.post-drupal-scaffold-cmd \
    'cd web/sites/default && test -z "$(grep '\''include \$devpanel_settings;'\'' settings.php)" && patch -Np1 -r /dev/null < $APP_ROOT/.devpanel/drupal-settings.patch || :'

# Compile Storybook.
composer config -j scripts.post-update-cmd \
    'command -v nvm > /dev/null || curl -so- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash' \
    'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && cd web/themes/contrib/demo_design_system && nvm install && npm install && npm run build' \
    'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && cd web/themes/contrib/demo_design_system/starshot_demo && nvm install && npm install && npm run build'
