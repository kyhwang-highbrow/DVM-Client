
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

-------------------------------------
-- function makeDefaultSettingData_Deck
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
-- function getStageScore
-------------------------------------
function SettingData_Deck:getAncientStageScore(stage_id)
    
    if (tonumber(stage_id) < 1401001) then
        return 0
    end

    if (tonumber(stage_id) > 1401050) then
        return 0
    end

    return self.m_rootTable['ancient_deck'][tostring(stage_id)]['best_score']
end

-------------------------------------
-- function getDeckAncient
-- @brief 로컬 파일에서 덱 정보 읽어서 리턴
-------------------------------------
function SettingData_Deck:getDeckAllAncient(deck_name)
    local cur_stage_id = g_ancientTowerData:getChallengingStageID()
    local t_ancient_deck = self.m_rootTable
    return self.m_rootTable
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

    if (not t_ancient_deck) then
        return nil
    end
    
    return t_ancient_deck
end
 
-------------------------------------
-- function saveAncientTowerDeck
-- @brief 로컬에 덱 정보 저장
-------------------------------------
function SettingData_Deck:saveAncientTowerDeck(l_deck, formation, leader, tamer_id, score, cur_stage_id)
    if (not g_ancientTowerData) then
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
    t_new_deck_data['deckname'] = 'ancient'
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