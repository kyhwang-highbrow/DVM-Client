local PARENT = UI

-------------------------------------
-- class UI_DragonMasteryLevelUp_Result
-------------------------------------
UI_DragonMasteryLevelUp_Result = class(PARENT,{
		m_dragonObject = 'StructDragonObject',
        m_prevLevel = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMasteryLevelUp_Result:init(dragon_object, prev_lv)
    local vars = self:load('dragon_mastery_lvup_result.ui')
    self.m_prevLevel = prev_lv
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonMasteryLevelUp_Result')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- initialize
	self.m_dragonObject = dragon_object

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMasteryLevelUp_Result:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonMasteryLevelUp_Result:initButton()
	self.vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMasteryLevelUp_Result:refresh()
    local vars = self.vars
    local dragon_object = self.m_dragonObject 


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
                --self:direct_levelup(dragon_object)
            end
            self:doAction(after_appear, false)
			SoundMgr:playEffect('UI', 'ui_grow_result')
        end
        dragon_animator:setDragonAppearCB(cb)
        local direct_result = true
		dragon_animator:startDirecting(direct_result)
    end

    -- 레벨 표시
    local mastery_level = dragon_object:getMasteryLevel()
    local is_first = (mastery_level == 1)

    vars['beforeLabel1']:setVisible(is_first)
    vars['beforeLabel2']:setVisible(not is_first)

    vars['beforeLabel2']:setString(Str('Lv.{1}', self.m_prevLevel or (mastery_level-1)))
    vars['afterLabel']:setString(Str('Lv.{1}', mastery_level))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonMasteryLevelUp_Result:click_exitBtn()
    self:close()
end
