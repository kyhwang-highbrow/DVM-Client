local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Hatchery
-------------------------------------
UI_Hatchery = class(PARENT,{
        m_npcAnimator = 'Animator',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Hatchery:init(tab, focus_id)
    local vars = self:load('hatchery.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Hatchery')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initTab(focus_id)
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
function UI_Hatchery:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Hatchery'
    self.m_titleStr = Str('부화소')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'fp' -- 우정포인트
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Hatchery:initUI()
    do -- NPC
        local res = 'res/character/npc/yuria/yuria.spine'
        local animator = MakeAnimator(res)
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator:changeAni('idle', true)
        self.vars['npcNode']:addChild(animator.m_node)
        self.m_npcAnimator = animator
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Hatchery:initButton()
    local vars = self.vars

    -- 마일리지 샵
    vars['mileageBtn']:registerScriptTapHandler(function() self:click_mileageBtn() end)

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Hatchery:refresh()
    self:refresh_highlight()
    self:refresh_mileage()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Hatchery:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_Hatchery:initTab(focus_id)
    local vars = self.vars

    local summon_tab = UI_HatcherySummonTab(self)
    local incubate_tab = UI_HatcheryIncubateTab(self, focus_id)
    local combine_tab = UI_HatcheryCombineTab(self)
    local relation_tab = UI_HatcheryRelationTab(self)
    vars['indivisualTabMenu']:addChild(summon_tab.root)
    vars['indivisualTabMenu']:addChild(incubate_tab.root)
    vars['indivisualTabMenu']:addChild(combine_tab.root)
    vars['indivisualTabMenu']:addChild(relation_tab.root)

    self:addTabWithTabUIAndLabel('summon', vars['summonTabBtn'], vars['summonTabLabel'], summon_tab)       -- 소환
    self:addTabWithTabUIAndLabel('incubate', vars['incubateTabBtn'], vars['incubateTabLabel'], incubate_tab) -- 부화
    self:addTabWithTabUIAndLabel('combine', vars['combineTabBtn'], vars['combineTabLabel'], combine_tab)    -- 조합
    self:addTabWithTabUIAndLabel('relation', vars['relationTabBtn'], vars['relationTabLabel'], relation_tab) -- 인연

    self:setTab('summon')

    -- 탭 바뀔 때 호출하는 함수 세팅
    self.m_cbChangeTab = function(tab, first)
        if (tab == 'incubate') then
            vars['eggInfoBtn']:setVisible(true)
        else
            vars['eggInfoBtn']:setVisible(false)
        end 
    end

end

-------------------------------------
-- function refresh_mileage
-------------------------------------
function UI_Hatchery:refresh_mileage()
    local vars = self.vars
    local mileage = g_userData:get('mileage')

    -- 마일리지 표시
    vars['mileageLabel']:setString(comma_value(mileage))

    -- 마일리지 상태에 따른 애니메이션 
    local ani_key_1, ani_key_2 = g_hatcheryData:getMileageAnimationKey()
    vars['mileageVisual1']:changeAni(ani_key_1, true)
    --vars['mileageVisual2']:changeAni(ani_key_2, true)

    -- 획득 가능 라벨
    --vars['availableLabel']:setVisible(ani_key_1 ~= nil)
end

-------------------------------------
-- function refresh_highlight
-------------------------------------
function UI_Hatchery:refresh_highlight()
    local vars = self.vars

    local highlight, t_highlight = g_hatcheryData:checkHighlight()
    -- vars['summonNotiSprite']:setVisible(t_highlight['summon'])
    -- vars['incubateNotiSprite']:setVisible(t_highlight['incubate'])
    -- vars['relationNotiSprite']:setVisible(t_highlight['relation'])
    vars['combineNotiSprite']:setVisible(t_highlight['combine'])
end

-------------------------------------
-- function click_mileageBtn
-------------------------------------
function UI_Hatchery:click_mileageBtn()
    local function finish_cb()
        self:refresh_mileage()
    end
    g_shopDataNew:openShopPopup('mileage', finish_cb)
end

-------------------------------------
-- function showNpc
-------------------------------------
function UI_Hatchery:showNpc()
    self.m_npcAnimator:setVisible(true)
end

-------------------------------------
-- function hideNpc
-------------------------------------
function UI_Hatchery:hideNpc()
    self.m_npcAnimator:setVisible(false)
end

-------------------------------------
-- function showMileage
-------------------------------------
function UI_Hatchery:showMileage()
    self.vars['mileageMenu']:setVisible(true)
end

-------------------------------------
-- function hideMileage
-------------------------------------
function UI_Hatchery:hideMileage()
    self.vars['mileageMenu']:setVisible(false)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_Hatchery:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)

    self.vars['eventInfoMenu']:setVisible(false)

    local is_summon_tab = (tab == 'summon')
    -- 전설 확률 2배 이벤트일 경우 해당 메뉴를 켜준다
    if (is_summon_tab == true) then
        -- 기존 핫타임
        local is_event_active = g_hotTimeData:isActiveEvent('event_legend_chance_up')
        if (is_event_active == true) then
            self.vars['eventInfoMenu']:setVisible(true)
            self.vars['timeLabel']:setString(g_hotTimeData:getEventRemainTimeTextDetail('event_legend_chance_up'))
            return
        end

        -- 핫타임(fevertime)
        local is_active = g_fevertimeData:isActiveFevertime_summonLegendUp()
        if (is_active == true) then
            self.vars['eventInfoMenu']:setVisible(true)
            self.vars['timeLabel']:setString(g_fevertimeData:getRemainTimeTextDetail_summonLegendUp())
            return
        end
    end
end
