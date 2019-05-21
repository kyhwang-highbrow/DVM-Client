-------------------------------------
-- class Serverdata_IllusionDungeon
-- @instance g_illusionDungeonData
-------------------------------------
Serverdata_IllusionDungeon = class({
    m_illusionInfo = 'StructEventIllusion', -- 전설 관련 서버데이터 Struct

    m_lOpenEventId = 'list',

    -- 환상 이벤트 공용 매개변수
    m_lSortData = 'list', -- 정렬 관련 세팅 정보 보관
    m_lDragonDeck = 'list', -- 서버덱에 저장하는 대신 여기서 들고 있음

    m_lillusionDragonInfo = 'List-StructDragonObject',
    m_lillusionRuneInfo = 'List-StructRuneObject',
})


Serverdata_IllusionDungeon.STATE = {
	['INACTIVE'] = 1,	-- 이벤트 던전 비활성화
	['LOCK'] = 2,		-- 레벨 제한
	['OPEN'] = 3,		-- 이벤트 던전 입장 가능
	['REWARD'] = 4,		-- 보상 수령 가능
	['DONE'] = 5,		-- 보상 수령 후 
}

-------------------------------------
-- function init
-------------------------------------
function Serverdata_IllusionDungeon:init()
     self.m_lSortData = {}
     self.m_illusionInfo = StructEventIllusion(1) -- 임의로 이벤트 키 1로 설정
     self:loadIllusionDragonInfo()
end

-------------------------------------
-- function getEventIllusionInfo
-------------------------------------
function Serverdata_IllusionDungeon:getEventIllusionInfo()
     return self.m_illusionInfo
end

-------------------------------------
-- function getIllusionState
-- @brief 환상 던전의 상태 
-------------------------------------
function Serverdata_IllusionDungeon:getIllusionState()
    local illusion_key = 'event_illusion'
	-- 이벤트 기간
	if (g_hotTimeData:isActiveEvent(illusion_key)) then
		--[[
		-- 레벨 체크
		if (g_contentLockData:isContentLock('challenge_mode')) then
			return ServerData_ChallengeMode.STATE['LOCK']

		else
        --]]
			return Serverdata_IllusionDungeon.STATE['OPEN']
		--end

	-- 보상 수령 기간
	elseif (g_hotTimeData:isActiveEvent(illusion_key .. '_reward')) then
		--[[
		-- 레벨 체크
		if (g_contentLockData:isContentLock('challenge_mode')) then
			return ServerData_ChallengeMode.STATE['LOCK']
        
		-- 보상 수령 전 (0 -> 이번 시즌 보상 받을게 있음)
		if (self.m_seasonRewardStatus == 0) then
			return StructEventIllusion.STATE['REWARD']

		-- 보상 수령 후 (1 -> 이번 시즌 보상 받음, 2 -> 이번 시즌 보상 받을게 없음)
		elseif (self.m_seasonRewardStatus == 1) or (self.m_seasonRewardStatus == 2) then
			return StructEventIllusion.STATE['DONE']

		end
        --]]
	end
    
    -- 해당 없으면 비활성화
	return Serverdata_IllusionDungeon.STATE['INACTIVE']
end

-------------------------------------
-- function getIllusionStatusText
-------------------------------------
function Serverdata_IllusionDungeon:getIllusionStatusText()
    
    -- 연습전 기간 (프리시즌)
    if (self:getIllusionState() == Serverdata_IllusionDungeon.STATE['PRESEASON']) then
        local time = g_hotTimeData:getEventRemainTime('event_illusion') or 0
        str = Str('{1} 남음', datetime.makeTimeDesc(time, true)) -- param : sec, showSeconds, firstOnly, timeOnly
        return str
    end

    local time = g_hotTimeData:getEventRemainTime('event_illusion') or 0

    local str = ''
    if (not self:isActive_illusion()) then
        if (time <= 0) then
            str = Str('오픈시간이 아닙니다.')
        end

    elseif (0 < time) then
        str = Str('{1} 남음', datetime.makeTimeDesc(time, true)) -- param : sec, showSeconds, firstOnly, timeOnly

    else
        str = Str('종료되었습니다.')
    end

    return str
end

-------------------------------------
-- function isActive_grandArena
-------------------------------------
function Serverdata_IllusionDungeon:isActive_illusion()
    return (self:getIllusionState() ~= Serverdata_IllusionDungeon.STATE['INACTIVE'])
end

-------------------------------------
-- function makeAdventureID
-- @brief 환상 던전 스테이지 ID 생성
--
-- stage_id
-- 191xxxx
--    1xxx difficulty 1~4
--       1 stage 던전 종류 1~..
-------------------------------------
function Serverdata_IllusionDungeon:makeAdventureID(difficulty, stage)
    return 1910000 + (difficulty * 1000) + (stage)
end

-------------------------------------
-- function parseStageID
-- @brief 환상 던전 스테이지 ID 분석
-------------------------------------
function Serverdata_IllusionDungeon:parseStageID(stage_id)
    local stage_id = tonumber(stage_id)

    local difficulty = getDigit(stage_id, 1000, 1)
    local chapter = getDigit(stage_id, 100000, 2)
    local stage = getDigit(stage_id, 1, 2)

    return difficulty, chapter, stage
end


-------------------------------------
-- function getDragonDataFromUid
-------------------------------------
function Serverdata_IllusionDungeon:getDragonDataFromUid(doid)
    local t_dragon = g_dragonsData:getDragonDataFromUid(doid)
    
    if (t_dragon) then
        return t_dragon
    end
     
    for i, dragon_data in ipairs(self.m_lillusionDragonInfo) do
        if (dragon_data['id'] == doid) then
            return dragon_data
        end
    end
end

-------------------------------------
-- function getDragonsSortData
-- @brief doid만 가지고 정렬가능한 정보를 요구할 때 사용
-------------------------------------
function Serverdata_IllusionDungeon:getDragonsSortData(doid)

    local struct_dragon_object = self:getDragonDataFromUid(doid)
    local t_sort_data = self.m_lSortData[doid]

	-- @mskim 간혹 kibana에 보고되는 에러, 예외처리함
	if (not struct_dragon_object) then
		if (not t_sort_data) then
			t_sort_data = self:setDragonsSortData(doid)
		end
	elseif (not t_sort_data) or (t_sort_data['updated_at'] ~= struct_dragon_object['updated_at']) then
        t_sort_data = self:setDragonsSortData(doid)
    end

    return t_sort_data
end

-------------------------------------
-- function setDragonsSortData
-------------------------------------
function Serverdata_IllusionDungeon:setDragonsSortData(doid)
    local struct_dragon_object = self:getDragonDataFromUid(doid)
    local t_sort_data = self:makeDragonsSortData(struct_dragon_object)
    self.m_lSortData[doid] = t_sort_data

    return t_sort_data
end

-------------------------------------
-- function makeDragonsSortData
-------------------------------------
function Serverdata_IllusionDungeon:makeDragonsSortData(struct_dragon_object)

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[struct_dragon_object['did']]

    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(struct_dragon_object)

    local t_sort_data = {}
    t_sort_data['doid'] = doid
    t_sort_data['did'] = struct_dragon_object['did']
    t_sort_data['hp'] = status_calc:getFinalStat('hp')
    t_sort_data['def'] = status_calc:getFinalStat('def')
    t_sort_data['atk'] = status_calc:getFinalStat('atk')
    t_sort_data['attr'] = attributeStrToNum(t_dragon['attr'])
    t_sort_data['lv'] = struct_dragon_object['lv']
    t_sort_data['grade'] = struct_dragon_object['grade']
    t_sort_data['evolution'] = struct_dragon_object['evolution']
    t_sort_data['rarity'] = dragonRarityStrToNum(t_dragon['rarity'])
    t_sort_data['friendship'] = struct_dragon_object:getFlv()
    t_sort_data['combat_power'] = struct_dragon_object:getCombatPower(status_calc)
    t_sort_data['updated_at'] = struct_dragon_object['updated_at']

    return t_sort_data
end

-------------------------------------
-- function setDragonDeck
-------------------------------------
function Serverdata_IllusionDungeon:setDragonDeck(l_dragon)
    self.m_lDragonDeck = l_dragon
end

-------------------------------------
-- function setDragonDeck
-------------------------------------
function Serverdata_IllusionDungeon:getDragonDeck(l_dragon)
    return self.m_lDragonDeck or {}
end

-------------------------------------
-- function getIllusionStageTitle
-------------------------------------
function Serverdata_IllusionDungeon:getIllusionStageTitle()
        local table_stage = TABLE:get('stage_data')
        local struct_illusion = self:getEventIllusionInfo()
        local cur_stage_id = struct_illusion:getCurIllusionStageId()
        local cur_stage_info = table_stage[cur_stage_id]

        if (not cur_stage_info) then
            return ''
        end
        
        local cur_stage_str = cur_stage_info['t_name'] or ''
        return Str(cur_stage_str)
 end



-------------------------------------
 -- function loadIllusionDragonInfo
-------------------------------------
function Serverdata_IllusionDungeon:loadIllusionDragonInfo()
    self.m_lillusionDragonInfo = {}
    self.m_lillusionRuneInfo = {}
    local ret_json, success_load = TABLE:loadJsonTable('illusion_dragon_info', '.txt')
    
    if (ret_json['illusion_runes']) then
        local l_rune = ret_json['illusion_runes']
        for i, rune_data in ipairs(l_rune) do
            local _rune_data = StructRuneObject(rune_data)
            table.insert(self.m_lillusionRuneInfo, rune_data)
        end
    end

    if (ret_json['illusion_dragons']) then
        local l_dragon = ret_json['illusion_dragons']
        for i, dragon_data in ipairs(l_dragon) do
            local _dragon_data = StructDragonObject(dragon_data)
            _dragon_data['id'] = 'illusion_'.. i
            _dragon_data['updated_at'] = 0
            _dragon_data:setRuneObjects(self.m_lillusionRuneInfo)
            table.insert(self.m_lillusionDragonInfo, _dragon_data)
        end
    end
end

-------------------------------------
 -- function getIllusionDragonList
-------------------------------------
function Serverdata_IllusionDungeon:getIllusionDragonList()
    return self.m_lillusionDragonInfo or {}
end

-------------------------------------
 -- function isIllusionDragon
-------------------------------------
function Serverdata_IllusionDungeon:isIllusionDragon(struct_dragon_object)
    if (not struct_dragon_object) then
        return false
    end

    local dragon_id = tostring(struct_dragon_object['id']) or ''
    
    local is_illusion = string.match(dragon_id, 'illusion')
    return is_illusion
end




