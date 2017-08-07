import sys
import os

# check ANDROID_SDK_ROOT
sdk_dir = os.getenv('ANDROID_HOME')
if sdk_dir == None:
    print('ANDROID_HOME is NOT defined!')
    print('')
    os.system('pause')
    sys.exit(1)

#ndk-build
command = 'ndk-build -j4 NDK_DEBUG=1 NDK_MODULE_PATH=../../cocos2d-x;../../cocos2d-x/cocos;../../cocos2d-x/external'
os.system(command)

#ant build & apk install
command = 'ant clean debug -f ./build.xml -Dsdk.dir=' + sdk_dir
os.system(command)

os.system('pause')
