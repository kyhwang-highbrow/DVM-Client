-------------------------------------
-- class Serverdata_IllusionDungeon
-- @instance g_illusionDungeonData
-------------------------------------
Serverdata_IllusionDungeon = class({

})
-------------------------------------
-- function init
-------------------------------------
function Serverdata_IllusionDungeon:init()
end

-------------------------------------
-- function makeAdventureID
-- @brief 환상 던전 스테이지 ID 생성
--
-- stage_id
-- 191xxxx
--    1xxx difficulty 1~4
--       1 stage 던전 종류 1~..
-------------------------------------
function Serverdata_IllusionDungeon:makeAdventureID(difficulty, stage)
    return 1910000 + (difficulty * 1000) + (stage)
end

-------------------------------------
-- function parseStageID
-- @brief 환상 던전 스테이지 ID 분석
-------------------------------------
function Serverdata_IllusionDungeon:parseStageID(stage_id)
    local stage_id = tonumber(stage_id)

    local difficulty = getDigit(stage_id, 1000, 1)
    local chapter = getDigit(stage_id, 100000, 2)
    local stage = getDigit(stage_id, 1, 2)

    return difficulty, chapter, stage
end

-------------------------------------
-- function setAdventDidList
-------------------------------------
function Serverdata_IllusionDungeon:setAdventDidList(list_str)

end

-------------------------------------
-- function getAdventDidList
-------------------------------------
function Serverdata_IllusionDungeon:getAdventDidList()

end

-------------------------------------
-- function getAdventTitle
-------------------------------------
function Serverdata_IllusionDungeon:getAdventTitle()

end

-------------------------------------
-- function getAdventStageCount
-------------------------------------
function Serverdata_IllusionDungeon:getAdventStageCount()

end