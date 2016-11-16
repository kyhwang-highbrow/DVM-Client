local PARENT = UI

-------------------------------------
-- class UI_DragonManageInfoView
-------------------------------------
UI_DragonManageInfoView = class(PARENT, {
        m_lDragonID = 'lsit',
        m_currIdx = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageInfoView:init(l_dragon_id_list, idx)
    self.m_lDragonID = l_dragon_id_list
    self.m_currIdx = idx

    local vars = self:load('dragon_management_info_view.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManageInfoView')

    self:initUI()
    self:initButton()
    self:refresh()

    local swipe = Camera_LobbySwipe(self.root, function(type) self:onSwipeEvent(type) end)
    swipe.m_sensitivity = 0.025

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManageInfoView:initUI()

end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManageInfoView:initButton()
    local vars = self.vars
    vars['prevDragonBtn']:registerScriptTapHandler(function() self:onSwipeEvent('right') end)
    vars['nextDragonBtn']:registerScriptTapHandler(function() self:onSwipeEvent('left') end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageInfoView:refresh()
    if (not self.m_lDragonID) then
        return
    end

    local idx = (self.m_currIdx or 1)
    self.m_currIdx = idx

    local dragon_id = self.m_lDragonID[idx]
    local vars = self.vars

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    do
        vars['nameLabel']:setString(Str(t_dragon['t_name']))
    end

    do
        vars['hatchNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], 1, t_dragon['attr'])
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['hatchNode']:addChild(animator.m_node)

        animator:changeAni('pose_1', false)
        animator:addAniHandler(function() animator:changeAni('idle', true) end)
    end

    do
        vars['hatchlingNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], 2, t_dragon['attr'])
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['hatchlingNode']:addChild(animator.m_node)

        animator:changeAni('pose_1', false)
        animator:addAniHandler(function() animator:changeAni('idle', true) end)
    end

    do
        vars['adultNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], 3, t_dragon['attr'])
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['adultNode']:addChild(animator.m_node)

        animator:changeAni('pose_1', false)
        animator:addAniHandler(function() animator:changeAni('idle', true) end)
    end

    self:refresh_navigation()
end

-------------------------------------
-- function refresh_navigation
-------------------------------------
function UI_DragonManageInfoView:refresh_navigation()
    local vars = self.vars


    local left_did = self.m_lDragonID[self.m_currIdx - 1]
    if left_did then
        vars['prevDragonBtn']:setVisible(true)    
        vars['prevDragonNode']:removeAllChildren()
        local icon = MakeSimpleDragonCard(left_did)
        icon.vars['clickBtn']:setEnabled(false)
        vars['prevDragonNode']:addChild(icon.root)
    else
        vars['prevDragonBtn']:setVisible(false)
    end

    local right_did = self.m_lDragonID[self.m_currIdx + 1]
    if right_did then
        vars['nextDragonBtn']:setVisible(true)    
        vars['nextDragonNode']:removeAllChildren()
        local icon = MakeSimpleDragonCard(right_did)
        icon.vars['clickBtn']:setEnabled(false)
        vars['nextDragonNode']:addChild(icon.root)
    else
        vars['nextDragonBtn']:setVisible(false)
    end
end

-------------------------------------
-- function onSwipeEvent
-------------------------------------
function UI_DragonManageInfoView:onSwipeEvent(type)

    -- idx 플러스
    if (type == 'left') then
        if (self.m_currIdx < #self.m_lDragonID) then
            self.m_currIdx = self.m_currIdx + 1
            self:refresh()
        end
    -- idx 마이너스
    elseif (type == 'right') then
        if (self.m_currIdx > 1) then
            self.m_currIdx = self.m_currIdx - 1
            self:refresh()
        end
    end
end

-------------------------------------
-- function tempGstarInit
-------------------------------------
function UI_DragonManageInfoView:tempGstarInit()
    self.m_lDragonID = {}
    table.insert(self.m_lDragonID, 120011) -- 파워 드래곤
    table.insert(self.m_lDragonID, 120021) -- 램곤
    table.insert(self.m_lDragonID, 120051) -- 애플칙
    table.insert(self.m_lDragonID, 120071) -- 스파인
    table.insert(self.m_lDragonID, 120081) -- 리프 드래곤
    table.insert(self.m_lDragonID, 120092) -- 테일 드래곤
    table.insert(self.m_lDragonID, 120142) -- 퍼플립스 드래곤
    table.insert(self.m_lDragonID, 120165) -- 티모벨
    table.insert(self.m_lDragonID, 120183) -- 이그블루 드래곤
    table.insert(self.m_lDragonID, 120193) -- 푸리티오
    table.insert(self.m_lDragonID, 120204) -- 라이케인
    table.insert(self.m_lDragonID, 120213) -- 가루다
    table.insert(self.m_lDragonID, 120273) -- 붐버
    table.insert(self.m_lDragonID, 120294) -- 고대 신룡
    table.insert(self.m_lDragonID, 120325) -- 크레센트 드래곤
    table.insert(self.m_lDragonID, 120335) -- 서펀트 드래곤

    self.m_currIdx = 1

    self:refresh()
end

--@CHECK
UI:checkCompileError(UI_DragonManageInfoView)
