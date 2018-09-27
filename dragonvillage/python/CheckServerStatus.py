#-*- coding: utf-8 -*-

import os
import sys
import time
import json
import hmac
import hashlib
# import requests
# import schedule

# 모듈 import(설치되어있지 않은 경우 install 후 import)
def importOrInstall(package):
    import importlib
    try:
        importlib.import_module(package)
    except ImportError:
        import pip
        pip.main(['install', package])
    finally:
        globals()[package] = importlib.import_module(package)

importOrInstall('requests')
importOrInstall('schedule')

######################################################################

SERVER_PATH = {
    'DEV' : "http://dv-test.perplelab.com:9003",
    'QA' : 'http://dv-qa.perplelab.com:9003',
    'KOREA' : 'http://dvm-api.perplelab.com',
    'JAPAN' : 'http://DVJP-ALB-1854934667.ap-southeast-1.elb.amazonaws.com',
    'ASIA' : 'http://DVSG-ALB-1276987470.ap-southeast-1.elb.amazonaws.com',
    'AMERICA' : 'http://DVUS-ALB-1364195487.us-east-1.elb.amazonaws.com'
}
HMAC_SECRET = 'Vjpmgg6MhKSBkSj4k36MQNyUwqS68qJCzRaXmID+45RQO07myxHJakFYY4i7Af6B'
MD5_SECRET = 'bd09b49ad742473a9663b0df11521927'

######################################################################

class CheckServerStatusJob():
    # def __init__(self):
    #     print '## def __init__'

    # def __del__(self):
    #     print '## def __del__'
    
    def getPlatformServerAuth(self, data):
        text = json.dumps(data)
        key = hmac.new(MD5_SECRET, text, hashlib.md5).hexdigest()
        return key

    def getGameServerAuth(self, data, url):
        query = "os=windows&uid=server"
        text = "POST\n%s\n%s" % (url, query)
        key = hmac.new(HMAC_SECRET, text, hashlib.sha1).hexdigest()
        return key

    def printCurrentTimeStr(self):
        now = time.localtime()
        now_str = "%04d-%02d-%02d %02d:%02d:%02d" % (now.tm_year, now.tm_mon, now.tm_mday, now.tm_hour, now.tm_min, now.tm_sec)
        print "current time : ", now_str

    def sendSlackMsg(self, server_name):
        fullUrl = 'https://slack.com/api/chat.postMessage'
        params = {
            'token' : 'xoxp-4049551466-58528144482-409940306166-79d561e763e94b36a6ca49a54bb9cd7d',
            'channel' : 'C1RUT070B',
            'text' : 'warning! %s server is gone.' % server_name,
            'username' : 'DVM Server Checker',
            'icon_emoji' : ':no_entry:'
        }
        r = requests.get(fullUrl, params = params)
        print r.status_code
        print "send slack msg"

    def checkServerIsAlive(self, path, server_name):
        url = "/get_version"
        fullUrl = path + url
        r = requests.get(fullUrl)

        if (r.status_code == 200):
            print "%s server is OK." % path
            print r.json()
        else:
            print "%s return status code %d." % (path, r.status_code)
            self.sendSlackMsg(server_name)
        
        print '----------------------------------'

######################################################################

def doJob():
    checkJob = CheckServerStatusJob()
    checkJob.printCurrentTimeStr()

    checkJob.checkServerIsAlive(SERVER_PATH['KOREA'], "korea")
    checkJob.checkServerIsAlive(SERVER_PATH['JAPAN'], "japan")
    checkJob.checkServerIsAlive(SERVER_PATH['ASIA'], "asia")
    checkJob.checkServerIsAlive(SERVER_PATH['AMERICA'], "america")

    print '##JOB DONE\n'

def main():
    print '## START ##'

    schedule.every(1).minutes.do(doJob)
    
    while 1:
        schedule.run_pending()
    
###################################
if __name__ == '__main__':
    main()
else:
    print '## I am being imported from another module'