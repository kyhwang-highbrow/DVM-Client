local PARENT = UI_MatchReady

-------------------------------------
-- class UI_MatchReadyClanWar
-------------------------------------
UI_MatchReadyClanWar = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MatchReadyClanWar:init()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_MatchReadyClanWar:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_MatchReadyClanWar'
    self.m_bVisible = true
    self.m_titleStr = Str('클랜전')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'honor'
    self.m_addSubCurrency = 'valor'

    -- 입장권 타입 설정
    self.m_staminaType = TableDrop:getStageStaminaType(CHALLENGE_MODE_STAGE_ID)
    self.m_uiBgm = 'bgm_dungeon_ready'
end

-------------------------------------
-- function click_deckBtn
-- @brief 출전 덱 변경
-------------------------------------
function UI_MatchReadyClanWar:click_deckBtn()
    local vars = self.vars 
    local deck_change_mode = true
    local ui = UI_ReadySceneNew(CLAN_WAR_STAGE_ID, true)
    local function close_cb()
        self:initUI()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_startBtn
-- @brief 시작 버튼
-------------------------------------
function UI_MatchReadyClanWar:click_startBtn()
    local scene = SceneGameClanWar()
    scene:runScene()
end

-------------------------------------
-- function getStructUserInfo_Player
-------------------------------------
function UI_MatchReadyClanWar:getStructUserInfo_Player()
    local struct_user_info = g_arenaData:getPlayerArenaUserInfo()
    return struct_user_info
end

-------------------------------------
-- function getStructUserInfo_Opponent
-------------------------------------
function UI_MatchReadyClanWar:getStructUserInfo_Opponent()
    local struct_user_info = g_arenaData:getPlayerArenaUserInfo()
    return struct_user_info
end

-------------------------------------
-- function initStaminaInfo
-------------------------------------
function UI_MatchReadyClanWar:initStaminaInfo()
    local vars = self.vars
end