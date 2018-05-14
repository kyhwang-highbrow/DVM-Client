local PARENT = UI_ReadySceneNew

-------------------------------------
-- class UI_ArenaDeckSettings
-------------------------------------
UI_ArenaDeckSettings = class(PARENT,{
        m_currTamerID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaDeckSettings:init(stage_id, sub_info)
end

-------------------------------------
-- function refresh_buffInfo_TamerBuff
-------------------------------------
function UI_ArenaDeckSettings:refresh_buffInfo_TamerBuff()
    local vars = self.vars

    -- 테이머 버프
    local tamer_id = self:getCurrTamerID()
	local t_tamer_data = g_tamerData:getTamerServerInfo(tamer_id)
	local skill_mgr = MakeTamerSkillManager(t_tamer_data)
	local skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx(3)	-- 3번이 콜로세움 테이머 스킬
	local tamer_buff = skill_info:getSkillDesc()

	vars['tamerBuffLabel']:setString(tamer_buff)
end

-------------------------------------
-- function getCurrTamerID
-------------------------------------
function UI_ArenaDeckSettings:getCurrTamerID()
    if (not self.m_currTamerID) then
        local l_deck, formation, deckname, leader, tamer_id = g_deckData:getDeck()
        self.m_currTamerID = tamer_id
    end
    return self.m_currTamerID
end

-------------------------------------
-- function click_tamerBtn
-- @breif
-------------------------------------
function UI_ArenaDeckSettings:click_tamerBtn()
    local tamer_id = self:getCurrTamerID()

    local ui = UI_TamerManagePopup_Colosseum(tamer_id)

    local function close_cb()
        self.m_currTamerID = ui.m_currTamerID
		self:refresh_tamer()
		self:refresh_buffInfo()
    end

	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_startBtn
-- @brief 시작 버튼
-------------------------------------
function UI_ArenaDeckSettings:click_startBtn()

    -- 콜로세움 공격 덱이 설정되었는지 여부 체크
    local l_dragon_obj = g_arenaData.m_playerUserInfo:getAtkDeck_dragonList()
    if (table.count(l_dragon_obj) <= 0) then
        local function yes()
            self:click_deckBtn()
        end
        MakeSimplePopup(POPUP_TYPE.YES_NO, Str('콜로세움 출전 덱이 설정되지 않았습니다.\n출전 덱을 설정하시겠습니까?'), yes)
        return
    end

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

                local scene = SceneGameArena()
                scene:runScene()
            end

            g_arenaData:request_colosseumStart(is_cash, cb)
        end

        if (not g_staminasData:checkStageStamina(ARENA_STAGE_ID)) then
            is_cash = true
            local cash = 50
            local msg = Str('입장권을 모두 소모하였습니다.\n{1}다이아몬드를 사용하여 진행하시겠습니까?', cash)
            MakeSimplePopup_Confirm('cash', cash, msg, request)
        else
            is_cash = false
            request()
        end
    end

    check_dragon_inven()
end