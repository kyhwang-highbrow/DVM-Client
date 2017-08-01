import os

# apk file location
# .\DragonVillageM\build\outputs\apk

# clean
#os.system('gradlew clean')

# build
#os.system('gradlew assembleDebug')
#os.system('gradlew installDebug')
#os.system('gradlew assembleRelease')
#os.system('gradlew installRelease')

# apk copy
src_path = './DragonVillageM/build/outputs/apk'
tar_path = './build'
os.system('robocopy "%s" "%s" *.apk /IS' % (src_path, tar_path ))

os.system('pause')
