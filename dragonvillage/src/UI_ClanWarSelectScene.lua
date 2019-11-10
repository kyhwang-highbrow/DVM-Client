local PARENT = UI

-------------------------------------
-- class UI_ClanWarSelectScene
-------------------------------------
UI_ClanWarSelectScene = class(PARENT,{
        m_tStructMatch = 'StructClanWarMatch',

        m_curSelectEnemyStructMatch = 'StructClanWarMatchItem',
})

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarSelectScene:init(struct_match)
    local vars = self:load('clan_war_match_select_scene.ui')
    self.m_tStructMatch = struct_match or {}

    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarSelectScene')

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarSelectScene:initUI()
    local vars = self.vars
    local struct_match = self.m_tStructMatch
    local t_enemy = struct_match:getEnemyMatchData()

    local create_func = function(ui, struct_match_item)
        -- 나의 닉네임
        local my_nick = struct_match_item:getMyNickName()
        ui.vars['userNameLabel1']:setString(my_nick)
        

        -- 상대편이 있을 경우 상대 닉네임
        -- 상대편 정보는 StructClanWar에서 들고 있기 때문에 여기서 세팅해준다.
        local defend_enemy_uid = struct_match_item:getDefendEnemyUid()
        if (defend_enemy_uid) then
            local struct_enemy_match_item = struct_match:getMatchMemberDataByUid(defend_enemy_uid)
            local enemy_nick = 'VS ' .. struct_enemy_match_item:getMyNickName() or ''
            ui.vars['userNameLabel2']:setString(enemy_nick)
            
            -- 승/패/승 세팅
            local l_game_result = struct_enemy_match_item:getGameResult()
            ui:setGameResult(l_game_result)

            -- 남은 시간 세팅
            local end_date = struct_enemy_match_item:getEndDate()
            ui:setEndTime(end_date)
            
            -- 클릭했을 때 
            ui.vars['selectBtn']:registerScriptTapHandler(function() self.m_curSelectEnemyStructMatch = struct_match_item end)
        else
            ui.vars['userNameLabel2']:setString('')
        end
    end

    local table_view = UIC_TableView(vars['rivalClanListNode'])
    table_view.m_defaultCellSize = cc.size(548, 80 + 5)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarSelectSceneListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(t_enemy)

	vars['readyBtn']:registerScriptTapHandler(function() UI_MatchReadyClanWar() end)

    local l_data = table_view.m_itemList
    for i, struct_match_item in ipairs(l_data) do
        if (i == 1) then
            self.m_curSelectEnemyStructMatch = struct_match_item['data']
        end 
    end

    if (IS_TEST_MODE()) then
        vars['testMenu']:setVisible(true)
        vars['testWinBtn']:registerScriptTapHandler(function() self:click_testBtn(true) end)
        vars['testLoseBtn']:registerScriptTapHandler(function() self:click_testBtn(false) end)
    end
end

-------------------------------------
-- function click_testBtn
-------------------------------------
function UI_ClanWarSelectScene:click_testBtn(is_win)
    local select_enemy_uid = self.m_curSelectEnemyStructMatch['uid']
    
    local start_cb = function()
        local finish_cb = function()
            
        end 
        g_clanWarData:request_clanWarFinish(is_win, finish_cb)
    end
    g_clanWarData:request_clanWarStart(select_enemy_uid, start_cb)
end

-------------------------------------
-- function refreshFocusUserInfo
-- @brief
-------------------------------------
function UI_ClanWarSelectScene:refreshFocusUserInfo(uid)
    local vars = self.vars

    local enemy_struct_match = self.m_curSelectEnemyStructMatch
    local user_info = enemy_struct_match:getUserInfo()
    vars['userNameLabel']:setString(user_info:getNickname() or '')

    local enemy_struct_match
    vars['powerLabel']:setString()

    -- 게임 결과
    local l_result = self.m_curSelectEnemyStructMatch:getEnemyStructMatch():getGameResult()
    l_result = table.reverse(l_result)
    local idx = 1 
    for i, result in ipairs(l_result) do
        local color
        -- 방어결과 = 공격자 결과의 반대
        if (result == 1) then
            color = StructClanWarMatch.STATE_COLOR['LOSE']
        else
            color = StructClanWarMatch.STATE_COLOR['WIN']
        end
        vars['setResult'..idx]:setColor(color)
    end
    --[[
    vars['dragonDeckNode

    vars['tamerNode

    vars['dragonNode
    --]]
end
