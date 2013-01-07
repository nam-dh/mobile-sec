#!/bin/sh
export CODESIGN_ALLOCATE=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/codesign_allocate
if [ “${PLATFORM_NAME}” == “iphoneos” ]; then
/Applications/Xcode.app/Contents/Developer/iphoneentitlements511/gen_entitlements.py “com.yourcompany.${PROJECT_NAME}” “${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/${PROJECT_NAME}.xcent”;
codesign -f -s “iPhone Developer” —entitlements “${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/${PROJECT_NAME}.xcent” “${BUILT_PRODUCTS_DIR}/${WRAPPER_zNAME}/”
fi
