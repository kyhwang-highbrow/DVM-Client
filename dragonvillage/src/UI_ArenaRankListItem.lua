local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaRankListItem
-------------------------------------
UI_ArenaRankListItem = class(PARENT, {
        m_rankInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaRankListItem:init(t_rank_info)
    self.m_rankInfo = t_rank_info
    local vars = self:load('arena_new_rank_popup_item_user_ranking.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaRankListItem:initUI()
    local vars = self.vars
    local t_rank_info = self.m_rankInfo
    local rank = t_rank_info.m_rank

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
    self:initRankInfo(vars, t_rank_info)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaRankListItem:initButton()
    -- 개발 모드에서 랭커와 바로 붙는 기능 추가
    if IS_TEST_MODE() then
        local vars = self.vars 
        vars['testBtn']:setVisible(true)
        vars['testBtn']:registerScriptTapHandler(function() self:click_testBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaRankListItem:refresh()
end

-------------------------------------
-- function click_testBtn
-- @brief 랭커 pvp 정보 받아와서 세팅후 개발 모드로 게임 실행
-------------------------------------
function UI_ArenaRankListItem:click_testBtn()
    local l_dragon_deck = g_arenaData.m_playerUserInfo:getDeck_dragonList()
    if (table.count(l_dragon_deck) <= 0) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 덱이 설정되지 않았습니다.'))
        return
    end

    local uid = g_userData:get('uid')
    local peer_uid = self.m_rankInfo.m_uid

    local function success_cb(ret)
        g_arenaData:makeMatchUserInfo(ret['pvpuser_info'])

        local scene = SceneGameArena(nil, nil, nil, true)
        scene:runScene()
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/game/arena/user_info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('peer', peer_uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
end