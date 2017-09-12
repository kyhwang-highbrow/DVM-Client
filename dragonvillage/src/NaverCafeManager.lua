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

