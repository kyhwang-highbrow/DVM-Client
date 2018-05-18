local PARENT = UI

-------------------------------------
-- class UI_UserDeckInfoPopupNew
-------------------------------------
UI_UserDeckInfoPopupNew = class(PARENT, {
        m_structUserInfoArena  = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_UserDeckInfoPopupNew:init(struct_user_info)
    self.m_uiName = 'UI_UserDeckInfoPopupNew'
    self.m_structUserInfoArena = struct_user_info

    local vars = self:load('user_deck_info_popup_new.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_UserDeckInfoPopupNew')

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
function UI_UserDeckInfoPopupNew:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserDeckInfoPopupNew:initButton()
    local vars = self.vars
    vars['teamBonusBtn']:registerScriptTapHandler(function() self:click_teamBonusBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserDeckInfoPopupNew:refresh()
    local vars = self.vars
    local struct_user_info = self.m_structUserInfoArena

    -- 레벨, 닉네임
    local str_lv = struct_user_info:getUserText()
    vars['nameLabel']:setString(str_lv)

    -- 전투력 
    local combat_power = struct_user_info:getDeckCombatPower()
    vars['powerLabel']:setString(Str('전투력 : {1}', comma_value(combat_power)))

    -- 테이머
    local animator = struct_user_info:getDeckTamerSDAnimator()
    vars['tamerNode']:addChild(animator.m_node)

    -- 드래곤
    self:refresh_dragons()
end

-------------------------------------
-- function refresh_dragons
-------------------------------------
function UI_UserDeckInfoPopupNew:refresh_dragons()
    local vars = self.vars

    local struct_user_info = self.m_structUserInfoArena
    local player_2d_deck = UI_2DDeck()
    player_2d_deck:setDirection('right')
    vars['formationNode']:addChild(player_2d_deck.root)
    player_2d_deck:initUI()

    local t_pvp_deck = struct_user_info:getPvpDeck()
    local l_dragons = struct_user_info:getDeck_dragonList()
    local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
    player_2d_deck:setDragonObjectList(l_dragons, leader)

    -- 진형 설정
    local formation = 'attack'
    if t_pvp_deck then
        formation = t_pvp_deck['formation'] or 'attack'
    end
    player_2d_deck:setFormation(formation)
end

-------------------------------------
-- function click_teamBonusBtn
-------------------------------------
function UI_UserDeckInfoPopupNew:click_teamBonusBtn()
    local struct_user_info = self.m_structUserInfoArena
    local l_dragons = struct_user_info:getDeck_dragonList()
    local ui = UI_TeamBonus(TEAM_BONUS_MODE.TOTAL, l_dragons)
    ui:setOnlyMyTeamBonus()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_UserDeckInfoPopupNew:click_closeBtn()
    self:close()
end

-------------------------------------
-- function RequestUserDeckInfoPopupNew
-------------------------------------
function RequestUserDeckInfoPopupNew(peer_uid, history_id)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        local struct_user_info = StructUserInfoArena:createUserInfo(ret['pvpuser_info'])
        UI_UserDeckInfoPopupNew(struct_user_info)
    end

    local function fail_cb(ret)
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/game/arena/user_info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('peer', peer_uid)
    if (history_id) then
        ui_network:setParam('oid', history_id)
    end
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
end