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
    cclog('## UI_HatcherySummonTab:onExitTab()')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HatcherySummonTab:initUI()
    local vars = self.vars

    -- È®·ü¾÷
    vars['eventSummonBtn']:registerScriptTapHandler(function() local is_bundle = false; self:click_eventSummonBtn(is_bundle) end)
    vars['eventBundleSummonBtn']:registerScriptTapHandler(function() local is_bundle = true; self:click_eventSummonBtn(is_bundle) end)

    -- Ä³½Ã »Ì±â
    vars['cashSummonBtn']:registerScriptTapHandler(function() local is_bundle = false; self:click_cashSummonBtn(is_bundle) end)
    vars['cashBundleSummonBtn']:registerScriptTapHandler(function() local is_bundle = true; self:click_cashSummonBtn(is_bundle) end)

    -- ¿ìÁ¤Æ÷ÀÎÆ® »Ì±â
    vars['friendSummonBtn']:registerScriptTapHandler(function() local is_bundle = false; self:click_friendSummonBtn(is_bundle) end)
    vars['friendBundleSummonBtn']:registerScriptTapHandler(function() local is_bundle = true; self:click_friendSummonBtn(is_bundle) end)
end

-------------------------------------
-- function click_eventSummonBtn
-- @brief È®·ü¾÷
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
    end

    local function fail_cb()
    end

    local is_sale = false
    g_hatcheryData:request_summonCashEvent(is_bundle, is_sale, finish_cb, fail_cb)
end

-------------------------------------
-- function click_cashSummonBtn
-- @brief Ä³½Ã »Ì±â
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
    end

    local function fail_cb()
    end

    local is_sale = false
    g_hatcheryData:request_summonCash(is_bundle, is_sale, finish_cb, fail_cb)
end

-------------------------------------
-- function click_friendSummonBtn
-- @brief ¿ìÁ¤Æ÷ÀÎÆ® »Ì±â
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