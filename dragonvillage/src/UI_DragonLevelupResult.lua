local PARENT = UI

-------------------------------------
-- class UI_DragonLevelupResult
-------------------------------------
UI_DragonLevelupResult = class(PARENT, {
        m_prevLv = 'number',
        m_prevExp = 'number',
        m_bonusRate = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLevelupResult:init(dragon_object, prev_lv, prev_exp, bonus_rate)
    local vars = self:load('dragon_levelup_result.ui')
    UIManager:open(self, UIManager.SCENE)

    self:sceneFadeInAction()

    -- @UI_ACTION
    self:doActionReset()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonLevelupResult')

    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

    self.m_prevLv = prev_lv
    self.m_prevExp = prev_exp
    self.m_bonusRate = bonus_rate

    self:initUI(dragon_object)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonLevelupResult:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLevelupResult:initUI(dragon_object)
    local vars = self.vars

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
                self:direct_levelup(dragon_object)
            end
            self:doAction(after_appear, false)
			SoundMgr:playEffect('UI', 'ui_grow_result')
        end
        dragon_animator:setDragonAppearCB(cb)
        local direct_result = true
		dragon_animator:startDirecting(direct_result)
    end

    -- 이전 경험치와 레벨 미리 표시
    local grade = (dragon_object['grade'] or 1)
    local lv = self.m_prevLv
    local exp = (dragon_object['exp'] or 0)
    local table_exp = TableDragonExp()
    local max_exp = table_exp:getDragonMaxExp(grade, lv)
    local percentage = (exp / max_exp) * 100
    percentage = math_floor(percentage)
    vars['expLabel']:setString(Str('{1}%', percentage))
    vars['expGauge']:setPercentage(percentage)
    vars['beforeLabel']:setString(Str('Lv.{1}', lv))
    vars['afterLabel']:setString(Str('Lv.{1}', lv))

    -- numberLabel 로 변환
    vars['atkLabel1'] = NumberLabel(vars['atkLabel1'], 0, 0.3)
    vars['defLabel1'] = NumberLabel(vars['defLabel1'], 0, 0.3)
    vars['hpLabel1'] = NumberLabel(vars['hpLabel1'], 0, 0.3)
    vars['atkLabel2'] = NumberLabel(vars['atkLabel2'], 0, 0.3)
    vars['defLabel2'] = NumberLabel(vars['defLabel2'], 0, 0.3)
    vars['hpLabel2'] = NumberLabel(vars['hpLabel2'], 0, 0.3)

    -- 이전 status 표시
    local doid = dragon_object['id']
    local status_calc = MakeOwnDragonStatusCalculator(doid, {['lv'] = lv})
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
function UI_DragonLevelupResult:refresh_status(dragon_object, lv)
    local vars = self.vars

    local doid = dragon_object['id']
    local status_calc = MakeOwnDragonStatusCalculator(doid, {['lv'] = lv})
    vars['atkLabel2']:setNumber(status_calc:getFinalStat('atk'))
    vars['defLabel2']:setNumber(status_calc:getFinalStat('def'))
    vars['hpLabel2']:setNumber(status_calc:getFinalStat('hp'))
end

-------------------------------------
-- function direct_levelup
-- @brief 레벨업 연출
-------------------------------------
function UI_DragonLevelupResult:direct_levelup(dragon_object)
    local vars = self.vars
    
    local prev_lv = self.m_prevLv
    local prev_exp = self.m_prevExp
    local bonus_rate = self.m_bonusRate

    local grade = (dragon_object['grade'] or 1)
    local dest_lv = (dragon_object['lv'] or 1)
    local dest_exp = (dragon_object['exp'] or 0)

    -- 경험치 연출 도우미
    local levelup_director = LevelupDirector(prev_lv, prev_exp, dest_lv, dest_exp, 'dragon', grade, self.root)

    levelup_director.m_cbUpdate = function(lv, exp, percentage)
        vars['afterLabel']:setString(Str('Lv.{1}', lv))
        vars['expLabel']:setString(Str('{1}%', percentage))
        vars['expGauge']:setPercentage(percentage)
    end
    levelup_director.m_cbLevelUp = function(lv)
        self:refresh_status(dragon_object, lv)
        SoundMgr:playEffect('UI', 'ui_dragon_level_up')
    end
    levelup_director.m_cbMaxLevel = function()
        vars['expLabel']:setString(Str('최대레벨'))
        vars['expGauge']:stopAllActions()
        vars['expGauge']:setPercentage(100)
    end
    levelup_director:start()

    -- 보너스 대성공
    if (100 < bonus_rate) then
        vars['bonusVisual']:setVisible(true)
        vars['bonusVisual']:changeAni('success_' .. tostring(bonus_rate))
    end
end
