-------------------------------------
-- table PerpleSdkManager
-- @brief PerpleSDK의 social 기능 bridge
-------------------------------------
PerpleSdkManager = {
    isAvailable = true
}

if (isWin32()) then
    PerpleSdkManager.isAvailable = false
end

-- private function table
-- 함수 사용 구조를 예쁘게 한다.
local Crashlytics = {
    isCrashlyticsAvailable = PerpleSdkManager.isAvailable
}

-------------------------------------
-- function twitterComposeTweet
-------------------------------------
function PerpleSdkManager:twitterComposeTweet(success_cb, fail_cb, cancel_cb)
	if (not self.isAvailable) then
		return
	end

	local size = cc.Director:getInstance():getWinSize()
    local texture = cc.RenderTexture:create( size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES )
    texture:setPosition( size.width / 2, size.height / 2 )

    texture:begin()
    g_currScene.m_scene:visit()
    texture:endToLua()
                
	-- 스샷 저장하고 트윗 인텐츠 출력
    local file_name = string.format('twtrshot_%s.png', os.time())
    texture:saveToFile(file_name, cc.IMAGE_FORMAT_PNG, true, function(node, ret_file_name)
        cclog('ret_file_name : ' .. ret_file_name)
		PerpleSDK:twitterComposeTweet(ret_file_name, function(ret, info)
			if (result == 'success') then
				--ccdisplay('twitter compose tweet SUCCESS')
				if (success_cb) then
					success_cb()
				end
			elseif (result == 'fail') then
				--ccdisplay('twitter compose tweet FAILURE')
				if (fail_cb) then
					fail_cb()
				end
			elseif (result == 'cancel') then
				--ccdisplay('twitter compose tweet CANCEL')
				if (cancel_cb) then
					cancel_cb()
				end
			end
		end)
    end)
end

-------------------------------------
-- function twitterFollow
-- 별도 창을 띄워서 팔로우 하러 보낸다, 세션 유지는 안되고 새로 로그인 해야함.
-------------------------------------
function PerpleSdkManager:twitterFollow()
	local url = 'https://twitter.com/intent/follow?user_id=955608372073586688'
	SDKManager:goToWeb(url)
end

-------------------------------------
-- function twitterFollowWebView
-- webview를 띄워서 팔로우 하러 보낸다. 세션 유지 안되고 새로 로그인 해야함.
-------------------------------------
function PerpleSdkManager:twitterFollowWebView(cb_func)
	local url = 'https://twitter.com/intent/follow?user_id=955608372073586688'
	UI_WebView(url):setCloseCB(cb_func)
end

-------------------------------------
-- function xsollaIsAvailable
-- xsolla build와 시점 차이로 인하여 예외처리
-------------------------------------
function PerpleSdkManager:xsollaIsAvailable()
	if (CppFunctions:isAndroid()) then
		if (PerpleSDK.xsollaIsAvailable) then
			if (PerpleSDK:xsollaIsAvailable()) then
				return true
			end
		end
	end

	return false
end

-------------------------------------
-- function onestoreIsAvailable
-- onestore build와 시점 차이로 인하여 예외처리
-------------------------------------
function PerpleSdkManager:onestoreIsAvailable()
	if (CppFunctions:isAndroid()) then
		if (PerpleSDK.onestoreIsAvailable) then
			if (PerpleSDK:onestoreIsAvailable()) then
				return true
			end
		end
	end

	return false
end

-------------------------------------
-- function getAdid
-- @brief 광고 식별자
-------------------------------------
function PerpleSdkManager:getAdid()
    if (PerpleSDK == nil) then
        return ''
    end

    if (PerpleSDK['adjustGetAdid'] == nil) then
        return ''
    end

    local adid = PerpleSDK['adjustGetAdid'](PerpleSDK)

    return adid
end



-------------------------------------
-- function makeErrorPopup
-- perpleSdk에서 반환한 에러 정보를 팝업으로 출력
-------------------------------------
function PerpleSdkManager:makeErrorPopup(info)
    local t_info = dkjson.decode(info)
	local error_str
	if (t_info) then
		if (t_info['msg'] and t_info['msg'] ~= '') then
			error_str = string.format('%s [Error code = %d:%s]\n%s', Str('오류가 발생했습니다.'), t_info['code'], t_info['subcode'], t_info['msg'])
		else
			error_str = string.format('%s [Error code = %d:%s]', Str('오류가 발생했습니다.'), t_info['code'], t_info['subcode'])
		end
	else
		error_str = string.format('%s [Error. %s]', Str('오류가 발생했습니다.'), info or '')
	end
    MakeSimplePopup(POPUP_TYPE.OK, error_str)
end

-------------------------------------
-- function getCrashlytics
-- @brief PerpleSdkManager를 통해서 crashlytics에 접근하도록 한다.
-------------------------------------
function PerpleSdkManager.getCrashlytics()
    return Crashlytics
end


-------------------------------------
-- table Crashlytics
-- @brief Firebase Crashlytics
-------------------------------------
-------------------------------------
-- function forceCrash
-------------------------------------
function Crashlytics:forceCrash()
	if (not self.isCrashlyticsAvailable) then
		return
	end
    PerpleSDK:crashlyticsForceCrash()
end

-------------------------------------
-- function setUid
-------------------------------------
function Crashlytics:setUid(uid)
	if (not self.isCrashlyticsAvailable) then
		return
	end
    if (not uid) then
        return
    end
    PerpleSDK:crashlyticsSetUid(uid)
end

-------------------------------------
-- function setLog
-------------------------------------
function Crashlytics:setLog(msg)
	if (not self.isCrashlyticsAvailable) then
		return
	end
    PerpleSDK:crashlyticsSetLog(msg)
end

-------------------------------------
-- function setExceptionLog
-------------------------------------
function Crashlytics:setExceptionLog(msg)
	if (not self.isCrashlyticsAvailable) then
		return
	end
    PerpleSDK:crashlyticsSetExceptionLog(msg)
end

-------------------------------------
-- function setData
-- @param key is have to string type
-- @param value can be string, int(not float), boolean
-------------------------------------
function Crashlytics:setData(key, value)
	if (not self.isCrashlyticsAvailable) then
		return
	end

    if (not key) then
        return
    elseif (value == nil) then
        return
    elseif (type(key) ~= 'string') then
        return
    end

    local value_type = type(value)
    if (value_type == 'string') then
        PerpleSDK:crashlyticsSetKeyString(key, value)
    elseif (value_type == 'number') then
        PerpleSDK:crashlyticsSetKeyInt(key, math_floor(value))
    elseif (value_type == 'boolean') then
        PerpleSDK:crashlyticsSetKeyBool(key, value and true or false)
    end
end


