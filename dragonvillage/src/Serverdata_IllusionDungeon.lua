-------------------------------------
-- class Serverdata_IllusionDungeon
-- @instance g_illusionDungeonData
-------------------------------------
Serverdata_IllusionDungeon = class({
    m_illusionInfo = 'StructEventIllusion',

    m_lOpenEventId = 'list',

    m_lSortData = 'list', -- 정렬 관련 세팅 정보 보관
    m_lDragonDeck = 'list', -- 서버덱에 저장하는 대신 여기서 들고 있음

    m_lIllusionDragonInfo = 'List-StructDragonObject',
    m_lIllusionRuneInfo = 'List-StructRuneObject',

    m_lIllusionRank = 'list', -- 랭크 리스트
    m_lIllusionRankReward = 'list', -- 랭크 보상 리스트

    m_gameKey = 'number',

    -- 둘 중 하나라도 없다면 보상 없음
    m_lastInfo = 'table',
    m_rewardInfo = 'table',
})


Serverdata_IllusionDungeon.STATE = {
	['INACTIVE'] = 1,	-- 이벤트 던전 비활성화
	['LOCK'] = 2,		-- 레벨 제한
	['OPEN'] = 3,		-- 이벤트 던전 입장 가능
	['REWARD'] = 4,		-- 보상 수령 가능
	['DONE'] = 5,		-- 보상 수령 후 
}


local MAX_ILLUSION_DIFFICULTY = 4
-------------------------------------
-- function init
-------------------------------------
function Serverdata_IllusionDungeon:init()
     self.m_lSortData = {}
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
			return Serverdata_IllusionDungeon.STATE['REWARD']
        
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
-- function getIllusionExchanageStatusText
-------------------------------------
function Serverdata_IllusionDungeon:getIllusionExchanageStatusText()

    local time = g_hotTimeData:getEventRemainTime('event_illusion_reward') or 0

    local str = ''
    if (0 < time) then
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
-- function makeIllusionStageID
-- @brief 환상 던전 스테이지 ID 생성
--
-- stage_id
-- 191xxxx
--    1xxx difficulty 1~4
--       1 stage 던전 종류 1~..
-------------------------------------
function Serverdata_IllusionDungeon:makeIllusionStageID(difficulty, stage)
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
-- function parseStageID
-- @brief 환상 던전 스테이지 ID 분석
-------------------------------------
function Serverdata_IllusionDungeon:getNextStage(stage_id)
    local difficulty, chapter, stage = self:parseStageID(stage_id)

    if (difficulty < MAX_ILLUSION_DIFFICULTY) then
        local next_diff = difficulty + 1
        local next_stage_id = self:makeIllusionStageID(next_diff, 1)
        return next_stage_id
    end
    
    return nil
end

-------------------------------------
-- function getDragonDataFromUid
-------------------------------------
function Serverdata_IllusionDungeon:getDragonDataFromUid(doid)
    local t_dragon = g_dragonsData:getDragonDataFromUid(doid)
    
    if (t_dragon) then
        return t_dragon
    end
     
    for i, dragon_data in ipairs(self.m_lIllusionDragonInfo) do
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
    local t_sort_data = g_dragonsData:makeDragonsSortData(struct_dragon_object)
    self.m_lSortData[doid] = t_sort_data

    return t_sort_data
end

-------------------------------------
-- function setDragonDeck
-------------------------------------
function Serverdata_IllusionDungeon:setDragonDeck(l_dragon)
    self.m_lDragonDeck = l_dragon

    local ret_json, success_load = TABLE:loadJsonTable('illusion_dragon_info', '.txt')
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
 -- @brief 환상던전 드래곤 정보를 로컬데이터에서 불러옴
-------------------------------------
function Serverdata_IllusionDungeon:loadIllusionDragonInfo()
    self.m_lIllusionDragonInfo = {}
    self.m_lIllusionRuneInfo = {}
    local ret_json, success_load = TABLE:loadJsonTable('illusion_dragon_info', '.txt')
    
    if (not success_load) then
        return
    end

    if (ret_json['illusion_runes']) then
        local l_rune = ret_json['illusion_runes']
        for i, rune_data in ipairs(l_rune) do
            local _rune_data = StructRuneObject(rune_data)
            table.insert(self.m_lIllusionRuneInfo, rune_data)
        end
    end

    if (ret_json['illusion_dragons']) then
        local l_dragon = ret_json['illusion_dragons']
        for i, dragon_data in ipairs(l_dragon) do
            local _dragon_data = StructDragonObject(dragon_data)
            _dragon_data['id'] = 'illusion_'.. i
            _dragon_data['updated_at'] = 0
            _dragon_data:setRuneObjects(self.m_lIllusionRuneInfo)
            table.insert(self.m_lIllusionDragonInfo, _dragon_data)
        end
    end
end

-------------------------------------
 -- function getIllusionDragonList
-------------------------------------
function Serverdata_IllusionDungeon:getIllusionDragonList()
    return self.m_lIllusionDragonInfo or {}
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

-------------------------------------
 -- function isIllusionDragonType
-------------------------------------
function Serverdata_IllusionDungeon:isIllusionDragonType(t_dragon_data)
    local table_dragon = TableDragon()
    local target_dragon_id = t_dragon_data['did']
    if (not target_dragon_id) then
        return false
    end
    
    -- 현재 환상인 드래곤 정보
    local l_illusion_dragon = g_illusionDungeonData:getIllusionDragonList()
    
    -- 같은 종류라면 true 반환    
    local target_dragon_type = table_dragon:getDragonType(target_dragon_id)
    local illusion_dragon_type = table_dragon:getDragonType(l_illusion_dragon[1]['did'])
    return (target_dragon_type == illusion_dragon_type)
end

-------------------------------------
 -- function getParticiPantInfo
 -- @brief 덱에 환상 드래곤 있을 경우 return 마이너스값, 덱에 나의 (환상류) 드래곤을 들고 있었다면 return 플러스값, 환상 드래곤이 출전 하지 않았다면 0
-------------------------------------
function Serverdata_IllusionDungeon:getParticiPantInfo()
    local participant_count = 0

    for i, dragon_id in ipairs(self.m_lDragonDeck) do
        local t_dragon_data = g_illusionDungeonData:getDragonDataFromUid(dragon_id)
        if (self:isIllusionDragonType(t_dragon_data)) then
            -- 환상드래곤이 내 드래곤이라면 
            if (not self:isIllusionDragon(t_dragon_data)) then
                participant_count = participant_count + 1
            else
                participant_count = participant_count - 5
            end
        end
    end
    return participant_count
end

-------------------------------------
 -- function isSameDid
-------------------------------------
function Serverdata_IllusionDungeon:isSameDid(a_doid, b_doid)
    local a_dragon = g_illusionDungeonData:getDragonDataFromUid(a_doid)
    local b_dragon = g_illusionDungeonData:getDragonDataFromUid(b_doid)

    if (not a_dragon) or (not b_dragon) then
        return false
    end

    local a_did = a_dragon:getDid()
    local b_did = b_dragon:getDid()

    return a_did == b_did
end

-------------------------------------
 -- function request_illusionInfo
-------------------------------------
function Serverdata_IllusionDungeon:request_illusionInfo(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    -- 콜백 함수
    local function success_cb(ret)
        self.m_lIllusionRankReward = ret['rank_reward_list'] or {}

        -- 환상 던전 토큰 갱신
        if (ret['event_illusion']) then
            if (ret['event_illusion']['token']) then
                g_serverData:applyServerData(ret['event_illusion']['token'], 'user', 'event_illusion')
            end
            self.m_illusionInfo = StructEventIllusion(ret['event_illusion'])
        end

        if (finish_cb) then
            finish_cb()

            -- 보상이 들어왔을 경우 정보 저장, nil 여부로 보상 확인
            if (ret['lastinfo']) then
                self.m_lastInfo = ret['lastinfo']
            else
                self.m_lastInfo = nil
            end

            if (ret['reward_info']) then
                self.m_rewardInfo = ret['reward_info']
            else
                self.m_rewardInfo = nil
            end

        end
    end

    -- 콜백 함수
    local function fail_cb(ret)
        if (fail_cb) then
            fail_cb()
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/illusion_dungeon/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function request_illusionStart
-------------------------------------
function Serverdata_IllusionDungeon:request_illusionStart(stage_id, deck_name, finish_cb, fail_cb)
    local func_request
    local func_success_cb
    local func_response_status_cb
    local stage = stage_id
    func_request = function()
        -- 유저 ID
        local uid = g_userData:get('uid')

        -- 네트워크 통신
        local ui_network = UI_Network()
        ui_network:setUrl('/game/illusion_dungeon/start')
        ui_network:setParam('uid', uid)
        ui_network:setParam('dungeon_number', 1) -- 전설 환상 던전으로 고정
        ui_network:setParam('deck_name', 'illusion')
        ui_network:setParam('is_mydragon', 0) -- 환상 드래곤 부류의 내 드래곤을 사용했나 여부 (아직 서버로직 확실치 않음)
        ui_network:setParam('stage', stage)
        ui_network:setMethod('POST')
        ui_network:setSuccessCB(func_success_cb)
        ui_network:setResponseStatusCB(response_status_cb)
        ui_network:setFailCB(fail_cb)
        ui_network:setRevocable(true)
        ui_network:setReuse(false)
        ui_network:request()
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    func_response_status_cb = function(ret)
        --[[
        if (ret['status'] == -1108) then
            -- 비슷한 티어 매칭 상대가 없는 상태
            -- 콜로세움 UI로 이동
            local function ok_cb()
                UINavigator:goTo('arena')
            end 
            MakeSimplePopup(POPUP_TYPE.OK, Str('현재 점수 구간 내의 대전 가능한 상대가 없습니다.\n다른 상대의 콜로세움 참여를 기다린 후에 다시 시도해 주세요.'), ok_cb)
            return true
        end
        --]]

        return false
    end

    -- 성공 콜백
    func_success_cb = function(ret)
        -- staminas, cash 동기화
        g_serverData:networkCommonRespone(ret)
        --[[
        -- 상대방 정보 여기서 설정
        if (ret['match_user']) then
            self:makeMatchUserInfo(ret['match_user'])
        end
        --]]
        self.m_gameKey = ret['gamekey']

        -- 실제 플레이 시간 로그를 위해 체크 타임 보냄
        g_accessTimeData:startCheckTimer()

        if finish_cb then
            finish_cb(self.m_gameKey)
        end
    end

    func_request()
end

-------------------------------------
 -- function request_illusionRankInfo
-------------------------------------
function Serverdata_IllusionDungeon:request_illusionRankInfo(rank_type, offset, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self.m_lIllusionRank = ret
        if (finish_cb) then
            finish_cb()
        end
    end

    -- 콜백 함수
    local function fail_cb(ret)
        return {}
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/illusion_dungeon/rank')
    ui_network:setParam('uid', uid)
    ui_network:setParam('offset', offset)
    ui_network:setParam('limit', 20)
    ui_network:setParam('type', rank_type)
    ui_network:setParam('dungeon_number', 1)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end


-------------------------------------
 -- function request_illusionShopInfo
-------------------------------------
function Serverdata_IllusionDungeon:request_illusionShopInfo(finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
           --[[
           "table":{
                "price":3000,
                "id":1001,
                "buy_count":2,
                "item":"703003;1",
                "token":700208
              }
            },{
              "table":{
                "price":2400,
                "id":1002,
                "buy_count":1,
                "item":"779215;1",
                "token":700208
              }
        --]]
        if (finish_cb) then
            finish_cb(ret)
        end 
    end

     -- 콜백 함수
    local function fail_cb(ret)
        return {}
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/illusion_dungeon/exchange_info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('dungeon_number', 1)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
 -- function request_illusionShopInfo
-------------------------------------
function Serverdata_IllusionDungeon:request_illusionExchange(prodeuct_id, count, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if (finish_cb) then
            finish_cb(ret)
        end 
    end

     -- 콜백 함수
    local function fail_cb(ret)
        return {}
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/illusion_dungeon/exchange')
    ui_network:setParam('uid', uid)
    ui_network:setParam('ex_id', prodeuct_id)
    ui_network:setParam('count', count)
    ui_network:setParam('dungeon_number', 1)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end




