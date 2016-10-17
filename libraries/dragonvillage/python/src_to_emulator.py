#-*- coding: utf-8 -*-

import sys
import os
import shutil

org_path = None
tar_path = None
try:
    org_path = os.environ['DV_DEV']
    tar_path = os.environ['DV_RES']
except:
    print '###############################################################'
    print 'Environment Variable Error'
    print 'DV_DEV : Dragon Village Development Root'
    print 'ex) D:\project\dragonvillage\frameworks\dragonvillage'
    print 'DV_RES : Dragon Village Resource Root'
    print 'ex) D:\dragonvillage\res\emulator'
    print 'Check your Environment variable that contain DV_DEV and DV_RES'
    print '###############################################################'
    os.system("Pause")
    exit(0)

def copy_files(src, dst):
    print src
    if not os.path.isdir(src):
        return
    else:
        for item in os.listdir(src):
            path = os.path.join(src, item)
            if not item.startswith('.') and os.path.isfile(path):
                shutil.copy(path, dst)
                print path
            if os.path.isdir(path):
                new_dst = os.path.join(dst, item)
                #os.mkdir(new_dst)
                copy_files(path, new_dst)

def copySrc():
    print "copy src"
    src_dir = os.path.join(org_path, "src")
    assets_src_dir = os.path.join(tar_path, "src")
    copy_files(src_dir, assets_src_dir)

def copySrcTool():
    print "copy src"
    src_dir = os.path.join(org_path, "src_tool")
    assets_src_dir = os.path.join(tar_path, "src_tool")
    copy_files(src_dir, assets_src_dir)

####################################
print "start"
####################################
#copy_resources
if __name__ == '__main__':

    try:
        copySrc()
        copySrcTool()
        print "assets copy done"
    except:
        print "error.. fail to copy"
    finally:
        os.system("Pause")

else:
    print 'I am being imported from another module'