#-*- coding:utf-8 -*-

####################################
# IMPORT
####################################
import sys
import os
import shutil
import module.utility as utils
# Pillow - PIL
utils.install_and_import('Pillow')
from PIL import Image


####################################
# GLOBAL
####################################
SAVE_PATH_FORMAT = '{folder}/{name}.png'
ICON_ORG_PATH = './app_icon.png'
ICON_ANDROID_PATH = '../proj.android_studio/app/res/'
ANDROID_FLAVOR_LIST = {'common'}
ICON_WINDOWS_PATH = '../proj.win32/res/'
ICON_IOS_PATH = '../proj.ios_mac/ios/Images.xcassets/AppIcon.appiconset/'
ICON_MAC_PATH = '../proj.ios_mac/mac/'

####################################
# FUNCTION
####################################
def ResizeImage(image, size, folder, image_name):
    resize_image = image.resize((size, size))

    if not os.path.exists(folder):
        os.makedirs(folder)

    path = SAVE_PATH_FORMAT.format(folder = folder, name = image_name)
    resize_image.save(path)
    print(path)

def Main(argv):
    print('############### START ResizeImage')

    # 외부에서 이미지 경로를 전달받은 경우
    if (1<len(argv)):
        png_path = argv[1]
    else:
        png_path = ICON_ORG_PATH

    print('png_path : ' + png_path)

    ## Orginal
    try:
        image = Image.open(png_path)
    except BaseException as e:
        print(e)
        print('############### FAIL ResizeImage')
        os.system("pause")
        return

    ## iOS
    print('############### iOS')
    ResizeImage(image, 16, ICON_IOS_PATH, '16')
    ResizeImage(image, 20, ICON_IOS_PATH, '20')
    ResizeImage(image, 29, ICON_IOS_PATH, '29')
    ResizeImage(image, 32, ICON_IOS_PATH, '32')
    ResizeImage(image, 40, ICON_IOS_PATH, '40')
    ResizeImage(image, 50, ICON_IOS_PATH, '50')
    ResizeImage(image, 57, ICON_IOS_PATH, '57')
    ResizeImage(image, 58, ICON_IOS_PATH, '58')
    ResizeImage(image, 60, ICON_IOS_PATH, '60')
    ResizeImage(image, 64, ICON_IOS_PATH, '64')
    ResizeImage(image, 72, ICON_IOS_PATH, '72')
    ResizeImage(image, 76, ICON_IOS_PATH, '76')
    ResizeImage(image, 80, ICON_IOS_PATH, '80')
    ResizeImage(image, 87, ICON_IOS_PATH, '87')
    ResizeImage(image, 100, ICON_IOS_PATH, '100')
    ResizeImage(image, 114, ICON_IOS_PATH, '114')
    ResizeImage(image, 120, ICON_IOS_PATH, '120')
    ResizeImage(image, 128, ICON_IOS_PATH, '128')
    ResizeImage(image, 144, ICON_IOS_PATH, '144')
    ResizeImage(image, 152, ICON_IOS_PATH, '152')
    ResizeImage(image, 167, ICON_IOS_PATH, '167')
    ResizeImage(image, 180, ICON_IOS_PATH, '180')
    ResizeImage(image, 256, ICON_IOS_PATH, '256')
    ResizeImage(image, 512, ICON_IOS_PATH, '512')
    ResizeImage(image, 1024, ICON_IOS_PATH, '1024')
    
    # Android
    print('############### Android')
    for res_flovor in ANDROID_FLAVOR_LIST:
        path = ICON_ANDROID_PATH + res_flovor + '/'
        ResizeImage(image, 24, path + 'drawable', 'icon')
        ResizeImage(image, 72, path + 'drawable-hdpi', 'icon')
        ResizeImage(image, 36, path + 'drawable-ldpi', 'icon')
        ResizeImage(image, 48, path + 'drawable-mdpi', 'icon')
        ResizeImage(image, 96, path + 'drawable-xhdpi', 'icon')
        ResizeImage(image, 144, path + 'drawable-xxhdpi', 'icon')
        ResizeImage(image, 192, path + 'drawable-xxxhdpi', 'icon')


    # Windows
    print('############### Windows')
    path = ICON_WINDOWS_PATH + 'game.ico'
    print(path)
    image.save(path, format = 'ICO', sizes=[(48,48)])

    # MAC
    print('############### Mac')
    # @sgkim 2021.03.31 MAC용 icns는 python에서 변환하는 것이 준비되어 있지 않다.
    #                   https://anyconv.com/ 와 같은 웹에서 제공하는 기능을 활용 할 것.

    print('############### FINISH ResizeImage')
    os.system("pause")


####################################
# MAIN
####################################
if __name__ == '__main__':
    Main(sys.argv)

else:
    print('## I am being imported from another module')