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
        if (value['deckName'] == deck_name) then
            idx = i
            break
        end
    end

    if (not idx) then
        idx = #l_deck + 1
    end

    self.m_serverData:applyServerData(t_deck, 'deck', idx)
    self:resetDragonDeckInfo()
    ResetMultiDeckCached()
end

-------------------------------------
-- function setDeck_usedDeckPvp
-- @brief
-------------------------------------
function ServerData_Deck:setDeck_usedDeckPvp(deck_name, t_deck)
    local l_deck = self.m_serverData:get('deckpvp') or {}

    local idx = nil
    for i,value in pairs(l_deck) do
        if (value['deckName'] == deck_name) then
            idx = i
            break
        end
    end

    if (not idx) then
        idx = #l_deck + 1
    end

    self.m_serverData:applyServerData(t_deck, 'deckpvp', idx)
    self:resetDragonDeckInfo()
    ResetMultiDeckCached()
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

    -- 콜로세움 (신규) 덱 예외처리
    elseif (deck_name == 'arena_new_a' or deck_name == 'arena_new_d' or  deck_name == 'arena_new') then
        -- 일단 급하니 그냥 꽂아넣는다
        if (deck_name == 'arena_new') then

            if (not g_arenaData.m_playerUserInfo) then
                return {}, self:adjustFormationName('default'), 'arena_new', 1
            end

            local l_doid, formation, deck_name, leader, tamer_id = g_arenaData.m_playerUserInfo:getDeck('arena')
            return l_doid, self:adjustFormationName(formation), 'arena_new', leader, tamer_id
        end


        if (not g_arenaNewData.m_playerUserInfo) then
            return {}, self:adjustFormationName('default'), deck_name, 1
        end

        local l_doid, formation, deck_name, leader, tamer_id = g_arenaNewData.m_playerUserInfo:getDeck(deck_name)
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

	-- 고대의 탑 (베스트팀 불러오기 사용했을 경우)
    elseif (deck_name == 'ancient') then
        if (g_autoPlaySetting:isAutoPlay()) then
            if (g_autoPlaySetting:get('load_best_deck')) then
                local stage_id = g_ancientTowerData.m_stageIdInAuto
                local t_data = g_settingDeckData:getDeckAncient(stage_id)

                if (t_data) then
                    local t_ret = {}
                    for i,v in ipairs(t_data['deck']) do
                        if (v ~= '') and g_dragonsData:getDragonDataFromUid(v) then
                            t_ret[tonumber(i)] = v
                        end
                    end
                    return t_data['deck'], self:adjustFormationName(t_data['formation']), 'ancient', t_data['leader'], t_data['tamer_id']
                end
            end
        end
    -- 환상 던전 로컬에 저장되어 있는 덱을 사용
    elseif (deck_name == 'illusion') then
        local t_data = g_settingDeckData:getLocalDeck(deck_name)
        if (t_data) then
            local t_ret = {}
            for i,v in ipairs(t_data['deck']) do
                if (v ~= '') and g_illusionDungeonData:getDragonDataFromUid(v) then
                    t_ret[tonumber(i)] = v
                end
            end
            return t_data['deck'], self:adjustFormationName(t_data['formation']), deck_name, t_data['leader'], t_data['tamer_id']
        end
    -- deckpvp collection을 사용하는 덱은 별도로 처리
    elseif self:isUsedDeckPvpDB(deck_name) then
        return self:getDeck_core_usedDeckPvpDB(deck_name)
    end

    local l_deck = self.m_serverData:get('deck')

    local t_deck
    local formation
	local leader
    local tamer_id
    for i, value in ipairs(l_deck) do
        if (value['deckName'] == deck_name) then
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
        
        -- 시험의 탑의 경우 속성에 따라 덱을 필터링
        if (string.match(deck_name, 'attr_tower')) then
            t_ret = g_attrTowerData:getAttrDragonDeck(t_ret)
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


    if (deck_name == 'clanwar') then
        return true
    end

    if (string.find(deck_name, 'league_raid')) then
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
        if (value['deckName'] == deck_name) then
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
            if (value['deckName'] == deck_name) then
                return value
            end
        end
    end

    local l_deck = self.m_serverData:get('deck')
    for i, value in ipairs(l_deck) do
        if (value['deckName'] == deck_name) then
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
            local deckname = ret_deck['deckName']

            g_deckData:setDeck_usedDeckPvp(deckname, ret_deck)

            if (string.find(deckname, 'league_raid')) then
                for i = 1, 3 do
                    local raid_deck_name = 'league_raid_' .. tostring(i)
                    cclog(raid_deck_name)
                    if (ret[raid_deck_name]) then
                        ccdump(ret[raid_deck_name])
                        g_deckData:setDeck_usedDeckPvp(raid_deck_name, ret[raid_deck_name])
                    end
                end
            end
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/set_deck')
    ui_network:setParam('uid', uid)

    ui_network:setParam('deck_name', _deckname)
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
-- function request_getPresetDeck
-------------------------------------
function ServerData_Deck:request_getPresetDeck(deck_name, finish_cb)

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        if ret['deck'] then
            local deck = ret['deck']
            local deck_name = deck['deckName']

            g_deckData:setDeck(deck_name, deck)
        end
    
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/get_preset_deck')
    ui_network:setParam('uid', uid)
    ui_network:setParam('deck_name', deck_name)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end