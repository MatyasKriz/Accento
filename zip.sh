#!/usr/bin/env bash

xcodebuild -scheme diacritics-macos -configuration Release -derivedDataPath "./build" clean build
(cd build/Build/Products/Release && mv diacritics-macos.app Accento.app && zip -rX file.zip Accento.app && mv file.zip ../../../../Accento.zip)
