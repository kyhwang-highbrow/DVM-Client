local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaNewRivalListItem
-------------------------------------
UI_ArenaNewRivalListItem = class(PARENT, {
        m_rivalInfo = '',
        m_isReChallenge = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewRivalListItem:init(t_rival_info)
    self.m_rivalInfo = t_rival_info
    local vars = self:load('arena_new_scene_item_01.ui')
    self.root:setSwallowTouch(true)
    self.m_isReChallenge = false

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
    local rivalScore = t_rival_info.m_rp < 0 and 0 or t_rival_info.m_rp
    rivalScore = comma_value(tonumber(rivalScore))

    vars['userLabel']:setString(Str('Lv. {1}', t_rival_info.m_lv) .. ' ' .. tostring(t_rival_info.m_nickname))
    vars['scoreLabel']:setString(Str(rivalScore))
    vars['powerLabel']:setString(comma_value(t_rival_info:getDeckCombatPower(true)))

    if (t_rival_info.m_structClan) then
        vars['clanLabel']:setString(t_rival_info.m_structClan.name)
        -- 클랜 마크
        local icon = t_rival_info.m_structClan:makeClanMarkIcon()
        if (icon) then
            vars['markNode']:addChild(icon)
        end

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

    -- battle_info 조회
    -- 0 도전하지 않은 상태, 1 승리, 2 패배
    local state = t_rival_info.m_state and t_rival_info.m_state or 1

    if (state == 0) then
        vars['startBtn']:setVisible(true)
        vars['reStartBtn']:setVisible(false)
        vars['winNode']:setVisible(false)

    elseif (state == 1) then
        vars['startBtn']:setVisible(false)
        vars['reStartBtn']:setVisible(false)
        vars['winNode']:setVisible(true)

    elseif (state == 2) then
        vars['startBtn']:setVisible(false)
        vars['reStartBtn']:setVisible(true)
        vars['winNode']:setVisible(false)
        self.m_isReChallenge = true
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewRivalListItem:initButton()
    local vars = self.vars 

    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)    
    vars['reStartBtn']:registerScriptTapHandler(function() self:click_restartBtn() end)   
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
function UI_ArenaNewRivalListItem:click_restartBtn()
    local l_dragon_deck = g_arenaNewData.m_playerUserInfo:getDeck_dragonList()
    local t_rival_info = self.m_rivalInfo

    if (table.count(l_dragon_deck) <= 0) then
        local ui = MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 덱이 설정되지 않았습니다.'))

        local function close_cb()
            if (t_rival_info.m_no) then
                g_arenaNewData:setMatchUser(self.m_rivalInfo)
                local loadingUI = UI_LoadingArenaNew(nil, self.m_isReChallenge)
                loadingUI:click_setAttackDeck()
            end
        end

        ui:setCloseCB(close_cb)

        return
    end

    if (t_rival_info.m_no) then
        g_arenaNewData:setMatchUser(self.m_rivalInfo)
        UI_LoadingArenaNew(nil, self.m_isReChallenge, true)
    end
end

-------------------------------------
-- function click_challengeBtn
-- @brief 랭커 pvp 정보 받아와서 세팅후 개발 모드로 게임 실행
-------------------------------------
function UI_ArenaNewRivalListItem:click_startBtn()
    local l_dragon_deck = g_arenaNewData.m_playerUserInfo:getDeck_dragonList()
    local t_rival_info = self.m_rivalInfo

    if (table.count(l_dragon_deck) <= 0) then
        local ui = MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 덱이 설정되지 않았습니다.'))

        local function close_cb()
            if (t_rival_info.m_no) then
                g_arenaNewData:setMatchUser(self.m_rivalInfo)
                local loadingUI = UI_LoadingArenaNew(nil, self.m_isReChallenge)
                loadingUI:click_setAttackDeck()
            end
        end

        ui:setCloseCB(close_cb)

        return
    end

    if (not g_staminasData:checkStageStamina(ARENA_NEW_STAGE_ID)) then
        local is_cash = false
        local function request()
            local function cb(ret)
                -- 스케쥴러 해제 (씬 이동하는 동안 입장권 모두 소모시 다이아로 바뀌는게 보기 안좋음)
                self.root:unscheduleUpdate()
            end

            g_staminasData:staminaCharge(ARENA_NEW_STAGE_ID)
        end

        -- 유료 입장권 체크
        local is_enough, insufficient_num = g_staminasData:hasStaminaCount(ARENA_NEW_STAGE_ID, 1)
        if (is_enough) then
            is_cash = true
            local msg = Str('입장권을 모두 소모하였습니다.\n{1}다이아몬드를 사용하여 진행하시겠습니까?', NEED_CASH)
            MakeSimplePopup_Confirm('cash', NEED_CASH, msg, request)

        -- 유료 입장권 부족시 입장 불가 
        else
            g_staminasData:staminaCharge(ARENA_NEW_STAGE_ID)
        end
        
        return
    end

    if (t_rival_info.m_no) then
        g_arenaNewData:setMatchUser(self.m_rivalInfo)
        UI_LoadingArenaNew(nil, self.m_isReChallenge)
    end

end
