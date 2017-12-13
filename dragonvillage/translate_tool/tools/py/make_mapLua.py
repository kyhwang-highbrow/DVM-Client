 # -*- coding: utf-8 -*-
import os
import re
from xml.dom.minidom import *
import codecs
import glob
import datetime

docAll = Document()
w = codecs.open('translate.xml', 'r', 'utf-8')
dom = parseString (codecs.encode(w.read(), 'utf-8'))
w.close()

root = dom.getElementsByTagName('TranslateMake')[0]
texts = root.getElementsByTagName('T')

langs = []
fds = {}

for dir in os.listdir('.'):
    if dir == 'a_temp':
        continue
    elif os.path.isdir(os.path.join('.', dir)):
        langs.append(unicode(dir))

for lang in langs:
    name = '../translate/' + lang.encode('utf-8') +  'Map.lua'
    print ( name )
    fds[lang] = codecs.open(name, 'w', 'utf-8')

count = 1

# 전체 번역 문장 갯수 출력
print texts.length

# ['한국어']:'대상언어' 로 맵핑된 루아 테이블 생성
for t in texts:
    keyStr = t.getAttribute('kr').replace('\"','\\"')
    keyStr = keyStr.replace("\'","\\'")

    for lang in langs:
        if count == 1 :
            fds[lang].write("LanguageMap = {")

        translateStr = t.getAttribute(lang).replace('\"','\\"')
        translateStr = translateStr.replace("\'","\\'")

        if translateStr == '' :
            translateStr = keyStr

        fds[lang].write("['" + keyStr + "']='" + translateStr +"',\n")

        if count == texts.length :
            fds[lang].write("}")
    count += 1

for k,v in fds.iteritems():
    v.close()

print('complete creating Maps!')

os.system("PAUSE")

