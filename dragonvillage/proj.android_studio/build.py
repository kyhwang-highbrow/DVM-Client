import os

# if you want to get more info, do THIS
#os.system('gradlew tasks')

# clean
#os.system('gradlew clean')

# build

## google
#os.system('gradlew assembleDevFullGoogleDebug assembleQaFullGoogleDebug assembleLiveqaFullGoogleDebug assembleLiveFullGoogleDebug assembleLiveMarketGoogleRelease')

## xsolla
#os.system('gradlew assembleDevFullXsollaDebug assembleQaFullXsollaDebug assembleLiveFullXsollaRelease')

##Onestore
os.system('gradlew assembleLiveFullOnestoreRelease')

os.system('pause')
