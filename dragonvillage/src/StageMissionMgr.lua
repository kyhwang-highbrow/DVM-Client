-------------------------------------
-- class StageMissionMgr
-------------------------------------
StageMissionMgr = class({
		-- 미션 (기록이 필요한 것)
		m_clearCnt = 'num',			-- 스테이지 클리어 횟수
		m_deathCnt = 'num',			-- 사망 드래곤 {1}기 이하인 상태에서 클리어
		m_useSkillCnt = 'num',		-- 드래곤의 스킬을 {1}번 이상 사용
		m_lapTime = 'num',			-- {1} 초 내에 스테이지 클리어
		m_feverCnt = 'num',			-- 피버를 {1}번 이상 사용
		m_bossFinishAtk = 'str',		-- 보스를 {1} 공격으로 처치
		
		-- 미션 (인게임 중에 기록할것이 없음)
		m_attrCnt = 'num',			-- {1} 속성 드래곤을 {2}기 이상 사용하여 클리어
		m_revolutionCnt = 'num',	-- {1} 상태의 드래곤을 {2}기 이상 사용하여 클리어
		m_dragonCnt = 'num',		-- 드래곤을 {1} 기 이하로 사용하여 클리어
		m_UsedTamer = 'str',		-- {1} 테이머를 사용하여 클리어
		m_UsedPosition = 'str',		-- {1} 진형을 사용하여 클리어
		m_UsedDragon = 'str',		-- {1} 드래곤을 사용하여 클리어
		m_UsedRole = 'str',			-- {1} 직업의 드래곤을 사용하지 않고 클리어

		m_dropTable = 'TableDrop',
     })

-------------------------------------
-- function init
-------------------------------------
function StageMissionMgr:init(stage_id)
	self.m_dropTable = TableDrop():get(stage_id)
	
	self.m_clearCnt = 0
	self.m_deathCnt = 0
	self.m_useSkillCnt = 0
	self.m_lapTime = 0
	self.m_feverCnt = 0
	self.m_bossFinishAtk = nil
end

-------------------------------------
-- function recordMission
-------------------------------------
function StageMissionMgr:recordMission(key, value)
	if (key == 'clear_cnt') then
		self.m_clearCnt = self.m_clearCnt + value

	elseif (key == 'death_cnt') then
		self.m_deathCnt = self.m_deathCnt + value

	elseif (key == 'use_skill') then
		self.m_useSkillCnt = self.m_useSkillCnt + value

	elseif (key == 'use_fever') then
		self.m_feverCnt = self.m_feverCnt + value

	elseif (key == 'lap_time') then
		self.m_lapTime = value

	elseif (key == 'finish_atk') then
		self.m_bossFinishAtk = value

	elseif (key == 'attribute_cnt') then
	elseif (key == 'revolution_state') then
	elseif (key == 'use_dragon_cnt') then
	elseif (key == 'use_tamer') then
	elseif (key == 'use_position') then
	elseif (key == 'use_dragon') then
	elseif (key == 'not_use_role') then
	
	else
		error('정의 되지 않은 키 : ' .. key)
	end
end

-------------------------------------
-- function checkWorldValue
-------------------------------------
function StageMissionMgr:checkWorldValue()
	local t_drop = self.m_dropTable
	
end

-------------------------------------
-- function init
-------------------------------------
function StageMissionMgr:getCompleteClearMission()
	local t_drop = self.m_dropTable

	local t_ret = {}
	t_ret['mission_1'] = 1
	t_ret['mission_2'] = 1
	t_ret['mission_3'] = 1

	return t_ret
end