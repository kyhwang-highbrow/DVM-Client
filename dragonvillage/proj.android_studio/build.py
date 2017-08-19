import os

# apk file location
# .\DragonVillageM\build\outputs\apk

# if you want to get more info, do THIS
#os.system('gradlew tasks')

# clean
os.system('clean.py')
os.system('gradlew clean')

# build
os.system('gradlew assembleRelease')
#os.system('gradlew assembleDebug')
#os.system('gradlew assembleMarket')
#os.system('gradlew assembleFull')

os.system('pause')
