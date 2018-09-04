
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

    url = "https://api.xsolla.com/merchant/v2/merchants/%d/token" % merchantId
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
                "value" : "user_id_test",
                "hidden" : False
            }
        },
        "settings" : {
            "project_id" : projectId,
            "mode" : "sandbox"
        }
    }
    print data
    r = requests.post(url, headers = headers, data = json.dumps(data))
    return r

###################################
# def main
###################################
def main():
    r = testRequestXsolla()
    
    print '\n###################################\n[response]\n###################################'
    print r.status_code
    print r.text

###################################
# MAIN
###################################
if __name__ == '__main__':
    main()
else:
    print '## I am being imported from another module'