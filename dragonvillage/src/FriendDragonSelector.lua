-------------------------------------
---@class FriendDragonSelector
-------------------------------------
FriendDragonSelector = class({
    m_selectCount = 'number',
    m_selectedFriends = 'map<>',
})

-------------------------------------
---@function init
-------------------------------------
function FriendDragonSelector:init(select_count)
    self.m_selectCount = select_count or 1
    self.m_selectedFriends = {}
end

-------------------------------------
---@function delSettedFriendDragon
-- @brief 친구 드래곤, 정보 초기화
-------------------------------------
function FriendDragonSelector:delSettedFriendDragon()
    self.m_selectedSharedFriendDragon = nil
    self.m_selectedShareFriendData = nil
    self.m_bReleaseDragon = false
end

-------------------------------------
---@function delSettedFriendDragonCard
-- @brief 친구 드래곤 슬롯 해제
-------------------------------------
function FriendDragonSelector:delSettedFriendDragonCard(doid)
    if (not g_friendData:checkFriendDragonFromDoid(doid)) then return end
    if (self.m_selectedSharedFriendDragon) and
       (self.m_selectedSharedFriendDragon == doid) then
        self.m_selectedSharedFriendDragon = nil
        self.m_selectedShareFriendData = nil
    end
end

-------------------------------------
---@function makeSettedFriendDragonCard
-- @brief 친구 드래곤 슬롯 세팅
-------------------------------------
function FriendDragonSelector:makeSettedFriendDragonCard(doid, idx)
    if (not g_friendData:checkFriendDragonFromDoid(doid)) then return end
    if (not self.m_selectedSharedFriendDragon) then
        self.m_selectedSharedFriendDragon = doid
        self.m_selectedSharedFriendDragonIdx = idx
        self.m_selectedShareFriendData = self:getFriendInfoFromDoid(self.m_selectedSharedFriendDragon)
    end
end

-------------------------------------
---@function  getFriendDragonSlotIdx
-- @brief 친구 드래곤 슬롯 번호
-------------------------------------
function FriendDragonSelector:getFriendDragonSlotIdx()
    if (self.m_selectedSharedFriendDragonIdx) then
        return self.m_selectedSharedFriendDragonIdx
    end
    return nil
end

-------------------------------------
--- @function getSettedFriendDragonID
-- @brief 친구 드래곤 id
-------------------------------------
function FriendDragonSelector:getSettedFriendDragonID()
    if (self.m_selectedSharedFriendDragon) then
        return self.m_selectedSharedFriendDragon
    end
    return nil
end

-------------------------------------
---@function checkSetSlotCondition
-- @brief 친구 드래곤 슬롯 세팅 조건 검사
-------------------------------------
function FriendDragonSelector:checkSetSlotCondition(doid)
    if (not g_friendData:checkFriendDragonFromDoid(doid)) then 
        return true 
    end

    -- 쿨타임 존재
    if (not g_friendData:checkUseEnableDragon(doid)) then 
        -- 따로 메세지 없음
        return false
    end

    -- 이미 선택된 친구가 있음
    if (self.m_selectedSharedFriendDragon) and (self.m_selectedSharedFriendDragon ~= doid) then 
        UIManager:toastNotificationRed(Str('친구 드래곤은 전투에 한 명만 참여할 수 있습니다'))
        return false
    end

    return true
end
