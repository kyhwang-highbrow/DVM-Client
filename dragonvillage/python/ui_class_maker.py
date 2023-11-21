# -*- coding: utf-8 -*-
#-------------------------------------------------------------
# 2016.08.12
# 형식에 맞추어 UI Class lua file 을 생성한다.
#-------------------------------------------------------------

import os

def makeLuaClassFile(class_name):
    fr = open("../src/UI_ClassForm.lua", 'r')
    fw = open("../src/" + class_name + ".lua", 'w')

    for line in fr.readlines():
        class_line = line.replace("UI_ClassForm", class_name)
        fw.write(class_line)
    fr.close()
    fw.close()

if __name__ == '__main__':
    print('UI LUA CLASS MAKER')
    
    print('Type class name which you want to make.')

    class_name = raw_input()

    makeLuaClassFile(class_name)

    print('...........Complete')
    os.system("PAUSE")