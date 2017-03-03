-------------------------------------
-- class GameLogRecorder
-------------------------------------
GameLogRecorder = class({
		-- 미션 (기록이 필요한 것)
		m_clearCnt = 'num',			-- 스테이지 클리어 횟수
		m_deathCnt = 'num',			-- 사망 드래곤 {1}기 이하인 상태에서 클리어
		m_useSkillCnt = 'num',		-- 드래곤의 스킬을 {1}번 이상 사용
		m_lapTime = 'num',			-- {1} 초 내에 스테이지 클리어
		m_feverCnt = 'num',			-- 피버를 {1}번 이상 사용
		m_bossFinishAtk = 'str',		-- 보스를 {1} 공격으로 처치
     })

-------------------------------------
-- function init
-------------------------------------
function GameLogRecorder:init()
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
function GameLogRecorder:recordMission(key, value)
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
	
	else
		error('정의 되지 않은 키 : ' .. key)
	end
end

