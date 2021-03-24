local PARENT = GameWorld

-------------------------------------
-- class GameWorldTrial
-------------------------------------
GameWorldTrial = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function GameWorldTrial:init(world)
end


-------------------------------------
-- function createComponents
-------------------------------------
function GameWorldTrial:createComponents()
    PARENT.createComponents(self)

    self.m_gameState = GameState_Trial(self)
end

-------------------------------------
-- function actStagePreparation
-------------------------------------
function GameWorldTrial:actStagePreparation()
    -- 파일에서 사전준비 정보를 얻어옴
    local script = self.m_waveMgr:getCurrentWaveScriptData()

    if (not script or not script['preparation']) then return end

    local preparationData = script['preparation']

    -- data_ ex : "300202;1;test;T7;R5"
    local l_str = seperate(preparationData, ';')
    local summonObj_id = tonumber(l_str[1])   -- 소환체 ID
    local t_summonObj = TableSummonObject():get(summonObj_id)

    if (not t_summonObj or not t_summonObj['type']) then return end

    local dynamic_wave = DynamicWave(self.m_waveMgr, preparationData, 0)
    self.m_waveMgr:summonCreature(dynamic_wave, t_summonObj['type'])
end