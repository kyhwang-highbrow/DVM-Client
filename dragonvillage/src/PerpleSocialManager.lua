-------------------------------------
-- table PerpleSocialManager
-- @brief PerpleSDK의 social 기능 bridge
-------------------------------------
PerpleSocialManager = {}

-------------------------------------
-- function twitterComposeTweet
-------------------------------------
function PerpleSocialManager:twitterComposeTweet(success_cb, fail_cb, cancel_cb)
	if (CppFunctions:isWin32()) then
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
			if (info == 'success') then
				--ccdisplay('twitter compose tweet SUCCESS')
				if (success_cb) then
					success_cb()
				end
			elseif (info == 'fail') then
				--ccdisplay('twitter compose tweet FAILURE')
				if (fail_cb) then
					fail_cb()
				end
			elseif (info == 'cancel') then
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
function PerpleSocialManager:twitterFollow()
	local url = 'https://twitter.com/intent/follow?user_id=955608372073586688'
	SDKManager:goToWeb(url)
end

-------------------------------------
-- function twitterFollowWebView
-- webview를 띄워서 팔로우 하러 보낸다. 세션 유지 안되고 새로 로그인 해야함.
-------------------------------------
function PerpleSocialManager:twitterFollowWebView(cb_func)
	local url = 'https://twitter.com/intent/follow?user_id=955608372073586688'
	UI_WebView(url):setCloseCB(cb_func)
end

