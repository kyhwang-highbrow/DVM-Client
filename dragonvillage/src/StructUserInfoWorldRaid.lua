local PARENT = StructUserInfoArenaNew
-------------------------------------
--- @class StructUserInfoWorldRaid
--- @instance
-------------------------------------
StructUserInfoWorldRaid = class(PARENT, {
    m_deckList = '',
})

-------------------------------------
--- @function getVisitType
-------------------------------------
function StructUserInfoWorldRaid:getVisitType()
    return 'world_raid'
end

-------------------------------------
-- function create_forRanking
-- @brief 랭킹 유저 정보
-------------------------------------
function StructUserInfoWorldRaid:create_forRanking(t_data)
    local user_info = StructUserInfoWorldRaid()

    user_info.m_uid = t_data['uid']
    user_info.m_nickname = t_data['nick']
    user_info.m_lv = t_data['lv']
    user_info.m_rank = t_data['rank']
    user_info.m_rankPercent = t_data['rate']
    user_info.m_tier = t_data['tier']
    user_info.m_rp = t_data['rp']
    user_info.m_state = t_data['state']
    user_info.m_profileFrame = t_data['profile_frame']
    user_info.m_profileFrameExpiredAt = t_data['profile_frame_expired_at']
    user_info.m_leaderDragonObject = StructDragonObject(t_data['leader'])
    -- 드래곤 룬 세팅
    user_info.m_leaderDragonObject:setRuneObjects(t_data['runes'])

    -- 클랜
    if (t_data['clan_info']) then
        local struct_clan = StructClan({})
        struct_clan:applySimple(t_data['clan_info'])
        user_info:setStructClan(struct_clan)
    end

    return user_info
end

-------------------------------------
-- function createUserInfo
-- @brief 콜로세움 유저 인포
-------------------------------------
function StructUserInfoWorldRaid:createUserInfo(t_data)
    local user_info = StructUserInfoWorldRaid()
    user_info.m_uid = t_data['uid']
    user_info.m_nickname = t_data['nick']
    user_info.m_lv = t_data['lv']
    user_info.m_rank = t_data['rank']
    user_info.m_rankPercent = t_data['rate']
    user_info.m_tier = t_data['tier']
    user_info.m_rp = t_data['rp']
    user_info.m_state = t_data['state']
    user_info.m_lairStats = t_data['lair_stats']
    user_info.m_researchStats = t_data['research_stats']
    user_info.m_hoid = t_data['hoid']
    user_info.m_profileFrame = t_data['profile_frame']
    user_info.m_profileFrameExpiredAt = t_data['profile_frame_expired_at']
    user_info.m_leaderDragonObject = StructDragonObject(t_data['leader'])
    
    -- 룬 & 드래곤 리스트 저장
    user_info:applyRunesDataList(t_data['runes']) --반드시 드래곤 설정 전에 룬을 설정해야함
    user_info:applyDragonsDataList(t_data['dragons'])

    -- 덱 저장
    user_info:applyDeckData(t_data['deck_info'])
    return user_info
end

-------------------------------------
--- @function getDeckList
-------------------------------------
function StructUserInfoWorldRaid:getDeckList()
    return self.m_deckList
end

-------------------------------------
--- @function applyDeckData
-------------------------------------
function StructUserInfoWorldRaid:applyDeckData(t_deck_info)
    self.m_deckList = {}
    for i = 1,3 do
        local t_deck = t_deck_info[tostring(i)]
        self.m_deckList[i] = t_deck
    end
end

-------------------------------------
--- @function getDeck_dragonList
-------------------------------------
function StructUserInfoWorldRaid:getDeck_dragonList(_idx, use_doid)
    local deck = self:getDeck(_idx)
    local t_deck = {}
    local l_dragons = {}
    if (deck) then        
        for i,v in pairs(deck) do
            local idx = tonumber(i)
            local doid = v            
            if use_doid then
                t_deck[idx] = doid -- doid로 저장 혹은 오브젝트로 저장
            else
                t_deck[idx] = self:getDragonObject(doid)
                table.insert(l_dragons, t_deck[idx])
            end
        end
    end

    return t_deck, l_dragons
end

-------------------------------------
-- function getDeckCombatPower
-- @brief 공격 덱 전투력
-------------------------------------
function StructUserInfoWorldRaid:getDeckCombatPower(_idx, force)
    local deck = self:getDeck(_idx)

    if (not deck) then
        return 0
    end

    local t_deck_dragon_list = self:getDeck_dragonList(_idx)
    -- 드래곤
    local total_combat_power = 0
    for i,v in pairs(t_deck_dragon_list) do
        total_combat_power = (total_combat_power + v:getCombatPower())
    end

    return total_combat_power
end

-------------------------------------
--- @function getDeck_dragonList
-------------------------------------
function StructUserInfoWorldRaid:getDeck(_idx)
    local deck = self.m_deckList[_idx]

    if deck == nil then
        return nil
    end

    return deck['deck']
end