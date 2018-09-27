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
    
    ## return platform auth key 
    def getPlatformServerAuth(self, data):
        text = json.dumps(data)
        key = hmac.new(MD5_SECRET, text, hashlib.md5).hexdigest()
        return key

    ## return game server auth key
    def getGameServerAuth(self, data, url):
        query = "os=windows&uid=server"
        text = "POST\n%s\n%s" % (url, query)
        key = hmac.new(HMAC_SECRET, text, hashlib.sha1).hexdigest()
        return str(key)

    ## print time
    def printCurrentTimeStr(self):
        now = time.localtime()
        now_str = "%04d-%02d-%02d %02d:%02d:%02d" % (now.tm_year, now.tm_mon, now.tm_mday, now.tm_hour, now.tm_min, now.tm_sec)
        print "# Current time : ", now_str

    ## send slack
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

    ## call server status api
    def checkServerStatus(self, path, server_name):
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

    ## try to login so check server is alive
    def checkServerByTryToLogin(self, path, server_name):
        url = "/login"
        fullUrl = path + url
        data = {
            "uid" : "server",
            "os" : "windows"
        }
        headers = {
            "Content-Type" : "application/x-www-form-urlencoded; charset=utf-8",
            # for platform server
            "HMAC" : self.getPlatformServerAuth(data),
            # for game server
            "hmac" : self.getGameServerAuth(data, url)
        }
        r = requests.post(fullUrl, headers=headers, data=data)

        if (r.status_code == 200):
            print "%s server is OK." % server_name
            print r.json()
        else:
            print "### %s server return status code %d." % (server_name, r.status_code)
            self.sendSlackMsg(server_name)
        
        print '----------------------------------'

######################################################################

def doJob():
    print '## JOB START ##'
    checkJob = CheckServerStatusJob()
    checkJob.printCurrentTimeStr()
    checkJob.checkServerByTryToLogin(SERVER_PATH['KOREA'], "korea")
    checkJob.checkServerByTryToLogin(SERVER_PATH['JAPAN'], "japan")
    checkJob.checkServerByTryToLogin(SERVER_PATH['ASIA'], "asia")
    checkJob.checkServerByTryToLogin(SERVER_PATH['AMERICA'], "america")
    print '## JOB DONE ##\n'

def main():
    print '### SCHEDULER START ###'

    schedule.every(5).minutes.do(doJob)
    while 1:
        schedule.run_pending()
        time.sleep(1)

    print '### SCHEDULER DONE ###'

    
###################################
if __name__ == '__main__':
    main()
else:
    print '## I am being imported from another module'