import os

# apk file location
# .\DragonVillageM\build\outputs\apk

# if you want to get more info, do THIS
#os.system('gradlew tasks')

# clean
os.system('clean.py')
os.system('gradlew clean')

# build
#os.system('gradlew assembleDev100mbTest')
#os.system('gradlew assembleDevFullTest')
#os.system('gradlew assembleQa100mbTest')
os.system('gradlew assembleQaFullTest')
#os.system('gradlew assembleLive100mb')
#os.system('gradlew assembleLiveFull')

os.system('pause')
