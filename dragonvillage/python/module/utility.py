#-*- coding:utf-8 -*-

import ctypes
import os

# 숨김 파일을 찾는다!
def is_hidden(filepath):
    name = os.path.basename(os.path.abspath(filepath))
    return name.startswith('.') or has_hidden_attribute(filepath)

# 숨김 파일 속성 체크
def has_hidden_attribute(filepath):
    try:
        attrs = ctypes.windll.kernel32.GetFileAttributesW(filepath)
        assert attrs != -1
        result = bool(attrs & 2)
    except (AttributeError, AssertionError):
        result = False
    return result
