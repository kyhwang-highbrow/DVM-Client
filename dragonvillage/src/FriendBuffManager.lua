-------------------------------------
-- interface FriendBuffManager
-------------------------------------
FriendBuffManager = class({
        m_tBuffData = 'table',

        -- 전투에 참여하는 친구 드래곤
        m_tFriendDragonData = 'table',

        m_bCalculated = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function FriendBuffManager:init()
    self.m_tBuffData = {}
    self.m_tFriendDragonData = nil
    self.m_bCalculated = false
end

-------------------------------------
-- function init
-------------------------------------
function FriendBuffManager:getBuffData()
    if (not self.m_bCalculated) then
        -- 버프 정보를 새로 생성
        self.m_tBuffData = {}

        -- 전투에 참여하는 친구 드래곤 버프
        if (self.m_tFriendDragonData) then
            local did = self.m_tFriendDragonData['did']
            local t_dragon = TableDragon():get(did)
            
            local t_friend_buff = TableFriendBuff:makeFriendBuffData(did, t_dragon['rarity'], t_dragon['attr'])
            self.m_tBuffData = t_friend_buff
        end

        -- TODO: 접속한 친구로 인해 받는 버프
        --

        self.m_bCalculated = true
    end

    return self.m_tBuffData
end

-------------------------------------
-- function setParticipationFriendDragon
-- @brief 전투에 참여할 친구 드래곤 설정
-------------------------------------
function FriendBuffManager:setParticipationFriendDragon(t_friend_dragon_data)
    self.m_tFriendDragonData = t_friend_dragon_data

    self.m_bCalculated = false
end






-- TODO: 임시 처리... 차후 ServerData_Friend 같은 곳에서 관리 되어야할듯
g_friendBuff = FriendBuffManager()
g_friendBuff:setParticipationFriendDragon(FRIEND_HERO)