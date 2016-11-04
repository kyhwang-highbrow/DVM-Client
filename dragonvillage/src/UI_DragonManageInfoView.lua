local PARENT = UI

-------------------------------------
-- class UI_DragonManageInfoView
-------------------------------------
UI_DragonManageInfoView = class(PARENT, {
        m_dragonID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageInfoView:init(dragon_id)
    self.m_dragonID = dragon_id

    local vars = self:load('dragon_management_info_view.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManageInfoView')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManageInfoView:initUI()
    local dragon_id = self.m_dragonID
    local vars = self.vars

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

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

end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonManageInfoView:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageInfoView:refresh()
end

--@CHECK
UI:checkCompileError(UI_DragonManageInfoView)
