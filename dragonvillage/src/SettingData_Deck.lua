
-------------------------------------
-- class SettingData_Deck
-- @instance g_settingDeckData
-------------------------------------
SettingData_Deck = class({
        m_rootTable = 'table',
    })


-------------------------------------
-- function init
-------------------------------------
function SettingData_Deck:init()
    
end

-------------------------------------
-- function getInstance
-------------------------------------
function SettingData_Deck:getInstance()
    if g_settingDeckData then
        return g_settingDeckData
    end
    
    g_settingDeckData = SettingData_Deck()
    g_settingDeckData:loadSettingDataFile()

    return g_settingDeckData
end

-------------------------------------
-- function loadSettingDataFile
-------------------------------------
function SettingData_Deck:loadSettingDataFile()
    local ret_json, success_load = LoadLocalSaveJson(self:getSettingDataSaveFileName())

    if (success_load == true) then
        self.m_rootTable = ret_json
    else
        self.m_rootTable = self:makeDefaultSettingData()
        self:saveSettingDataFile()
    end
end

-------------------------------------
-- function saveSettingDataFile
-------------------------------------
function SettingData_Deck:saveSettingDataFile()
    return SaveLocalSaveJson(self:getSettingDataSaveFileName(), self.m_rootTable, false) -- param : filename, t_data, skip_xor)
end

-------------------------------------
-- function getSettingDataSaveFileName
-------------------------------------
function SettingData_Deck:getSettingDataSaveFileName()
    local file = 'local_deck_data.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end




------------------------------------------------------------------
-- 범용적으로 사용하는 함수
------------------------------------------------------------------

-------------------------------------
-- function getLocalDeck
-- @brief 로컬 파일에서 덱 정보 읽어서 리턴
-------------------------------------
function SettingData_Deck:getLocalDeck(deck_name)
    local t_deck_data = self.m_rootTable[deck_name]

    if (not t_deck_data) then
        return nil
    end
    -- 보유한 드래곤인지 체크
    self:checkUserDragon(t_deck_data['deck'], deck_name)

    -- 보유한 테이머인지 체크
    self:checkUserTamer(t_deck_data)

    return t_deck_data
end

-------------------------------------
-- function saveLocalDeck
-------------------------------------
function SettingData_Deck:saveLocalDeck(deck_name, l_deck, formation, leader, tamer_id, score) 

    -- 덱 순서에 맞게 다시 재배열
    local l_deck_order = {}
    for ind = 1,5 do
        l_deck_order[ind] = l_deck[ind]
    end

    -- 새로 저장할 덱 정보
    local t_new_deck_data = {}
    t_new_deck_data['deck'] = l_deck_order
    t_new_deck_data['formation'] = formation
    t_new_deck_data['deckName'] = deck_name
    t_new_deck_data['leader'] = leader
    t_new_deck_data['tamer'] = tamer_id
    t_new_deck_data['best_score'] = score
    
    
    -- 덱 정보 갱신
    self.m_rootTable[deck_name] = t_new_deck_data
    return SaveLocalSaveJson(self:getSettingDataSaveFileName(), self.m_rootTable, false) 
end









------------------------------------------------------------------
-- 고대의 탑에서만 사용하는 함수
------------------------------------------------------------------

-------------------------------------
-- function makeDefaultSettingData
-------------------------------------
function SettingData_Deck:makeDefaultSettingData()
    local root_table = {}
    root_table['ancient_deck'] = {}
    do -- 고대의 탑 덱 저장
        for stage_id = 1401001, 1401050 do
            local t_data = {}
            t_data['stage_id'] = stage_id
            t_data['best_score'] = 0
            root_table['ancient_deck'][tostring(stage_id)] = t_data
        end
    end

    return root_table
end

-------------------------------------
-- function get
-- @brief
-------------------------------------
function SettingData_Deck:get(...)
    local args = {...}
    local cnt = #args

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                return nil
            end
            container = container[key]
        else
            if (container[key] ~= nil) then
                return clone(container[key])
            end
        end
    end

    return nil
end

-------------------------------------
-- function getAncientStageScore
-------------------------------------
function SettingData_Deck:getAncientStageScore(stage_id)
    -- stage_id가 숫자 형태로 넘어왔는지 확인 (고대의 탑 1층~50층 스테이지ID 범위도 확인)
    local stage_id_num = tonumber(stage_id)
    if (stage_id_num == nil) then
        return 0
    elseif (stage_id_num < 1401001) then
        return 0
    elseif (1401050 < stage_id_num) then
        return 0
    end

    -- stage_id를 문자열로 변환하여 해당 스테이지의 최고점을 얻어옴
    local stage_id_str = tostring(stage_id)
    if (stage_id_str == nil) then
        return 0
    end
    local score = self:get('ancient_deck', stage_id_str, 'best_score')
    local score_num = tonumber(score)
    return score_num or 0
end

-------------------------------------
-- function getDeckAllAncient
-- @brief 로컬 파일에서 덱 정보 읽어서 리턴, 베스트 팀 팝업 출력할 때 사용
-------------------------------------
function SettingData_Deck:getDeckAllAncient()
    local t_ancientDeck = {}
    for stage_id = 1401001, 1401050 do
        local t_data = self:getDeckAncient(stage_id)
        -- 드래곤 덱이 없을 경우 nill값을 반환, 찍어줄 때 점수 정보는 필요하기에 디폴트 정보 출력
        if (not t_data) then
            t_data = self.m_rootTable['ancient_deck'][tostring(stage_id)]
        end
        t_ancientDeck[stage_id] = t_data
    end
    return t_ancientDeck
end

-------------------------------------
-- function getDeckAncient
-- @brief 로컬 파일에서 덱 정보 읽어서 리턴
-------------------------------------
function SettingData_Deck:getDeckAncient(stage_id)
    local t_ancient_deck = self.m_rootTable['ancient_deck'][tostring(stage_id)]

    if (not t_ancient_deck) then
        return nil
    end

    -- deck 정보가 없다면 빈 정보로 간주(best_score 등 초기화 정보 있는 상태)
    if (not t_ancient_deck['deck']) then
        return nil
    end

    -- deck 정보가 없다면 빈 정보로 간주(best_score 등 초기화 정보 있는 상태)
    if (#t_ancient_deck['deck'] == 0) then
        return nil
    end

    if (not t_ancient_deck) then
        return nil
    end

    -- 보유한 드래곤인지 체크
    self:checkUserDragon(t_ancient_deck['deck'])
    
    -- 보유한 테이머인지 체크
    self:checkUserTamer(t_ancient_deck)

    return t_ancient_deck
end

-------------------------------------
-- function checkUserTamer
-------------------------------------
function SettingData_Deck:checkUserTamer(t_ancient_deck)
    if (not g_tamerData:hasTamer(t_ancient_deck['tamer'])) then
        t_ancient_deck['tamer'] = nil
    end
end

-------------------------------------
-- function checkUserDragon
-- @brief 유저의 드래곤인지 체크, 아니라면 드래곤 obj를 nil로 변환
-------------------------------------
function SettingData_Deck:checkUserDragon(l_deck, deck_name)
    for ind, doid in ipairs(l_deck) do
        -- 환상 던전은 다른 드래곤 리스트를 탐색함
        if (deck_name == 'illusion') then
            if (not g_illusionDungeonData:getDragonDataFromUid(doid)) then
                l_deck[ind] = nil
            end
        else    
            if (not g_dragonsData:getDragonDataFromUid(doid)) then
                l_deck[ind] = nil
            end
        end
    end
end
 
-------------------------------------
-- function saveAncientTowerDeck
-- @brief 로컬에 덱 정보 저장
-------------------------------------
function SettingData_Deck:saveAncientTowerDeck(l_deck, formation, leader, tamer_id, score, cur_stage_id)
    if (not g_ancientTowerData) then
        return
    end
    
    if (not cur_stage_id) then
        return
    end

    local cur_floor = self:getFloorByStageId(cur_stage_id)
    
    -- 기존에 저장된 덱 정보
    local ancient_deck_data = self.m_rootTable['ancient_deck']
     
    if (not ancient_deck_data) then
        ancient_deck_data = {}
    end
    
    -- 덱 순서에 맞게 다시 재배열
    local l_deck_order = {}
    for ind = 1,5 do
        l_deck_order[ind] = l_deck[ind]
    end

    -- 새로 저장할 덱 정보
    local t_new_deck_data = {}
    t_new_deck_data['deck'] = l_deck_order
    t_new_deck_data['formation'] = formation
    t_new_deck_data['deckName'] = 'ancient'
    t_new_deck_data['leader'] = leader
    t_new_deck_data['tamer'] = tamer_id
    t_new_deck_data['best_score'] = score
    t_new_deck_data['stage_id'] = cur_stage_id
    
    
    -- 덱 정보 갱신
    self.m_rootTable['ancient_deck'][tostring(cur_stage_id)] = t_new_deck_data
    return SaveLocalSaveJson(self:getSettingDataSaveFileName(), self.m_rootTable, false) 
end

-------------------------------------
-- function getFloorByStageId
-------------------------------------
function SettingData_Deck:getFloorByStageId(stage_id)
    local stage_id = stage_id or 0
    return tonumber(stage_id)%100
end

-------------------------------------
-- function resetAncientBestDeck
-------------------------------------
function SettingData_Deck:resetAncientBestDeck()
    SaveLocalSaveJson(self:getSettingDataSaveFileName(), nil, false)
end
