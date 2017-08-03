import os

# apk file location
# .\DragonVillageM\build\outputs\apk

# clean
os.system('clean.py')
#os.system('gradlew clean')

# build
os.system('gradlew assembleRelease')
#os.system('gradlew installRelease')
#os.system('gradlew assembleDebug')
#os.system('gradlew installDebug')

# apk copy
src_path = './DragonVillageM/build/outputs/apk'
tar_path = './build'
os.system('robocopy "%s" "%s" *.apk /IS' % (src_path, tar_path ))

os.system('pause')
