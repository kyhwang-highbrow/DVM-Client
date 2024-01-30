local PARENT = UI

-------------------------------------
-- class UI_WorldRaidUserDeckInfoPopup
-------------------------------------
UI_WorldRaidUserDeckInfoPopup = class(PARENT, {
    m_tData  = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:init(ret)
    self.m_uiName = 'UI_WorldRaidUserDeckInfoPopup'
    self.m_tData = ret
    
    local vars = self:load('world_raid_user.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_WorldRaidUserDeckInfoPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:initButton()
    local vars = self.vars
    vars['teamBonusBtn']:registerScriptTapHandler(function() self:click_teamBonusBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:refresh()
    local vars = self.vars
    -- local struct_user_info = self.m_structUserInfoArena

    -- -- 레벨, 닉네임
    -- local str_lv = struct_user_info:getUserText()
    -- vars['nameLabel']:setString(str_lv)

    -- -- 전투력 
    -- local combat_power = struct_user_info:getDeckCombatPower()
    -- vars['powerLabel']:setString(Str('전투력 : {1}', comma_value(combat_power)))

    -- -- 테이머
    -- local animator = struct_user_info:getDeckTamerSDAnimator()
    -- vars['tamerNode']:addChild(animator.m_node)

    -- -- 드래곤
    -- self:refresh_dragons()
end

-------------------------------------
-- function refresh_dragons
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:refresh_dragons()
    local vars = self.vars

    -- local struct_user_info = self.m_structUserInfoArena
    -- local player_2d_deck = UI_2DDeck()
    -- player_2d_deck:setDirection('right')
    -- vars['formationNode']:addChild(player_2d_deck.root)
    -- player_2d_deck:initUI()

    -- local t_pvp_deck = struct_user_info:getPvpDeck()
    -- local l_dragons = struct_user_info:getDeck_dragonList()
    -- local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
    -- player_2d_deck:setDragonObjectList(l_dragons, leader)

    -- -- 진형 설정
    -- local formation = 'attack'
    -- if t_pvp_deck then
    --     formation = t_pvp_deck['formation'] or 'attack'
    -- end
    -- local force_arena = true -- 아레나 진형 체크
    -- player_2d_deck:setFormation(formation, force_arena)
end

-------------------------------------
-- function click_teamBonusBtn
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:click_teamBonusBtn()
    local struct_user_info = self.m_structUserInfoArena
    local l_dragons = struct_user_info:getDeck_dragonList()
    local ui = UI_TeamBonus(TEAM_BONUS_MODE.TOTAL, l_dragons)
    ui:setOnlyMyTeamBonus()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup:click_closeBtn()
    self:close()
end

-------------------------------------
--- @function open
-------------------------------------
function UI_WorldRaidUserDeckInfoPopup.open(hoid)
    local success_cb = function(ret)
        UI_WorldRaidUserDeckInfoPopup(ret)
    end

    g_worldRaidData:request_WorldRaidUserDeck(hoid, success_cb)
end