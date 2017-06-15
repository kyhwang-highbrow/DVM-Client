local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_HatcherySummonTab
-------------------------------------
UI_HatcherySummonTab = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HatcherySummonTab:init(owner_ui)
    local vars = self:load('hatchery_summon.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_HatcherySummonTab:onEnterTab(first)
    if (first == true) then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_HatcherySummonTab:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HatcherySummonTab:initUI()
    local vars = self.vars

    -- 확률업
    vars['eventSummonBtn']:registerScriptTapHandler(function() local is_bundle = false; self:click_eventSummonBtn(is_bundle) end)
    vars['eventBundleSummonBtn']:registerScriptTapHandler(function() local is_bundle = true; self:click_eventSummonBtn(is_bundle) end)

    -- 캐시 뽑기
    vars['cashSummonBtn']:registerScriptTapHandler(function() local is_bundle = false; self:click_cashSummonBtn(is_bundle) end)
    vars['cashBundleSummonBtn']:registerScriptTapHandler(function() local is_bundle = true; self:click_cashSummonBtn(is_bundle) end)

    -- 우정포인트 뽑기
    vars['friendSummonBtn']:registerScriptTapHandler(function() local is_bundle = false; self:click_friendSummonBtn(is_bundle) end)
    vars['friendBundleSummonBtn']:registerScriptTapHandler(function() local is_bundle = true; self:click_friendSummonBtn(is_bundle) end)
end

-------------------------------------
-- function click_eventSummonBtn
-- @brief 확률업
-------------------------------------
function UI_HatcherySummonTab:click_eventSummonBtn(is_bundle)
    local function finish_cb(ret)
        local l_dragon_list = ret['added_dragons']
        local l_slime_list = ret['added_slimes']
        local ui = UI_GachaResult_Dragon(l_dragon_list, l_slime_list)

        local function close_cb()
            self:sceneFadeInAction()
        end
        ui:setCloseCB(close_cb)

        -- 추가된 마일리지
        local added_mileage = ret['added_mileage'] or 0
        UIManager:toastNotificationGreen(Str('{1}마일리지가 적립되었습니다.', added_mileage))
    end

    local function fail_cb()
    end

    local is_sale = false
    g_hatcheryData:request_summonCashEvent(is_bundle, is_sale, finish_cb, fail_cb)
end

-------------------------------------
-- function click_cashSummonBtn
-- @brief 캐시 뽑기
-------------------------------------
function UI_HatcherySummonTab:click_cashSummonBtn(is_bundle)
    local function finish_cb(ret)
        local l_dragon_list = ret['added_dragons']
        local l_slime_list = ret['added_slimes']
        local ui = UI_GachaResult_Dragon(l_dragon_list, l_slime_list)

        local function close_cb()
            self:sceneFadeInAction()
        end
        ui:setCloseCB(close_cb)

        -- 추가된 마일리지
        local added_mileage = ret['added_mileage'] or 0
        UIManager:toastNotificationGreen(Str('{1}마일리지가 적립되었습니다.', added_mileage))
    end

    local function fail_cb()
    end

    local is_sale = false
    g_hatcheryData:request_summonCash(is_bundle, is_sale, finish_cb, fail_cb)
end

-------------------------------------
-- function click_friendSummonBtn
-- @brief 우정포인트 뽑기
-------------------------------------
function UI_HatcherySummonTab:click_friendSummonBtn(is_bundle)
    local function finish_cb(ret)
        local l_dragon_list = ret['added_dragons']
        local l_slime_list = ret['added_slimes']
        local ui = UI_GachaResult_Dragon(l_dragon_list, l_slime_list)

        local function close_cb()
            self:sceneFadeInAction()
        end
        ui:setCloseCB(close_cb)
    end

    local function fail_cb()
    end

    g_hatcheryData:request_summonFriendshipPoint(is_bundle, finish_cb, fail_cb)
end