#-*- coding: utf-8 -*-

import os
import sys
import time
import json
import hmac
import hashlib
import module.utility as utils
# import requests
# import schedule

utils.install_and_import('requests', globals())
utils.install_and_import('schedule', globals())

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

PROBLEM_COUNT = {}

######################################################################

class CheckServerStatusJob():
    # def __init__(self):
    #     print('## def __init__')

    # def __del__(self):
    #     print('## def __del__')
    
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
        print("# Current time : ", now_str)

    ## send slack
    def sendSlackMsg(self, server_name, is_red_card):
        channel = "C1RUT070B"
        text = 'warning! [%s] server do not respond.' % server_name,
        if (is_red_card):
            channel = "C1QFD2E4S"
            text = 'warning! [%s] server is gone.' % server_name,

        fullUrl = 'https://slack.com/api/chat.postMessage'
        params = {
            'token' : 'xoxp-4049551466-58528144482-409940306166-79d561e763e94b36a6ca49a54bb9cd7d',
            'channel' : channel,
            'text' : text,
            'username' : 'DVM Server Checker',
            'icon_emoji' : ':no_entry:'
        }
        r = requests.get(fullUrl, params = params)
        print("# send slack msg")

    # set problem count by server name and send slack msg if have to do
    def addProblemCount(self, serverName):
        if (serverName in PROBLEM_COUNT):
            PROBLEM_COUNT[serverName] += 1
        else:
            PROBLEM_COUNT[serverName] = 1

        if (PROBLEM_COUNT[serverName] >= 3):
            PROBLEM_COUNT[serverName] = 0
            return True
        else:
            return False

    ## call server status api
    def checkServerStatus(self, path, serverName):
        url = "/get_version"
        fullUrl = path + url
        r = requests.get(fullUrl)

        if (r.status_code == 200):
            print("%s server is OK." % path)
            print(r.json())
            PROBLEM_COUNT[serverName] = 0

        else:
            print("%s return status code %d." % (path, r.status_code))
            isRedCard = self.addProblemCount(serverName)
            self.sendSlackMsg(serverName, isRedCard)
        
        print('----------------------------------')

    ## try to login so check server is alive
    def checkServerByTryToLogin(self, path, serverName):
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
            # for game server ## hardcording
            "hmac" : self.getGameServerAuth(data, url)
        }
        r = requests.post(fullUrl, headers=headers, data=data)

        if (r.status_code == 200):
            print("%s server is OK." % serverName)
            print(r.json())
            PROBLEM_COUNT[serverName] = 0
        else:
            print("### %s server return status code %d." % (serverName, r.status_code))
            isRedCard = self.addProblemCount(serverName)
            self.sendSlackMsg(serverName, isRedCard)
        
        print('----------------------------------')

######################################################################

def doJob():
    print('## JOB START ##')
    checkJob = CheckServerStatusJob()
    checkJob.printCurrentTimeStr()
    checkJob.checkServerByTryToLogin(SERVER_PATH['KOREA'], "KOREA")
    checkJob.checkServerByTryToLogin(SERVER_PATH['JAPAN'], "JAPAN")
    checkJob.checkServerByTryToLogin(SERVER_PATH['ASIA'], "ASIA")
    checkJob.checkServerByTryToLogin(SERVER_PATH['AMERICA'], "AMERICA")
    print('## JOB DONE ##\n')

def main():
    print('### SCHEDULER START ###')

    schedule.every(3).minutes.do(doJob)
    while 1:
        schedule.run_pending()
        time.sleep(1)

    print('### SCHEDULER DONE ###')

    
###################################
if __name__ == '__main__':
    main()
else:
    print('## I am being imported from another module')