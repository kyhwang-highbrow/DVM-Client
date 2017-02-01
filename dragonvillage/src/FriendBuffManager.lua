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
-- function getBuffData
-------------------------------------
function FriendBuffManager:getBuffData()
    -- 버프 정보를 새로 생성
    if (not self.m_bCalculated) then
        self.m_tBuffData = {}
        
        -- 전투에 참여하는 친구 드래곤 버프
        if (self.m_tFriendDragonData) then
            local did = self.m_tFriendDragonData['did']
            local t_dragon = TableDragon():get(did)
            
            local t_friend_buff = TableFriendBuff:makeFriendBuffData(did, t_dragon['rarity'], t_dragon['attr'])
            if (t_friend_buff) then
                self.m_tBuffData = t_friend_buff
            end
        end

        -- TODO: 접속한 친구로 인해 받는 버프
        --

        self.m_bCalculated = true
    end

    return self.m_tBuffData
end

-------------------------------------
-- function getBuffStr
-------------------------------------
function FriendBuffManager:getBuffStr()
    -- 현재는 TableRuneStatus를 이용하여 문자열을 가져옴(차후 정리 필요)
    local t_friend_buff = self:getBuffData()
    local bExistBuff = false

    local str = '{@SKILL_DESC}'

    if (t_friend_buff['add_status']) then
        for category, value in pairs(t_friend_buff['add_status']) do
            if (bExistBuff) then
                str = (str .. '\n') .. TableRuneStatus:getCategoryStr(category) .. ' ' .. TableRuneStatus:getStatusValueStr(category, value)
            else
                str = str .. TableRuneStatus:getCategoryStr(category) .. ' ' .. TableRuneStatus:getStatusValueStr(category, value)
            end

            bExistBuff = true
        end
    end

    if (t_friend_buff['add_status']) then
        for category, value in pairs(t_friend_buff['multiply_status']) do
            if (bExistBuff) then
                str = (str .. '\n') .. TableRuneStatus:getCategoryStr(category) .. ' ' .. TableRuneStatus:getStatusMultiplyValueStr(category, value)
            else
                str = str .. TableRuneStatus:getCategoryStr(category) .. ' ' .. TableRuneStatus:getStatusMultiplyValueStr(category, value)
            end

            bExistBuff = true
        end
    end

    if(not bExistBuff) then
        str = str .. Str('없음')
    end

    return str
end

-------------------------------------
-- function setParticipationFriendDragon
-- @brief 전투에 참여할 친구 드래곤 설정
-------------------------------------
function FriendBuffManager:setParticipationFriendDragon(t_friend_dragon_data)
    self.m_tFriendDragonData = t_friend_dragon_data

    self.m_bCalculated = false
end

-------------------------------------
-- function isExistBuff
-------------------------------------
function FriendBuffManager:isExistBuff()
    local t_friend_buff = self:getBuffData()
    
    if (t_friend_buff['add_status'] and table.count(t_friend_buff['add_status']) > 0) then
        return true
    end

    if (t_friend_buff['multiply_status'] and table.count(t_friend_buff['multiply_status']) > 0) then
        return true
    end

    return false
end






-- TODO: 임시 처리... 차후 ServerData_Friend 같은 곳에서 관리 되어야할듯
g_friendBuff = FriendBuffManager()