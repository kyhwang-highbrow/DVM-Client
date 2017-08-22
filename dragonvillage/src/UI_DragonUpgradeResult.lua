local PARENT = UI

-------------------------------------
-- class UI_DragonUpgradeResult
-------------------------------------
UI_DragonUpgradeResult = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonUpgradeResult:init(dragon_object)
    local vars = self:load('dragon_upgrade_result.ui')
    UIManager:open(self, UIManager.SCENE)

    self:sceneFadeInAction()

    -- @UI_ACTION
    self:doActionReset()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonUpgradeResult')
    -- 백키 블럭
    UIManager:blockBackKey(true)

    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)

    self:refresh(dragon_object)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonUpgradeResult:click_exitBtn()
    self:close()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonUpgradeResult:refresh(dragon_object)
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

    vars['starVisual']:setVisible(false)

    -- 드래곤 에니메이터
    if vars['dragonNode'] then
        local dragon_animator = UIC_DragonAnimatorDirector()
        vars['dragonNode']:addChild(dragon_animator.m_node)
        dragon_animator:setDragonAnimator(dragon_object['did'], dragon_object['evolution'], dragon_object['friendship']['flv'])
        local function cb()
            -- 액션 후 백키 블럭 해제
            self:doAction(function() UIManager:blockBackKey(false) end, false)
			SoundMgr:playEffect('UI', 'ui_star_up')
            
            -- @ MASTER ROAD
            local t_data = {clear_key = 'd_grup'}
            g_masterRoadData:updateMasterRoad(t_data)

            -- 등급 비주얼
            vars['starVisual']:setVisible(true)
            local ani_name = TableDragon:getStarAniName(did, evolution)
            ani_name = ani_name .. grade
			vars['starVisual']:changeAni(ani_name)
        end
        dragon_animator:setDragonAppearCB(cb)
		dragon_animator:startDirecting()
    end

    self:refresh_status(dragon_object)
end

-------------------------------------
-- function refresh_status
-- @brief 능력치 정보 갱신
-------------------------------------
function UI_DragonUpgradeResult:refresh_status(dragon_object)
    local vars = self.vars

    local doid = dragon_object['id']

    local chaged_dragon_data = {}
    chaged_dragon_data['grade'] = (dragon_object['grade'] - 1)
    chaged_dragon_data['lv'] = TableGradeInfo:getMaxLv(chaged_dragon_data['grade'])

    local status_calc = MakeOwnDragonStatusCalculator(doid, chaged_dragon_data)
    vars['atkLabel1']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['defLabel1']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hpLabel1']:setString(status_calc:getFinalStatDisplay('hp'))

    local status_calc = MakeOwnDragonStatusCalculator(doid)
    vars['atkLabel2']:setString(status_calc:getFinalStatDisplay('atk'))
    vars['defLabel2']:setString(status_calc:getFinalStatDisplay('def'))
    vars['hpLabel2']:setString(status_calc:getFinalStatDisplay('hp'))
end