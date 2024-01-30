local PARENT = StructUserInfoArenaNew
-------------------------------------
--- @class StructUserInfoWorldRaid
--- @instance
-------------------------------------
StructUserInfoWorldRaid = class(PARENT, {
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