#-*- coding:utf-8 -*-

# 모듈 import(설치되어있지 않은 경우 install 후 import)
# 자주 사용하는 기능들은 모듈화 하자 .. PyHighbrow
def installIfNotExist(package):
    import importlib
    try:
        importlib.import_module(package)
    except ImportError:
        import pip
        pip.main(['install', package])
    # finally:
    #     globals()[package] = importlib.import_module(package)

####################################
# IMPORT
####################################
import os
import shutil
# Pillow - PIL
installIfNotExist('Pillow')
from PIL import Image


####################################
# GLOBAL
####################################
SAVE_PATH_FORMAT = '{folder}/{name}.png'
ICON_ORG_PATH = './app_icon.png'

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

####################################
# MAIN
####################################
if __name__ == '__main__':
    
    print('############### START ResizeImage')

    ## Orginal
    image = Image.open(ICON_ORG_PATH)

    ## iOS
    print('############### iOS')
    ResizeImage(image, 20, 'ios', 'icon_20')
    ResizeImage(image, 24, 'ios', 'icon_20@2x')
    ResizeImage(image, 60, 'ios', 'icon_20@3x')
    ResizeImage(image, 29, 'ios', 'icon_29')
    ResizeImage(image, 58, 'ios', 'icon_29@2x')
    ResizeImage(image, 87, 'ios', 'icon_29@3x')
    ResizeImage(image, 40, 'ios', 'icon_40')
    ResizeImage(image, 80, 'ios', 'icon_40@2x')
    ResizeImage(image, 120, 'ios', 'icon_40@3x')
    ResizeImage(image, 50, 'ios', 'icon_50')
    ResizeImage(image, 100, 'ios', 'icon_50@2x')
    ResizeImage(image, 57, 'ios', 'icon_57')
    ResizeImage(image, 114, 'ios', 'icon_57@2x')
    ResizeImage(image, 120, 'ios', 'icon_60@2x')
    ResizeImage(image, 180, 'ios', 'icon_60@3x')
    ResizeImage(image, 72, 'ios', 'icon_72')
    ResizeImage(image, 144, 'ios', 'icon_72@2x')
    ResizeImage(image, 76, 'ios', 'icon_76')
    ResizeImage(image, 152, 'ios', 'icon_76@2x')
    ResizeImage(image, 167, 'ios', 'icon_83.5@2x')
    ResizeImage(image, 1024, 'ios', 'icon_1024')

    # Android
    print('############### Android')
    ResizeImage(image, 24, 'aos/drawable', 'icon')
    ResizeImage(image, 72, 'aos/drawable-hdpi', 'icon')
    ResizeImage(image, 36, 'aos/drawable-ldpi', 'icon')
    ResizeImage(image, 48, 'aos/drawable-mdpi', 'icon')
    ResizeImage(image, 96, 'aos/drawable-xhdpi', 'icon')
    ResizeImage(image, 144, 'aos/drawable-xxhdpi', 'icon')
    ResizeImage(image, 192, 'aos/drawable-xxxhdpi', 'icon')

    # Copy는 다음에 만들자

    print('############### FINISH ResizeImage')

else:
    print('## I am being imported from another module')