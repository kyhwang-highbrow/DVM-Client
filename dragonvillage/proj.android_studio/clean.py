import os
import shutil

directories = '''\
./.gradle
./build
./DragonVillageM/.externalNativeBuild
./DragonVillageM/build
../../cocos2d-x/cocos/platform/android/libcocos2dx/build
../../libraries/apk_expansion/downloader_library/build
../../libraries/apk_expansion/market_licensing/build
'''
directories = directories.split('\n')

for directory in directories:
    if os.path.exists(directory):
        shutil.rmtree(directory)
