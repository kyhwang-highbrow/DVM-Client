
import requests
import base64
import json

# base64
def base64encode(input):
    output = base64.b64encode(input)
    return output

def testRequestXsolla():
    print('###################################\n[request xsolla token]\n###################################')

    merchantId = 60608
    apiKey = "tP3xsMG3ZXasBD52"
    projectId = 35264

    url = "https://api.xsolla.com/merchant/v3/merchants/%d/token" % merchantId
    print(url)

    base64Key = base64encode(str(merchantId) + ":" + apiKey)
    headers = {
        "Authorization" : "Basic %s" % base64Key,
        "Content-Type" : "application/json",
        "Accept" : "application/json"
    }
    print(headers)
    data = {
        "user" : {
            "id" : {
                "value" : "typOEMNKDZSfZHvZP2HEYUjy2653",
                "hidden" : True
            },
            "name" : {
                "value" : "Kami test name",
                "hidden" : False
            }
        },
        "settings" : {
            "project_id" : projectId,
            "external_id" : "validation_key", 
            "mode" : "sandbox",
            "ui" : {
                "size" : "medium",
                "version" : "mobile",
                "theme" : "default_dark"
            }
        },
        "purchase" : {
            "checkout" : {
                "currency" : "USD",
                "amount" : 55
            }
        },
        "custom_parameters" : {
            "product_id" : 90091,
            "price" : 55000
        }
    }
    print(data)
    r = requests.post(url, headers = headers, data = json.dumps(data))
    print(r.json())
    print("https://sandbox-secure.xsolla.com/paystation3/?access_token=%s" % r.json()['token'])

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

def testRequestUpdatePatch():
    url = "http://192.168.1.41:7777/maintenance/update_patch_dv"
    r = requests.get(url)
    return r

###################################
# def main
###################################
def main():
    r = testRequestUpdatePatch()
    
    print('\n###################################\n[response]\n###################################')
    print("status_code : %s" % r.status_code)
    # print("text : %s" % r.text)

###################################
# MAIN
###################################
if __name__ == '__main__':
    main()
else:
    print('## I am being imported from another module')