local PARENT = Structure

-- 덱(팀)의 json 데이터 예시
--{
--    "tamerInfo":{
--      "skill_lv4":55,
--      "tid":110004,
--      "skill_lv3":63,
--      "skill_lv2":63,
--      "costume":730400,
--      "skill_lv1":55
--    },
--    "tamer":110004,
--    "formationlv":1,
--    "deck":{
--      "2":"5a6ed5bff6608a4ae906491b",
--      "3":"5a508f53f6608a11e8dff4cc",
--      "1":"59a6db9691bcb621e707f6e8",
--      "5":"59ab4495476c0d2c4baf0482"
--    },
--    "formation":"charge",
--    "leader":2,
--    "deckName":"arena"
--}

-------------------------------------
-- class StructDeck
-- @brief 덱(팀) 정보를 관리하는 구조체
-------------------------------------
StructDeck = class(PARENT, {
    })

local THIS = StructDeck

-------------------------------------
-- function init
-------------------------------------
function StructDeck:init()
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructDeck:getClassName()
    return 'StructDeck'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructDeck:getThis()
    return THIS
end