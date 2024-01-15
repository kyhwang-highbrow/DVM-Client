local PARENT = GameWorldWorldRaid

-------------------------------------
-- class GameWorldWorldRaidCooperation
-------------------------------------
GameWorldWorldRaidCooperation = class(PARENT, {
    })

-------------------------------------
--- @function makeHeroDeck
--- @brief 덱 만들고 버프 부여하기
-------------------------------------
function GameWorldWorldRaidCooperation:makeHeroDeck()
    -- 부모 함수 호출
    PARENT.makeHeroDeck(self)

    -- 유저의 드래곤 덱 리스트
    local l_deck = self:getDragonList()
    for i, dragon in pairs(l_deck) do
        -- 스테이지 버프 적용
        self:applyEventDealkingStageBonus(dragon)
    end
end