#!/bin/bash
#
# This script generates changelog for each releases

NEW_TAG=$(git describe --tags --abbrev=0)
OLD_TAG=$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))

cat << EOF
# Changelog

## [$(git describe --tags --abbrev=0)] - $(date +%d-%m-%Y)
EOF
for i in "feat:Added" "bug:Fixed" "refactor:Changed" "remove:Removed" "deprecate:Deprecated" "security:Security"; do
    TYPE=${i%%:*}
    TITLE=${i#*:}
    if [[ -n $(git log --pretty='%h - %s (%an)' ${OLD_TAG}..${NEW_TAG} | grep -i -E "^.{10}(${TYPE}: )") ]]; then
        echo -e "\n### ${TITLE}\n"
        git log --pretty="%h - %s (%an)" ${OLD_TAG}..${NEW_TAG} | grep -i -E "^.{10}(${TYPE}: )" | sed "s/${TYPE}: //"
    fi
done
