local PARENT = UI_DragonChangeResult

-------------------------------------
-- class UI_DragonEvolutionResult
-------------------------------------
UI_DragonTransformChangeResult = class(PARENT, {})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonTransformChangeResult:init(dragon_data, before_evolution)
    local vars = self:load('dragon_transform_result.ui')
    UIManager:open(self, UIManager.SCENE)

    self:sceneFadeInAction()

    -- @UI_ACTION
    self:doActionReset()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonTransformChangeResult')
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
function UI_DragonTransformChangeResult:setResultText(struct_dragon_data)
    local vars = self.vars

    local before = self.m_before_evolution
    local after = struct_dragon_data['transform']

    vars['dragonNameLabel']:setString(struct_dragon_data:getDragonNameWithEclv())
    vars['beforeLabl']:setString(evolutionName(before))
    vars['afterLabel']:setString(evolutionName(after))
end