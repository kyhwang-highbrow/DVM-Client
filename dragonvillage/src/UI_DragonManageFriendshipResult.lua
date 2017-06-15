local PARENT = UI

-------------------------------------
-- class UI_DragonManageFriendshipResult
-------------------------------------
UI_DragonManageFriendshipResult = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageFriendshipResult:init(dragon_object)
    local vars = self:load('dragon_friendship_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self:sceneFadeInAction()

    -- @UI_ACTION
    self:doActionReset()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManageFriendshipResult')

    self:initUI()
    self:initButton()
    self:refresh(dragon_object)

    SoundMgr:playEffect('UI', 'ui_grow_result')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonManageFriendshipResult:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonManageFriendshipResult:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonManageFriendshipResult:refresh(dragon_object)
    local vars = self.vars

    -- 배경
    local attr = TableDragon:getDragonAttr(dragon_object['did'])
    if self:checkVarsKey('bgNode', attr) then
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end


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

    local friendship_obj = dragon_object:getFriendshipObject()
    local t_friendship_info = friendship_obj:getFriendshipInfo()

    vars['conditionInfoLabel']:setString(t_friendship_info['desc'])

    local flv = friendship_obj['flv']

    vars['conditionLabel1']:setString(TableFriendship:getFriendshipName(flv - 1))
    vars['emoticonNode1']:addChild(TableFriendship:getFriendshipIcon(flv - 1))

    vars['conditionLabel2']:setString(TableFriendship:getFriendshipName(flv))
    vars['emoticonNode2']:addChild(TableFriendship:getFriendshipIcon(flv))
end

--@CHECK
UI:checkCompileError(UI_DragonManageFriendshipResult)
