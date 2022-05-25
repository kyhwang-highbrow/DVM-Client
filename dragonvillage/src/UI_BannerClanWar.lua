local PARENT = UI

-------------------------------------
-- class UI_BannerClanWar
-------------------------------------
UI_BannerClanWar = class(PARENT,{
		m_attack_uid = 'string',
		m_enddate = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BannerClanWar:init(t_data, end_date)
    self.m_uiName = 'UI_BannerClanWar'
    local vars = self:load('lobby_banner_clan_war.ui')

	self.m_attack_uid = attacking_uid
	self.m_enddate = end_date
    --cclog('# self.m_enddate : ' .. tostring(self.m_enddate))

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(t_data, end_date)
    self:initButton()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-- @param t_data(table, my_match_info)
-- @param end_date(number, timestamp)
-------------------------------------
function UI_BannerClanWar:initUI(t_data, end_date)
    self.m_enddate = end_date

    local vars = self.vars

    -- 배너 UI가 여러 상태일 수 있다. 각 상태에 맞는 menu만 활성화 시킨다.
    local curr_state = 2
    for i=1, 10 do
        local menu = vars['stateMenu' .. i]
        if menu then
            menu:setVisible(i == curr_state)
        end
    end

    -- 초기화
    vars['scoreLabel1']:setString('')
    vars['clanMarkNode1']:removeAllChildren()
    vars['scoreLabel2']:setString('')
    vars['clanMarkNode2']:removeAllChildren()

    -- 왼쪽 클랜
    local t_clan_a = t_data['clan_a']
    if t_clan_a then
        vars['scoreLabel1']:setString(tostring(t_clan_a['set_score']) or '')
        local clan_mark = StructClanMark:create(t_clan_a['mark'] or '')
        local icon = clan_mark:makeClanMarkIcon()
        vars['clanMarkNode1']:addChild(icon)
    end

    -- 오른쪽 클랜
    local t_clan_b = t_data['clan_b']
    if t_clan_b then
        vars['scoreLabel2']:setString(tostring(t_clan_b['set_score']) or '')
        local clan_mark = StructClanMark:create(t_clan_b['mark'] or '')
        local icon = clan_mark:makeClanMarkIcon()
        vars['clanMarkNode2']:addChild(icon)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BannerClanWar:initButton()
    local vars = self.vars
    vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end

-------------------------------------
-- function update
-------------------------------------
function UI_BannerClanWar:update()
	local vars = self.vars
	local end_time = self.m_enddate

    if (not end_time) then
        vars['timeLabel2']:setString('')
        return
    end

    -- 공격 끝날 때 까지 남은 시간 = 공격 시작 시간 + 1시간
    local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    local remain_time = (end_time - cur_time)
    if (remain_time > 0) then
        vars['timeLabel2']:setString(datetime.makeTimeDesc_timer_filledByZero(remain_time))
    else
        vars['timeLabel2']:setString('')
    end
end

-------------------------------------
-- function click_bannerBtn
-------------------------------------
function UI_BannerClanWar:click_bannerBtn()
    UINavigatorDefinition:goTo('clan_war')
end