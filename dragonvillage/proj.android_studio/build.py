import os

# if you want to get more info, do THIS
#os.system('gradlew tasks')

# clean
#os.system('gradlew clean')

# build

## google
#os.system('gradlew assembleDevFullGoogleDebug assembleQaFullGoogleDebug assembleLiveqaFullGoogleDebug assembleLiveFullGoogleDebug assembleLiveMarketGoogleRelease')
#os.system('gradlew assembleLiveFullGoogleRelease')
#os.system('gradlew assembleLiveMarketGoogleRelease')
#os.system('gradlew assembleDevFullGoogleDebug')
#os.system('gradlew assembleLiveMarketGoogleDebug')

## xsolla
#os.system('gradlew assembleDevFullXsollaDebug assembleQaFullXsollaDebug assembleLiveFullXsollaRelease')

## cafe bazaar
#os.system('gradlew assembleQaFullCafebazaarDebug')

os.system('gradlew assembleQaFullGoogleDebug')

os.system('pause')
