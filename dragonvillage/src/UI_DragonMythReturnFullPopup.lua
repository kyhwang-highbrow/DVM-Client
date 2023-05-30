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
    self.m_timestamp = 0

    local t_dragon = TableDragon():get(did)
    local summon_start_date = t_dragon['summon_add']
    if summon_start_date ~= '' then
        if (string.find(summon_start_date, ':') == nil) then
            summon_start_date = summon_start_date .. ' 00:00:00'
        end
        self.m_timestamp = ServerTime:getInstance():datestrToTimestampSec(summon_start_date)
    end
    
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

-------------------------------------
-- function open
-------------------------------------
function UI_DragonMythReturnFullPopup.open(ower_ui)
    local did_list = {120431, 120432, 120433, 120434, 120435}

    if #did_list  == 0 then
        return nil
    else
        return UI_DragonMythReturnFullPopup(ower_ui, did_list)
    end
end