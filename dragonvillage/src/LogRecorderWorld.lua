local PARENT = LogRecorder

-------------------------------------
-- class LogRecorderWorld
-------------------------------------
LogRecorderWorld = class(PARENT, {
		m_world = 'GameWorld',

		m_attrCnt = 'table<attr>',		-- {1} 속성 드래곤을 {2}기 이상 사용하여 클리어
		m_evolutionCnt = 'table<rev>',	-- {1} 상태의 드래곤을 {2}기 이상 사용하여 클리어
		m_dragonCnt = 'num',			-- 드래곤을 {1} 기 이하로 사용하여 클리어
		m_usedTamer = 'str',			-- {1} 테이머를 사용하여 클리어
		m_usedFormation = 'str',		-- {1} 진형을 사용하여 클리어
		m_usedDragon = 'table<did>',	-- {1} 드래곤을 사용하여 클리어
		m_usedRole = 'table<role>',		-- {1} 직업의 드래곤을 사용하지 않고 클리어

		-- 미션 (기록이 필요한 것)
		m_clearCnt = 'num',			-- 스테이지 클리어 횟수
		m_deathCnt = 'num',			-- 사망 드래곤 {1}기 이하인 상태에서 클리어
		m_useSkillCnt = 'num',		-- 드래곤의 스킬을 {1}번 이상 사용
		m_lapTime = 'num',			-- {1} 초 내에 스테이지 클리어
		m_feverCnt = 'num',			-- 피버를 {1}번 이상 사용
		m_bossFinishAtk = 'str',	-- 보스를 {1} 공격으로 처치 -> ('finish_basic', 'finish_active', 'finish_fever')

        m_activeKillCnt = 'num',    -- 드래그 스킬로 처치한 드래곤 수 (즉시 데미지만 포함)

		m_tCharLogTable = 'table',	-- ingame 캐릭터들 개별 기록 저장

        -- 인트로 전투에 필요한 것
        m_attackCnt = 'num',        -- 평타 횟수
        m_dropItemCnt = 'num',      -- 드랍 아이템 수

        -- 기획 밸런스 테스트를 위한 것
        m_totalDamageToHero = 'number', -- 영웅이 받은 총피해(로그 표시마다 초기화 시킴)

        -- 클랜던전에서 총피해량을 맞춰보기 위해서 사용
        m_totalDamageToEnemy = 'number',-- 적군이 받은 총피해(로그 표시마다 초기화 시킴)
     })

-------------------------------------
-- function init
-------------------------------------
function LogRecorderWorld:init(world)
	self.m_world = world

	self.m_deathCnt = 0
	self.m_useSkillCnt = 0
	self.m_lapTime = 0
	self.m_feverCnt = 0
    self.m_activeKillCnt = 0
    self.m_attackCnt = 0
    self.m_dropItemCnt = 0
    self.m_totalDamageToHero = 0
    self.m_totalDamageToEnemy = 0

	self.m_bossFinishAtk = nil

	self.m_tCharLogTable = {}

	self:recordStaticAllLog()
end

-------------------------------------
-- function recordStaticAllLog
-------------------------------------
function LogRecorderWorld:recordStaticAllLog()
	local world = self.m_world
	local l_dragon = world:getDragonList()


	-- 출전한 드래곤의 수
	self.m_dragonCnt = #l_dragon
	
	-- 사용한 테이머 (영문)
	self.m_usedTamer = g_tamerData:getCurrTamerTable('tid')
	
	-- 사용한 진형
	self.m_usedFormation = world.m_deckFormation

	-- 속성 별 드래곤 수
	self.m_attrCnt = {}
	
	-- 진화 별 드래곤 수
	self.m_evolutionCnt = {}

	-- 사용한 드래곤id 리스트
	self.m_usedDragon = {}

	-- 사용한 드래곤 직군
	self.m_usedRole = {}

	-- 테이블이 필요한 데이터 적용
	for i, dragon in pairs(l_dragon) do
		local attr = dragon.m_attribute
		self:applyDataInTable(self.m_attrCnt, attr)

		local evolution = dragon.m_tDragonInfo:getEvolution()
		self:applyDataInTable(self.m_evolutionCnt, evolution)

		local did = dragon.m_dragonID
		self:applyDataInTable(self.m_usedDragon, did)

		local role = dragon.m_tDragonInfo:getRole()
		self:applyDataInTable(self.m_usedRole, role)

        -- 드래곤 캐릭터 로그
        local unique_id = dragon.m_tDragonInfo['id']
        self.m_tCharLogTable[unique_id] = dragon.m_charLogRecorder
	end

    -- 테이커 캐릭터 로그
    local tamer = world.m_tamer
    if (tamer) then
        local unique_id = tamer.m_charTable['tid']
        self.m_tCharLogTable[unique_id] = tamer.m_charLogRecorder
    end
end

-------------------------------------
-- function recordLog
-------------------------------------
function LogRecorderWorld:recordLog(key, value)
	if (key == 'death_cnt') then
		self.m_deathCnt = self.m_deathCnt + value

	elseif (key == 'use_skill') then
		self.m_useSkillCnt = self.m_useSkillCnt + value

	elseif (key == 'use_fever') then
		self.m_feverCnt = self.m_feverCnt + value

	elseif (key == 'lap_time') then
		self.m_lapTime = value

	elseif string.find(key, 'finish_') then
		self.m_bossFinishAtk = value
	
	elseif (key == 'clear_cnt') then
		-- @TODO 클리어 카운트는 미리 1을 더해놓고 연산한다
		self.m_clearCnt = value + 1

	elseif (key == 'attribute_cnt') then
		self.m_attrCnt = value

	elseif (key == 'evolution_state') then
		self.m_revolutionCnt = value

	elseif (key == 'use_dragon_cnt') then
		self.m_dragonCnt = value
		
	elseif (key == 'use_tamer') then
		self.m_usedTamer = value

	elseif (key == 'use_formation') then
		self.m_usedFormation = value
		
	elseif (key == 'use_dragon') then
		self.m_usedDragon = value

	elseif (key == 'not_use_role') then
		self.m_usedRole = value

    elseif (key == 'active_kill_cnt') then
		self.m_activeKillCnt = self.m_activeKillCnt + value

    elseif (key == 'basic_attack_cnt') then
		self.m_attackCnt = self.m_attackCnt + value

    elseif (key == 'drop_item_cnt') then
		self.m_dropItemCnt = self.m_dropItemCnt + value

    elseif (key == 'total_damage_to_hero') then
		self.m_totalDamageToHero = self.m_totalDamageToHero + value

    elseif (key == 'total_damage_to_enemy') then
		self.m_totalDamageToEnemy = self.m_totalDamageToEnemy + value

	else
		error('정의 되지 않은 키 : ' .. key)
	end
end

-------------------------------------
-- function getLog
-------------------------------------
function LogRecorderWorld:getLog(key)
	if (key == 'death_cnt') then
		return self.m_deathCnt

	elseif (key == 'use_skill') then
		return self.m_useSkillCnt

	elseif (key == 'use_fever') then
		return self.m_feverCnt

	elseif (key == 'lap_time') then
		return self.m_lapTime

	elseif string.find(key, 'finish_') then
		return self.m_bossFinishAtk
	
	elseif (key == 'clear_cnt') then
		return self.m_clearCnt

	elseif (key == 'attribute_cnt') then
		return self.m_attrCnt

	elseif (key == 'evolution_state') then
		return self.m_evolutionCnt

	elseif (key == 'use_dragon_cnt') then
		return self.m_dragonCnt

	elseif (key == 'use_tamer') then
		return self.m_usedTamer

	elseif (key == 'use_formation') then
		return self.m_usedFormation

	elseif (key == 'use_dragon') then
		return self.m_usedDragon

	elseif (key == 'not_use_role') then
		return self.m_usedRole
    
    elseif (key == 'active_kill_cnt') then
		return self.m_activeKillCnt

    elseif (key == 'basic_attack_cnt') then
		return self.m_attackCnt

    elseif (key == 'drop_item_cnt') then
		return self.m_dropItemCnt

    elseif (key == 'total_damage_to_hero') then
		return self.m_totalDamageToHero

    elseif (key == 'total_damage_to_enemy') then
		return self.m_totalDamageToEnemy

    else
		return 0
	end
end

-------------------------------------
-- function printRecord
-- @brief 전체 로그를 출력
-------------------------------------
function LogRecorderWorld:printRecord()
	local t_print = 
	{
		attribute_count = self.m_attrCnt,
		evolution_count = self.m_evolutionCnt,
		dragon_count = self.m_dragonCnt,
		used_tamer = self.m_usedTamer,
		used_formation = self.m_usedFormation,
		used_dragon = self.m_usedDragon,
		used_role = self.m_usedRole,
		clear_count = self.m_clearCnt,
		death_count = self.m_deathCnt,
		skill_count = self.m_useSkillCnt,
		fever_count = self.m_feverCnt,
		lap_time = self.m_lapTime,
		boss_finish_attack = self.m_bossFinishAtk,
		char_log = m_tCharLogTable,
	}

	ccdump(t_print)
end