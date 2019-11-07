local PARENT = UI

-------------------------------------
-- class UI_ClanWarSelectScene
-------------------------------------
UI_ClanWarSelectScene = class(PARENT,{
        m_tStructMatchMy = 'table',
        m_tStructMatchEnemy = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarSelectScene:init(t_my_struct_match, t_enemy_struct_match)
    local vars = self:load('challenge_mode_scene.ui')
    self.m_tStructMatchMy = t_my_struct_match or {}
    self.m_tStructMatchEnemy = t_enemy_struct_match or {}

    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarSelectScene')

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarSelectScene:initUI()
    local vars = self.vars
    local l_enemy = self.m_tStructMatchEnemy
    
    local create_func = function(ui, struct_match)
        local nick_name = struct_match:getNameTextWithEnemy()
        local defend_state = struct_match:getDefendState()
        local defend_state_text = struct_match:getDefendStateText()

        ui.vars['userNameLabel']:setString(nick_name ..  ' - ' .. defend_state_text)
    end

    table_view = UIC_TableView(vars['floorNode'])
    table_view.m_defaultCellSize = cc.size(548, 80 + 5)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarMatchingSceneListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_enemy)

	vars['startBtn']:registerScriptTapHandler(function() UI_MatchReadyClanWar() end)
end