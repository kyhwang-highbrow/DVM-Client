#-*- coding:utf-8 -*-
import hashlib

def get_checksum_md5(path):
    f = open(path, 'rb')
    data = f.read()
    hash = hashlib.md5(data).hexdigest()
    return hash