import os

# if you want to get more info, do THIS
#os.system('gradlew tasks')

# clean
# os.system('gradlew clean')

# build

######################################################################################
## flavor
######################################################################################
## platform : google, xsolla, cafebazaar, onestore
## server : dev, qa, liveqa, live
## asset : market, full
######################################################################################


######################################################################################
## build
######################################################################################
## google (old)
#os.system('gradlew assembleDevFullGoogleDebug assembleQaFullGoogleDebug assembleLiveqaFullGoogleDebug assembleLiveFullGoogleDebug assembleLiveMarketGoogleRelease')

#### google
# os.system('gradlew assembleGoogleLiveMarketRelease') # for upload
# os.system('gradlew assembleGoogleLiveFullRelease')
# os.system('gradlew assembleGoogleDevFullDebug') # for dev
# os.system('gradlew assembleGoogleQaFullDebug') # for qa
# os.system('gradlew assembleGoogleLiveqaFullDebug') # for live qa

# ##Onestore
# os.system('gradlew assembleOnestoreLiveFullRelease') # for upload
os.system('gradlew assembleOnestoreDevFullDebug') # for dev
#os.system('gradlew assembleOnestoreQaFullDebug') # for qa
#os.system('gradlew assembleOnestoreLiveqaFullDebug') # for live qa

## xsolla
#os.system('gradlew assembleXsollaDevFullDebug assembleXsollaQaFullDebug assembleXsollaLiveFullRelease')
######################################################################################

os.system('pause')
