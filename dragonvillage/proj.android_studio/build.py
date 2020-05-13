import os

# if you want to get more info, do THIS
#os.system('gradlew tasks')

# clean
#os.system('gradlew clean')

# build

######################################################################################
## flavor
######################################################################################
## platform : google, googledev, googleqa, googleliveqa, xsolla, cafebazaar, onestore
## server : dev, qa, liveqa, live
## asset : market, full
######################################################################################


######################################################################################
## build
######################################################################################
## google (old)
##os.system('gradlew assembleDevFullGoogleDebug assembleQaFullGoogleDebug assembleLiveqaFullGoogleDebug assembleLiveFullGoogleDebug assembleLiveMarketGoogleRelease')

#### google
#os.system('gradlew assembleGoogleLiveMarketRelease') # for upload
#os.system('gradlew assembleGoogleliveLiveFullRelease')
#os.system('gradlew assembleGoogledevDevFullDebug') # for dev
#os.system('gradlew assembleGoogleqaQaFullDebug') # for qa
#os.system('gradlew assembleGoogleliveqaLiveqaFullDebug') # for live qa

##Onestore
#os.system('gradlew assembleOnestoreLiveFullRelease') # for upload
os.system('gradlew assembleOnestoreDevFullDebug') # for dev
#os.system('gradlew assembleOnestoreQaFullDebug') # for qa

## xsolla
#os.system('gradlew assembleXsollaDevFullDebug assembleXsollaQaFullDebug assembleXsollaLiveFullRelease')
######################################################################################

# Install APK. -r is used for reinstallation.
#os.system('adb install -r app/build/outputs/apk/onestoreDevFull/debug/dvm_onestore_0.7.1_vc43_dev_full_debug.apk')

# Run APK (https://tailstar.net/autohotkey/12723421)
#os.system('adb shell am start -n com.perplelab.dragonvillagem.onestore/org.cocos2dx.lua.AppActivity')

os.system('pause')
