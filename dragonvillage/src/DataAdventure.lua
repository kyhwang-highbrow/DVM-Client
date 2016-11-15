-- g_adventureData

--MAX_ADVENTURE_CHAPTER = 6
MAX_ADVENTURE_CHAPTER = 3
MAX_ADVENTURE_STAGE = 8
MAX_ADVENTURE_DIFFICULTY = 3

-------------------------------------
-- class DataAdventure
-------------------------------------
DataAdventure = class({
        m_userData = 'UserData',
        m_tData = 'table',

        m_lStageList = 'list',
        m_lSortStageList = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function DataAdventure:init(user_data_instance, user_data)

    self.m_userData = user_data_instance

    if (not user_data['adventure']) then
        user_data['adventure'] = {}
        user_data['adventure']['stage_list'] = {}
        user_data['adventure']['open_chapter'] = 1
        user_data['adventure']['last_stage'] =  makeAdventureID(1, 1, 1)
        user_data['adventure']['last_chapter'] = 1 -- 마지막에 플레이한 챕터
    end

    -- 'adventure'
    self.m_tData = user_data['adventure']
    self.m_lStageList = user_data['adventure']['stage_list']

    -- 정렬
    self.m_lSortStageList = {}
    for i,v in pairs(self.m_lStageList) do
        table.insert(self.m_lSortStageList, v)
    end

    table.sort(self.m_lSortStageList, function(a, b)
            return a['stage'] > b['stage']
        end)
end

-------------------------------------
-- function makeAdventureID
-- @brief 모험모드 스테이지 ID 생성
--
-- stage_id
-- 1xxxx mode 1(adventure) ~ 9
--  1xxx difficulty 1~3
--   01x chapter 01~10
--     1 stage 1~8 
--
-------------------------------------
function makeAdventureID(difficulty, chapter, stage)
    return 10000 + (difficulty * 1000) + (chapter * 10) + stage
end

-------------------------------------
-- function parseAdventureID
-- @brief 모험모드 스테이지 ID 분석
-------------------------------------
function parseAdventureID(stage_id)
    local stage_id = tonumber(stage_id)

    local difficulty = getDigit(stage_id, 1000, 1)
    local chapter = getDigit(stage_id, 10, 2)
    local stage = getDigit(stage_id, 1, 1)

    return difficulty, chapter, stage
end

-------------------------------------
-- function getStageData
-- @brief 
-- @param stage_id
-- @return 
--         ['clear_cnt']=0;
--         ['stage']='11017';
--         ['grade']=0;
-------------------------------------
function DataAdventure:getStageData(stage_id)
    local stage_id = tostring(stage_id)

    if self.m_lStageList[stage_id] then
        return self.m_lStageList[stage_id]
    else
        return self:makeStageData(stage_id)
    end
end

-------------------------------------
-- function getStageScoreList
-- @brief 스테이지별 스코어 0~3
-- @param difficulty
-- @param chapter
-------------------------------------
function DataAdventure:getStageScoreList(difficulty, chapter)
    local t_ret = {}

    local focus_stage = nil

    for i=1, MAX_ADVENTURE_STAGE do
        local stage_id = makeAdventureID(difficulty, chapter, i)
        local t_stage_data = self:getStageData(stage_id)
        t_ret[i] = t_stage_data

        if (not focus_stage) then
            focus_stage = i
        end

        if (t_stage_data['grade'] > 0) then
            focus_stage = math_min(i + 1, MAX_ADVENTURE_STAGE)
        end
    end
    
    return t_ret, focus_stage
end

-------------------------------------
-- function clearStage
-- @brief
-------------------------------------
function DataAdventure:clearStage(stage_id, grade)
    local stage_id = tostring(stage_id)

    local t_stage_data = nil

    if (not self.m_lStageList[stage_id]) then
        self.m_lStageList[stage_id] = self:makeStageData(stage_id)

        -- 정렬 테이블에도 추가 후 정렬
        table.insert(self.m_lSortStageList, self.m_lStageList[stage_id])
        table.sort(self.m_lSortStageList, function(a, b)
            return a['stage'] > b['stage']
        end)
    end

    t_stage_data = self.m_lStageList[stage_id]
    t_stage_data['grade'] = math_max(grade, t_stage_data['grade'])
    t_stage_data['clear_cnt'] = t_stage_data['clear_cnt'] + 1

    -- 챕터 오픈
    if (t_stage_data['clear_cnt'] == 1) then
        local difficulty, chapter, stage = parseAdventureID(stage_id)
        if (difficulty == 1) and (stage == MAX_ADVENTURE_STAGE) then
            local open_chapter = math_min(chapter + 1, MAX_ADVENTURE_CHAPTER)
            self.m_tData['open_chapter'] = open_chapter
        end

    end

    self.m_userData:setDirtyLocalSaveData()
end

-------------------------------------
-- function makeStageData
-- @brief
--{
--    "fixed_lucky_point": 0,
--    "hid_1": 111033,
--    "stage": 10021,
--    "grade": 3,
--    "challenge_b": 1,
--    "hid_3": 111013,
--    "rare_hero_piece_gauge": 0,
--    "rare_hero_piece": 0,
--    "drop_fixed_gauge": 6,
--    "lap": 0,
--    "uid": "1531",
--    "hid_2": 111013,
--    "challenge_a": 1,
--    "total_drop_fixed_cnt": 0,
--    "clear_cnt": 6,
--    "lucky_point": 6
--},
-------------------------------------
function DataAdventure:makeStageData(stage_id)
    local stage_id = tostring(stage_id)

    local t_stage_data = {}
    t_stage_data['stage'] = stage_id
    t_stage_data['grade'] = 0
    t_stage_data['clear_cnt'] = 0
    t_stage_data['first_reward'] = 0 -- 0은 확인 전, -1은 보상 없음, 1은 보상 있음, 2는 수령 가능, 3은 수령 완료
    return t_stage_data
end

-------------------------------------
-- function getDigit
-- @brief id에서 특정 자릿수를 리턴
-- @param id
-- @param base_digit 기본 자릿수
-- @param range 자릿수 범위
-- ex) IDHelper:getDigit(12345, 100, 2) = 23
-------------------------------------
function getDigit(id, base_digit, range)
    local range = range or 1
    local digit = math_floor((id % (base_digit * math_pow(10, range)))/base_digit)
    return digit
end


-------------------------------------
-- function getFocusHighStage
-- @brief
-------------------------------------
function DataAdventure:getFocusHighStage()
    -- # 가장 높은 클리어 스테이지를 얻어온다.
    -- # grade가 0보다 작으면 해당 stage_id를 리턴
    -- # stage가 8보다 작으면 stage_id + 1
    -- # stage가 8이면 chapter를 하나 올리고 stage를 1로 지정
end

-------------------------------------
-- function isOpenGlobalChapter
-- @brief
-------------------------------------
function DataAdventure:isOpenGlobalChapter(chapter)
    if (MAX_ADVENTURE_CHAPTER < chapter) then
        return false
    end

    local is_open = (chapter <= self.m_tData['open_chapter'])
    return is_open
end

-------------------------------------
-- function isOpenStage
-- @brief stage_id에 해당하는 스테이지가 입장 가능한지를 리턴
-------------------------------------
function DataAdventure:isOpenStage(stage_id)
    local prev_stage_id = getPrevStageID(stage_id)

    if (not prev_stage_id) then
        return true
    else
        t_stage_data = self:getStageData(prev_stage_id)
        local is_open = (0 < t_stage_data['clear_cnt'])
        return is_open
    end
end

-------------------------------------
-- function isOpenChapter
-- @brief
-------------------------------------
function DataAdventure:isOpenChapter(difficulty, chapter)
    if (MAX_ADVENTURE_CHAPTER < chapter) then
        return false
    end

    local stage = 1
    local stage_id = makeAdventureID(difficulty, chapter, stage)
    return self:isOpenStage(stage_id)
end

-------------------------------------
-- function getChapterOpenDifficulty
-- @brief
-------------------------------------
function DataAdventure:getChapterOpenDifficulty(chapter)
    if (MAX_ADVENTURE_CHAPTER < chapter) then
        return 0
    end
    
    local open_difficulty = 0
    for i=1, MAX_ADVENTURE_DIFFICULTY do
        if self:isOpenChapter(i, chapter) then
            open_difficulty = i
        end
    end

    return open_difficulty
end

-------------------------------------
-- function getPrevStageID
-- @brief
-------------------------------------
function getPrevStageID(stage_id)
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    if (difficulty==1) and (chapter==1) and (stage==1) then
        return false
    end

    if (difficulty == 1) then
        if (stage == 1) then
            return makeAdventureID(difficulty, chapter-1, MAX_ADVENTURE_STAGE)
        else
            return makeAdventureID(difficulty, chapter, stage-1)
        end
    else
        if (stage == 1) then
            return makeAdventureID(difficulty-1, chapter, MAX_ADVENTURE_STAGE)
        else
            return makeAdventureID(difficulty, chapter, stage-1)
        end
    end
end

-------------------------------------
-- function allStageClear
-- @TEST
-- stage_id
-- 1xxxx mode 1(adventure) ~ 9
--  1xxx difficulty 1~3
--   01x chapter 01~10
--     1 stage 1~8 
--
-------------------------------------
function DataAdventure:allStageClear()
	for difficulty = 1, 3 do
		for chapter = 1, MAX_ADVENTURE_CHAPTER do
			for stage = 1, MAX_ADVENTURE_STAGE do
				local stage_id = makeAdventureID(difficulty, chapter, stage)
                stage_id = tostring(stage_id)

				local t_stage_data = {}
				t_stage_data['stage'] = stage_id
				t_stage_data['grade'] = 3
				t_stage_data['clear_cnt'] = 1
				t_stage_data['first_reward'] = 2 -- 0은 확인 전, -1은 보상 없음, 1은 보상 있음, 2는 수령 가능, 3은 수령 완료
				
				self.m_lStageList[stage_id] = t_stage_data
			end
		end
	end

	self.m_tData['open_chapter'] = 6

	self.m_userData:setDirtyLocalSaveData(true)
end


-------------------------------------------------------------------------------------------------------------------
-- 최초 클리어 보상 관련 start
-------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function getFirstRewardInfo
-- @brief
-------------------------------------
function DataAdventure:getFirstRewardInfo(stage_id)
    local t_stage_data = self:getStageData(stage_id)

    -- 0은 확인 전, -1은 보상 없음, 1은 보상 있음, 2는 수령 가능, 3은 수령 완료
    if (not t_stage_data['first_reward']) then
        t_stage_data['first_reward'] = 0
        self.m_userData:setDirtyLocalSaveData()
    end

    local table_first_reward = TABLE:get('first_reward')
    local t_first_reward = table_first_reward[stage_id]

    -- 0이 아닌 경우 즉시 리턴
    if (t_stage_data['first_reward'] ~= 0) then
        local state = self:fristRewardStateNumToStr(t_stage_data['first_reward'])

        -- 세이브데이터에는 'NA'상태인데 테이블에는 보상 정보가 존재할 경우 초기화
        if ((state == 'NA') and t_first_reward) then
            t_stage_data['first_reward'] = 0

        -- 세이브데이터에는 보상 정보가 있는데 테이블에는 보상 정보가 존재하지 않을 경우 초기화
        elseif ((state ~= 'NA') and (not t_first_reward)) then
            t_stage_data['first_reward'] = 0
        
        -- 현재 상태를 리턴
        else
            return state
        end

    end

    -- 이하 코드는 0인 경우 초기화 작업

    -- 보상 정보가 있을 경우
    if t_first_reward then
        if (1 <= t_stage_data['clear_cnt']) then
            t_stage_data['first_reward'] = self:fristRewardStateStrToNum('open')
        else
            t_stage_data['first_reward'] = self:fristRewardStateStrToNum('lock')
        end
    else
        t_stage_data['first_reward'] = self:fristRewardStateStrToNum('NA')
    end
    self.m_userData:setDirtyLocalSaveData()

    local state = self:fristRewardStateNumToStr(t_stage_data['first_reward'])
    return state
end

-------------------------------------
-- function fristRewardStateNumToStr
-- @brief
-------------------------------------
function DataAdventure:fristRewardStateNumToStr(first_reward_state_num)
    if (type(first_reward_state_num) == 'string') then
        return first_reward_state_num
    end

    -- 해당사항 없음
    if (first_reward_state_num == -1) then
        return 'NA'

    -- 상자 잠김(스테이지 클리어 전)
    elseif (first_reward_state_num == 1) then
        return 'lock'

    -- 상자 열림(스테이지 클리어 후 보상은 받지 않은 상태)
    elseif (first_reward_state_num == 2) then
        return 'open'

    -- 보상까지 수령한 상태
    elseif (first_reward_state_num == 3) then
        return 'finish'

    else
        error('first_reward_state_num : ' .. first_reward_state_num)
    end

end

-------------------------------------
-- function fristRewardStateStrToNum
-- @brief
-------------------------------------
function DataAdventure:fristRewardStateStrToNum(first_reward_state_str)
    if (type(first_reward_state_str) == 'number') then
        return first_reward_state_str
    end

    -- 해당사항 없음
    if (first_reward_state_str == 'NA') then
        return -1

    -- 상자 잠김(스테이지 클리어 전)
    elseif (first_reward_state_str == 'lock') then
        return 1

    -- 상자 열림(스테이지 클리어 후 보상은 받지 않은 상태)
    elseif (first_reward_state_str == 'open') then
        return 2

    -- 보상까지 수령한 상태
    elseif (first_reward_state_str == 'finish') then
        return 3

    else
        error('first_reward_state_str : ' .. first_reward_state_str)
    end

end

-------------------------------------
-- function optainFirstReward
-- @brief 최초 클리어 보상 획득
-------------------------------------
function DataAdventure:optainFirstReward(stage_id)
    local state = self:getFirstRewardInfo(stage_id)

    if (state ~= 'open') then
        error('state : ' .. state)
    end

    local table_first_reward = TABLE:get('first_reward')
    local t_first_reward = table_first_reward[stage_id]

    -- 보상 지급
    --[[
    for i=1, 10 do
        local item_id = t_first_reward['reward_' .. i] or 0
        local item_cnt = t_first_reward['value_' .. i] or 0

        if (item_id ~= 0) then
            g_userDataOld:optainItem(item_id, item_cnt)
        end
    end
    --]]

    -- 최초 클리어 보상 완료 처리
    local t_stage_data = self:getStageData(stage_id)
    t_stage_data['first_reward'] = self:fristRewardStateStrToNum('finish')

    self.m_userData:setDirtyLocalSaveData()
end

-------------------------------------------------------------------------------------------------------------------
-- 최초 클리어 보상 관련 end
-------------------------------------------------------------------------------------------------------------------