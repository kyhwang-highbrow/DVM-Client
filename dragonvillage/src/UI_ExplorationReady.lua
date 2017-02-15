local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ExplorationReady
-------------------------------------
UI_ExplorationReady = class(PARENT,{
        m_eprID = '',
        m_selectedHours = 'number',-- 선택된 탐험 시간
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ExplorationReady:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ExplorationReady'
    self.m_bVisible = true or false
    self.m_titleStr = Str('탐험 준비') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_ExplorationReady:init(epr_id)
    self.m_eprID = epr_id

    local vars = self:load('exploration_ready.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ExplorationReady')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ExplorationReady:initTab()
    local vars = self.vars
    self:addTab(1, vars['timeBtn1'])
    self:addTab(4, vars['timeBtn2'])
    self:addTab(6, vars['timeBtn3'])
    self:addTab(12, vars['timeBtn4'])

    self:setTab(1)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ExplorationReady:onChangeTab(tab, first)
    local vars = self.vars

    local hours = tab
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    -- 탐험 소요 시간 표시
    vars['timeLabel']:setString(Str('{1} 시간', hours))
    cca.uiReactionSlow(vars['timeLabel'])

    -- 획득하는 경험치 표시
    local add_exp = location_info[tostring(hours) .. '_hours_exp']
    vars['expLabel']:setString(comma_value(add_exp))
    cca.uiReactionSlow(vars['expLabel'])

    -- 획득하는 아이템 리스트
    local reward_items_str = location_info[tostring(hours) .. '_hours_items']
    local reward_items_list = g_itemData:parsePackageItemStr(reward_items_str)
    vars['rewardNode']:removeAllChildren()

    local scale = 0.53
    local l_pos = getSortPosList(150 * scale + 3, #reward_items_list)

    for i,v in ipairs(reward_items_list) do
        local ui = UI_ItemCard(v['item_id'], v['count'])
        vars['rewardNode']:addChild(ui.root)
        ui.root:setScale(0)
        ui.root:setPosition(l_pos[i], 0)
        ui.root:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.02), cc.ScaleTo:create(0.25, scale)))
    end


end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ExplorationReady:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExplorationReady:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExplorationReady:refresh()
    local vars = self.vars
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    -- 지역 이름
    vars['locationLabel']:setString(Str(location_info['t_name']))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ExplorationReady:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ExplorationReady)
