local PARENT = UI

-------------------------------------
-- class UI_BannerGrandArena
-------------------------------------
UI_BannerIllusion = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BannerIllusion:init()
    self.m_uiName = 'UI_BannerIllusion'
    local vars = self:load('lobby_event_dungeon_banner.ui')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BannerIllusion:initUI()
    local vars = self.vars

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    if (g_illusionDungeonData:getIllusionState() == Serverdata_IllusionDungeon.STATE['OPEN']) then
        vars['dscLabel']:setString(Str('이벤트 중'))
    else
        if (g_illusionDungeonData:getRewardPossible()) then
            vars['dscLabel']:setString(Str('보상 획득 가능'))
        else
            vars['dscLabel']:setString(Str('교환소 이용 가능'))
        end
    end

    vars['titleLabel']:setString(Str('환상 던전'))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BannerIllusion:initButton()
    local vars = self.vars
    vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BannerIllusion:refresh()
end

-------------------------------------
-- function update
-- @brief 매 프레임 호출되는 함수
-------------------------------------
function UI_BannerIllusion:update(dt)
    local vars = self.vars
    --[[
    local state = g_grandArena:getGrandArenaState()
    
    -- 연습전
    if (state == ServerData_GrandArena.STATE['PRESEASON']) then
        local text = g_grandArena:getGrandArenaStatusText()
        vars['timeLabel']:setString(text)

        local text = ''
        vars['descLabel']:setString(text)

    -- 이벤트 진행 중
    elseif (state == ServerData_GrandArena.STATE['OPEN']) then
        local text = g_grandArena:getGrandArenaStatusText()
        vars['timeLabel']:setString(text)

        local struct_user_info = g_grandArena:getPlayerGrandArenaUserInfo()
        local text = struct_user_info:getGrandArena_RankText()
        vars['descLabel']:setString(text)

    -- 이벤트 종료 후 보상 획득 가능
    elseif (state == ServerData_GrandArena.STATE['REWARD']) then
        vars['timeLabel']:setString('')

        vars['descLabel']:setString(Str('보상'))
    else
        vars['timeLabel']:setString('')

        vars['descLabel']:setString('')
    end
    --]]

    local time_text = ''
    if (g_illusionDungeonData:getIllusionState() == Serverdata_IllusionDungeon.STATE['OPEN']) then
        time_text = g_illusionDungeonData:getIllusionStatusText()
    else
        time_text = g_illusionDungeonData:getIllusionExchanageStatusText()
    end
    vars['timeLabel']:setString(time_text)
end

-------------------------------------
-- function click_bannerBtn
-------------------------------------
function UI_BannerIllusion:click_bannerBtn()
    -- @brief 그랜드 콜로세움으로 이동
    UINavigator:goTo('event_illusion_dungeon')
end

--@CHECK
UI:checkCompileError(UI_BannerIllusion)
