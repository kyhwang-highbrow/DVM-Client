-------------------------------------
-- class ServerData_Deck
-------------------------------------
ServerData_Deck = class({
        m_serverData = 'ServerData',

        m_mapDragonDeckInfo = 'map',

        m_selectedDeck = 'string', -- 현재 선택되어 있는 덱
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Deck:init(server_data)
    self.m_serverData = server_data
    self.m_selectedDeck = self.m_serverData:get('local', 'selected_deck') or 'adv'
end

-------------------------------------
-- function response_deckInfo
-- @brief users/get_deck에 해당하는 response이며 users/title에서 함께 받는 것으로 수정됨
-------------------------------------
function ServerData_Deck:response_deckInfo(l_deck)
    self.m_serverData:applyServerData(l_deck, 'deck')
end

-------------------------------------
-- function response_deckPvpInfo
-- @brief game/pvp/get_deck에 해당하는 response이며 users/title에서 함께 받는 것으로 수정됨
-------------------------------------
function ServerData_Deck:response_deckPvpInfo(l_deck)
    self.m_serverData:applyServerData(l_deck, 'deckpvp')
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_Deck:get(key)
    return self.m_serverData:get('deck', key)
end

-------------------------------------
-- function setDeck
-- @brief
-------------------------------------
function ServerData_Deck:setDeck(deck_name, t_deck)
    local l_deck = self.m_serverData:get('deck')

    local idx = nil
    for i,value in pairs(l_deck) do
        if (value['deckname'] == deck_name) then
            idx = i
            break
        end
    end

    if (not idx) then
        idx = #l_deck + 1
    end

    self.m_serverData:applyServerData(t_deck, 'deck', idx)
    self:resetDragonDeckInfo()
end

-------------------------------------
-- function setDeck_usedDeckPvp
-- @brief
-------------------------------------
function ServerData_Deck:setDeck_usedDeckPvp(deck_name, t_deck)
    local l_deck = self.m_serverData:get('deckpvp') or {}

    local idx = nil
    for i,value in pairs(l_deck) do
        if (value['deckname'] == deck_name) or (value['deckName'] == deck_name) then
            idx = i
            break
        end
    end

    if (not idx) then
        idx = #l_deck + 1
    end

    self.m_serverData:applyServerData(t_deck, 'deckpvp', idx)
    self:resetDragonDeckInfo()
end

-------------------------------------
-- function getDeck
-- @brief
-------------------------------------
function ServerData_Deck:getDeck(deck_name)
    local l_deck, formation, deckname, leader, tamer_id = self:getDeck_core(deck_name)

    if (not tamer_id) or (0 == tamer_id) then
        tamer_id = g_tamerData:getCurrTamerID()
    end

    return l_deck, formation, deckname, leader, tamer_id
end

-------------------------------------
-- function getDeck_core
-- @brief
-------------------------------------
function ServerData_Deck:getDeck_core(deck_name)
    deck_name = deck_name or self.m_selectedDeck or 'adv'

    -- 콜로세움 (신규) 덱 예외처리
    if (deck_name == 'arena') then
        if (not g_arenaData.m_playerUserInfo) then
            return {}, self:adjustFormationName('default'), deck_name, 1
        end

        local l_doid, formation, deck_name, leader, tamer_id = g_arenaData.m_playerUserInfo:getDeck(deck_name)
        return l_doid, self:adjustFormationName(formation), deck_name, leader, tamer_id

    -- 콜로세움 덱 예외처리
    elseif (deck_name == 'pvp_atk') or (deck_name == 'pvp_def') then
        if (not g_colosseumData.m_playerUserInfo) then
            return {}, self:adjustFormationName('default'), deck_name, 1
        end

        local l_doid, formation, deck_name, leader, tamer_id = g_colosseumData.m_playerUserInfo:getDeck(deck_name)
        return l_doid, self:adjustFormationName(formation), deck_name, leader, tamer_id
    
    -- 친선전 덱 예외처리
    elseif (deck_name == 'fpvp_atk') then
        if (not g_friendMatchData.m_playerUserInfo) then
            return {}, self:adjustFormationName('default'), deck_name, 1
        end

        local l_doid, formation, deck_name, leader, tamer_id = g_friendMatchData.m_playerUserInfo:getDeck(deck_name)

        -- 덱 유효한지 검사 (친선전은 드래곤 삭제 가능)
        local t_ret = {}
        for i,v in pairs(l_doid) do
            if (v ~= '') and g_dragonsData:getDragonDataFromUid(v) then
                t_ret[tonumber(i)] = v
            end
        end

        return t_ret, self:adjustFormationName(formation), deck_name, leader, tamer_id

    -- deckpvp collection을 사용하는 덱은 별도로 처리
    elseif self:isUsedDeckPvpDB(deck_name) then
        return self:getDeck_core_usedDeckPvpDB(deck_name)

    -- 고대의 탑의 경우, 로컬에 저장된 덱이 있다면 불러옴
    elseif (deck_name == 'ancient') then
        local t_ret, formation, deck_name, leader, tamer_id = self:getDeckAncient(deck_name)
        
        -- 저장된 값이 있다면 그 값을 리턴, 없다면 서버에 저장한 ancient 덱(최근에 사용한 덱)을 사용
        if (t_ret) then
            return t_ret, formation, deck_name, leader, tamer_id
        end
    end

    local l_deck = self.m_serverData:get('deck')

    local t_deck
    local formation
	local leader
    local tamer_id
    for i, value in ipairs(l_deck) do
        if (value['deckname'] == deck_name) then
            t_deck = value['deck']
            formation = value['formation']
			leader = value['leader']
            tamer_id = value['tamer']
        end
    end

    if t_deck then
        local t_ret = {}
        for i,v in pairs(t_deck) do
            if (v ~= '') and g_dragonsData:getDragonDataFromUid(v) then
                t_ret[tonumber(i)] = v
            end
        end
        
        return t_ret, self:adjustFormationName(formation), deck_name, leader, tamer_id
    end

    return {}, self:adjustFormationName('default'), deck_name, 1, tamer_id
end

-------------------------------------
-- function isUsedDeckPvpDB
-- @brief 서버에서 deck과 deckpvp라는 collection을 사용하는데
--        콜로세움, 그랜드 콜로세움 등은 deckpvp에서 덱 정보를 저장함
--        deckpvp 콜렉션을 사용하는 덱 명칭인지 확인용 함수
-------------------------------------
function ServerData_Deck:isUsedDeckPvpDB(deck_name)
    if (deck_name == 'grand_arena_up') then
        return true
    end

    if (deck_name == 'grand_arena_down') then
        return true
    end

    return false
end

-------------------------------------
-- function getDeck_core_usedDeckPvpDB
-- @brief 서버에서 deck과 deckpvp라는 collection을 사용하는데
--        콜로세움, 그랜드 콜로세움 등은 deckpvp에서 덱 정보를 저장함
-------------------------------------
function ServerData_Deck:getDeck_core_usedDeckPvpDB(deck_name)
    local l_deck = self.m_serverData:get('deckpvp') or {}

    local t_deck
    local formation
	local leader
    local tamer_id
    for i, value in ipairs(l_deck) do
        if (value['deckname'] == deck_name) or (value['deckName'] == deck_name) then
            t_deck = value['deck']
            formation = value['formation']
			leader = value['leader']
            tamer_id = value['tamer']
        end
    end

    if t_deck then
        local t_ret = {}
        for i,v in pairs(t_deck) do
            if (v ~= '') and g_dragonsData:getDragonDataFromUid(v) then
                t_ret[tonumber(i)] = v
            end
        end
        
        return t_ret, self:adjustFormationName(formation), deck_name, leader, tamer_id
    end

    return {}, self:adjustFormationName('default'), deck_name, 1, tamer_id
end

-------------------------------------
-- function getDeck_lowData
-- @brief
-------------------------------------
function ServerData_Deck:getDeck_lowData(deck_name)

    -- deckpvp collection을 사용하는 덱인 경우
    if self:isUsedDeckPvpDB(deck_name) then
        local l_deck = self.m_serverData:get('deckpvp')
        for i, value in ipairs(l_deck) do
            if (value['deckname'] == deck_name) or (value['deckName'] == deck_name) then
                return value
            end
        end
    end

    local l_deck = self.m_serverData:get('deck')
    for i, value in ipairs(l_deck) do
        if (value['deckname'] == deck_name) then
            return value
        end
    end

    return nil
end

-------------------------------------
-- function adjustFormationName
-- @brief
-------------------------------------
function ServerData_Deck:adjustFormationName(formation)
    if (not formation) or (formation == 'default') then
        return 'attack'
    end

    return formation
end

-------------------------------------
-- function resetDragonDeckInfo
-- @breif 해당 드래곤이 덱에 설정되어있는지 여부
-------------------------------------
function ServerData_Deck:resetDragonDeckInfo()
    self.m_mapDragonDeckInfo = {}

    local l_deck = self:getDeck()

    for i,v in pairs(l_deck) do
        self.m_mapDragonDeckInfo[v] = i
    end
end

-------------------------------------
-- function isSettedDragon
-- @breif 해당 드래곤이 덱에 설정되어있는지 여부
-------------------------------------
function ServerData_Deck:isSettedDragon(doid)
    if (not self.m_mapDragonDeckInfo) then
        self:resetDragonDeckInfo()
    end

    if self.m_mapDragonDeckInfo[doid] then
        return self.m_mapDragonDeckInfo[doid]
    else
        return false
    end
end

-------------------------------------
-- function getSelectedDeckName
-------------------------------------
function ServerData_Deck:getSelectedDeckName()
    return self.m_selectedDeck
end

-------------------------------------
-- function setSelectedDeck
-------------------------------------
function ServerData_Deck:setSelectedDeck(deck_name)
    self.m_serverData:applyServerData(deck_name, 'local', 'selected_deck')
    self.m_selectedDeck = deck_name

    -- 이걸 해줘야 최초 진입시 모드별 셋팅된 덱을 가져옴 2018-01-09 ks
    self:resetDragonDeckInfo()
end

-------------------------------------
-- function getDeckCombatPower
-- @brief
-------------------------------------
function ServerData_Deck:getDeckCombatPower(deck_name)
    local combat_power = 0

    local l_deck = self:getDeck(deck_name)

    for _,doid in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        if t_dragon_data then
            combat_power = combat_power + t_dragon_data:getCombatPower()
        end
    end

    return combat_power
end

-------------------------------------
-- function getDeckAncient
-- @brief
-------------------------------------
function ServerData_Deck:getDeckAncient(deck_name)
    local cur_stage_id = g_ancientTowerData:getChallengingStageID()
    local ancient_deck_data = LoadLocalSaveJson('ancient_deck_data.json')

    if (ancient_deck_data) then
        local t_ancient_deck = ancient_deck_data[tostring(cur_stage_id)]
        local l_dragon = {}
        if (t_ancient_deck) then
            for i,v in pairs(t_ancient_deck['deck']) do
                -- 드래곤 데이터를 리스트 형식으로 변환
                if (v ~= '') and g_dragonsData:getDragonDataFromUid(v) then
                    l_dragon[tonumber(i)] = v
                end
            end
            return l_dragon, self:adjustFormationName(t_ancient_deck['formation']), deck_name, t_ancient_deck['leader'], t_ancient_deck['tamer_id']
        end
    end

    return nil
end

-------------------------------------
-- function request_setDeckPvpCollection
-------------------------------------
function ServerData_Deck:request_setDeckPvpCollection(deckname, formation, leader, l_edoid, tamer, finish_cb, fail_cb)
    local _deckname = deckname

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        if ret['deck'] then
            local ret_deck = ret['deck']
            local t_deck = ret_deck['deck']
            local deckname = ret_deck['deckname'] or ret_deck['deckName']

            g_deckData:setDeck_usedDeckPvp(deckname, ret_deck)
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/set_deck')
    ui_network:setParam('uid', uid)

    ui_network:setParam('deckname', _deckname)
    ui_network:setParam('formation', formation)
    ui_network:setParam('leader', leader)
    ui_network:setParam('tamer', tamer)
    

    for i,doid in pairs(l_edoid) do
        ui_network:setParam('edoid' .. i, doid)
    end

    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function saveAncientTowerDeck
-------------------------------------
function ServerData_Deck:saveAncientTowerDeck(l_deck, formation, leader, tamer_id)
    local cur_stage_id = g_ancientTowerData:getChallengingStageID()
    
    -- 기존에 저장된 덱 정보
    local ancient_deck_data = LoadLocalSaveJson('ancient_deck_data.json')
    
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

    -- 드래곤이 배치되지 않았다면 저장하지 않음
    if (#l_deck == 0) then
        return
    end
    
    -- 덱 정보 갱신
    ancient_deck_data[tostring(cur_stage_id)] = t_new_deck_data

    SaveLocalSaveJson('ancient_deck_data.json', ancient_deck_data, true) -- param : filename, t_data, skip_xor
end