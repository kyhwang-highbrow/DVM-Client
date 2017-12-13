# -*- coding: utf-8 -*-
import os
import re
from xml.dom.minidom import *
import codecs
import glob
import datetime
import csv

# 특정 파일을 아예 삭제해버린다. 반드시 svn:update를 통해 복원해야한다.
def deleteExceptFiles():
    f = open('./noTranslateTables.txt','r')
    lines = f.readlines()
    f.close()
    for fileName in lines:
        fileName = fileName.replace('\n','')
        if fileName.endswith('.csv'):
            fileName = '../data/' + fileName
        elif fileName.endswith('.ui'):
            fileName = '../res/ui/' + fileName
        elif fileName.endswith('.lua'):
            fileName = '../src/' + fileName
        if os.path.isfile(fileName) :
            os.remove(fileName)
            print('delete ' + fileName + ', because it have to exclude')


def unicode_csv_reader(utf8_data, dialect=csv.excel, **kwargs):
    csv_reader = csv.reader(utf8_data, dialect=dialect, **kwargs)
    for row in csv_reader:
        yield [unicode(cell, 'utf-8') for cell in row]

# csv 에서 추출하는 코드
def populateFromCsv(path):
    try:
        s = unicode_csv_reader(open(path))
    except:
        pass

    hint = path[path.rfind('\\')+1:]
    for rows in s:
        for match in rows:
            if not re.match(u'.*[가-힣]+.*', match):
                continue
            if not level.has_key(match):
                level[match] = []
            if not hint in level[match]:
                level[match].append(hint)

def iterCsv(path):
    for f in os.listdir(path):
        p = os.path.join(path, f)
        if os.path.isdir(p):
            iterCsv(p)
            continue

        if p.endswith('csv'):
            populateFromCsv(p)

# lua script에서 추출하는 코드
def populateStr(path):
    f = open(path, 'r')
    s = f.read()
    try:
        s = s.decode('utf-8-sig')
    except:
        pass

    hint = path[path.rfind('\\')+1:]
    for match in re.findall("Str\('([^']*)'", s):
        if not re.match(u'.*[가-힣]+.*', match):
            continue
        #if translated.has_key(match):
        #   continue
        if not script.has_key(match):
            script[match] = []
        if not hint in script[match]:
            script[match].append(hint)

def iterLua(path):
    for f in os.listdir(path):
        p = os.path.join(path, f)
        if os.path.isdir(p):
            iterLua(p)
            continue
        if p.endswith('lua'):
            populateStr(p)

# xml에서 추출하는 코드
def iterate(node, depth, info):
    for child in node.childNodes:
        if child.nodeType == Node.ELEMENT_NODE:
            attrs = child.attributes
            for i in range(attrs.length):
                attr = attrs.item(i)
                if attr.name == 'id':
                    continue
                if info.has_key(depth) and info[depth].has_key(attr.name):
                    continue
                value = unicode(attr.value)
                if re.match(u'.*[가-힣]+.*', value):
                    if not info.has_key(depth):
                        info[depth] = {}
                    info[depth][attr.name] = True

            iterate(child, depth + 1, info)


colorIds = {}
def pop(node, depth, info, hint, tags):
    for child in node.childNodes:
        if child.nodeType == Node.ELEMENT_NODE:
            if depth > 0:
                id = None
                attrs = child.attributes
                for i in range(attrs.length):
                    attr = attrs.item(i)
                    if id == None and attr.name == 'id':
                        id = attr.value
                    elif attr.name == 'reprId':
                        id = attr.value
                if id:
                    tags.append(child.nodeName + '[' + id + ']')
                else:
                    tags.append(child.nodeName)

            if info.has_key(depth):
                for i in range(attrs.length):
                    attr = attrs.item(i)
                    if not info[depth].has_key(attr.name):
                        continue

                    value = unicode(attr.value)
                    #if translated.has_key(value):
                    #   continue
                    if not level.has_key(value):
                        level[value] = []

                    if attr.name == 'color':
                        curHint = 'color'
                        if id:
                            if not colorIds.has_key(value):
                                colorIds[value] = []
                            if not id in colorIds[value]:
                                colorIds[value].append(id)
                    else:
                        curHint = hint + '(' + '.'.join(tags) + '.' + attr.name + ')'
                    if not curHint in level[value]:
                        level[value].append(curHint)

            pop(child, depth + 1, info, hint, tags)
            if len(tags) > 0:
                del tags[len(tags)-1]

def populateFromXml(path):
    node = xml.dom.minidom.parse(path)
    info = {}
    iterate(node, 0, info)
    pop(node, 0, info, path[path.rfind('\\')+1:], [])

def iterXml(path):
    for f in os.listdir(path):
        if f == 'compensation.xml':
            continue
        p = os.path.join(path, f)
        if os.path.isdir(p):
            iterXml(p)
            continue

        if p.endswith('xml'):
            populateFromXml(p)

# ui 파일에서 추출하는 코드
def readUIElems(lines, hint):
    lines.pop()
    tempWidth = 0
    neccerayInfo = ''
    while True:
        line_org = lines.pop()
        if not line_org:
            break

        line = line_org.strip()
        pos = line.find('=')
        key = line[0:pos].strip()
        value = line[pos + 1:].strip()[1:-2]
        if (key == 'text') or (key == 'placeholder'):
            if re.match(u'.*[가-힣]+.*', value):
                if not ui.has_key(value):
                    ui[value] = []
                if not hint in ui[value]:
                    ui[value].append(hint)
                    ui[value].append(neccerayInfo)
        elif key == 'width':
            tempWidth = line[pos + 1:].replace(';','')
        elif key == 'font_size':
            tempSize = line[pos + 1:].replace(';','')
            
            inputableWord = int( int(tempWidth)/round(int(tempSize)*0.610714285714286 + 0.086904761904762))
            
            #inputableWord = int(round(0.07*int(tempWidth) - 0.45*int(tempSize) + 10.78))
            neccerayInfo = "[th_word_limit :" + `inputableWord` + "]"


def populateFromUI(path):
    s = open(path).read()
    try:
        s = s.decode('utf-8-sig')
    except:
        pass

    lines = s.split('\n')
    lines.reverse()

    readUIElems(lines, path[path.rfind('\\')+1:])

def iterUI(path):
    for f in os.listdir(path):
        p = os.path.join(path, f)
        if os.path.isdir(p):
            iterUI(p)
            continue

        if p.endswith('ui'):
            populateFromUI(p)

# 이미 번역이 완료된 파일들에서 번역된 결과물들을 취합하는 코드
def iterTranslateXml(node, lang, dic):
    for child in node.childNodes:
        if child.nodeType == Node.ELEMENT_NODE:
            attrs = child.attributes
            key = None
            value = None
            for i in range(attrs.length):
                attr = attrs.item(i)
                if attr.name == 'kr':
                    key = unicode(attr.value)
                elif attr.name == lang:
                    value = unicode(attr.value)

            if key != None and value != None:
                if not dic.has_key(key):
                    dic[key] = {}

                if not dic[key].has_key(lang):
                    dic[key][lang] = ''

                if (value != ''):
                    dic[key][lang] = value

            iterTranslateXml(child, lang, dic)

def loadTranslated(lang, dic, date):
    for f in glob.glob('translateMake/%s/*.xml' % lang):
        if f.find(date) >= 0:
            print f, 'will be overwritten'
            continue
        node = xml.dom.minidom.parse(f)
        iterTranslateXml(node, lang, dic)

#entry point

date = datetime.date.today().isoformat()

deleteExceptFiles()

print('creating translate script file....')

baseDir = '../../../hod_prototype/'

langs = []
for dir in os.listdir('.'):
    if dir == 'a_temp' or dir == 'a_keep':
        continue
    if os.path.isdir(os.path.join('.', dir)):
        langs.append(unicode(dir))

script = {}
level = {}
ui = {}
os.chdir('../../../hod_prototype/res/ui')
iterUI('.')
os.chdir('../../')

os.chdir('data')
iterCsv('.')
os.chdir('../')

os.chdir('src')
iterLua('.')
os.chdir('../../util/TranslateServer/py')

l2 = {}
for key in script.keys():
    print('now crawling in csv ... : ' + key )
    l2[key] = ','.join(script[key])
x2 = {}
for key in level.keys():
    print('now crawling in lua ... : ' + key )
    x2[key] = ','.join(level[key])
u2 = {}
for key in ui.keys():
    print('now crawling in ui ... : ' + key )
    u2[key] = ','.join(ui[key])

translated = {}
all = {}

docs = {}
roots = {}
print('creating translate script file : phase 2 ....')
for lang in langs:
    print(lang)
    loadTranslated(lang, translated, date)
    docs[lang] = Document()
    roots[lang] = docs[lang].createElement("TranslateMake")
    docs[lang].appendChild(roots[lang])

docAll = Document()
rootAll = docAll.createElement("TranslateMake")
docAll.appendChild(rootAll)

# 번역 요청 시에 순서가 너무 뒤죽박죽 섞이지 않게 하기 위해 적당히 순서를 잡아준 것임
translationTargetKeys = sorted(x2.items(), key=lambda (k,v): v) + sorted(l2.items(), key=lambda (k,v): v) + sorted(u2.items(), key=lambda (k,v): v)
done = {}
print('creating translate script file : phase 3 ....')
for item in sorted(translationTargetKeys) :
    key = item[0]
    key.replace("\"", "&quot;")
    if key in done:
        continue
    done[key] = True
    hints = []

    # levelOnly는 이후에 실제 클라이언트에서 xml 로드가 끝나고나면
    # 메모리에 들고 있지 않아도 되기 때문에 flagging 해둠
    levelOnly = True
    if level.has_key(key):
        hints = hints + level[key]
    if script.has_key(key):
        hints = hints + script[key]
        levelOnly = False
    if ui.has_key(key): 
        hints = hints + ui[key]
        levelOnly = False

    for i in range(len(hints)):
        if hints[i] == 'color' and colorIds.has_key(key):
            hints[i] = 'color['+','.join(colorIds[key])+']'

    t1 = docAll.createElement("T")
    t1.setAttribute("kr", key)
    t1.setAttribute("hints", ','.join(hints))
    if levelOnly:
        t1.setAttribute("x", "true")
    rootAll.appendChild(t1)

    for lang in langs:
        if translated.has_key(key) and translated[key].has_key(lang) and translated[key][lang] != '':
            # 이미 번역 결과물이 있다면 translate.xml에만 넣어주고
            # 추가 요청 대상이 되지 않도록 continue
            t1.setAttribute(lang, translated[key][lang])
            continue

        t1.setAttribute(lang, "")

        t2 = docs[lang].createElement("T")
        t2.setAttribute("kr", key)
        t2.setAttribute(lang, "")
        t2.setAttribute("hints", ','.join(hints))
        roots[lang].appendChild(t2)

gen_dir = 'bin'

w = codecs.open(gen_dir + '/translate.xml', 'w', 'utf-8-sig')
docAll.writexml(w, encoding='utf-8', indent='\t', newl='\n')
w.close()

newpath = gen_dir + '/a_temp' 
if not os.path.exists(newpath):
    os.makedirs(newpath)

for lang in langs:
    if len(roots[lang].childNodes) == 0:
        print 'no changes in %s' % lang
        continue

    w = codecs.open(gen_dir + '/a_temp/%s_%s.xml' % (lang, date), 'w', 'utf-8-sig')
    docs[lang].writexml(w, encoding='utf-8', indent='\t', newl='\n')
    w.close()

#os.system('translate\\CheckFontCharacterSet.exe jp RgPPokkru-Bd')

print('complete creating translate script file !')
os.system("PAUSE")
