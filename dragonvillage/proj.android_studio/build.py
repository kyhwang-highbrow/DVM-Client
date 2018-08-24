import os

# if you want to get more info, do THIS
#os.system('gradlew tasks')

# clean
#os.system('gradlew clean')

# build
os.system('gradlew assembleDevFullDebug assembleQaFullDebug assembleLiveqaFullDebug assembleLiveFullDebug assembleLiveMarketRelease')

os.system('pause')
