local PARENT = UI

-------------------------------------
-- class UI_EventAdvent
-------------------------------------
UI_EventAdvent = class(PARENT,{
        m_eventDataUI = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventAdvent:init()
    -- summon.vrp를 에러 메시지 없이 불러오려면 아래 plist를 SpriteFrameCache에 올려줘야한다.
    -- 하지만 에러 메세지 없애자고 메모리를 낭비할 필요는 없음
    -- Translate:a2dTranslate('ui/a2d/summon/summon_cut.plist')

    local vars = self:load('event_advent.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventAdvent:initUI()
    local vars = self.vars

    -- 깜짝 출현 남은 시간
    do
        vars['timeLabel']:setString('')

        local frame_guard = 1
        local function update(dt)
            frame_guard = frame_guard + dt
            if (frame_guard < 1) then
                return
            end
            frame_guard = frame_guard - 1
            
            local remain_time = g_hotTimeData:getEventRemainTime('event_advent')
            if remain_time > 0 then
                local time_str = ServerTime:getInstance():makeTimeDescToSec(remain_time, true)
                vars['timeLabel']:setString(Str('{1} 남음', time_str))
            end
        end
        self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
    end

	local daily_egg_max = g_eventAdventData:getDailyAdventEggMax()
	local daily_egg_get = g_eventAdventData:getDailyAdventEggGet()
	local obtain_text = Str('일일 최대 {1}/{2}개 획득 가능', daily_egg_get, daily_egg_max)
	vars['obtainLabel']:setString(obtain_text)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventAdvent:initButton()
    local vars = self.vars
    vars['stageMoveBtn']:registerScriptTapHandler(function() self:click_stageMoveBtn() end)
	vars['infoBtn']:registerScriptTapHandler(function() UI_EventAdvent.createAdventInfoPopup() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventAdvent:refresh()
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventAdvent:onEnterTab()
    self:refresh()
end

-------------------------------------
-- function click_stageMoveBtn
-- @brief 깜짝 출현 챕터 보통 난이도 1스테이지로 보냄
-------------------------------------
function UI_EventAdvent:click_stageMoveBtn()
    local advent_default_stage_id = 1119901
    UINavigator:goTo('adventure', advent_default_stage_id)
end

-------------------------------------
-- function createAdventPopup
-- @brief 팝업 형태로 열기
-------------------------------------
function UI_EventAdvent.createAdventPopup()
    local ui = UI_EventAdvent()
	UIManager:open(ui, UIManager.POPUP)
	
	-- @UI_ACTION
    ui:doActionReset()
    ui:doAction(nil, false)

	-- 백키 지정
    g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'UI_EventAdventInfoPopup')

	ui.vars['okBtn']:setVisible(true)
	ui.vars['okBtn']:registerScriptTapHandler(function() ui:close() end)
	ui.vars['closeBtn']:setVisible(true)
	ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)
end

-------------------------------------
-- function createAdventInfoPopup
-- @brief 깜짝 출현 도움말 팝업
-------------------------------------
function UI_EventAdvent.createAdventInfoPopup()
	local ui = UI()
	ui:load('event_advent_info_popup.ui')
	UIManager:open(ui, UIManager.POPUP)
	ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)

	-- @UI_ACTION
    ui:doActionReset()
    ui:doAction(nil, false)
	
	-- 백키 지정
    g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'UI_EventAdventInfoPopup')
end
