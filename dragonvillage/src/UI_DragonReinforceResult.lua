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
                --self:direct_levelup(dragon_object)
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
    vars['beforeLabel']:setString(string.format('+ %d', lv - 1))
    vars['afterLabel']:setString(string.format('+ %d', lv))

end
