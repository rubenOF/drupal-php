#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

disclaimer="\n// Generated by Wodby."
settings_php="${DRUPAL_SITE_DIR}/settings.php"
sites_php="${DRUPAL_ROOT}/sites/sites.php"

mkdir -p "${DRUPAL_SITE_DIR}"
chmod 755 "${DRUPAL_SITE_DIR}" || true

# Include wodby.settings.php
if [[ ! -f "${settings_php}" ]]; then
    echo -e "<?php\n\n" > "${settings_php}"
fi

if [[ $( grep -ic "wodby.settings.php" "${settings_php}" ) -eq 0 ]]; then
    chmod 644 "${settings_php}"
    echo -e "${disclaimer}" >> "${settings_php}"
    echo -e "include '${WODBY_DIR_CONF}/wodby.settings.php';" >> "${settings_php}"
fi

# Include wodby.sites.php for Drupal 7 and 8.
if [[ "${DRUPAL_SITE}" != "default" ]]; then
    if [[ "${DRUPAL_VERSION}" == "8" ]] || [[ "${DRUPAL_VERSION}" == "7" ]]; then
        if [[ $( grep -ic "wodby.sites.php" "${sites_php}" ) -eq 0 ]]; then
            echo -e "${disclaimer}" >> "${sites_php}"
            echo -e "include '${WODBY_DIR_CONF}/wodby.settings.php';" >> "${sites_php}"
        fi
    fi
fi

DRUPAL_SITE_FILES="${DRUPAL_SITE_DIR}/files"

if [[ -d "${DRUPAL_SITE_FILES}" ]]; then
    if [[ ! -L "${DRUPAL_SITE_FILES}" ]]; then
        if [[ "$(ls -A "${DRUPAL_SITE_FILES}")" ]]; then
            echo "Error: directory ${DRUPAL_SITE_FILES} is not empty. Files directory can not be under version control and must not exists"
            exit 1
        # If dir is not symlink and empty, remove it and link.
        else
            rm -rf "${DRUPAL_SITE_FILES}"
            ln -sf "${WODBY_DIR_FILES}/public" "${DRUPAL_SITE_FILES}"
        fi
    fi
else
    ln -sf "${WODBY_DIR_FILES}/public" "${DRUPAL_SITE_FILES}"
fi
