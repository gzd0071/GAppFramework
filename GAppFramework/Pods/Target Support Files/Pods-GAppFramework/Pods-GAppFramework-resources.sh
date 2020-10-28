#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
  # If UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, then there's nowhere for us to copy
  # resources to, so exit 0 (signalling the script phase was successful).
  exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY:-}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/BaiduMapKit/BaiduMapKit/BaiduMapAPI_Map.framework/mapapi.bundle"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/blank.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/DMLSMSValidationVC.xib"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_bg_captcha.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_cancel_normal@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_cancel_normal@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_cancel_selected@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_cancel_selected@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_confirm_normal@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_confirm_normal@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_confirm_selected@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_confirm_selected@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/newLoginWechat@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/newLoginWechat@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/onekeyBtnGray.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/onekeyBtnYellow.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/onekeyCenterImg@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/onekeyCenterImg@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/onekeyClose@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/onekeyClose@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/登录页点缀@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/登录页点缀@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_apply.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_cancel.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_captcha.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_city.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_continuous_sign.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_delete.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_fail.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_limit.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_location.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_logout.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_normal.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_phone.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_resume.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_service.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_shortage.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_sign.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_success.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_uncommit.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_unsaved.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_cancel_normal@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_cancel_normal@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_cancel_selected@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_cancel_selected@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_confirm_normal@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_confirm_normal@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_confirm_selected@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_confirm_selected@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_captcha_refresh@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_captcha_refresh@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_select_check@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_select_check@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_select_check_normal@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_select_check_normal@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/empty_nodata@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/empty_nofound@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/empty_nonetwork@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/empty_noserver@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/picker/models/province.plist"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/debugger_app_flow.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/debugger_app_info.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/debugger_app_info@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/debugger_develop_log.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/debugger_login.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/debugger_request.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_ab@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_align@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_align@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_arrow_down@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_arrow_down@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_back@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_back@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_close@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_close@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_close_white@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_close_white@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_cpu@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_cpu@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_crash@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_crash@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_default@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_default@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_dir@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_dir@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_expand@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_expand@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_expand_no@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_expand_no@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_file@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_file@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_file_2@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_file_2@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_fps@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_fps@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_h5@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_h5@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_kadun@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_kadun@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_location@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_location@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_log@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_log@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_logo@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_logo@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_memory@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_memory@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_method_use_time@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_method_use_time@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_mock_gps@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_mock_gps@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_more@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_more@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_net@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_net@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_netflow_list_select@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_netflow_list_select@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_netflow_list_unselect@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_netflow_list_unselect@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_netflow_summary_select@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_netflow_summary_select@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_netflow_summary_unselect@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_netflow_summary_unselect@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_nslog@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_nslog@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_qingchu@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_qingchu@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_search@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_search@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_search_highlight@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_search_highlight@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_self@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_self@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_straw@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_straw@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_ui@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_ui@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_viewmetrics@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_viewmetrics@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_view_check@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_view_check@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_visual@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/doraemon_visual@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/QRCodeScanLine@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/QRCodeScanLine@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/QRCodeScanLineGrid@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/enter/img/QRCodeScanLineGrid@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/items/common/net/json/data/jquery.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/items/common/net/json/data/json-viewer.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/items/common/net/json/data/json-viewer-dark-theme.css"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/items/common/net/json/data/json-viewer-light-theme.css"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/items/common/net/json/data/jsonviewer.html"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/js/2.592e1fb3.chunk.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/js/main.7fd7fa56.chunk.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/js/runtime~main.c5541365.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/js/2.592e1fb3.chunk.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/js/main.085c9404.chunk.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/js/main.2bd8856a.chunk.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/js/main.6f7308da.chunk.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/js/main.7306ec3f.chunk.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/js/main.7fd7fa56.chunk.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/js/main.ee7b3bb9.chunk.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/js/main.f57c5626.chunk.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/js/runtime~main.c5541365.js"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/css/2.b861deda.chunk.css"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/css/main.747540e0.chunk.css"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/css/2.8233fab0.chunk.css"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/css/2.b861deda.chunk.css"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/css/main.0caff4d5.chunk.css"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/static/static/css/main.747540e0.chunk.css"
  install_resource "${PODS_ROOT}/../components/businessSupport/GDebugger/debugger/debugger/funcs/httpserver/web/index.html"
  install_resource "${PODS_ROOT}/MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "${PODS_ROOT}/SAMKeychain/Support/SAMKeychain.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/BaiduMapKit/BaiduMapKit/BaiduMapAPI_Map.framework/mapapi.bundle"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/blank.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/DMLSMSValidationVC.xib"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_bg_captcha.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_cancel_normal@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_cancel_normal@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_cancel_selected@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_cancel_selected@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_confirm_normal@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_confirm_normal@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_confirm_selected@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/dml_alert_confirm_selected@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/newLoginWechat@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/newLoginWechat@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/onekeyBtnGray.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/onekeyBtnYellow.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/onekeyCenterImg@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/onekeyCenterImg@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/onekeyClose@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/onekeyClose@3x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/登录页点缀@2x.png"
  install_resource "${PODS_ROOT}/../components/business/DMLogin/Assets/登录页点缀@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_apply.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_cancel.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_captcha.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_city.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_continuous_sign.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_delete.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_fail.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_limit.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_location.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_logout.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_normal.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_phone.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_resume.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_service.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_shortage.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_sign.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_success.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_uncommit.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_bg_unsaved.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_cancel_normal@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_cancel_normal@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_cancel_selected@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_cancel_selected@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_confirm_normal@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_confirm_normal@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_confirm_selected@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_btn_confirm_selected@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_captcha_refresh@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_captcha_refresh@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_select_check@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_select_check@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_select_check_normal@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/dialog_select_check_normal@3x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/empty_nodata@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/empty_nofound@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/empty_nonetwork@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/img/empty_noserver@2x.png"
  install_resource "${PODS_ROOT}/../components/businessSupport/DMUILib/DMUILib/picker/models/province.plist"
  install_resource "${PODS_ROOT}/MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "${PODS_ROOT}/SAMKeychain/Support/SAMKeychain.bundle"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "${XCASSET_FILES:-}" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  if [ -z ${ASSETCATALOG_COMPILER_APPICON_NAME+x} ]; then
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  else
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${TARGET_TEMP_DIR}/assetcatalog_generated_info_cocoapods.plist"
  fi
fi
