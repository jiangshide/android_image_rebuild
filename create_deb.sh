#!/bin/bash

if [ -f androidcompat.deb ]; then
    rm androidcompat.deb
fi

mv *-rebuild.img android-compatible-env/images/

cd android-compatible-env
dpkg-buildpackage -us -uc -i -b
cd -

exit $?
