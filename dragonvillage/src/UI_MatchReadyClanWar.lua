local PARENT = UI_MatchReady

-------------------------------------
-- class UI_MatchReadyClanWar
-------------------------------------
UI_MatchReadyClanWar = class(PARENT,{
		m_myStructMatchItem = 'StructClanWarMatchItem',
		m_curEnemyStructMatchItem = 'StructClanWarMatchItem',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MatchReadyClanWar:init(struct_match_item, my_struct_match_item)
	self.m_myStructMatchItem = my_struct_match_item
	self.m_curEnemyStructMatchItem = struct_match_item

	self:getStructUserInfo_Opponent() -- 적 정보 초기화
	self:getStructUserInfo_Player()
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
    local check_dragon_inven
    local check_item_inven
    local start_game

    -- 드래곤 가방 확인(최대 갯수 초과 시 획득 못함)
    check_dragon_inven = function()
        local function manage_func()
            self:click_manageBtn()
        end
        g_dragonsData:checkMaximumDragons(check_item_inven, manage_func)
    end

    -- 아이템 가방 확인(최대 갯수 초과 시 획득 못함)
    check_item_inven = function()
        local function manage_func()
            UI_Inventory()
        end
        g_inventoryData:checkMaximumItems(start_game, manage_func)
    end

    start_game = function()
        -- 콜로세움 시작 요청
        local is_cash = false
        local function request()
            local function cb(ret)
                -- 시작이 두번 되지 않도록 하기 위함
                UI_BlockPopup()
                -- 스케쥴러 해제 (씬 이동하는 동안 입장권 모두 소모시 다이아로 바뀌는게 보기 안좋음)
                self.root:unscheduleUpdate()
                local scene = SceneGameClanWar(ret['gamekey'])
                scene:runScene()
            end

			local enemy_uid = self.m_curEnemyStructMatchItem['uid']
            -- self.m_historyID이 nil이 아닌 경우 재도전, 복수전
            g_clanWarData:request_clanWarStart(enemy_uid, cb)
        end

        -- 기본 입장권 부족시
        if (not g_staminasData:checkStageStamina(ARENA_STAGE_ID)) then
            -- 유료 입장권 체크
            local is_enough, insufficient_num = g_staminasData:hasStaminaCount('arena_ext', 1)
            if (is_enough) then
                is_cash = true
                local msg = Str('입장권을 모두 소모하였습니다.\n{1}다이아몬드를 사용하여 진행하시겠습니까?', NEED_CASH)
                MakeSimplePopup_Confirm('cash', NEED_CASH, msg, request)

            -- 유료 입장권 부족시 입장 불가 
            else
                -- 스케쥴러에서 버튼 비활성화로 막음
            end
        else
            is_cash = false
            request()
        end
    end

    check_dragon_inven()
end

-------------------------------------
-- function getStructUserInfo_Player
-------------------------------------
function UI_MatchReadyClanWar:getStructUserInfo_Player()
    local struct_user_info = g_clanWarData:getStructUserInfo_Player()	-- g_arenaData:getPlayerArenaUserInfo()	-
	struct_user_info:setClanWarStructMatchItem(self.m_myStructMatchItem)
    return struct_user_info
end

-------------------------------------
-- function getStructUserInfo_Opponent
-------------------------------------
function UI_MatchReadyClanWar:getStructUserInfo_Opponent()
    local struct_user_info = g_clanWarData:getEnemyUserInfo()
    return struct_user_info
end

-------------------------------------
-- function initStaminaInfo
-------------------------------------
function UI_MatchReadyClanWar:initStaminaInfo()
    local vars = self.vars
end