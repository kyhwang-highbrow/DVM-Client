/****************************************************************************
 Copyright (c) 2013-2014 Chukong Technologies Inc.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
#include "lua_xml_http_request.h"
#include <string>
#include "tolua_fix.h"
#include "CCLuaStack.h"
#include "CCLuaValue.h"
#include "CCLuaEngine.h"
#include "LuaScriptHandlerMgr.h"


using namespace cocos2d;
using namespace std;

LuaMinXmlHttpRequest::LuaMinXmlHttpRequest():_isNetwork(true)
{
    _httpHeader.clear();
    _requestHeader.clear();
    _withCredentialsValue = true;
    _httpRequest  = new network::HttpRequest();
}

LuaMinXmlHttpRequest::~LuaMinXmlHttpRequest()
{
    _httpHeader.clear();
    _requestHeader.clear();
}

/**
 *  @brief Implementation for header retrieving.
 *  @param header
 */
void LuaMinXmlHttpRequest::_gotHeader(string header)
{
    // Get Header and Set StatusText
    // Split String into Tokens
    char * cstr = new char [header.length()+1];
    
    // check for colon.
    size_t found_header_field = header.find_first_of(":");
    
    if (found_header_field != std::string::npos)
    {
        // Found a header field.
        string http_field;
        string http_value;
        
        http_field = header.substr(0,found_header_field);
        http_value = header.substr(found_header_field+1, header.length());
        
        // Get rid of all \n
        if (!http_value.empty() && http_value[http_value.size() - 1] == '\n') {
            http_value.erase(http_value.size() - 1);
        }
        
        _httpHeader[http_field] = http_value;
        
    }
    else
    {
        // Seems like we have the response Code! Parse it and check for it.
        char * pch;
        strcpy(cstr, header.c_str());
        
        pch = strtok(cstr," ");
        while (pch != NULL)
        {
            
            stringstream ss;
            string val;
            
            ss << pch;
            val = ss.str();
            size_t found_http = val.find("HTTP");
            
            // Check for HTTP Header to set statusText
            if (found_http != std::string::npos) {
                
                stringstream mystream;
                
                // Get Response Status
                pch = strtok (NULL, " ");
                mystream << pch;
                
                pch = strtok (NULL, " ");
                mystream << " " << pch;
                
                _statusText = mystream.str();
                
            }
            
            pch = strtok (NULL, " ");
        }
    }
    
    CC_SAFE_DELETE_ARRAY(cstr);
}

/**
 *  @brief Set Request header for next call.
 *  @param field  Name of the Header to be set.
 *  @param value  Value of the Headerfield
 */
void LuaMinXmlHttpRequest::setRequestHeader(const char* field, const char* value)
{
    stringstream header_s;
    stringstream value_s;
    string header;
    
    map<string, string>::iterator iter = _requestHeader.find(field);
    
    // Concatenate values when header exists.
    if (iter != _requestHeader.end())
    {
        value_s << iter->second << "," << value;
    }
    else
    {
        value_s << value;
    }
    
    _requestHeader[field] = value_s.str();
}

/**
 * @brief  If headers has been set, pass them to curl.
 *
 */
void LuaMinXmlHttpRequest::_setHttpRequestHeader()
{
    std::vector<string> header;
    
    for (auto it = _requestHeader.begin(); it != _requestHeader.end(); ++it)
    {
        const char* first = it->first.c_str();
        const char* second = it->second.c_str();
        size_t len = sizeof(char) * (strlen(first) + 3 + strlen(second));
        char* test = (char*) malloc(len);
        memset(test, 0,len);
        
        strcpy(test, first);
        strcpy(test + strlen(first) , ": ");
        strcpy(test + strlen(first) + 2, second);
        
        header.push_back(test);
        
        free(test);
        
    }
    
    if (!header.empty())
    {
        _httpRequest->setHeaders(header);
    }
    
}

/**
 * @brief   Send out request and fire callback when done.
 */
void LuaMinXmlHttpRequest::_sendRequest()
{
    //jjo, progress 관련 callback 추가 (2014/11/04)
    _httpRequest->setResponseCallbackWithProgress(this
        , httpresponse_selector(LuaMinXmlHttpRequest::handle_requestResponse)
        , httpprogress_selector(LuaMinXmlHttpRequest::handle_requestProgress)
    );

    network::HttpClient::getInstance()->send(_httpRequest);
    _httpRequest->release();
}

// jjo, progress 관련 callback 함수 추가 (2014/11/03)
void LuaMinXmlHttpRequest::handle_requestProgress(int size)
{
    // call back lua function
    int handler = cocos2d::ScriptHandlerMgr::getInstance()->getObjectHandler((void*)this, cocos2d::ScriptHandlerMgr::HandlerType::XMLHTTPREQUEST_PROGRESS_CHANGE);
    if (0 != handler)
    {
        LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
        stack->pushInt(size);
        int ret = stack->executeFunctionByHandler(handler, 1);
        stack->clean();
    }
}

/**
 *  @brief Callback for HTTPRequest. Handles the response and invokes Callback.
 *  @param sender   Object which initialized callback
 *  @param respone  Response object
 *  @js NA
 */
void LuaMinXmlHttpRequest::handle_requestResponse(network::HttpClient *sender, network::HttpResponse *response)
{
    if (0 != strlen(response->getHttpRequest()->getTag()))
    {
        CCLOG("%s completed", response->getHttpRequest()->getTag());
    }
    
    long statusCode = response->getResponseCode();
    char statusString[64] = {};
    sprintf(statusString, "HTTP Status Code: %ld, tag = %s", statusCode, response->getHttpRequest()->getTag());

    // call back lua function
    int handler = cocos2d::ScriptHandlerMgr::getInstance()->getObjectHandler((void*)this, cocos2d::ScriptHandlerMgr::HandlerType::XMLHTTPREQUEST_READY_STATE_CHANGE);
    
    if (!response->isSucceed())
    {
        CCLOG("response failed");
        CCLOG("error buffer: %s", response->getErrorBuffer());
        _errorText = std::string(response->getErrorBuffer());
        //jjo, 실패할 경우 false (boolean) 을 보내준다.
        if (0 != handler)
        {
            LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
            stack->pushBoolean(false);
            int ret = stack->executeFunctionByHandler(handler, 1);
            stack->clean();
        }
        return;
    }
    
    // set header
    std::vector<char> *headers = response->getResponseHeader();
    
    char* concatHeader = (char*) malloc(headers->size() + 1);
    std::string header(headers->begin(), headers->end());
    strcpy(concatHeader, header.c_str());
    
    std::istringstream stream(concatHeader);
    std::string line;
    while(std::getline(stream, line)) {
        _gotHeader(line);
    }

    /** get the response data **/
    std::vector<char> *buffer = response->getResponseData();
    std::string s2(buffer->begin(), buffer->end());

    if (statusCode == 200)
    {
        //Succeeded
        _status = 200;
        _readyState = DONE;
        _dataSize = buffer->size();
        _data.write(s2.c_str(), _dataSize + 1);
    }
    else
    {
        _status = statusCode; //jjo, statusCode를 그대로 저장하도록 수정
    }

    //jjo, 성공할 경우 true (boolean) 을 보내준다.
    if (0 != handler)
    {
        LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
        stack->pushBoolean(true);
        int ret = stack->executeFunctionByHandler(handler, 1);
        stack->clean();
    }

    // Free Memory.
    free((void*)concatHeader);

}

void LuaMinXmlHttpRequest::getByteData(unsigned char* byteData)
{
    _data.read((char*)byteData, _dataSize);
}

void LuaMinXmlHttpRequest::setTimeoutForConnect(int value)
{
    _httpRequest->setTimeoutForConnect(value);
}

int LuaMinXmlHttpRequest::getTimeoutForConnect()
{
    return _httpRequest->getTimeoutForConnect();
}

void LuaMinXmlHttpRequest::setTimeoutForRead(int value)
{
    _httpRequest->setTimeoutForRead(value);
}

int LuaMinXmlHttpRequest::getTimeoutForRead()
{
    return _httpRequest->getTimeoutForRead();
}

/* function to regType */
static void lua_reg_xml_http_request(lua_State* L)
{
    tolua_usertype(L, "cc.XMLHttpRequest");
}

static int lua_collect_xml_http_request (lua_State* L)
{
    LuaMinXmlHttpRequest* self = (LuaMinXmlHttpRequest*) tolua_tousertype(L,1,0);
    Mtolua_delete(self);
    return 0;
}

static int lua_cocos2dx_XMLHttpRequest_constructor(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif
    
    argc = lua_gettop(L)-1;
    if (argc == 0)
    {
        self = new LuaMinXmlHttpRequest();
        self->autorelease();
        int ID =  self? (int)self->_ID : -1;
        int* luaID = self? &self->_luaID : NULL;
        toluafix_pushusertype_ccobject(L, ID, luaID, (void*)self, "cc.XMLHttpRequest");
        return 1;
    }
    
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "XMLHttpRequest",argc, 0);
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_cocos2dx_XMLHttpRequest_constructor'.",&tolua_err);
    return 0;
#endif
}

static int lua_get_XMLHttpRequest_responseType(lua_State* L)
{
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_get_XMLHttpRequest_responseType'\n", nullptr);
        return 0;
    }
#endif
    
    tolua_pushnumber(L, (lua_Number)self->getResponseType());
    return 1;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_get_XMLHttpRequest_responseType'.",&tolua_err);
    return 0;
#endif
}

static int lua_set_XMLHttpRequest_responseType(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_set_XMLHttpRequest_responseType'\n", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(L) - 1;
    
    if (1 == argc)
    {
#if COCOS2D_DEBUG >= 1
        if (!tolua_isnumber(L, 2, 0, &tolua_err))
            goto tolua_lerror;
#endif
        int responseType = (int)tolua_tonumber(L,2,0);
        
        self->setResponseType((LuaMinXmlHttpRequest::ResponseType)responseType);
        
        return 0;
    }
    
    CCLOG("'setResponseType' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 1);
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_set_XMLHttpRequest_responseType'.",&tolua_err);
    return 0;
#endif
}

static int lua_get_XMLHttpRequest_withCredentials(lua_State* L)
{
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_get_XMLHttpRequest_withCredentials'\n", nullptr);
        return 0;
    }
#endif
    
    tolua_pushboolean(L, self->getWithCredentialsValue());
    return 1;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_get_XMLHttpRequest_withCredentials'.",&tolua_err);
    return 0;
#endif
}

static int lua_set_XMLHttpRequest_withCredentials(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_set_XMLHttpRequest_withCredentials'\n", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(L) - 1;
    
    if (1 == argc)
    {
#if COCOS2D_DEBUG >= 1
        if (!tolua_isboolean(L, 2, 0, &tolua_err))
            goto tolua_lerror;
#endif
        self->setWithCredentialsValue((bool)tolua_toboolean(L, 2, 0));
        return 0;
    }
    
    CCLOG("'setWithCredentials' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 1);
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_set_XMLHttpRequest_withCredentials'.",&tolua_err);
    return 0;
#endif
}

static int lua_get_XMLHttpRequest_timeoutForConnect(lua_State* L)
{
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_get_XMLHttpRequest_timeoutForConnect'\n", nullptr);
        return 0;
    }
#endif
    
    tolua_pushnumber(L, (lua_Number)self->getTimeoutForConnect());
    return 1;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_get_XMLHttpRequest_timeoutForConnect'.",&tolua_err);
    return 0;
#endif
}

static int lua_set_XMLHttpRequest_timeoutForConnect(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_set_XMLHttpRequest_timeoutForConnect'\n", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(L) - 1;
    
    if (1 == argc)
    {
#if COCOS2D_DEBUG >= 1
        if (!tolua_isnumber(L, 2, 0, &tolua_err))
            goto tolua_lerror;
#endif
        self->setTimeoutForConnect((int)tolua_tonumber(L, 2, 0));
        return 0;
    }
    
    CCLOG("'setTimeout' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 1);
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_set_XMLHttpRequest_timeoutForConnect'.",&tolua_err);
    return 0;
#endif
}

static int lua_get_XMLHttpRequest_timeoutForRead(lua_State* L)
{
    LuaMinXmlHttpRequest* self = nullptr;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L, 1, "cc.XMLHttpRequest", 0, &tolua_err)) goto tolua_lerror;
#endif

    self = (LuaMinXmlHttpRequest*)tolua_tousertype(L, 1, 0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L, "invalid 'self' in function 'lua_get_XMLHttpRequest_timeoutForRead'\n", nullptr);
        return 0;
    }
#endif

    tolua_pushnumber(L, (lua_Number)self->getTimeoutForRead());
    return 1;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L, "#ferror in function 'lua_get_XMLHttpRequest_timeoutForRead'.", &tolua_err);
    return 0;
#endif
}

static int lua_set_XMLHttpRequest_timeoutForRead(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L, 1, "cc.XMLHttpRequest", 0, &tolua_err)) goto tolua_lerror;
#endif

    self = (LuaMinXmlHttpRequest*)tolua_tousertype(L, 1, 0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L, "invalid 'self' in function 'lua_set_XMLHttpRequest_timeoutForRead'\n", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(L) - 1;

    if (1 == argc)
    {
#if COCOS2D_DEBUG >= 1
        if (!tolua_isnumber(L, 2, 0, &tolua_err))
            goto tolua_lerror;
#endif
        self->setTimeoutForRead((int)tolua_tonumber(L, 2, 0));
        return 0;
    }

    CCLOG("'setTimeout' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L, "#ferror in function 'lua_set_XMLHttpRequest_timeoutForRead'.", &tolua_err);
    return 0;
#endif
}

static int lua_get_XMLHttpRequest_readyState(lua_State* L)
{
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_get_XMLHttpRequest_readyState'\n", nullptr);
        return 0;
    }
#endif
    
    lua_pushinteger(L, (lua_Integer)self->getReadyState());
    
    return 1;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_get_XMLHttpRequest_readyState'.",&tolua_err);
    return 0;
#endif
}

static int lua_get_XMLHttpRequest_status(lua_State* L)
{
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_get_XMLHttpRequest_status'\n", nullptr);
        return 0;
    }
#endif
    
    lua_pushinteger(L, (lua_Integer)self->getStatus());
    
    return 1;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_get_XMLHttpRequest_status'.",&tolua_err);
    return 0;
#endif
}

static int lua_get_XMLHttpRequest_statusText(lua_State* L)
{
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_get_XMLHttpRequest_statusText'\n", nullptr);
        return 0;
    }
#endif
    
    lua_pushstring(L, self->getStatusText().c_str());
    
    return 1;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_get_XMLHttpRequest_statusText'.",&tolua_err);
    return 0;
#endif
}

static int lua_get_XMLHttpRequest_errorText(lua_State* L)
{
    LuaMinXmlHttpRequest* self = nullptr;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L, 1, "cc.XMLHttpRequest", 0, &tolua_err)) goto tolua_lerror;
#endif

    self = (LuaMinXmlHttpRequest*)tolua_tousertype(L, 1, 0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L, "invalid 'self' in function 'lua_get_XMLHttpRequest_errorText'\n", nullptr);
        return 0;
    }
#endif

    lua_pushstring(L, self->getErrorText().c_str());

    return 1;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L, "#ferror in function 'lua_get_XMLHttpRequest_errorText'.", &tolua_err);
    return 0;
#endif
}

static int lua_get_XMLHttpRequest_responseText(lua_State* L)
{
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_get_XMLHttpRequest_responseText'\n", nullptr);
        return 0;
    }
#endif
    lua_pushstring(L, self->getDataStr().c_str());
    return 1;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_get_XMLHttpRequest_responseText'.",&tolua_err);
    return 0;
#endif
}

static int lua_get_XMLHttpRequest_response(lua_State* L)
{
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_get_XMLHttpRequest_response'\n", nullptr);
        return 0;
    }
#endif
    
    if (self->getResponseType() == LuaMinXmlHttpRequest::ResponseType::JSON)
    {
        lua_pushstring(L, self->getDataStr().c_str());
        return 1;
    }
    else if(self->getResponseType() == LuaMinXmlHttpRequest::ResponseType::ARRAY_BUFFER)
    {
        LuaStack *pStack = LuaEngine::getInstance()->getLuaStack();
        if (NULL == pStack) {
            return 0;
        }
        
        lua_State *tolua_s = pStack->getLuaState();
        if (NULL == tolua_s) {
            return 0;
        }
        
        LuaValueArray array;
        
        uint8_t* tmpData = new uint8_t[self->getDataSize()];
        if (nullptr == tmpData)
        {
            return 0;
        }
        
        self->getByteData(tmpData);
        
        for (int i = 0 ; i < self->getDataSize(); i++)
        {
            LuaValue value = LuaValue::intValue(tmpData[i]);
            array.push_back(value);
        }
        
        pStack->pushLuaValueArray(array);
        
        CC_SAFE_DELETE_ARRAY(tmpData);
        return 1;
    }
    else
    {
        if (self->getStatus() == 200)
        {
            lua_pushlstring(L, self->getDataStr().c_str(), self->getDataSize());
        }
        return 1;
    }
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_get_XMLHttpRequest_response'.",&tolua_err);
    return 0;
#endif
}

static int lua_get_XMLHttpRequest_downloadPath(lua_State* L)
{
    LuaMinXmlHttpRequest* self = nullptr;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L, 1, "cc.XMLHttpRequest", 0, &tolua_err)) goto tolua_lerror;
#endif

    self = (LuaMinXmlHttpRequest*)tolua_tousertype(L, 1, 0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L, "invalid 'self' in function 'lua_get_XMLHttpRequest_downloadPath'\n", nullptr);
        return 0;
    }
#endif

    lua_pushstring(L, self->getDownloadPath().c_str());
    return 1;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L, "#ferror in function 'lua_get_XMLHttpRequest_downloadPath'.", &tolua_err);
    return 0;
#endif
}

static int lua_set_XMLHttpRequest_downloadPath(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L, 1, "cc.XMLHttpRequest", 0, &tolua_err)) goto tolua_lerror;
#endif

    self = (LuaMinXmlHttpRequest*)tolua_tousertype(L, 1, 0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L, "invalid 'self' in function 'lua_set_XMLHttpRequest_downloadPath'\n", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(L) - 1;

    if (1 == argc)
    {
#if COCOS2D_DEBUG >= 1
        if (!tolua_isstring(L, 2, 0, &tolua_err))
            goto tolua_lerror;
#endif
        std::string downloadPath = tolua_tostring(L, 2, "");

        self->setDownloadPath(downloadPath);

        if (nullptr != self->getHttpRequest())
        {
            self->getHttpRequest()->setDownloadPath(downloadPath);
        }

        return 0;
    }

    CCLOG("'setDownloadPath' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L, "#ferror in function 'lua_set_XMLHttpRequest_downloadPath'.", &tolua_err);
    return 0;
#endif
}

static int lua_cocos2dx_XMLHttpRequest_open(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_cocos2dx_XMLHttpRequest_open'\n", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(L) - 1;
    
    if ( argc >= 2)
    {
#if COCOS2D_DEBUG >= 1
        if (!tolua_isstring(L, 2, 0, &tolua_err) ||
            !tolua_isstring(L, 3, 0, &tolua_err))
            goto tolua_lerror;
#endif
        
        std::string method = tolua_tostring(L, 2, "");
        std::string url    = tolua_tostring(L, 3, "");
        bool async = true;
        if (argc > 2)
        {
#if COCOS2D_DEBUG >= 1
            if (!tolua_isboolean(L, 4, 0, &tolua_err) )
                goto tolua_lerror;
#endif
            async = tolua_toboolean(L, 4, 0);
        }
        
        self->setUrl(url);
        self->setMethod(method);
        self->setReadyState(1);
        self->setAsync(async);
        
        if (url.length() > 5 && url.compare(url.length() - 5, 5, ".json") == 0 )
        {
            self->setResponseType(LuaMinXmlHttpRequest::ResponseType::JSON);
        }
        
        if (nullptr != self->getHttpRequest())
        {
            if (method.compare("post") == 0 || method.compare("POST") == 0)
            {
                self->getHttpRequest()->setRequestType(network::HttpRequest::Type::POST);
            }
            else
            {
                self->getHttpRequest()->setRequestType(network::HttpRequest::Type::GET);
            }
            
            self->getHttpRequest()->setUrl(url.c_str());
            
        }
        
        self->setIsNetWork(true);
        self->setReadyState(LuaMinXmlHttpRequest::OPENED);

        return 0;
    }
    
    CCLOG("'open' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 2);
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_cocos2dx_XMLHttpRequest_open'.",&tolua_err);
    return 0;
#endif
}

static int lua_cocos2dx_XMLHttpRequest_send(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;
    //std::string data = "";
    const char* data = NULL;
    size_t size = 0;
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_cocos2dx_XMLHttpRequest_send'\n", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(L) - 1;

    if ( 1 == argc )
    {
#if COCOS2D_DEBUG >= 1
        if (!tolua_isstring(L, 2, 0, &tolua_err))
            goto tolua_lerror;
#endif
        //data = tolua_tostring(L, 2, "");
        data = (const char*) lua_tolstring(L, 2, &size);
    }
    
    if (size > 0 &&
        (self->getMethod().compare("post") == 0 || self->getMethod().compare("POST") == 0) &&
        nullptr != self->getHttpRequest())
    {
        self->getHttpRequest()->setRequestData(data,size);
    }
    
    self->_setHttpRequestHeader();
    self->_sendRequest();
    return 0;
    
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_cocos2dx_XMLHttpRequest_send'.",&tolua_err);
    return 0;
#endif
}

/**
 * @brief abort function Placeholder!
 */
static int lua_cocos2dx_XMLHttpRequest_abort(lua_State* L)
{
    return 0;
}

static int lua_cocos2dx_XMLHttpRequest_setRequestHeader(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;
    const char* field = "";
    const char* value = "";
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_cocos2dx_XMLHttpRequest_setRequestHeader'\n", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(L) - 1;
    
    if ( 2 == argc )
    {
#if COCOS2D_DEBUG >= 1
        if (!tolua_isstring(L, 2, 0, &tolua_err) ||
            !tolua_isstring(L, 3, 0, &tolua_err) )
            goto tolua_lerror;
#endif
        
        field = tolua_tostring(L, 2, "");
        value = tolua_tostring(L, 3, "");
        self->setRequestHeader(field, value);
        return 0;
    }
    
    CCLOG("'setRequestHeader' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_cocos2dx_XMLHttpRequest_setRequestHeader'.",&tolua_err);
    return 0;
#endif
}

static int lua_cocos2dx_XMLHttpRequest_getAllResponseHeaders(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;
    
    stringstream responseheaders;
    string responseheader = "";
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_cocos2dx_XMLHttpRequest_getAllResponseHeaders'\n", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(L) - 1;
    
    if ( 0 == argc )
    {
        map<string, string> httpHeader = self->getHttpHeader();
        
        for (auto it = httpHeader.begin(); it != httpHeader.end(); ++it)
        {
            responseheaders << it->first << ": "<< it->second << "\n";
        }
        
        responseheader = responseheaders.str();
        tolua_pushstring(L, responseheader.c_str());
        return 1;
    }
    
    CCLOG("'getAllResponseHeaders' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_cocos2dx_XMLHttpRequest_getAllResponseHeaders'.",&tolua_err);
    return 0;
#endif
}

static int lua_cocos2dx_XMLHttpRequest_getResponseHeader(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;
    
    string responseheader = "";
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_cocos2dx_XMLHttpRequest_getAllResponseHeaders'\n", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(L) - 1;
    
    if ( 1 == argc )
    {
#if COCOS2D_DEBUG >= 1
        if (!tolua_isstring(L, 2, 0, &tolua_err) )
            goto tolua_lerror;
#endif
        responseheader = tolua_tostring(L, 2, "");
        
        stringstream streamData;
        streamData << responseheader;
        
        string value = streamData.str();
        
        auto iter = self->getHttpHeader().find(value);
        if (iter != self->getHttpHeader().end())
        {
            tolua_pushstring(L, (iter->second).c_str());
            return 1;
        }
    }
    
    CCLOG("'getResponseHeader' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_cocos2dx_XMLHttpRequest_getAllResponseHeaders'.",&tolua_err);
    return 0;
#endif
}

static int lua_cocos2dx_XMLHttpRequest_registerScriptHandler(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;
    
    string responseheader = "";
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_cocos2dx_XMLHttpRequest_registerScriptHandler'\n", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(L) - 1;
    
    if (1 == argc)
    {
#if COCOS2D_DEBUG >= 1
        if (!toluafix_isfunction(L,2,"LUA_FUNCTION",0,&tolua_err))
            goto tolua_lerror;
#endif
        
        int handler = (  toluafix_ref_function(L,2,0));
        cocos2d::ScriptHandlerMgr::getInstance()->addObjectHandler((void*)self, handler, cocos2d::ScriptHandlerMgr::HandlerType::XMLHTTPREQUEST_READY_STATE_CHANGE);
        return 0;
    }
    
    CCLOG("'registerScriptHandler' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_cocos2dx_XMLHttpRequest_registerScriptHandler'.",&tolua_err);
    return 0;
#endif
}

static int lua_cocos2dx_XMLHttpRequest_unregisterScriptHandler(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;
    
    string responseheader = "";
    
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L,1,"cc.XMLHttpRequest",0,&tolua_err)) goto tolua_lerror;
#endif
    
    self = (LuaMinXmlHttpRequest*)  tolua_tousertype(L,1,0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L,"invalid 'self' in function 'lua_cocos2dx_XMLHttpRequest_unregisterScriptHandler'\n", nullptr);
        return 0;
    }
#endif
    
    argc = lua_gettop(L) - 1;
    
    if (0 == argc)
    {
        cocos2d::ScriptHandlerMgr::getInstance()->removeObjectHandler((void*)self, cocos2d::ScriptHandlerMgr::HandlerType::XMLHTTPREQUEST_READY_STATE_CHANGE);
        
        return 0;
    }
    
    CCLOG("'unregisterScriptHandler' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_cocos2dx_XMLHttpRequest_unregisterScriptHandler'.",&tolua_err);
    return 0;
#endif
    
}

static int lua_cocos2dx_XMLHttpRequest_registerProgressScriptHandler(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;

    string responseheader = "";

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L, 1, "cc.XMLHttpRequest", 0, &tolua_err)) goto tolua_lerror;
#endif

    self = (LuaMinXmlHttpRequest*)tolua_tousertype(L, 1, 0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L, "invalid 'self' in function 'lua_cocos2dx_XMLHttpRequest_registerProgressScriptHandler'\n", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(L) - 1;

    if (1 == argc)
    {
#if COCOS2D_DEBUG >= 1
        if (!toluafix_isfunction(L, 2, "LUA_FUNCTION", 0, &tolua_err))
            goto tolua_lerror;
#endif

        int handler = (toluafix_ref_function(L, 2, 0));
        cocos2d::ScriptHandlerMgr::getInstance()->addObjectHandler((void*)self, handler, cocos2d::ScriptHandlerMgr::HandlerType::XMLHTTPREQUEST_PROGRESS_CHANGE);
        return 0;
    }

    CCLOG("'registerProgressScriptHandler' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L, "#ferror in function 'lua_cocos2dx_XMLHttpRequest_registerProgressScriptHandler'.", &tolua_err);
    return 0;
#endif
}

static int lua_cocos2dx_XMLHttpRequest_unregisterProgressScriptHandler(lua_State* L)
{
    int argc = 0;
    LuaMinXmlHttpRequest* self = nullptr;

    string responseheader = "";

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertype(L, 1, "cc.XMLHttpRequest", 0, &tolua_err)) goto tolua_lerror;
#endif

    self = (LuaMinXmlHttpRequest*)tolua_tousertype(L, 1, 0);
#if COCOS2D_DEBUG >= 1
    if (nullptr == self)
    {
        tolua_error(L, "invalid 'self' in function 'lua_cocos2dx_XMLHttpRequest_unregisterProgressScriptHandler'\n", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(L) - 1;

    if (0 == argc)
    {
        cocos2d::ScriptHandlerMgr::getInstance()->removeObjectHandler((void*)self, cocos2d::ScriptHandlerMgr::HandlerType::XMLHTTPREQUEST_PROGRESS_CHANGE);

        return 0;
    }

    CCLOG("'unregisterProgressScriptHandler' function of XMLHttpRequest wrong number of arguments: %d, was expecting %d\n", argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L, "#ferror in function 'lua_cocos2dx_XMLHttpRequest_unregisterProgressScriptHandler'.", &tolua_err);
    return 0;
#endif

}

TOLUA_API int register_xml_http_request(lua_State* L)
{
    tolua_open(L);
    lua_reg_xml_http_request(L);
    tolua_module(L,"cc",0);
    tolua_beginmodule(L,"cc");
      tolua_cclass(L,"XMLHttpRequest","cc.XMLHttpRequest","cc.Ref",lua_collect_xml_http_request);
      tolua_beginmodule(L,"XMLHttpRequest");
        tolua_variable(L, "responseType", lua_get_XMLHttpRequest_responseType, lua_set_XMLHttpRequest_responseType);
        tolua_variable(L, "withCredentials", lua_get_XMLHttpRequest_withCredentials, lua_set_XMLHttpRequest_withCredentials);
        tolua_variable(L, "timeoutForConnect", lua_get_XMLHttpRequest_timeoutForConnect, lua_set_XMLHttpRequest_timeoutForConnect);
        tolua_variable(L, "timeoutForRead", lua_get_XMLHttpRequest_timeoutForRead, lua_set_XMLHttpRequest_timeoutForRead);
        tolua_variable(L, "readyState", lua_get_XMLHttpRequest_readyState, nullptr);
        tolua_variable(L, "status",lua_get_XMLHttpRequest_status,nullptr);
        tolua_variable(L, "statusText", lua_get_XMLHttpRequest_statusText, nullptr);
        tolua_variable(L, "errorText", lua_get_XMLHttpRequest_errorText, nullptr);
        tolua_variable(L, "responseText", lua_get_XMLHttpRequest_responseText, nullptr);
        tolua_variable(L, "response", lua_get_XMLHttpRequest_response, nullptr);
        tolua_variable(L, "downloadPath", lua_get_XMLHttpRequest_downloadPath, lua_set_XMLHttpRequest_downloadPath);
        tolua_function(L, "new", lua_cocos2dx_XMLHttpRequest_constructor);
        tolua_function(L, "open", lua_cocos2dx_XMLHttpRequest_open);
        tolua_function(L, "send", lua_cocos2dx_XMLHttpRequest_send);
        tolua_function(L, "abort", lua_cocos2dx_XMLHttpRequest_abort);
        tolua_function(L, "setRequestHeader", lua_cocos2dx_XMLHttpRequest_setRequestHeader);
        tolua_function(L, "getAllResponseHeaders", lua_cocos2dx_XMLHttpRequest_getAllResponseHeaders);
        tolua_function(L, "getResponseHeader", lua_cocos2dx_XMLHttpRequest_getResponseHeader);
        tolua_function(L, "registerScriptHandler", lua_cocos2dx_XMLHttpRequest_registerScriptHandler);
        tolua_function(L, "unregisterScriptHandler", lua_cocos2dx_XMLHttpRequest_unregisterScriptHandler);
        tolua_function(L, "registerProgressScriptHandler", lua_cocos2dx_XMLHttpRequest_registerProgressScriptHandler);
        tolua_function(L, "unregisterProgressScriptHandler", lua_cocos2dx_XMLHttpRequest_unregisterProgressScriptHandler);
      tolua_endmodule(L);
    tolua_endmodule(L);
    return 1;
}
