local PARENT = UI

-------------------------------------
-- class UI_AdventureFirstRewardPopup
-------------------------------------
UI_AdventureFirstRewardPopup = class(PARENT, ITopUserInfo_EventListener:getCloneTable(), {
        m_stageID = 'number',
        m_cbRefresh = 'function',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureFirstRewardPopup:init(stage_id, cb_refresh)
    self.m_stageID = stage_id
    self.m_cbRefresh = cb_refresh

    local vars = self:load('adventure_first_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    

    local drop_helper = DropHelper(stage_id)
    local l_icon = drop_helper:getDisplayItemIconList_firstReward()
    local l_pos = getSortPosList(150, #l_icon)

    for i,icon in ipairs(l_icon) do
        vars['itemNode']:addChild(icon)
        icon:setPositionX(l_pos[i])
    end

    self:refreshUI()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_AdventureFirstRewardPopup')
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_AdventureFirstRewardPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AdventureFirstRewardPopup'
    self.m_bUseExitBtn = false
end

-------------------------------------
-- function refreshUI
-- @brief
-------------------------------------
function UI_AdventureFirstRewardPopup:refreshUI()
    local stage_id = self.m_stageID
    local vars = self.vars

    local difficulty, chapter, stage = parseAdventureID(stage_id)
    local first_reward_state = g_adventureData:getFirstRewardInfo(stage_id)

    if (first_reward_state == 'lock') then
        vars['descLabel']:setString(Str('{1}-{2} 통과시 수령 가능', chapter, stage))
        vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
        vars['receiveLabel']:setString('닫기')

    elseif (first_reward_state == 'open') then
        vars['descLabel']:setString(Str('{1}-{2} 보상 수령 가능', chapter, stage))
        vars['okBtn']:registerScriptTapHandler(function() self:click_receiveBtn() end)
        vars['receiveLabel']:setString('수령')

    elseif (first_reward_state == 'finish') then
        vars['descLabel']:setString(Str('{1}-{2} 보상 수령 완료', chapter, stage))
        vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
        vars['receiveLabel']:setString('닫기')

    else
        error('first_reward_state : ' .. first_reward_state)
    end  
end

-------------------------------------
-- function click_receiveBtn
-------------------------------------
function UI_AdventureFirstRewardPopup:click_receiveBtn()
    SoundMgr:playEffect('EFFECT', 'get_gacha')

    local l_reward_item = DropHelper:getFirstRewardItemList(self.m_stageID)

    local function finish_cb()
        g_adventureData:optainFirstReward(self.m_stageID)
        g_topUserInfo:refreshData()

        if self.m_cbRefresh then
            self.m_cbRefresh()
        end
        MakeSimplePopup(POPUP_TYPE.OK, Str('{@BLACK}' ..'보상을 수령하였습니다.'), function()
            self:refreshUI()
        end)
    end

    GameState:dropItem_network(l_reward_item, finish_cb)

    --[[
    g_adventureData:optainFirstReward(self.m_stageID)

    if self.m_cbRefresh then
        self.m_cbRefresh()
    end

    MakeSimplePopup(POPUP_TYPE.OK, Str('{@BLACK}' ..'보상을 수령하였습니다.'), function()
            self:refreshUI()
        end)
    --]]
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AdventureFirstRewardPopup:click_exitBtn()
    self:close()
end