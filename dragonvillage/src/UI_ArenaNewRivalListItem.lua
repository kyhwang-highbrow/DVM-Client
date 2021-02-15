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

    if (t_rival_info.m_structClan) then
        vars['clanLabel']:setString(t_rival_info.name)
    else
        vars['clanLabel']:setString('')
    end

    -- 드래곤 리스트
    local t_deck_dragon_list = t_rival_info:getDefDeck_dragonList()

   -- for i,v in pairs(t_deck_dragon_list) do
    for i = 1, 5 do
        local card_ui = IconHelper:getItemIcon(771683)
        card_ui:setScale(1)
        vars['dragonNode' .. i]:addChild(card_ui)
        --local icon = UI_DragonCard(v)
        --icon.root:setSwallowTouch(false)
        --vars['dragonNode' .. i]:addChild(icon.root)
    end
    --[[
    local tag = t_rank_info.m_tag
    
    -- 다음 랭킹 보기 
    if (tag == 'next') then
        vars['nextBtn']:setVisible(true)
        vars['itemMenu']:setVisible(false)
        return
    end

    -- 이전 랭킹 보기 
    if (tag == 'prev') then
        vars['prevBtn']:setVisible(true)
        vars['itemMenu']:setVisible(false)
        return
    end

    -- 점수 표시
    vars['scoreLabel']:setString(t_rank_info:getRPText())

    -- 유저 정보 표시 (레벨, 닉네임)
    vars['userLabel']:setString(t_rank_info:getUserText())

    -- 순위 표시
    vars['rankingLabel']:setString(t_rank_info:getRankText())

    do -- 리더 드래곤 아이콘
        local ui = t_rank_info:getLeaderDragonCard()
        if ui then
            ui.root:setSwallowTouch(false)
            vars['profileNode']:addChild(ui.root)
            
			ui.vars['clickBtn']:registerScriptTapHandler(function() 
				local is_visit = true
				UI_UserInfoDetailPopup:open(t_rank_info, is_visit, nil)
			end)
        end
    end

    do -- 티어 아이콘
        local icon = t_rank_info:makeTierIcon(nil, 'big')
        vars['tierIconNode']:addChild(icon)

        vars['tierLabel']:setString(t_rank_info:getTierName())
    end

    do -- 내 순위 UI일 경우
        local uid = g_userData:get('uid')
        local is_my_rank = (uid == t_rank_info.m_uid)
        vars['meSprite']:setVisible(is_my_rank)
    end

    -- 공통의 정보
    self:initRankInfo(vars, t_rank_info)]]
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
    local l_dragon_deck = g_arenaData.m_playerUserInfo:getDeck_dragonList()
    if (table.count(l_dragon_deck) <= 0) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 덱이 설정되지 않았습니다.'))
        return
    end

    local uid = g_userData:get('uid')
    local peer_uid = self.m_rivalInfo.m_uid

    local function success_cb(ret)
        g_arenaNewData:makeMatchUserInfo(ret['pvpuser_info'])

        local scene = SceneGameArenaNew(nil, nil, nil, true)
        scene:runScene()
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/game/arena_new/user_info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('peer', peer_uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
end