
-------------------------------------
-- class SettingData_Deck
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
    self.m_rootTable = LoadLocalSaveJson('local_deck_data.json')
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

    do -- 고대의 탑 덱 저장
        local t_data = {}
        for stage_id = 1401001, 1401050 do
            t_data[stage_id] = {}  
        end
        root_table['ancient_deck'] = t_data
    end

    return root_table
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
function SettingData_Deck:getA(deck_name)
    local cur_stage_id = g_ancientTowerData:getChallengingStageID()
    local t_ancient_deck = self.m_rootTable
    local l_dragon = {}

    if (not t_ancient_deck) then
        return nil
    end

    if (not t_ancient_deck['deck']) then
        return nil
    end

    for i,v in pairs(t_ancient_deck['deck']) do
        -- 드래곤 데이터를 리스트 형식으로 변환
        if (v ~= '') and g_dragonsData:getDragonDataFromUid(v) then
            l_dragon[tonumber(i)] = v
        end
    end

    
    return l_dragon, t_ancient_deck
end
 
-------------------------------------
-- function saveAncientTowerDeck
-- @brief 로컬에 덱 정보 저장
-------------------------------------
function SettingData_Deck:saveAncientTowerDeck(l_deck, formation, leader, tamer_id)
    if (not g_ancientTowerData) then
        return
    end
    
    local cur_stage_id = g_ancientTowerData:getChallengingStageID()
     
    -- 기존에 저장된 덱 정보
    local ancient_deck_data = self:getDeckAncient('ancient_deck')
     
    if (not ancient_deck_data) then
        ancient_deck_data = {}
    end
     
    -- 새로 저장할 덱 정보
    local t_new_deck_data = {}
    t_new_deck_data['deck'] = l_deck
    t_new_deck_data['formation'] = formation
    t_new_deck_data['deckname'] = 'ancient'
    t_new_deck_data['leader'] = leader
    t_new_deck_data['tamer'] = tamer_id
 
    -- 덱 정보 갱신
    self.m_rootTable[cur_stage_id] = t_new_deck_data
end
