local PARENT = UI

-------------------------------------
-- class UI_ArenaNewRankInfoPopup
-------------------------------------
UI_ArenaNewRankInfoPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewRankInfoPopup:init()
    local vars = self:load('arena_new_scene_ranking_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaNewRankInfoPopup')

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
function UI_ArenaNewRankInfoPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewRankInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewRankInfoPopup:refresh()
    local vars = self.vars

    do -- 최고 기록 데이터
        local struct_user_info = g_arenaNewData:getPlayerArenaUserInfoHighRecord()

        -- 티어 아이콘
        vars['tierIconNode1']:removeAllChildren()
        local icon = struct_user_info:makeTierIcon(nil, 'big')
        vars['tierIconNode1']:addChild(icon)

        -- 티어 이름
        local tier_name = struct_user_info:getTierName()
        vars['tierLabel1']:setString(tier_name)


        -- 순위, 점수, 승률, 연승
        local str = struct_user_info:getRankText() .. '\n'
            .. struct_user_info:getRPText()  .. '\n'
            .. struct_user_info:getWinRateText()  .. '\n'
        vars['rankingLabel1']:setString(str)
    end

    do -- 현재 시즌 기록
        local struct_user_info = g_arenaNewData:getPlayerArenaUserInfo()

        -- 티어 아이콘
        vars['tierIconNode2']:removeAllChildren()
        local icon = struct_user_info:makeTierIcon(nil, 'big')
        vars['tierIconNode2']:addChild(icon)

        -- 티어 이름
        local tier_name = struct_user_info:getTierName()
        vars['tierLabel2']:setString(tier_name)

        -- 순위, 점수, 승률
        local str = struct_user_info:getRankText() .. '\n'
            .. struct_user_info:getRPText()  .. '\n'
            .. struct_user_info:getWinRateText()  .. '\n'
        vars['rankingLabel2']:setString(str)
    end
end

--@CHECK
UI:checkCompileError(UI_ArenaNewRankInfoPopup)
