local PARENT = UI

-------------------------------------
-- class UI_DragonLevelupResult
-------------------------------------
UI_DragonLevelupResult = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLevelupResult:init(dragon_object, prev_lv)
    local vars = self:load('dragon_levelup_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self:sceneFadeInAction()

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonLevelupResult')

    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

    self:refresh(dragon_object, prev_lv)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonLevelupResult:click_exitBtn()
    self:close()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLevelupResult:refresh(dragon_object, prev_lv)
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
        local dragon_animator = UIC_DragonAnimator()
        dragon_animator:setTalkEnable(false)
        vars['dragonNode']:addChild(dragon_animator.m_node)
        dragon_animator:setDragonAnimator(dragon_object['did'], dragon_object['evolution'], dragon_object['friendship']['flv'])
    end

    -- 레벨 표시
    vars['beforeLabel']:setString(Str('Lv.{1}', prev_lv))
    vars['afterLabel']:setString(Str('Lv.{1}', dragon_object['lv']))

    do -- 경혐치 exp
        local grade = (dragon_object['grade'] or 1)
        local eclv = (dragon_object['eclv'] or 0)
        local lv = (dragon_object['lv'] or 1)
        local exp = (dragon_object['exp'] or 0)
        local table_exp = TableDragonExp()
        local max_exp = table_exp:getDragonMaxExp(grade, lv)
        local is_max_lv = TableGradeInfo:isMaxLevel(grade, eclv, lv)

        if (not is_max_lv) then
            local percentage = (exp / max_exp) * 100
            percentage = math_floor(percentage)
            vars['expLabel']:setString(Str('{1}%', percentage))

            vars['expGauge']:stopAllActions()
            vars['expGauge']:setPercentage(0)
            vars['expGauge']:runAction(cc.ProgressTo:create(0.2, percentage)) 
        else
            vars['expLabel']:setString(Str('최대레벨'))
            vars['expGauge']:stopAllActions()
            vars['expGauge']:setPercentage(100)
        end
    end

    self:refresh_status(dragon_object, prev_lv)
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonLevelupResult:refresh_status(dragon_object, prev_lv)
    local vars = self.vars

    local doid = dragon_object['id']

    local status_calc = MakeOwnDragonStatusCalculator(doid, {['lv'] = prev_lv})
    vars['atkLabel1']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['defLabel1']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hpLabel1']:setString(status_calc:getFinalStatDisplay('hp'))

    local status_calc = MakeOwnDragonStatusCalculator(doid)
    vars['atkLabel2']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['defLabel2']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hpLabel2']:setString(status_calc:getFinalStatDisplay('hp'))
end