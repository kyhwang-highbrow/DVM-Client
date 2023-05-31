local PARENT = UI

-------------------------------------
-- class UI_DragonMythReturnFullPopup
-------------------------------------
UI_DragonMythReturnFullPopup = class(PARENT, {
    m_didList = 'list<number>',
    m_dId = 'number',
    m_timestamp = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMythReturnFullPopup:init(did)
    local vars = self:load('event_dragon_myth_return.ui')
    self.m_dId = did
    self.m_timestamp = TablePickupSchedule:getInstance():getReturnTimeStampByDid(did)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMythReturnFullPopup:initUI()
    local vars = self.vars
    local t_dragon_data = {}
    local did = self.m_dId
    
--[[     local did = TableDragonSkin:getDragonSkinValue('did', item_id)
    local struct_dragon_exist = g_dragonsData:getBestDragonByDid(did) ]]

    t_dragon_data['did'] = did
    t_dragon_data['evolution'] = 3 --struct_dragon_exist and struct_dragon_exist['evolution'] or 3
    t_dragon_data['grade'] = 1
    t_dragon_data['dragon_skin'] = 0

    local struct_dragon = StructDragonObject(t_dragon_data)
    local attribute = struct_dragon:getAttr()

    do -- 스파인
	    local animator = AnimatorHelper:makeDragonAnimatorByTransform(struct_dragon)
	    vars['dragonNode']:addChild(animator.m_node)

        animator:changeAni('pose_1', false)
        animator:addAniHandler(function() animator:changeAni('idle', true) end)

        local action = cc.EaseExponentialOut:create(cc.MoveTo:create(0.8, cc.p(0, 0)))

        animator:setPositionY(-200)
        animator:runAction(action)
    end

    do -- 이름
        local dragon_name = TableDragon:getDragonName(did)
        local curr_time_millisec = ServerTime:getInstance():getCurrentTimestampMilliseconds()
        local desc = ServerTime:getInstance():timestampMillisecToDatestrExceptTime(self.m_timestamp * 1000)
        local wday = ServerTime:getInstance():getWeekDaySimpleStringFromTimeStampSec(self.m_timestamp)

        desc = string.gsub(desc, '-', '.')
        desc = desc .. '(' .. Str(wday) .. ')'

        vars['infoLabel']:setStringArg(desc, dragon_name)
        vars['titleLabel']:setStringArg(dragon_name)
    end
    

    do -- 배경
        local res_file = string.format('res/ui/event/bg_dragon_skin_%s.png', attribute)
        local animator = MakeAnimator(res_file)
        vars['bgNode']:removeAllChildren()
        vars['bgNode']:addChild(animator.m_node)
    end


    do -- 타이핑 효과

        local ready_func = function (letter)
            letter:setVisible(false)
        end

        local show_func = function (letter)
            letter:setVisible(true)
            letter:setScale(2.5)
            letter:stopAllActions()
            letter:runAction(cc.EaseExponentialOut:create(cc.ScaleTo:create(0.3, 1)))
        end

        local str = clone(vars['titleLabel']:getString())
        vars['titleLabel']:setString('')

        local typing_label = MakeTypingEffectLabel(vars['titleLabel'])

        typing_label:setDueTime(0.6)
        typing_label:setReadyFunc(ready_func)
        typing_label:setShowFunc(show_func)

        local function act_text()
            typing_label:setString(str)
            --typing_label.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(5.1), cc.FadeOut:create(0.2), cc.RemoveSelf:create()))
        end

        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function() act_text() end)))
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonMythReturnFullPopup:initButton()
    local vars = self.vars
    --vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMythReturnFullPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_DragonMythReturnFullPopup:click_rewardBtn()
    local vars = self.vars
end