local PARENT = UI

-------------------------------------
-- class UI_DragonEvolutionResult
-------------------------------------
UI_DragonEvolutionResult = class(PARENT, {
        m_dragon_object = '',
        m_dragon_animator = '',
     })

local ZOOM_SCALE = 1.5
local ZOOM_TIME = 2.5

-------------------------------------
-- function init
-------------------------------------
function UI_DragonEvolutionResult:init(dragon_object)
    local vars = self:load('dragon_evolution_result.ui')
    UIManager:open(self, UIManager.SCENE)

    self:sceneFadeInAction()

    -- @UI_ACTION
    self:doActionReset()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonEvolutionResult')
    -- 백키 블럭
    UIManager:blockBackKey(true)

    vars['skipBtn']:registerScriptTapHandler(function() self:click_skipBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

    self:setResultText(dragon_object)
    self:showEvolutionEffect(dragon_object)

    SoundMgr:playBGM('ui_dragon_evolution', false)
end

-------------------------------------
-- function setResultText
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonEvolutionResult:setResultText(dragon_object)
    local vars = self.vars

    local doid = dragon_object['id']
    local evolution = dragon_object['evolution']

    vars['dragonNameLabel']:setString(dragon_object:getDragonNameWithEclv())
    vars['beforeLabl']:setString(evolutionName(evolution - 1))
    vars['afterLabel']:setString(evolutionName(evolution))

    local status_calc = MakeOwnDragonStatusCalculator(doid, {['evolution'] = dragon_object['evolution'] - 1})
    vars['atkLabel1']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['defLabel1']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hpLabel1']:setString(status_calc:getFinalStatDisplay('hp'))

    local status_calc = MakeOwnDragonStatusCalculator(doid)
    vars['atkLabel2']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['defLabel2']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hpLabel2']:setString(status_calc:getFinalStatDisplay('hp'))
end

-------------------------------------
-- function showEvolutionEffect
-------------------------------------
function UI_DragonEvolutionResult:showEvolutionEffect(dragon_object)
    local vars = self.vars

    self.m_dragon_object = dragon_object

    local did = dragon_object['did']
    local evolution = dragon_object['evolution']

    -- vrp 줌 액션
    local zoom_action_func = function(node)
        local zoom_action = cc.ScaleTo:create(ZOOM_TIME, ZOOM_SCALE)
        local move_action = cc.MoveBy:create(ZOOM_TIME, cc.p(0, 150))
        local spawn_action = cc.Spawn:create(zoom_action, move_action)
        node:runAction(spawn_action)
    end

    -- 좌우 흔듬
    do
        local node = vars['shakeNode']
        local move_time = 0.5
        local level = 50
        local move_action = cc.Sequence:create(
            cc.DelayTime:create(0.5),
		    cc.MoveBy:create( move_time, cc.p(-level, 0) ),
		    cc.MoveBy:create( move_time, cc.p( level, 0) ),
            cc.MoveBy:create( move_time, cc.p( level, 0) ),
		    cc.MoveBy:create( move_time, cc.p(-level, 0) )
	    )
        node:runAction(move_action)
    end

    -- 배경 이펙트
    do
        local visual = vars['bg_visual']
        zoom_action_func(visual)
        local a1 = cc.DelayTime:create(4) 
        local a2 = cc.EaseIn:create(cc.MoveBy:create(1.2, cc.p(0, -1500)), 0.3)
        local action = cc.Sequence:create(a1, a2)
        visual:runAction(action)
    end

    -- 드래곤 하단 이펙트
    do 
        local visual = vars['evolutionVisual1']
        visual:setVisible(true)
        zoom_action_func(visual)
    end

    -- 드래곤 상단 이펙트
    do 
        local visual = vars['evolutionVisual2']
        visual:setVisible(true)
        visual:changeAni('idle_top', false)
        zoom_action_func(visual)

        visual:addAniHandler(function()
            visual:changeAni('idle', true)
        end)
    end

    -- 기존 드래곤
    do
        local dragon_node = vars['dragonNode']
        local dragon_animator = AnimatorHelper:makeDragonAnimator_usingDid(did, evolution-1)
        dragon_node:addChild(dragon_animator.m_node)

        local visual = dragon_animator.m_node
        zoom_action_func(visual)

        local delay_action = cc.DelayTime:create(3.5)
        local fade_action = cc.FadeOut:create(1)
        local action = cc.Sequence:create(delay_action, fade_action)
        visual:runAction(action)
    end

    self:showResult()
end

-------------------------------------
-- function showResult
-------------------------------------
function UI_DragonEvolutionResult:showResult(immediately)
    local vars = self.vars

    local dragon_node = vars['dragonNode']
    local dragon_object = self.m_dragon_object 

    local did = dragon_object['did']
    local evolution = dragon_object['evolution']

    local dragon_animator = AnimatorHelper:makeDragonAnimator_usingDid(did, evolution)
    dragon_node:addChild(dragon_animator.m_node)

    local visual = dragon_animator.m_node
    visual:setVisible(false)
    visual:setScale(ZOOM_SCALE)

    local delay_action1 = immediately and cc.DelayTime:create(0) or cc.DelayTime:create(6)

    -- 진화 드래곤 등장 
    local show_action1 = cc.CallFunc:create(function()
        vars['skipBtn']:setVisible(false)

        visual:setVisible(true)
        dragon_node:setPositionY(0)
        dragon_animator:changeAni('attack', false)
        dragon_animator:addAniHandler(function()
            dragon_animator:changeAni('idle', true)
        end)
    end)

    local delay_action2 = cc.DelayTime:create(0.5)

    -- 결과 메뉴 보여줌
    local show_action2 = cc.CallFunc:create(function()
			
		-- 백키 블럭 해제
		UIManager:blockBackKey(false)

        SoundMgr:playEffect('UI', 'ui_grow_result')
        self:doActionReset()
        self:doAction(nil, false)
    end)

    local action = cc.Sequence:create(delay_action1, show_action1,
                                        delay_action2, show_action2) 
    visual:runAction(action)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonEvolutionResult:click_exitBtn()
    self:fadeOutClose()
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UI_DragonEvolutionResult:click_skipBtn()
    local vars = self.vars 

    -- 페이드인 효과
    self:sceneFadeInAction(nil, nil, 1.0)

    do
        local node = vars['shakeNode']
        node:stopAllActions()
    end

    -- 배경 이펙트
    do
        local visual = vars['bg_visual']
        visual:stopAllActions()
    end

    -- 드래곤 하단 이펙트
    do 
        local visual = vars['evolutionVisual1']
        visual:stopAllActions()
    end

    -- 드래곤 상단 이펙트
    do 
        local visual = vars['evolutionVisual2']
        visual:stopAllActions()
        visual:changeAni('idle', true)
    end

    local dragon_node = vars['dragonNode']
    dragon_node:removeAllChildren()

    local immediately = true
    self:showResult(immediately)
end

-------------------------------------
-- function fadeOutClose
-------------------------------------
function UI_DragonEvolutionResult:fadeOutClose()
    -- @ MASTER ROAD
    local t_data = {clear_key = 'd_evup'}
    g_masterRoadData:updateMasterRoad(t_data)

    self:sceneFadeOutAction(function() 
        SoundMgr:playPrevBGM()
        self:close() 
    end)
end