MAX_ADVENTURE_CHAPTER = 6
MAX_ADVENTURE_STAGE = 8
MAX_ADVENTURE_DIFFICULTY = 3

-------------------------------------
-- class ServerData_Adventure
-------------------------------------
ServerData_Adventure = class({
        m_serverData = 'ServerData',

        m_stageList = 'map',
        m_chapterAchieveInfoList = 'map', -- 챕터(챕터와 난이도를 포함한)별 도전과제 달성 정보 리스트

        -- 챕터 달성도 테이블 정보(서버에서 던져줌)
        m_chapterAchiveDataTable = 'map',


        -- 모험모드 진행 정보
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Adventure:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function goToAdventureScene
-------------------------------------
function ServerData_Adventure:goToAdventureScene(stage_id, skip_request)
    local function finish_cb()
        local scene = SceneAdventure(stage_id)
        scene:runScene()
    end

    -- 네트워크 통신으로 서버 데이터를 갱신하지 않고 즉시 실행할 경우
    if skip_request then
        finish_cb()
        return
    end

    local function fail_cb()

    end
    
    self:request_adventureInfo(finish_cb, fail_cb)
end

-------------------------------------
-- function request_adventureInfo
-------------------------------------
function ServerData_Adventure:request_adventureInfo(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        --self:response_colosseumInfo(ret, cb)

        self:organizeStageList(ret['stage_list'])
        self:organizeChapterAchieveInfoList(ret['chapter_list'])
        self:organizeChapterAchieveDataTable(ret['chapter_archievement'])
        
        

        if finish_cb then
            return finish_cb(ret)
        end

        --ccdump(ret)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/stage/list')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', 1) -- 1 : adventrue(모험)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
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
    self.m_chapterAchieveInfoList = {}

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
        -- 아이템 수령
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 챕터 정보 갱신
        self:organizeChapterAchieveInfoList(ret['chapter_list'])

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
        local stage_info = self:getStageInfo(prev_stage_id)
        local is_open = (0 < stage_info['clear_cnt'])
        return is_open
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

    if (stage < MAX_ADVENTURE_STAGE) then
        local next_stage_id = makeAdventureID(difficulty, chapter, stage + 1)
        return next_stage_id
    end

    if (3 == difficulty) then
        if (chapter < MAX_ADVENTURE_CHAPTER) then
            local next_stage_id = makeAdventureID(difficulty, chapter + 1, 1)
            return next_stage_id
        else
            return stage_id
        end
    end

    if (1 == difficulty) and (chapter < MAX_ADVENTURE_CHAPTER) then
        local next_stage_id = makeAdventureID(difficulty, chapter + 1, 1)
        return next_stage_id
    end

    if (1 < difficulty) then
        local next_stage_id = makeAdventureID(difficulty + 1, chapter, 1)
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

    if (stage < MAX_ADVENTURE_STAGE) then
        local next_stage_id = makeAdventureID(difficulty, chapter, stage + 1)
        return next_stage_id
    end

    return nil
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
        -- 마지막에 진입한 스테이지 저장
        g_localData:applyLocalData(stage_id, 'adventure_focus_stage')
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
        difficulty_str = Str('쉬움')

    elseif (difficulty == 2) then
        difficulty_str = Str('보통')

    elseif (difficulty == 3) then
        difficulty_str = Str('어려움')

    else
        error('difficulty : ' .. difficulty)

    end

    return Str('모험') .. ' > ' .. difficulty_str
end

-------------------------------------
-- function isOpenGlobalChapter
-- @brief 해당 챕터의 쉬움 난이도가 열렸는지 여부
-------------------------------------
function ServerData_Adventure:isOpenGlobalChapter(chapter)
    local difficulty = 1
    return self:isOpenChapter(difficulty, chapter)
end
