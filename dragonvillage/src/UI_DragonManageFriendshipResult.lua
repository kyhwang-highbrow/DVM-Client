local PARENT = UI

-------------------------------------
-- class UI_DragonManageFriendshipResult
-------------------------------------
UI_DragonManageFriendshipResult = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonManageFriendshipResult:init(pre_dragon_object, cur_dragon_object)
    local vars = self:load('dragon_friendship_result.ui')
    UIManager:open(self, UIManager.POPUP)

    self:sceneFadeInAction()

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonManageFriendshipResult')

    self:initUI()
    self:initButton()
    self:refresh(pre_dragon_object, cur_dragon_object)

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
function UI_DragonManageFriendshipResult:refresh(pre_dragon_object, cur_dragon_object)
    local vars = self.vars

    -- 배경
    local dragon_object = cur_dragon_object
    local attr = TableDragon:getDragonAttr(dragon_object['did'])
    if self:checkVarsKey('bgNode', attr) then
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    local pre_friendship_obj = pre_dragon_object:getFriendshipObject()
    local friendship_obj = dragon_object:getFriendshipObject()
    local t_friendship_info = friendship_obj:getFriendshipInfo()

    vars['conditionInfoLabel']:setString(t_friendship_info['desc'])

    local flv = friendship_obj['flv']

    local pre_info = friendship_obj:getFriendshipInfo(flv-1)

    vars['conditionLabel1']:setString(TableFriendship:getFriendshipName(flv - 1))
    vars['conditionLabel1']:setColor(TableFriendship:getTextColorWithFlv(flv - 1))
    vars['emoticonNode1']:addChild(TableFriendship:getFriendshipIcon(flv - 1))

    vars['conditionLabel2']:setString(TableFriendship:getFriendshipName(flv))
    vars['conditionLabel2']:setColor(TableFriendship:getTextColorWithFlv(flv))
    vars['emoticonNode2']:addChild(TableFriendship:getFriendshipIcon(flv))

    -- 다음 단계도 보여줌
    if (flv + 2 <= FRIENDSHIP_MAX_LV) then
        vars['conditionLabel3']:setString(TableFriendship:getFriendshipName(flv + 1))
        vars['conditionLabel3']:setColor(TableFriendship:getTextColorWithFlv(flv + 1))
        vars['emoticonNode3']:addChild(TableFriendship:getFriendshipIcon(flv + 1))
    else
        vars['emotionSprite3']:setVisible(false)
    end

    -- 친밀도 보너스 표시
    do 
        local pre_atk = pre_friendship_obj['fatk']
        local pre_def = pre_friendship_obj['fdef']
        local pre_hp = pre_friendship_obj['fhp']

        local cur_atk = friendship_obj['fatk']
        local cur_def = friendship_obj['fdef']
        local cur_hp = friendship_obj['fhp']

        local max_atk = t_friendship_info['atk_max']
        local max_def = t_friendship_info['def_max']
        local max_hp = t_friendship_info['hp_max']

        vars['atkLabel1']:setString(Str('{1}/{2}', comma_value(cur_atk), comma_value(max_atk)))
        vars['defLabel1']:setString(Str('{1}/{2}', comma_value(cur_def), comma_value(max_def)))
        vars['hpLabel1']:setString(Str('{1}/{2}', comma_value(cur_hp), comma_value(max_hp)))

        vars['atkLabel2']:setString(Str('{1}', comma_value(cur_atk - pre_atk)))
        vars['defLabel2']:setString(Str('{1}', comma_value(cur_def - pre_def)))
        vars['hpLabel2']:setString(Str('{1}', comma_value(cur_hp - pre_hp)))

        vars['atkGauge']:setPercentage((pre_atk/max_atk) * 100)
        vars['defGauge']:setPercentage((pre_def/max_def) * 100)
        vars['hpGauge']:setPercentage((pre_hp/max_hp) * 100)

        local function gauge_act_func(node, cur_per)
            node:runAction(cc.EaseElasticOut:create(cc.ProgressTo:create(2, cur_per * 100), 1.5))
        end

        -- bar animation
        local visual = vars['barVisual']
        visual:setVisible(true)
        visual:changeAni('bar', false)
        visual:addAniHandler(function()
            gauge_act_func(vars['atkGauge'], cur_atk/max_atk)
            gauge_act_func(vars['defGauge'], cur_def/max_def)
            gauge_act_func(vars['hpGauge'], cur_hp/max_hp)
        end) 
    end
end

--@CHECK
UI:checkCompileError(UI_DragonManageFriendshipResult)
