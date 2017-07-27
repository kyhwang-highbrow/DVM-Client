import os

# apk file location
# .\DragonVillageM\build\outputs\apk

# debug build
#command = 'gradlew assembleDebug'
# debug build and install
#command = 'gradlew installDebug'

# release build
command = 'gradlew installDebug'
# release build and install
#command = 'gradlew installRelease'

os.system(command)
os.system('pause')
