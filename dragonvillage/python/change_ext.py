# -*- coding: utf-8 -*-
import os, sys, optparse

def main():
    parser = optparse.OptionParser('usage change_ext.py -s <source ext> -d <dest ext>')
    parser.add_option('-s', dest='srcext', type='string', help='source ext')
    parser.add_option('-d', dest='destext', type='string', help='dest ext')
    
    (options, args) = parser.parse_args()
    
    srcext = options.srcext
    destext = options.destext
    
    if (srcext == None) | (destext == None):
        print(parser.usage)
        exit(0)
        
    for base, dirs, names in os.walk("./"):
        for name in names:
            if os.path.splitext(name)[1].lower() == "."+srcext:
                src = os.path.join(base, name)
                dest = os.path.splitext(src)[0]+"."+destext
                os.rename(src, dest)
    
if __name__ == '__main__':
    main()