local PARENT = StructUserInfo

-------------------------------------
-- class StructUserInfoForest
-- @instance
-------------------------------------
StructUserInfoForest = class(PARENT, {
    })

-------------------------------------
-- function create
-------------------------------------
function StructUserInfoForest:create(t_data)
    local user_info = StructUserInfoColosseum()

    user_info.m_nickname = t_data['nick']
    user_info.m_lv = t_data['lv']
    user_info.m_tamerID = t_data['tamer']
    user_info.m_tamerTitleID = t_data['tamer_title']
    user_info.m_tamerCostumeID = t_data['costume_id']
    user_info.m_leaderDragonObject = StructDragonObject(t_data['leader'])
    user_info.m_lastArenaTier = t_data['arena_new_last_tier']

    return user_info
end

-------------------------------------
-- function init
-------------------------------------
function StructUserInfoForest:init()
end