local PARENT = UI

-------------------------------------
-- class UI_ClanWarSelectScene
-------------------------------------
UI_ClanWarSelectScene = class(PARENT,{
        m_tStructMatch = 'StructClanWarMatch',

        m_curSelectEnemyStructMatch= 'StructClanWarMatchItem',
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
        -- 클릭했을 때 
        ui.vars['selectBtn']:registerScriptTapHandler(function() 
            self.m_curSelectEnemyStructMatch = struct_match_item 
            self:refreshFocusUserInfo() 
        end)

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
    for i, data in ipairs(l_data) do
        if (i == 1) then
            self.m_curSelectEnemyStructMatch = data['data']
            break
        end 
    end

    self:refreshFocusUserInfo()

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
function UI_ClanWarSelectScene:refreshFocusUserInfo()
    local vars = self.vars
    local struct_match = self.m_tStructMatch
    local struct_match_item = self.m_curSelectEnemyStructMatch
    if (not struct_match_item) then
        return
    end

    local enemy_nick = struct_match_item:getMyNickName() or ''
    vars['userNameLabel']:setString(enemy_nick)
    
    -- 리더 드래곤
    local struct_clan_info = struct_match_item:getUserInfo()
    local dragon_icon = struct_clan_info:getLeaderDragonCard()
    if (dragon_icon) then
        vars['dragonNode']:addChild(dragon_icon.root)
        vars['dragonNode']:setScale(0.5)
    end
    
    local defend_enemy_uid = struct_match_item:getDefendEnemyUid()
    local struct_enemy_match_item = struct_match:getMatchMemberDataByUid(defend_enemy_uid)
    if (not struct_enemy_match_item) then
        return
    end
    
    -- 승/패/승 세팅
    local l_game_result = struct_enemy_match_item:getGameResult()
    for i, result in ipairs(l_game_result) do
        local color
        if (result == '0') then
            color = StructClanWarMatch.STATE_COLOR['LOSE']
        else
            color = StructClanWarMatch.STATE_COLOR['WIN']
        end
        if (vars['setResult'..i]) then
            vars['setResult'..i]:setColor(color)
        end
    end

    --]]

    --[[
    vars['dragonDeckNode
    vars['powerLabel']
    vars['tamerNode
    --]]
    
end
