local PARENT = UI

-------------------------------------
-- class UI_DragonEvolutionResult
-------------------------------------
UI_DragonEvolutionResult = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonEvolutionResult:init(dragon_object)
    local vars = self:load('dragon_evolution_result.ui')
    UIManager:open(self, UIManager.SCENE)

    self:sceneFadeInAction()

    -- @UI_ACTION
    self:doActionReset()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonEvolutionResult')

    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

    self:refresh(dragon_object)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonEvolutionResult:click_exitBtn()
    self:close()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonEvolutionResult:refresh(dragon_object)
    local vars = self.vars
    SoundMgr:playEffect('EFFECT', 'reward')

    local did = dragon_object['did']
    local grade = dragon_object['grade']
    local evolution = dragon_object['evolution']

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[did]
    
    -- 배경
    local attr = TableDragon:getDragonAttr(did)
    if self:checkVarsKey('bgNode', attr) then
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    -- 이름
    vars['dragonNameLabel']:setString(dragon_object:getDragonNameWithEclv())

    -- 드래곤 에니메이터
    if vars['dragonNode'] then
        local dragon_animator = UIC_DragonAnimatorDirector()
        vars['dragonNode']:addChild(dragon_animator.m_node)
        dragon_animator:setDragonAnimator(dragon_object['did'], dragon_object['evolution'], dragon_object['friendship']['flv'])
        local function cb()
            self:doAction(nil, false)
        end
        dragon_animator:setDragonAppearCB(cb)
		dragon_animator:startDirecting()
    end

    -- 진화 단계 텍스트
    vars['beforeLabl']:setString(evolutionName(evolution - 1))
    vars['afterLabel']:setString(evolutionName(evolution))

    self:refresh_status(dragon_object)
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonEvolutionResult:refresh_status(dragon_object)
    local vars = self.vars

    local doid = dragon_object['id']

    local status_calc = MakeOwnDragonStatusCalculator(doid, {['evolution'] = dragon_object['evolution'] - 1})
    vars['atkLabel1']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['defLabel1']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hpLabel1']:setString(status_calc:getFinalStatDisplay('hp'))

    local status_calc = MakeOwnDragonStatusCalculator(doid)
    vars['atkLabel2']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['defLabel2']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hpLabel2']:setString(status_calc:getFinalStatDisplay('hp'))
end