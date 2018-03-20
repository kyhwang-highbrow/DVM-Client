local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_TeamBonus
-------------------------------------
UI_TeamBonus = class(PARENT,{
        m_initail_tab = '',
        m_selDeck = '',
        m_selDid = 'number',

        m_tTabClass = 'table',
    })

TEAM_BONUS_MODE = {
    DRAGON = 'dragon', -- 드래곤 별 팀 보너스
    TOTAL  = 'all', -- 전체 팀 보너스
}

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_TeamBonus:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_TeamBonus'
    self.m_bVisible = true 
    self.m_titleStr = Str('팀 보너스')
    self.m_bUseExitBtn = true -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_TeamBonus:init(initail_tab, l_deck, sel_did)
    local vars = self:load('team_bonus.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_initail_tab = initail_tab or TEAM_BONUS_MODE.DRAGON
    self.m_selDeck = l_deck
    self.m_selDid = sel_did

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_TeamBonus')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TeamBonus:initUI()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_TeamBonus:initTab()
    self.m_tTabClass = {}
    self.m_tTabClass[TEAM_BONUS_MODE.DRAGON] = UI_TeamBonus_Dragon(self)
    self.m_tTabClass[TEAM_BONUS_MODE.TOTAL] = UI_TeamBonus_Total(self)

    local vars = self.vars
    self:addTabAuto(TEAM_BONUS_MODE.DRAGON, vars, vars['dragonListNode1'])
    self:addTabAuto(TEAM_BONUS_MODE.TOTAL, vars, vars['allListNode'])

    self:setTab(self.m_initail_tab)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_TeamBonus:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)

    if (not self.m_tTabClass[tab]) then
        return
    end

    -- 상세보기는 드래곤 별 팀 보너스에만 노출
    local detail_popup = self.vars['detailMenu']
    detail_popup:setVisible(tab == TEAM_BONUS_MODE.DRAGON)

    self.m_tTabClass[tab]:onEnterTab(first)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TeamBonus:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TeamBonus:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_TeamBonus:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_TeamBonus)
