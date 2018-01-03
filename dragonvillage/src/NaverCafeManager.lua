-------------------------------------
-- table NaverCafeManager
-- @brief 네이버 카페 SDK 매니져
-------------------------------------
NaverCafeManager = {
}

-------------------------------------
-- function skip
-------------------------------------
local function skip()
    if (isWin32()) then 
        return true
    end

    return false
end

-------------------------------------
-- function naverCafeShowWidgetWhenUnloadSdk
-------------------------------------
function NaverCafeManager:naverCafeShowWidgetWhenUnloadSdk(isShowWidget)
    if (skip()) then 
        return
    end

    -- @isShowWidget : 1(SDK unload 시 카페 위젯 보여주기) or 0(안 보여주기)
    PerpleSDK:naverCafeShowWidgetWhenUnloadSdk(isShowWidget)
end

-------------------------------------
-- function naverCafeStartWidget
-------------------------------------
function NaverCafeManager:naverCafeStartWidget()
    if (skip()) then 
        return
    end

    PerpleSDK:naverCafeStartWidget()
end

-------------------------------------
-- function naverCafeStart
-------------------------------------
function NaverCafeManager:naverCafeStart(tapNumber)
    if (skip()) then 
        return
    end

    -- @tapNumber : 0(Home) or 1(Notice) or 2(Event) or 3(Menu) or 4(Profile)
    PerpleSDK:naverCafeStart(tapNumber)
end

-------------------------------------
-- function naverCafeStop
-------------------------------------
function NaverCafeManager:naverCafeStop()
    if (skip()) then 
        return
    end

    PerpleSDK:naverCafeStop()
end

-------------------------------------
-- function naverCafeSyncGameUserId
-- @brief 네이버 카페에 user id 연동
-------------------------------------
function NaverCafeManager:naverCafeSyncGameUserId(uid)
    if (skip()) then 
        return
    end

    if (not uid) then
        return
    end

    if (uid == '') then
        return
    end

    if (type(uid) ~= 'string') then
        return
    end

    PerpleSDK:naverCafeSyncGameUserId(uid)
end

-------------------------------------
-- function naverCafeStartImageWrite
-- @brief 네이버 카페에 이미지 글쓰기 시작
-------------------------------------
function NaverCafeManager:naverCafeStartImageWrite(fileUri)
    if (skip()) then
        return
    end

    if not fileUri then
        return
    end

    PerpleSDK:naverCafeStartImageWrite(fileUri)
end

-------------------------------------
-- function naverCafeSetCallback
-- @brief 네이버 카페에 callback 세팅
-------------------------------------
function NaverCafeManager:naverCafeSetCallback()
    if (skip()) then
        return
    end

    --콜백 세팅할때 세팅되는게 필요해서
    --현재는 스크린샷 기능만 콜백으로 사용
    PerpleSDK:naverCafeSetCallback(function(ret, info) self:onNaverCafeCallback(ret, info) end)
end

-------------------------------------
-- function naverCafeSetCallback
-- @brief 네이버 카페에 callback 세팅
-------------------------------------
function NaverCafeManager:onNaverCafeCallback(ret, info)
    if ret == 'screenshot' or ret == 'article' then
        local size = cc.Director:getInstance():getWinSize()
        local texture = cc.RenderTexture:create( size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES )
        texture:setPosition( size.width / 2, size.height / 2 )

        texture:begin()
        g_currScene.m_scene:visit()
        texture:endToLua()
                
        local fileName = 'screenShot_' .. TimeLib:initInstance():getServerTime() .. '.png'
        texture:saveToFile( fileName, cc.IMAGE_FORMAT_PNG, true, function(node, retFileName)
            cclog( 'retFileName : ' .. retFileName )
            self:naverCafeStartImageWrite( retFileName )
        end )
        
    end
end

