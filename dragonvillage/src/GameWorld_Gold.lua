local PARENT = IEventListener:getCloneClass()


-------------------------------------
-- class GameWorld_Gold
-------------------------------------
GameWorld_Gold = class(PARENT, {
        m_world = 'GameWorld',
        m_inGameUI = 'UI',

        -- drop테이블에서 받아오는 보너스 골드 정보
        m_goldPerHit = 'number',
        m_goldPerDamage = 'number',
        m_goldLimit = 'number',

        -- 보너스 골드 시스템 활성 여부
        m_bActiveBonusGoldSystem = 'boolean',

        -- 획득 골드량 보안 처리
        m_snGold = 'SecurityNumberClass',
    })

-------------------------------------
-- function init
-------------------------------------
function GameWorld_Gold:init(world)
    self.m_world = world
    self.m_inGameUI = world.m_inGameUI

    local stage_id = world.m_stageID
    local gold_per_hit, gold_per_damage, gold_per_limit = TableDrop:getStageBonusGoldInfo(stage_id)

    -- 0일 경우 기본값 지정, -1일 경우 무제한
    if (gold_per_limit == 0) then
        gold_per_limit = 10000
    end

    self.m_goldPerHit = gold_per_hit
    self.m_goldPerDamage = gold_per_damage
    self.m_goldLimit = gold_per_limit

    -- 보너스 골드 시스템 활성 여부
    if (0 < gold_per_hit) or (0 < gold_per_damage) then
        self.m_bActiveBonusGoldSystem = true
    else
        self.m_bActiveBonusGoldSystem = false
    end

    -- 획득 골드량 보안 처리
    self.m_snGold = SecurityNumberClass(0)

    -- 보너스 골드 시스템 활성이 된 경우에 초기화
    if self.m_bActiveBonusGoldSystem then
        self.m_inGameUI:init_goldUI()
        world:addListener('make_dragon', self)
        world:addListener('make_monster', self)
    end
end


-------------------------------------
-- function obtainGold
-------------------------------------
function GameWorld_Gold:obtainGold(add_gold, x, y)
    local prev_gold = self.m_snGold:get()

    if (self.m_goldLimit ~= -1) then
        add_gold = math_min(add_gold, (self.m_goldLimit - prev_gold))
    end

    if (add_gold <= 0) then
        return
    end
    
    self:makeEffectGoldDrop(x, y)

    self.m_snGold:add(add_gold)

    self.m_inGameUI:setGold(self.m_snGold:get(), prev_gold)
end

-------------------------------------
-- function getObtainGold
-------------------------------------
function GameWorld_Gold:getObtainGold()
    local obtain_gold = self.m_snGold:get()
    return obtain_gold
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameWorld_Gold:onEvent(event_name, t_event, ...)
    -- 드래곤 생성 시 'hit' 이벤트 등록
    if (event_name == 'make_dragon') then
        local dragon = t_event['dragon']
        dragon:addListener('hit', self)

    -- 몬스터 생성 시 'damaged' 이벤트 등록
    elseif (event_name == 'make_monster') then
        local monster = t_event['monster']
        monster:addListener('damaged', self)

    -- 아군 드래곤히 hit를 했을 경우 추가 골드
    elseif (event_name == 'hit') then
        local x = t_event['i_x']
        local y = t_event['i_y']
        self:obtainGold(self.m_goldPerHit, x, y)

    -- monster가 데미지를 입었을 경우 추가 골드
    elseif (event_name == 'damaged') then
        local damage = t_event['damage']
        local x = t_event['i_x']
        local y = t_event['i_y']
        self:obtainGold(damage * self.m_goldPerDamage, x, y)
    end
end

-------------------------------------
-- function makeEffectGoldDrop
-------------------------------------
function GameWorld_Gold:makeEffectGoldDrop(x, y)
    local res = 'res/effect/effect_hit_gold/effect_hit_gold.vrp'
    local idx = math_random(1, 3)
    self.m_world:addInstantEffect(res, 'hit_' .. idx, x, y)
end