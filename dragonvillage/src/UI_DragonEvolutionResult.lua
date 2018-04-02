local PARENT = UI_DragonChangeResult

-------------------------------------
-- class UI_DragonEvolutionResult
-------------------------------------
UI_DragonEvolutionResult = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonEvolutionResult:init(dragon_data, before_evolution)
    local vars = self:load('dragon_evolution_result.ui')
    UIManager:open(self, UIManager.SCENE)

    self:sceneFadeInAction()

    -- @UI_ACTION
    self:doActionReset()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonEvolutionResult')
    -- 백키 블럭
    UIManager:blockBackKey(true)

    self:initButton()

    local struct_dragon_data = self.m_dragon_data
    self:setResultText(struct_dragon_data)
    self:showEvolutionEffect(struct_dragon_data)

    SoundMgr:playBGM('ui_dragon_evolution', false)
end

-------------------------------------
-- function setResultText
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonEvolutionResult:setResultText(struct_dragon_data)
    local vars = self.vars

    local doid = struct_dragon_data['id']
    local evolution = struct_dragon_data['evolution']

    vars['dragonNameLabel']:setString(struct_dragon_data:getDragonNameWithEclv())
    vars['beforeLabl']:setString(evolutionName(evolution - 1))
    vars['afterLabel']:setString(evolutionName(evolution))

    local status_calc = MakeOwnDragonStatusCalculator(doid, {['evolution'] = struct_dragon_data['evolution'] - 1})
    vars['atkLabel1']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['defLabel1']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hpLabel1']:setString(status_calc:getFinalStatDisplay('hp'))

    local status_calc = MakeOwnDragonStatusCalculator(doid)
    vars['atkLabel2']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['defLabel2']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hpLabel2']:setString(status_calc:getFinalStatDisplay('hp'))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonChangeResult:click_exitBtn()
    -- @ MASTER ROAD
    local t_data = {clear_key = 'd_evup'}
    g_masterRoadData:updateMasterRoad(t_data)

    self:fadeOutClose()
end