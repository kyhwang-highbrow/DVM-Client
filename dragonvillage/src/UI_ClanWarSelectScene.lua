local PARENT = UI

-------------------------------------
-- class UI_ClanWarSelectScene
-------------------------------------
UI_ClanWarSelectScene = class(PARENT,{
        m_structMatchMy = 'table',
        m_structMatchEnemy = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarSelectScene:init(struct_match_my, struct_match_enemy)
    local vars = self:load('clan_war_match_scene.ui')
    self.m_structMatchMy = struct_match_my
    self.m_structMatchEnemy = struct_match_enemy

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
    local struct_my_clan_match = self.m_structMatchEnemy

    local my_create_func = function(ui, data)
        local clan_member_uid = data['uid']
        local struct_clan_member_info = struct_my_clan_match:getClanMembersInfo(clan_member_uid)
        if (struct_clan_member_info) then
            ui:setClanMemberInfo(struct_clan_member_info)
        end
        
        ui.vars['resultSprite']:setVisible(false)
        ui.vars['infoBtn']:setVisible(true)
        ui.vars['infoBtn']:registerScriptTapHandler(function() UI_MatchReadyClanWar() end)
    end

        -- 테이블 뷰 인스턴스 생성
    local l_myClan = struct_my_clan_match:getDefendMembers()
    
    table_view = UIC_TableView(vars['meClanListNode'])
    table_view.m_defaultCellSize = cc.size(548, 80 + 5)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarMatchingSceneListItem_My, my_create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_myClan)
end