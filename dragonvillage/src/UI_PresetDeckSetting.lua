local PARENT = UI
-------------------------------------
-- class UI_PresetDeckSetting
-------------------------------------
UI_PresetDeckSetting = class(PARENT,{
        m_gameMode = 'number', 
        -- UI_ReadyScene_Select 관련 변수
        m_readySceneSelect = 'UI_ReadySceneNew_Select',
        -- UI_ReadyScene_Deck 관련 변수
        m_readySceneDeck = 'UI_ReadySceneNew_Deck',

        -- 정렬 도우미
        m_sortManagerDragon = '',
        m_sortManagerFriendDragon = '',
        m_uicSortList = 'UIC_SortList',

        
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PresetDeckSetting:init()
    self.m_uiName = 'UI_PresetDeckSetting'
    self.m_gameMode = 0
    self:load('battle_ready_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ItemInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PresetDeckSetting:initUI()
    local vars = self.vars

    self.m_readySceneSelect = UI_PresetDeckSetting_Select(self)
    self.m_readySceneDeck = UI_PresetDeckSetting_Deck(self)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PresetDeckSetting:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PresetDeckSetting:refresh()
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 장착여부에 따른 카드 갱신
-------------------------------------
function UI_PresetDeckSetting:refresh_dragonCard(doid, is_friend)
    if (not self.m_readySceneDeck) then
        return
    end

    self.m_readySceneDeck:refresh_dragonCard(doid, is_friend)
end

-------------------------------------
-- function refresh_combatPower
-------------------------------------
function UI_PresetDeckSetting:refresh_combatPower()
    local vars = self.vars

    local stage_id = self.m_stageID
    local game_mode = self.m_gameMode

	if (stage_id == COLOSSEUM_STAGE_ID or stage_id == FRIEND_MATCH_STAGE_ID or game_mode == GAME_MODE_CLAN_RAID or stage_id == ARENA_NEW_STAGE_ID or stage_id == ARENA_STAGE_ID or stage_id == CLAN_WAR_STAGE_ID) then
		vars['cp_Label']:setString('')
        vars['cp_Label2']:setString('')

        local deck = self.m_readySceneDeck:getDeckCombatPower()
		vars['cp_Label1']:setString(comma_value( math.floor(deck + 0.5) ))

    elseif isExistValue(game_mode, GAME_MODE_EVENT_ARENA) then
        vars['cp_Label']:setString('')
        vars['cp_Label2']:setString('')

        local deck = self.m_readySceneDeck:getDeckCombatPower()
		vars['cp_Label1']:setString(comma_value( math.floor(deck + 0.5) ))

	else
		local recommend = TableStageData():getRecommendedCombatPower(stage_id, game_mode)
        vars['cp_Label2']:setString(comma_value( math.floor(recommend + 0.5) ))

		local deck = self.m_readySceneDeck:getDeckCombatPower()

        -- 테이머
        do
            local tamer_id = self:getCurrTamerID()
            local t_tamer_data = g_tamerData:getTamerServerInfo(tamer_id)
            local table = g_constant:get('UI', 'TAMER_SKILL_COMBAT_POWER')
            
            for i = 1, 3 do
                local lv = t_tamer_data['skill_lv' .. i]
                if (lv and lv > 0) then
                    deck = deck + table[i] * (lv - 1)
                end
            end
        end

		vars['cp_Label1']:setString(comma_value( math.floor(deck + 0.5) ))

	end
end

-------------------------------------
-- function refresh_buffInfo
-------------------------------------
function UI_PresetDeckSetting:refresh_buffInfo()
    local vars = self.vars
	
	if (not self.m_readySceneDeck) then
		return
	end

    -- 테이머 버프
    self:refresh_buffInfo_TamerBuff()

	-- 리더 버프
	do
        local leader_buff_str = self:getLeaderBuffDesc()
        if (leader_buff_str) then
            vars['leaderBuffLabel']:setString(leader_buff_str)
        else
            vars['leaderBuffLabel']:setString(Str('리더 버프 없음'))
        end
	end

	-- 진형 버프
    -- 콜로세움 (신규) - 버프 없어서 이름 표시
	if (self.m_bArena) then
        local l_formation = g_formationArenaData:getFormationInfoList()
		local curr_formation = self.m_readySceneDeck.m_currFormation
		local formation_data = l_formation[curr_formation]  
        local formation_name = TableFormationArena():getFormationName(formation_data['formation'])
        vars['fomationLabel']:setString(Str('진형 변경'))
        vars['formationBuffLabel']:setString(formation_name)

    else
		local l_formation = g_formationData:getFormationInfoList()
		local curr_formation = self.m_readySceneDeck.m_currFormation
		local formation_data = l_formation[curr_formation]        
		local formation_buff = TableFormation():getFormatioDesc(formation_data['formation'])

		vars['formationBuffLabel']:setString(formation_buff)
	end
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_PresetDeckSetting:click_okBtn()
    self:close()
end

-------------------------------------
-- function open
-------------------------------------
function UI_PresetDeckSetting.open()
    local ui = UI_PresetDeckSetting()
    return ui
end


--@CHECK
UI:checkCompileError(UI_ItemInfoPopup)
