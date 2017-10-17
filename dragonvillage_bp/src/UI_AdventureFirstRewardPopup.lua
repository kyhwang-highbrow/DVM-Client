local PARENT = UI_RewardListPopup

-------------------------------------
-- class UI_AdventureFirstRewardPopup
-------------------------------------
UI_AdventureFirstRewardPopup = class(PARENT, {
        m_stageID = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureFirstRewardPopup:init(stage_id)
    self.m_stageID = stage_id

    local first_reward_data = g_adventureFirstRewardData:getFirstRewardInfo(stage_id)
    local item_package_str = first_reward_data['reward']

    self:setRewardItemCardList_byItemPackageStr(item_package_str)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_AdventureFirstRewardPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AdventureFirstRewardPopup:initUI()
    local vars = self.vars
    vars['titleLabel']:setString(Str('최초 클리어 보상'))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdventureFirstRewardPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AdventureFirstRewardPopup:refresh()
    if (not self.m_stageID) then
        return
    end

    local vars = self.vars
    local stage_id = self.m_stageID

    local stage_info = g_adventureData:getStageInfo(stage_id)
    local state = stage_info:getFirstClearRewardState()

    if (state == 'received') then
        vars['descLabel']:setString(Str('보상 수령 완료'))
        vars['receiveLabel']:setString(Str('닫기'))
        vars['okBtn']:registerScriptTapHandler(function() self:close() end)

    elseif (state == 'opend') then
        vars['descLabel']:setString(Str('보상 수령 가능'))
        vars['receiveLabel']:setString(Str('수령'))
        vars['okBtn']:registerScriptTapHandler(function() self:click_receiveBtn() end)
        vars['okBtn']:setAutoShake(true)

    elseif (state == 'lock') then
        local name = g_stageData:getStageName(stage_id)
        vars['descLabel']:setString(Str('{1}통과 후 수령 가능', name))
        vars['receiveLabel']:setString(Str('닫기'))
        vars['okBtn']:registerScriptTapHandler(function() self:close() end)

    else
        error('status : ' .. status)
    end

end

-------------------------------------
-- function click_receiveBtn
-------------------------------------
function UI_AdventureFirstRewardPopup:click_receiveBtn()
    local function finish_cb(ret)
        self:close()
        ItemObtainResult(ret)
		SoundMgr:playEffect('UI', 'ui_out_item_get')
    end

    local function fail_cb(ret)

    end

    g_adventureFirstRewardData:request_firstClearReward(self.m_stageID, finish_cb, fail_cb)
end