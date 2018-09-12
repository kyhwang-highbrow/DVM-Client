
import requests
import base64
import json

# base64
def base64encode(input):
    output = base64.b64encode(input)
    return output

def testRequestXsolla():
    print '###################################\n[request xsolla token]\n###################################'

    merchantId = 60608
    apiKey = "tP3xsMG3ZXasBD52"
    projectId = 35042
    secretKey = "dR0p3BnJAunszS5g"

    url = "https://api.xsolla.com/merchant/v3/merchants/%d/token" % merchantId
    print url

    base64Key = base64encode(str(merchantId) + ":" + apiKey)
    headers = {
        "Authorization" : "Basic %s" % base64Key,
        "Content-Type" : "application/json",
        "Accept" : "application/json"
    }
    print headers
    data = {
        "user" : {
            "id" : {
                "value" : "test_user.id.value",
                "hidden" : True
            },
            "name" : {
                "value" : "Kami test name",
                "hidden" : False
            }
        },
        "settings" : {
            "project_id" : projectId,
            "external_id" : "test_external_id", 
            "mode" : "sandbox",
            "ui" : {
                "size" : "medium",
                "version" : "mobile",
                "theme" : "default_dark"
            }
        },
        "purchase" : {
            "virtual_items" : {
                "items" : [
                    {
                        "sku" : "test_sku_gold",
                        "amount" : 1
                    }
                ]
            }
        },
        "custom_parameters" : {
            "product_id" : 90091,
            "price" : 55000
        }
    }
    print data
    r = requests.post(url, headers = headers, data = json.dumps(data))
    print r.json()
    print "https://sandbox-secure.xsolla.com/paystation3/?access_token=%s" % r.json()['token']

    return r

def testRequestPlatformServer():
    url = "https://d27b1s0fi2x5xo.cloudfront.net/1003/versions/getPatchInfo"
    headers = {
        "Content-Type" : "application/json"
    }
    data = {
        "game_id" : 1003,
        "app_ver" : "0.5.8",
        "server" : "DEV"
    }
    r = requests.post(url, headers = headers, data = json.dumps(data))
    return r

###################################
# def main
###################################
def main():
    r = testRequestPlatformServer()
    
    print '\n###################################\n[response]\n###################################'
    print "status_code : %s" % r.status_code
    print "text : %s" % r.text

###################################
# MAIN
###################################
if __name__ == '__main__':
    main()
else:
    print '## I am being imported from another module'