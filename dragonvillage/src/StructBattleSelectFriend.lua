-------------------------------------
-- class StructBattleSelectFriend
-- @brief 친구 드래곤 선택 정보
-------------------------------------
StructBattleSelectFriend = class({
    m_friendInfo = 'StructUserInfoFriend', -- 친구 정보
    m_doid = 'string', -- 친구 드래곤 아이디
    m_deckName = 'string', -- 덱 이름
    m_deckSlotIdx = 'number',
})

local THIS = StructBattleSelectFriend
-------------------------------------
-- function init
-------------------------------------
function StructBattleSelectFriend:init()
end

-------------------------------------
---@function getSelectFriendDoid
-------------------------------------
function StructBattleSelectFriend:getLanguageSimpleDisplayName()
end

-------------------------------------
---@function getLanguageEnglishDisplayName
-------------------------------------
function StructBattleSelectFriend:getLanguageEnglishDisplayName()
end