#-*- coding:utf-8 -*-

import ctypes
import os
import sys
import importlib

# import 시도하고 없으면 설치한다
# @mskim 2020.11.26 alias를 사용하거나 from을 사용하는 경우 global scope에 등록하지 않아야 한다.
def install_and_import(package, globalScope = None):
    try:
        importlib.import_module(package)
    except ImportError:
        import pip
        pip.main(['install', package])
    finally:
        if globalScope:
            globalScope[package] = importlib.import_module(package)

# 숨김 파일을 찾는다!
def is_hidden(filepath):
    name = os.path.basename(os.path.abspath(filepath))
    return name.startswith('.') or __has_hidden_attribute(filepath)

# 숨김 파일 속성 체크
def __has_hidden_attribute(filepath):
    try:
        if isPython3():
            attrs = ctypes.windll.kernel32.GetFileAttributesW(filepath)
        else:
            attrs = ctypes.windll.kernel32.GetFileAttributesW(unicode(filepath))
        assert attrs != -1
        result = bool(attrs & 2)
    except (AttributeError, AssertionError):
        result = False
    return result

def isPython3():
    return sys.version_info >= (3, 0, 0)