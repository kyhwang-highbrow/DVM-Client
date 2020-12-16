local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_RuneForge
-------------------------------------
UI_RuneForge = class(PARENT,{
        m_npcAnimator = 'Animator',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForge:init(tab, focus_id)
    local vars = self:load('rune_forge.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_RuneForge')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initTab(tab, focus_id)
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()

    if tab then
        self:setTab(tab)
    end
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_RuneForge:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_RuneForge'
    self.m_bUseExitBtn = true
    self.m_titleStr = nil
    self.m_invenType = 'rune'
    self.m_bShowInvenBtn = true 
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForge:initUI()
    local vars = self.vars

    do -- NPC
        local res = 'res/character/npc/deet/deet.spine'
        local animator = MakeAnimator(res)
        animator:setDockPoint(0.5, 0.5)
        animator:setAnchorPoint(0.5, 0.5)
        animator:changeAni('idle', true)
        vars['npcNode']:removeAllChildren()
        vars['npcNode']:addChild(animator.m_node)
        self.m_npcAnimator = animator
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneForge:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForge:refresh()
    self:refresh_highlight()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RuneForge:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initTab
-- @param type : info, manage, combine, gacha, reinforce, grind
-------------------------------------
function UI_RuneForge:initTab(type, focus_id)
    local vars = self.vars
    local type = type or 'info'

    local info_tab = UI_RuneForgeInfoTab(self)
    local manage_tab = UI_RuneForgeManageTab(self)
    local combine_tab = UI_RuneForgeCombineTab(self)
    local gacha_tab = UI_RuneForgeGachaTab(self)
    local reinforce_tab = UI_RuneForgeReinforceTab(self)
    local grind_tab = UI_RuneForgeGrindTab(self)
    vars['indivisualTabMenu']:addChild(info_tab.root)
    vars['indivisualTabMenu']:addChild(manage_tab.root)
    vars['indivisualTabMenu']:addChild(combine_tab.root)
    vars['indivisualTabMenu']:addChild(gacha_tab.root)
    vars['indivisualTabMenu']:addChild(reinforce_tab.root)
    vars['indivisualTabMenu']:addChild(grind_tab.root)
    
    self:addTabWithTabUIAndLabel('info', vars['infoTabBtn'], vars['infoTabLabel'], info_tab)       -- 정보
    self:addTabWithTabUIAndLabel('manage', vars['manageTabBtn'], vars['manageTabLabel'], manage_tab) -- 관리
    self:addTabWithTabUIAndLabel('combine', vars['combineTabBtn'], vars['combineTabLabel'], combine_tab)    -- 조합
    self:addTabWithTabUIAndLabel('gacha', vars['gachaTabBtn'], vars['gachaTabLabel'], gacha_tab) -- 가챠
    self:addTabWithTabUIAndLabel('reinforce', vars['reinforceTabBtn'], vars['reinforceTabLabel'], reinforce_tab) -- 강화
    self:addTabWithTabUIAndLabel('grind', vars['grindTabBtn'], vars['grindTabLabel'], grind_tab) -- 연마

    self:setTab(type)

    -- 탭 바뀔 때 호출하는 함수 세팅
    self.m_cbChangeTab = function(tab, first)
        
    end

end

-------------------------------------
-- function refresh_highlight
-------------------------------------
function UI_RuneForge:refresh_highlight()
    local vars = self.vars

    -- local highlight, t_highlight = g_hatcheryData:checkHighlight()
    -- vars['summonNotiSprite']:setVisible(t_highlight['summon'])
    -- vars['incubateNotiSprite']:setVisible(t_highlight['incubate'])
    -- vars['relationNotiSprite']:setVisible(t_highlight['relation'])
    -- vars['combineNotiSprite']:setVisible(t_highlight['combine'])
end

-------------------------------------
-- function showNpc
-------------------------------------
function UI_RuneForge:showNpc()
    self.vars['npcNode']:setVisible(true)
    self.m_npcAnimator:setVisible(true)
end

-------------------------------------
-- function hideNpc
-------------------------------------
function UI_RuneForge:hideNpc()
    self.vars['npcNode']:setVisible(false)
    self.m_npcAnimator:setVisible(false)
end

-------------------------------------
-- function showMileage
-------------------------------------
function UI_RuneForge:showMileage()
    -- self.vars['mileageMenu']:setVisible(true)
end

-------------------------------------
-- function hideMileage
-------------------------------------
function UI_RuneForge:hideMileage()
    -- nself.vars['mileageMenu']:setVisible(false)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_RuneForge:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)
end
