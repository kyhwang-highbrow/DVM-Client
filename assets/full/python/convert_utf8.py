#-*- coding:utf-8 -*-

import os
import sys
#import chardet
#import codecs

count_encoding = 0
count_bom = 0
count_endline = 0
count_files = 0

def install_and_import(package):
    import importlib
    try:
        importlib.import_module(package)
    except ImportError:
        import pip
        pip.main(['install', package])
    finally:
        globals()[package] = importlib.import_module(package)

#import
install_and_import('chardet')
install_and_import('codecs')

def convert(rootdir, subdir, subdir2, endline = False):
    path = os.path.join(rootdir, subdir)

    for item in os.listdir(path):
        fullpath = os.path.join(path, item)

        subdir3 = subdir2 + '/' + item

        if item.endswith('.lua'):
            utf8_converter(fullpath, subdir3, endline)

        if os.path.isdir(fullpath):
            convert(path, item, subdir3)


def utf8_converter(file_path, file, universal_endline = False):
    '''
    Convert any type of file to UTF-8 without BOM
    and using universal endline by default.

    Parameters
    ----------
    file_path : string, file path.
    universal_endline : boolean (True),
                        by default convert endlines to universal format.
    '''

    global count_encoding
    global count_bom
    global count_endline
    global count_files

    # Fix file path
    file_path = os.path.realpath(os.path.expanduser(file_path))

    # Read from file
    file_open = open(file_path)
    raw = file_open.read()
    file_open.close()

    # Check encoding 'utf-8'
    code = chardet.detect(raw)['encoding']
    check = False
    if code != 'utf-8' and code != 'ascii':
        check = True

    # Decode
    if check:
        raw = raw.decode(code)

    msg = file
    changed = False

    # Remove windows end line
    if universal_endline:
        msg = msg + ',[Endline]'
        changed = True
        count_endline = count_endline + 1
        raw = raw.replace('\r\n', '\n')

    # Encode to UTF-8
    if check:
        msg = msg + ',[' + code + ']'
        changed = True
        count_encoding = count_encoding + 1
        raw = raw.encode('utf8')

    # Remove BOM
    if raw.startswith(codecs.BOM_UTF8):
        msg = msg + ',[BOM]'
        changed = True
        count_bom = count_bom + 1
        raw = raw.replace(codecs.BOM_UTF8, '', 1)

    # Write to file
    if changed:
        print(msg)
        count_files = count_files + 1
        file_open = open(file_path, 'w')
        file_open.write(raw)
        file_open.close()


print('------------------------------------------------------------')

#상위 폴더를 root_dir경로로 지정
root_dir = os.path.dirname(os.path.realpath(__file__))
root_dir = os.path.join(root_dir, '../')

sub_dir = 'src'
print(sub_dir + ' ...')
convert(root_dir, sub_dir, '../' + sub_dir)

sub_dir = 'src_tool'
print(sub_dir + ' ...')
convert(root_dir, sub_dir, '../' + sub_dir)

print('------------------------------------------------------------')
print('Total ' + str(count_files) + ' files changed')

os.system('pause')
