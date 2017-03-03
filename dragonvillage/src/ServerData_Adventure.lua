-------------------------------------
-- class ServerData_Adventure
-------------------------------------
ServerData_Adventure = class({
        m_serverData = 'ServerData',

        m_stageList = 'map',
        m_chapterAchieveInfoList = 'map', -- 챕터(챕터와 난이도를 포함한)별 도전과제 달성 정보 리스트
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