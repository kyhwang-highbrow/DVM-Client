local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaNewRivalListItem
-------------------------------------
UI_ArenaNewRivalListItem = class(PARENT, {
        m_rivalInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewRivalListItem:init(t_rival_info)
    self.m_rivalInfo = t_rival_info
    local vars = self:load('arena_new_scene_item_01.ui')
    self.root:setSwallowTouch(true)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewRivalListItem:initUI()
    local vars = self.vars
    
    local t_rival_info = self.m_rivalInfo

    vars['userLabel']:setString(Str('레벨 {1}/{2}', t_rival_info.m_lv, t_rival_info.m_nickname))
    vars['scoreLabel']:setString(Str('{1}점', t_rival_info.m_rp))
    vars['powerLabel']:setString(self.m_rivalInfo:getDeckCombatPower(true))

    if (t_rival_info.m_structClan) then
        vars['clanLabel']:setString(t_rival_info.m_structClan.name)
    else
        vars['clanLabel']:setString('')
    end

    -- 드래곤 리스트
    local t_deck_dragon_list = t_rival_info.m_dragonsObject
    local dragonMaxCount = 5
    local dragonSlotIndex = 1

    for i,v in pairs(t_deck_dragon_list) do
        local icon = UI_DragonCard(v)
        icon.root:setSwallowTouch(true)
        vars['dragonNode' .. dragonSlotIndex]:addChild(icon.root)

        dragonSlotIndex =  dragonSlotIndex + 1
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewRivalListItem:initButton()
    local vars = self.vars 
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewRivalListItem:refresh()
end

-------------------------------------
-- function click_challengeBtn
-- @brief 랭커 pvp 정보 받아와서 세팅후 개발 모드로 게임 실행
-------------------------------------
function UI_ArenaNewRivalListItem:click_startBtn()
    local l_dragon_deck = g_arenaNewData.m_playerUserInfo:getDeck_dragonList()
    if (table.count(l_dragon_deck) <= 0) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 덱이 설정되지 않았습니다.'))
        return
    end

    local uid = g_userData:get('uid')
    local peer_uid = self.m_rivalInfo.m_uid

    local t_rival_info = self.m_rivalInfo

    if (t_rival_info.m_no) then
        --g_arenaNewData:makeMatchUserInfo(ret['pvpuser_info'])
        g_arenaNewData:setMatchUser(self.m_rivalInfo)
        UI_LoadingArenaNew()
    end
end