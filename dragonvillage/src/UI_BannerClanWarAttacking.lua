local PARENT = UI

-------------------------------------
-- class UI_BannerClanWarAttacking
-------------------------------------
UI_BannerClanWarAttacking = class(PARENT,{
		m_attack_uid = 'string',
		m_enddate = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BannerClanWarAttacking:init(attacking_uid, end_date)
    self.m_uiName = 'UI_BannerClanWarAttacking'
    local vars = self:load('lobby_banner_clan_war.ui')

	self.m_attack_uid = attacking_uid
	self.m_enddate = end_date

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()

	self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BannerClanWarAttacking:initUI()
    local vars = self.vars
	vars['attackLabel']:setString(Str('공격 중'))

    -- 배너 UI가 여러 상태일 수 있다. 각 상태에 맞는 menu만 활성화 시킨다.
    local curr_state = 1
    for i=1, 10 do
        local menu = vars['stateMenu' .. i]
        if menu then
            menu:setVisible(i == curr_state)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BannerClanWarAttacking:initButton()
    local vars = self.vars
    vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end

-------------------------------------
-- function update
-------------------------------------
function UI_BannerClanWarAttacking:update()
	local vars = self.vars
	local end_time = self.m_enddate

    if (not end_time) then
        vars['timeLabel']:setString('')
        return
    end

    -- 공격 끝날 때 까지 남은 시간 = 공격 시작 시간 + 1시간
    local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    local remain_time = (end_time - cur_time)
    if (remain_time > 0) then
        vars['timeLabel']:setString(datetime.makeTimeDesc_timer_filledByZero(remain_time))
    else
        vars['timeLabel']:setString('')
    end
end


-------------------------------------
-- function click_bannerBtn
-------------------------------------
function UI_BannerClanWarAttacking:click_bannerBtn()
    UINavigatorDefinition:goTo('clan_war')
end

