local PARENT = UI_ReadySceneNew

-------------------------------------
-- class UI_FriendMatchDeckSettingsArena
-------------------------------------
UI_FriendMatchDeckSettingsArena = class(PARENT,{
        m_currTamerID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendMatchDeckSettingsArena:init(stage_id, sub_info)
end

-------------------------------------
-- function refresh_buffInfo_TamerBuff
-------------------------------------
function UI_FriendMatchDeckSettingsArena:refresh_buffInfo_TamerBuff()
    local vars = self.vars

    -- 테이머 버프
    local tamer_id = self:getCurrTamerID()
	local t_tamer_data = g_tamerData:getTamerServerInfo(tamer_id)
	local skill_mgr = MakeTamerSkillManager(t_tamer_data)
	--local skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx(3)	-- 3번이 콜로세움 테이머 스킬
    local skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx(2)	-- 2번이 패시브
	local tamer_buff = skill_info:getSkillDesc()

	vars['tamerBuffLabel']:setString(tamer_buff)
end

-------------------------------------
-- function refresh_buffInfo
-------------------------------------
function UI_FriendMatchDeckSettingsArena:refresh_buffInfo()
    local vars = self.vars
	
	if (not self.m_readySceneDeck) then
		return
	end

    -- 테이머 버프
    self:refresh_buffInfo_TamerBuff()

	-- 리더 버프
	do
		self.m_readySceneDeck:refreshLeader()
		
		local leader_buff		
		local leader_idx = self.m_readySceneDeck.m_currLeader
		local l_doid = self.m_readySceneDeck.m_lDeckList
		local leader_doid = l_doid[leader_idx]
		if (leader_doid) then
			local t_dragon_data = g_dragonsData:getDragonDataFromUid(leader_doid)
			local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
			local skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx('Leader')

			if (skill_info) then
				leader_buff = skill_info:getSkillDesc()
			else
				leader_buff = Str('리더 버프 없음')
			end
		else
			leader_buff = Str('리더 버프 없음')
		end
		vars['leaderBuffLabel']:setString(leader_buff)
	end

	-- 진형 버프
    if IS_ARENA_OPEN() then
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
-- function getCurrTamerID
-------------------------------------
function UI_FriendMatchDeckSettingsArena:getCurrTamerID()
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
function UI_FriendMatchDeckSettingsArena:click_tamerBtn()
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
-- function click_fomationBtn
-- @breif
-------------------------------------
function UI_FriendMatchDeckSettingsArena:click_fomationBtn()
	-- m_readySceneDeck에서 현재 formation 받아와 전달
	local curr_formation_type = self.m_readySceneDeck.m_currFormation
    local ui = UI_FormationArenaPopup(curr_formation_type)

	-- 종료하면서 선택된 formation을 m_readySceneDeck으로 전달
	local function close_cb(formation_type)
        if formation_type then
		    self.m_readySceneDeck:setFormation(formation_type)
            self:refresh_combatPower()
		    self:refresh_buffInfo()
        end
	end
	ui:setCloseCB(close_cb)
end