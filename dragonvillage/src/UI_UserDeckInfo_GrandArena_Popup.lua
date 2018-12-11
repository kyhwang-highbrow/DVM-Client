local PARENT = UI

-------------------------------------
-- class UI_UserDeckInfo_GrandArena_Popup
-------------------------------------
UI_UserDeckInfo_GrandArena_Popup = class(PARENT, {
        m_structUserInfo_grandArena  = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:init(struct_user_info)
    self.m_uiName = 'UI_UserDeckInfo_GrandArena_Popup'
    self.m_structUserInfo_grandArena = struct_user_info

    local vars = self:load('grand_arena_user_deck_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_UserDeckInfo_GrandArena_Popup')

    -- @UI_ACTION
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['teamBonusBtn1']:registerScriptTapHandler(function() self:click_teamBonusBtn() end)
    vars['teamBonusBtn2']:registerScriptTapHandler(function() self:click_teamBonusBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:refresh()
    local vars = self.vars
    local struct_user_info = self.m_structUserInfo_grandArena

    -- 레벨, 닉네임
    local str_lv = struct_user_info:getUserText()
    vars['nameLabel']:setString(str_lv)
    
    -- 전투력 
    local str = struct_user_info:getDeckCombatPowerByDeckname('grand_arena_up') + struct_user_info:getDeckCombatPowerByDeckname('grand_arena_down')
    vars['powerLabel']:setString(Str('전투력 : {1}', comma_value(str)))

    -- 아이콘
    icon = struct_user_info:getDeckTamerIcon('grand_arena_up') -- deckname
    if (icon) then
        vars['tamerNode']:removeAllChildren()
        vars['tamerNode']:addChild(icon)
    end

    -- 덱
    local deck_name = 'grand_arena_up'
	local l_dragon_obj = struct_user_info:getDeck_dragonObjList(deck_name)
    local t_deck_lowdata = struct_user_info:getDeckLowData(deck_name)
	local leader = t_deck_lowdata['leader']
	local formation = t_deck_lowdata['formation']
	self:initDeckUI('left', 'up', l_dragon_obj, leader, formation)


    local deck_name = 'grand_arena_down'
	local l_dragon_obj = struct_user_info:getDeck_dragonObjList(deck_name)
    local t_deck_lowdata = struct_user_info:getDeckLowData(deck_name)
	local leader = t_deck_lowdata['leader']
	local formation = t_deck_lowdata['formation']
	self:initDeckUI('left', 'down', l_dragon_obj, leader, formation)
end

-------------------------------------
-- function refresh_dragons
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:refresh_dragons()
    local vars = self.vars

   
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:click_closeBtn()
    self:close()
end


-------------------------------------
-- function initDeckUI
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:initDeckUI(direction, direction_v, l_dragon_obj, leader, formation)
    local vars = self.vars
    local parent_node

    if (direction_v == 'up') then
        parent_node = vars['formationNode1']
    else
        parent_node = vars['formationNode2']
    end
   

    local player_2d_deck = UI_2DDeck(true, true)
    player_2d_deck:setDirection(direction)
    parent_node:addChild(player_2d_deck.root)
    player_2d_deck:initUI()

    -- 드래곤 생성 (리더도 함께)
    player_2d_deck:setDragonObjectList(l_dragon_obj, leader)
        
    -- 진형 설정
    player_2d_deck:setFormation(formation)
end


-------------------------------------
-- function click_teamBonusBtn
-------------------------------------
function UI_UserDeckInfo_GrandArena_Popup:click_teamBonusBtn()
    local struct_user_info = self.m_structUserInfo_grandArena
    local l_dragons = struct_user_info:getDeck_dragonList()
    local b_recommend = false
	local ui = UI_TeamBonus(TEAM_BONUS_MODE.TOTAL, l_dragons, nil, b_recommend)
end