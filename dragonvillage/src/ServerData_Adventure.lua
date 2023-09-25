MAX_ADVENTURE_CHAPTER = 12
MAX_ADVENTURE_STAGE = 7
MAX_ADVENTURE_DIFFICULTY = 5

-------------------------------------
---@class ServerData_Adventure
-- g_adventureData
---@return ServerData_Adventure
-------------------------------------
ServerData_Adventure = class({
        m_serverData = 'ServerData',

        m_stageList = 'map',
        m_chapterAchieveInfoList = 'map', -- 챕터(챕터와 난이도를 포함한)별 도전과제 달성 정보 리스트

        -- 챕터 달성도 테이블 정보(서버에서 던져줌)
        m_chapterAchiveDataTable = 'map',

		-- 스테이지 정보 갱신 필요 여부(true일 경우 갱신 필요)
        m_bDirtyStageList = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Adventure:init(server_data)
    self.m_serverData = server_data
    self.m_bDirtyStageList = true
end

-------------------------------------
-- function request_adventureInfo
-------------------------------------
function ServerData_Adventure:request_adventureInfo(finish_cb, fail_cb)

    -- 스테이지 정보 갱신이 필요하지 않은 경우
    if (self.m_bDirtyStageList == false) then
        finish_cb()
        return
    end

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_adventureInfo(ret)
        
        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/stage/list')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', GAME_MODE_ADVENTURE) -- 11 : adventrue(모험)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function response_adventureInfo
-------------------------------------
function ServerData_Adventure:response_adventureInfo(ret)
    self:organizeStageList(ret['stage_list'])
    self:organizeChapterAchieveInfoList(ret['chapter_list'])
    self:organizeChapterAchieveDataTable(ret['chapter_archievement'])
    g_adventureFirstRewardData:organizeFirstRewardDataTable(ret['first_reward_list'])

    -- 정보가 갱신됨
    self.m_bDirtyStageList = false
end

-------------------------------------
-- function setDirtyStageList
-- @brief 스테이지 정보 갱신이 필요한 경우
-------------------------------------
function ServerData_Adventure:setDirtyStageList()
    self.m_bDirtyStageList = true
end

-------------------------------------
-- function organizeStageList
-------------------------------------
function ServerData_Adventure:organizeStageList(stage_list)
    self.m_stageList = {}

    for i,v in pairs(stage_list) do
        local key = tonumber(i)
        v['stage_id'] = key
        self.m_stageList[key] = StructAdventureStageInfo(v)
    end
end

-------------------------------------
-- function organizeStageList_modified
-------------------------------------
function ServerData_Adventure:organizeStageList_modified(stage_list)
    if (not stage_list) then
        return
    end

    if (not self.m_stageList) then
        self.m_stageList = {}
    end

    for i,v in pairs(stage_list) do
        local key = tonumber(i)
        v['stage_id'] = key
        self.m_stageList[key] = StructAdventureStageInfo(v)
    end
end

-------------------------------------
-- function getStageInfo
-------------------------------------
function ServerData_Adventure:getStageInfo(stage_id)
    if (not self.m_stageList[stage_id]) then
        self.m_stageList[stage_id] = StructAdventureStageInfo()
        self.m_stageList[stage_id].stage_id = stage_id
    end

    return self.m_stageList[stage_id]
end

-------------------------------------
-- function getStageClearCnt
-------------------------------------
function ServerData_Adventure:getStageClearCnt(stage_id)
	if (self.m_stageList[stage_id]) then
		return self.m_stageList[stage_id]['clear_cnt']
	end

	return 0
end

-------------------------------------
-- function getLastClearedStage
-- @breif 클리어한 마지막 스테이지
-------------------------------------
function ServerData_Adventure:getLastClearedStage()
    local ret_id = 0
	for stage_id, t_stage_info in pairs(self.m_stageList) do
        if (ret_id < stage_id) then
            ret_id = stage_id
        end
    end
    return ret_id
end

-------------------------------------
-- function organizeChapterAchieveDataTable
-------------------------------------
function ServerData_Adventure:organizeChapterAchieveDataTable(chapter_archievement)
    self.m_chapterAchiveDataTable = table.listToMap(chapter_archievement, 'chapter_id')
end



-------------------------------------
-- function getChapterAchieveData
-------------------------------------
function ServerData_Adventure:getChapterAchieveData(chapter_id)
    return self.m_chapterAchiveDataTable[chapter_id]
end

-------------------------------------
-- function organizeChapterAchieveInfoList
-------------------------------------
function ServerData_Adventure:organizeChapterAchieveInfoList(chapter_list)
    if (not chapter_list) then
        return
    end

    -- 무조건 새로 생성 전체를 갱신
    self.m_chapterAchieveInfoList = {}

    for i,v in pairs(chapter_list) do
        local key = v['chapter_id']
        self.m_chapterAchieveInfoList[key] = StructAdventureChapterAchieveInfo(v)
    end
end

-------------------------------------
-- function organizeChapterAchieveInfoList_modified
-------------------------------------
function ServerData_Adventure:organizeChapterAchieveInfoList_modified(chapter_list)
    if (not chapter_list) then
        return
    end

    if (not self.m_chapterAchieveInfoList) then
        self.m_chapterAchieveInfoList = {}
    end

    for i,v in pairs(chapter_list) do
        local key = v['chapter_id']
        self.m_chapterAchieveInfoList[key] = StructAdventureChapterAchieveInfo(v)
    end
end

-------------------------------------
-- function getChapterAchieveInfo
-------------------------------------
function ServerData_Adventure:getChapterAchieveInfo(chapter_id)
    if (not self.m_chapterAchieveInfoList[chapter_id]) then
        self.m_chapterAchieveInfoList[chapter_id] = StructAdventureChapterAchieveInfo()
        self.m_chapterAchieveInfoList[chapter_id].chapter_id = chapter_id
    end

    return self.m_chapterAchieveInfoList[chapter_id]
end

-------------------------------------
-- function request_chapterAchieveReward
-------------------------------------
function ServerData_Adventure:request_chapterAchieveReward(chapter_id, star, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        -- @analytics
        Analytics:trackUseGoodsWithRet(ret, '챕터 달성 보상')

        -- 아이템 수령
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 챕터 정보 갱신
        self:organizeChapterAchieveInfoList_modified(ret['modified_chapter'])

        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/chapter/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('chapter_id', chapter_id)
    ui_network:setParam('star', star)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function isOpenStage
-- @brief stage_id에 해당하는 스테이지가 입장 가능한지를 리턴
-------------------------------------
function ServerData_Adventure:isOpenStage(stage_id)
    local prev_stage_id = getPrevStageID(stage_id)
    if (not prev_stage_id) then
        return true
    else
        return self:isClearStage(prev_stage_id)
    end
end

-------------------------------------
-- function isOpenChapter
-- @brief
-------------------------------------
function ServerData_Adventure:isOpenChapter(difficulty, chapter)
    if (MAX_ADVENTURE_CHAPTER < chapter) then
        return false
    end

    local stage = 1
    local stage_id = makeAdventureID(difficulty, chapter, stage)
    return self:isOpenStage(stage_id)
end

-------------------------------------
-- function isClearStage
-- @brief 해당 스테이지 클리어 여부
-------------------------------------
function ServerData_Adventure:isClearStage(stage_id)
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    -- 깜짝 출현 스테이지는 항상 클리어
    if (isAdventStageID(stage_id)) then
        return true
    end

	-- 룬 축제 이벤트는 항상 클리어
    if (g_stageData:isRuneFestivalStage(stage_id) == true) then
        return true
    end

    local stage_info = self:getStageInfo(stage_id)
    return (0 < stage_info['clear_cnt'])
end

-------------------------------------
-- function isClearChapter
-- @brief 해당 챕터 클리어 여부
-------------------------------------
function ServerData_Adventure:isClearChapter(difficulty, chapter)
    if (MAX_ADVENTURE_CHAPTER < chapter) then
        return false
    end

    local stage = MAX_ADVENTURE_STAGE
    local stage_id = makeAdventureID(difficulty, chapter, stage)
    return self:isClearStage(stage_id)
end

-------------------------------------
-- function getSimplePrevStageID
-- @brief 같은 챕터 안에서 이전 스테이지
-------------------------------------
function ServerData_Adventure:getSimplePrevStageID(stage_id)
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    if (1 < stage) then
        local next_stage_id = makeAdventureID(difficulty, chapter, stage - 1)
        return next_stage_id
    end

    return nil
end

-------------------------------------
-- function getNextStageID
-- @brief
-------------------------------------
function ServerData_Adventure:getNextStageID(stage_id)
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    if (stage < self:getMaxStage(chapter)) then
        local next_stage_id = makeAdventureID(difficulty, chapter, stage + 1)
        return next_stage_id
    end

    if (chapter < MAX_ADVENTURE_CHAPTER) then
        local next_stage_id = makeAdventureID(difficulty, chapter + 1, 1)
        return next_stage_id
    end

    if (difficulty < MAX_ADVENTURE_DIFFICULTY) then
        -- 깜짝 출현 챕터로 인해 다음 난이도의 첫번째 챕터 예외처리
        local first_chapter
        if (chapter == SPECIAL_CHAPTER.ADVENT) then
            first_chapter = SPECIAL_CHAPTER.ADVENT
        elseif (chapter == SPECIAL_CHAPTER.RUNE_FESTIVAL) then -- 룬 축제 이벤트
            first_chapter = SPECIAL_CHAPTER.RUNE_FESTIVAL
        else
            first_chapter = 1
        end

        local next_stage_id = makeAdventureID(difficulty + 1, first_chapter, 1)
        return next_stage_id
    end
    
    return nil
end

-------------------------------------
-- function getSimpleNextStageID
-- @brief 같은 챕터 안에서 다음 스테이지
-------------------------------------
function ServerData_Adventure:getSimpleNextStageID(stage_id)
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    if (stage < self:getMaxStage(chapter)) then
        local next_stage_id = makeAdventureID(difficulty, chapter, stage + 1)
        return next_stage_id
    end

    return nil
end

-------------------------------------
-- function getMaxStage
-- @brief chapter에 따라 최대 스테이지 리턴
-------------------------------------
function ServerData_Adventure:getMaxStage(chapter)
    if (chapter == SPECIAL_CHAPTER.ADVENT) then
        return g_eventAdventData:getAdventStageCount()
    elseif (chapter == SPECIAL_CHAPTER.RUNE_FESTIVAL) then -- 룬 축제 이벤트
        return g_eventRuneFestival:getAdventStageCount()
    else
        return MAX_ADVENTURE_STAGE
    end
end

-------------------------------------
-- function getChapterOpenDifficulty
-- @brief
-------------------------------------
function ServerData_Adventure:getChapterOpenDifficulty(chapter)
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
-- function getFocusStage
-- @brief 해당 스테이지에서 진입 가능한 가장 높은 스테이지 리턴
-------------------------------------
function ServerData_Adventure:getFocusStage(difficulty, chapter)
    local focus_stage = nil

    for i=1, MAX_ADVENTURE_STAGE do
        local stage_id = makeAdventureID(difficulty, chapter, i)
        local stage_info = self:getStageInfo(stage_id)

        if (not focus_stage) then
            focus_stage = i
        end

        if (stage_info['clear_cnt'] > 0) then
            focus_stage = math_min(i + 1, MAX_ADVENTURE_STAGE)
        end
    end

    return focus_stage
end


-------------------------------------
-- function makeAdventureID
-- @brief 모험모드 스테이지 ID 생성
--
-- stage_id
-- 1xxxxx mode 1(adventure) ~ 9
--  1xxxx difficulty 1~3
--   01xx chapter 01~12
--     01 stage 1~12
--
-------------------------------------
function makeAdventureID(difficulty, chapter, stage)
    return 1100000 + (difficulty * 10000) + (chapter * 100) + stage
end

-------------------------------------
-- function makeAdventureChapterID
-- @brief 모험모드 챕터 ID 생성
-------------------------------------
function makeAdventureChapterID(difficulty, chapter)
    local chapter_id = (difficulty * 100) + chapter
    return chapter_id
end

-------------------------------------
-- function parseAdventureID
-- @brief 모험모드 스테이지 ID 분석
-------------------------------------
function parseAdventureID(stage_id)
    local stage_id = tonumber(stage_id)

    local difficulty = getDigit(stage_id, 10000, 1)
    local chapter = getDigit(stage_id, 100, 2)
    local stage = getDigit(stage_id, 1, 2)

    return difficulty, chapter, stage
end

-------------------------------------
-- function isAdventStageID
-- @brief 깜짝 출현 챕터 여부
-------------------------------------
function isAdventStageID(stage_id)
    local stage_id = tonumber(stage_id)
    local chapter = getDigit(stage_id, 100, 2)

    return (chapter == SPECIAL_CHAPTER.ADVENT)
end

-------------------------------------
-- function getPrevStageID
-- @brief
-------------------------------------
function getPrevStageID(stage_id)
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    if (chapter == SPECIAL_CHAPTER.ADVENT) then
        return getPrevStageID_advent(difficulty, chapter, stage)
    end

    -- 룬 축제 이벤트
    if (chapter == SPECIAL_CHAPTER.RUNE_FESTIVAL) then
        return false
    end

    if (difficulty==1) and (chapter==1) and (stage==1) then
        return false
    end

    if (chapter==1) and (stage==1) then
        return makeAdventureID(difficulty-1, MAX_ADVENTURE_CHAPTER, MAX_ADVENTURE_STAGE)
    end

    if (stage==1) then
        return makeAdventureID(difficulty, chapter-1, MAX_ADVENTURE_STAGE)
    end

    return makeAdventureID(difficulty, chapter, stage-1)
end

-------------------------------------
-- function getPrevStageID_advent
-- @brief 깜짝 출협 챕터 전용 
-- @sub getPrevStageID
-------------------------------------
function getPrevStageID_advent(difficulty, chapter, stage)
    if (difficulty == 1) and (stage == 1) then
        return false
    end

    if (stage == 1) then
        stage = g_eventAdventData:getAdventStageCount()
        return makeAdventureID(difficulty - 1, chapter, stage)
    end

    return makeAdventureID(difficulty, chapter, stage-1)
end

-------------------------------------
-- function setFocusStage
-- @brief
-------------------------------------
function ServerData_Adventure:setFocusStage(stage_id)
    if (stage_id == DEV_STAGE_ID) then
        return
    end


    local game_mode = g_stageData:getGameMode(stage_id)

    -- 모험모드만 저장
    if (game_mode == GAME_MODE_ADVENTURE) then

        local skip_focus_stage = false
        local difficulty, chapter, stage = parseAdventureID(stage_id)

        -- 룬 축제 이벤트는 스테이지 저장 X
        if (chapter == SPECIAL_CHAPTER.RUNE_FESTIVAL) then
            skip_focus_stage = true
        end

        -- 마지막에 진입한 스테이지 저장
        if (skip_focus_stage == false) and self:isOpenStage(stage_id) then
            g_settingData:applySettingData(stage_id, 'adventure_focus_stage')
        end
    end
end

-------------------------------------
-- function getStageCategoryStr
-- @brief
-------------------------------------
function ServerData_Adventure:getStageCategoryStr(stage_id)
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    local difficulty_str = ''
    if (difficulty == 1) then
        difficulty_str = Str('보통')

    elseif (difficulty == 2) then
        difficulty_str = Str('어려움')

    elseif (difficulty == 3) then
        difficulty_str = Str('지옥')

    elseif (difficulty == 4) then
        difficulty_str = Str('불지옥')
    elseif (difficulty == 5) then
        difficulty_str = Str('심연 0')
    else
        error('difficulty : ' .. difficulty)

    end

    return Str('모험') .. ' > ' .. difficulty_str
end

-------------------------------------
-- function isOpenGlobalChapter
-- @brief 해당 챕터의 보통 난이도가 열렸는지 여부
-------------------------------------
function ServerData_Adventure:isOpenGlobalChapter(chapter)
    local difficulty = 1
    return self:isOpenChapter(difficulty, chapter)
end
