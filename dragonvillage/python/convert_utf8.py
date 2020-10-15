#-*- coding:utf-8 -*-

import os
import sys
import module.utility as utils
#import chardet
#import codecs

# Global
count_encoding = 0
count_bom = 0
count_endline = 0
count_files = 0

#import
utils.install_and_import('chardet', globals())
utils.install_and_import('codecs', globals())

def convert(rootdir, subdir, subdir2, endline = False):
    path = os.path.join(rootdir, subdir)

    for item in os.listdir(path):
        fullpath = os.path.join(path, item)

        subdir3 = subdir2 + '/' + item

        if item.endswith('.lua'):
            if utils.isPython3():
                utf8_converter_py3(fullpath, subdir3, endline)
            else:
                utf8_converter_py2(fullpath, subdir3, endline)

        if os.path.isdir(fullpath):
            convert(path, item, subdir3)

# Python2
def utf8_converter_py2(file_path, file, universal_endline = False):
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

# Python3
def utf8_converter_py3(file_path, file, universal_endline = False):
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

    msg = file
    check = False
    changed = False

    # file open .. Python3는 기본적으로 utf-8
    try:
        file_open = codecs.open(file_path, 'r', 'utf-8')
        raw = file_open.read()
    except UnicodeDecodeError:
        file_open.close()
        file_open = codecs.open(file_path)
        raw = file_open.read()
        check = True
    finally:
        file_open.close()

    # Remove windows end line
    if universal_endline:
        msg = msg + ',[Endline]'
        changed = True
        count_endline = count_endline + 1
        raw = raw.replace('\r\n', '\n')

    # Encode to UTF-8
    if check:
        msg = msg + ',[not utf-8]'
        changed = True
        count_encoding = count_encoding + 1

    # Remove BOM
    if raw.startswith(codecs.BOM_UTF8.decode()):
        msg = msg + ',[BOM]'
        changed = True
        count_bom = count_bom + 1
        raw = raw.replace(codecs.BOM_UTF8, '', 1)

    # Write to file
    if changed:
        print(msg)
        count_files = count_files + 1
        with open(file_path, 'w', encoding='utf-8') as file_open:
            file_open.write(raw)

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
