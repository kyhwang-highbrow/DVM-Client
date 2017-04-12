local PARENT = UI

-------------------------------------
-- class UI_DragonExceedResult
-------------------------------------
UI_DragonExceedResult = class(PARENT,{
        m_tDragonData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonExceedResult:init(t_dragon_data)
    self.m_tDragonData = t_dragon_data

    local vars = self:load('transcend_result.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonExceedResult')

    self:initUI()
    self:initButton()
    self:refresh()

    SoundMgr:playEffect('EFFECT', 'success_starup')

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonExceedResult:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonExceedResult:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonExceedResult:refresh()
    local vars = self.vars

    local t_dragon_data = self.m_tDragonData
    local did = t_dragon_data['did']

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[did]
    
    do -- 드래곤 에니메이터
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'], t_dragon['attr'])
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator:setScale(1)
        vars['dragonNode']:removeAllChildren()
        vars['dragonNode']:addChild(animator.m_node)
    end

    do -- 등급 별 표시
        local eclv = t_dragon_data['eclv']
        local ani = string.format('eclv_%.2d', eclv)
        vars['starVisual']:changeAni(ani)
    end

    do -- 드래곤 이름
        vars['dragonNameLabel']:setString(t_dragon_data:getDragonNameWithEclv())
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_DragonExceedResult:click_closeBtn()
    local function func()
        self:close()
    end
    self:sceneFadeOutAndCallFunc(func)
end

--@CHECK
UI:checkCompileError(UI_DragonExceedResult)
