-------------------------------------
---@class FriendDragonSelector
-------------------------------------
FriendDragonSelector = class({
    m_selectedFriends = 'map<>',
    m_bReleaseDragon = 'boolean',
})

-------------------------------------
---@function init
-------------------------------------
function FriendDragonSelector:init()
    self.m_selectedFriends = {}
end

-------------------------------------
---@function delSettedFriendDragon
-- @brief 친구 드래곤, 정보 초기화
-------------------------------------
function FriendDragonSelector:delSettedFriendDragon(_deck_key)
    if _deck_key == nil then
        self.m_selectedFriends = {}
        return
    end

    if self.m_selectedFriends[_deck_key] ~= nil then
        self.m_selectedFriends[_deck_key] = nil
    end
end

-------------------------------------
---@function delSettedFriendDragonCard
-- @brief 친구 드래곤 슬롯 해제
-------------------------------------
function FriendDragonSelector:delSettedFriendDragonCard(doid, _deck_key)
    local deck_key = _deck_key
    if (not g_friendData:checkFriendDragonFromDoid(doid)) then 
        return
    end

    local struct_battle_select_friend = self.m_selectedFriends[deck_key]
    if struct_battle_select_friend == nil then
        return
    end

    if struct_battle_select_friend:getSelectFriendDoid() ~= doid then
        return
    end

    self.m_selectedFriends[deck_key] = nil
end

-------------------------------------
---@function makeSettedFriendDragonCard
-- @brief 친구 드래곤 슬롯 세팅
-------------------------------------
function FriendDragonSelector:makeSettedFriendDragonCard(doid, idx, _deck_key)
    if (not g_friendData:checkFriendDragonFromDoid(doid)) then 
        return 
    end

    local deck_key = _deck_key
    local struct_battle_select_friend = self.m_selectedFriends[deck_key]
    if struct_battle_select_friend ~= nil then
        return
    end

    struct_battle_select_friend = StructBattleSelectFriend()
    struct_battle_select_friend.m_doid = doid
    struct_battle_select_friend.m_deckSlotIdx = idx
    struct_battle_select_friend.m_deckName = deck_key
    struct_battle_select_friend.m_friendInfo = g_friendData:getFriendInfoFromDoid(doid)
    self.m_selectedFriends[deck_key] = struct_battle_select_friend
end

-------------------------------------
---@function  getFriendDragonSlotIdx
-- @brief 친구 드래곤 슬롯 번호
-------------------------------------
function FriendDragonSelector:getFriendDragonSlotIdx(_deck_key)
    local struct_battle_select_friend = self.m_selectedFriends[_deck_key]
    if struct_battle_select_friend == nil then
        return nil
    end

    return struct_battle_select_friend:getSelectFriendDragonSlotIdx()
end

-------------------------------------
--- @function getSettedFriendDragonID
-- @brief 친구 드래곤 id
-------------------------------------
function FriendDragonSelector:getSettedFriendDragonID(_deck_key)
    local struct_battle_select_friend = self.m_selectedFriends[_deck_key]
    if struct_battle_select_friend == nil then
        return nil
    end

    return struct_battle_select_friend:getSelectFriendDoid()
end

-------------------------------------
--- @function getSettedFriendUID
-- @brief 친구 uid
-------------------------------------
function FriendDragonSelector:getSettedFriendUID(_deck_key)
    local struct_battle_select_friend = self.m_selectedFriends[_deck_key]
    if struct_battle_select_friend == nil then
        return nil
    end

    local t_friend_info = struct_battle_select_friend:getSelectFriendInfo()
    if (not t_friend_info) then 
        return nil
    end

    return t_friend_info.m_uid
end

-------------------------------------
---@function checkSetSlotCondition
-- @brief 친구 드래곤 슬롯 세팅 조건 검사
-------------------------------------
function FriendDragonSelector:checkSetSlotCondition(doid, _deck_key)
    if (not g_friendData:checkFriendDragonFromDoid(doid)) then
        return true 
    end

    -- 쿨타임 존재
    if (not g_friendData:checkUseEnableDragon(doid)) then 
        -- 따로 메세지 없음
        return false
    end

    local struct_battle_select_friend = self.m_selectedFriends[_deck_key]
    if struct_battle_select_friend ~= nil then
        if struct_battle_select_friend:getSelectFriendDoid() ~= doid then
            UIManager:toastNotificationRed(Str('친구 드래곤은 전투에 한 명만 참여할 수 있습니다'))
            return false
        end
    end

    return true
end

-------------------------------------
---@function checkSameDidInFriends
-- @brief 친구 동종 드래곤 세팅 체크
-------------------------------------
function FriendDragonSelector:checkSameDidInFriends(idx, doid)
    for k, select_friend_battle in pairs(self.m_selectedFriends) do
        local f_idx = select_friend_battle:getSelectFriendDragonSlotIdx()
        local f_doid = select_friend_battle:getSelectFriendDoid()
        if (g_dragonsData:isSameDid(f_doid, doid)) and (idx ~= f_idx) then
            return true
        end
    end

    return false
end

-------------------------------------
--- @function getParticipationFriendDragon
--- @brief
-------------------------------------
function FriendDragonSelector:getParticipationFriendDragon(_deck_key)
    if self.m_selectedFriends[_deck_key] == nil then
        return nil
    end

    local struct_battle_select_friend = clone(self.m_selectedFriends[_deck_key])
    local t_friend_info = struct_battle_select_friend:getSelectFriendInfo()
    if (not t_friend_info) then        
        return nil
    end

    self.m_selectedFriends[_deck_key] = nil
    local dragon_object = t_friend_info.m_leaderDragonObject
    local rune_object = t_friend_info.m_runesObject
    local slot_idx = struct_battle_select_friend:getSelectFriendDragonSlotIdx()
    
    return dragon_object, rune_object, slot_idx
end