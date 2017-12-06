local PARENT = UI

-------------------------------------
-- class UI_DragonReinforceResult
-------------------------------------
UI_DragonReinforceResult = class(PARENT, {
        m_prevLv = 'number',
        m_prevExp = 'number',
        m_bonusRate = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonReinforceResult:init(t_dragon_data)
    local vars = self:load('dragon_reinforce_result.ui')
    UIManager:open(self, UIManager.SCENE)

    self:sceneFadeInAction()

    -- @UI_ACTION
    self:doActionReset()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonReinforceResult')

    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

    self.m_prevLv = prev_lv

    self:initUI(t_dragon_data)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonReinforceResult:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonReinforceResult:initUI(t_dragon_data)
    local vars = self.vars

	local dragon_object = StructDragonObject(t_dragon_data)
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
            local function after_appear()
                self:refresh_status(dragon_object)
            end
            self:doAction(after_appear, false)
			SoundMgr:playEffect('UI', 'ui_grow_result')
        end
        dragon_animator:setDragonAppearCB(cb)
        local direct_result = true
		dragon_animator:startDirecting(direct_result)
    end

	 -- 이전 경험치와 레벨 미리 표시
    local lv = dragon_object:getRlv()
	local icon = IconHelper:getDragonReinforceIcon(lv)
    vars['beforeNode']:addChild(icon)
	local icon = IconHelper:getDragonReinforceIcon(lv)
    vars['afterNode']:addChild(icon)

    -- numberLabel 로 변환
    vars['atkLabel1'] = NumberLabel(vars['atkLabel1'], 0, 0.3)
    vars['defLabel1'] = NumberLabel(vars['defLabel1'], 0, 0.3)
    vars['hpLabel1'] = NumberLabel(vars['hpLabel1'], 0, 0.3)
    vars['atkLabel2'] = NumberLabel(vars['atkLabel2'], 0, 0.3)
    vars['defLabel2'] = NumberLabel(vars['defLabel2'], 0, 0.3)
    vars['hpLabel2'] = NumberLabel(vars['hpLabel2'], 0, 0.3)

    -- 이전 status 표시
	local t_prev_data = clone(dragon_object)
	t_prev_data['reinforce']['lv'] = lv - 1
    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_prev_data)
    local atk = status_calc:getFinalStat('atk')
    local def = status_calc:getFinalStat('def')
    local hp = status_calc:getFinalStat('hp')
    vars['atkLabel1']:setNumber(atk)
    vars['defLabel1']:setNumber(def)
    vars['hpLabel1']:setNumber(hp)
    vars['atkLabel2']:setNumber(atk)
    vars['defLabel2']:setNumber(def)
    vars['hpLabel2']:setNumber(hp)
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonReinforceResult:refresh_status(dragon_object)
    local vars = self.vars

    local doid = dragon_object['id']
    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(dragon_object)
    vars['atkLabel2']:setNumber(status_calc:getFinalStat('atk'))
    vars['defLabel2']:setNumber(status_calc:getFinalStat('def'))
    vars['hpLabel2']:setNumber(status_calc:getFinalStat('hp'))
end
