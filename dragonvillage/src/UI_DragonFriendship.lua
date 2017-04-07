local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonFriendship
-------------------------------------
UI_DragonFriendship = class(PARENT,{
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonFriendship:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonFriendship'
    self.m_bVisible = true or false
    self.m_titleStr = Str('친밀도') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonFriendship:init(doid)
    local vars = self:load('dragon_management_friendship.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonFriendship')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 정렬 도우미
    self:init_dragonSortMgr()

    -- 첫 선택 드래곤 지정
    self:setDefaultSelectDragon(doid)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonFriendship:initUI()
    local vars = self.vars
    self:init_dragonTableView()

    vars['heartNumberLabel'] = NumberLabel_Percent(vars['heartLabel'])

    vars['fruitNumberLabel1'] = NumberLabel(vars['fruitLabel1'], 0, 0.3)
    vars['fruitNumberLabel2'] = NumberLabel(vars['fruitLabel2'], 0, 0.3)
    vars['fruitNumberLabel3'] = NumberLabel(vars['fruitLabel3'], 0, 0.3)
    vars['fruitNumberLabel4'] = NumberLabel(vars['fruitLabel4'], 0, 0.3)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonFriendship:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-- @brief 선택된 드래곤이 변경되었을 때 호출
-------------------------------------
function UI_DragonFriendship:refresh()

    local t_dragon_data = self.m_selectDragonData

    if (not t_dragon_data) then
        return
    end

    local vars = self.vars
    -- 드래곤 테이블
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]
    local did = t_dragon_data['did']

    -- 배경
    local attr = TableDragon:getDragonAttr(did)
    if self:checkVarsKey('bgNode', attr) then
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    do -- 드래곤 리소스
        local evolution = t_dragon_data['evolution']
        vars['dragonNode']:removeAllChildren()
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, t_dragon['attr'])
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        animator:changeAni('idle', true)

        vars['dragonNode']:addChild(animator.m_node)
    end

    self:refreshFruits(attr)

    self:setHeartGauge(80)
end

-------------------------------------
-- function setHeartGauge
-- @brief
-------------------------------------
function UI_DragonFriendship:setHeartGauge(percentage, b_init)
    local vars = self.vars
    if b_init then
        vars['heartNumberLabel']:setNumber(0, true)
        vars['heartGauge']:setPercentage(0)
    end
    vars['heartNumberLabel']:setNumber(percentage)
    vars['heartGauge']:stopAllActions()
    vars['heartGauge']:runAction(cc.EaseElasticOut:create(cc.ProgressTo:create(1, percentage), 1.5))
end

-------------------------------------
-- function refreshFruits
-- @brief
-------------------------------------
function UI_DragonFriendship:refreshFruits(attr)
    local vars = self.vars

    local l_fruit_list = TableItem:getFruitsListByAttr(attr)

    for i=1, 4 do
        local fid = l_fruit_list[i]['item']
        vars['fruitNode' .. i]:removeAllChildren()
        local icon = IconHelper:getItemIcon(fid)
        vars['fruitNode' .. i]:addChild(icon)

        icon:setScale(0)
        icon:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.025), cc.EaseElasticOut:create(cc.ScaleTo:create(1, 1, 1), 0.3)))


        local count = g_userData:getFruitCount(fid)
        vars['fruitNumberLabel' .. i]:setNumber(count)
    end
    --[[
    fruitBtn1

    fruitNode1
    fruitNode1
    fruitNode1
    fruitNode1

    fruitLabel1
    fruitLabel2
    fruitLabel3
    fruitLabel4
    --]]
end

--@CHECK
UI:checkCompileError(UI_DragonFriendship)
