-------------------------------------
-- function makeDragonNew
-------------------------------------
function GameWorld:makeDragonNew(t_dragon_data, bRightFormation)
    -- 유저가 보유하고있는 드래곤의 정보
    local t_dragon_data = t_dragon_data
    local bLeftFormation = true
    if bRightFormation then bLeftFormation = false end

    local dragon_id = t_dragon_data['did']

    -- 테이블의 드래곤 정보
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    local doid = t_dragon_data['id']
    local lv = t_dragon_data['lv'] or 1
    local grade = t_dragon_data['grade'] or 1
    local evolution = t_dragon_data['evolution'] or 1
	local attr = t_dragon['attr']

    local dragon = Hero(nil, {0, 0, 20})
    dragon.m_bLeftFormation = bLeftFormation

    dragon:setDragonSkillLevelList(t_dragon_data['skill_0'], t_dragon_data['skill_1'], t_dragon_data['skill_2'], t_dragon_data['skill_3'])
    dragon:initDragonSkillManager('dragon', dragon_id, evolution)
    dragon:initActiveSkillCoolTime() -- 액티브 스킬 쿨타임 지정
    dragon.m_tDragonInfo = t_dragon_data
    dragon:initAnimatorHero(t_dragon['res'], evolution, attr)
    dragon.m_animator:setScale(0.5 * t_dragon['scale'])
    dragon:initState()
    dragon:initStatus(t_dragon, lv, grade, evolution, doid)

    -- 기본 정보 저장
    dragon.m_dragonID = dragon_id
    dragon.m_charTable = t_dragon

    if bLeftFormation then
        dragon:changeState('idle')
    else
        dragon:changeState('move')
        dragon.m_animator:setFlip(true)
    end
    
    -- 피격 처리
    dragon:addDefCallback(function(attacker, defender, i_x, i_y)
        dragon:undergoAttack(attacker, defender, i_x, i_y)
    end)

    self:addToUnitList(dragon)
    dragon:makeHPGauge({0, -80})

    return dragon
end

-------------------------------------
-- function makeMonsterNew
-------------------------------------
function GameWorld:makeMonsterNew(monster_id, level)

    local t_monster = TableMonster():get(monster_id)

    if (not t_monster) then
        error(tostring('다음 ID는 존재하지 않습니다 : ' .. monster_id))
    end

    local body = {0, 0, 50}

    -- 사이즈 타입별 피격박스 반지름 변경
    local size_type = t_monster['size_type']
    if (size_type == 's') then
        body[3] = 30
    elseif (size_type == 'm') then
        body[3] = 40
    elseif (size_type == 'l') then
        body[3] = 60
    elseif (size_type == 'xl') then
        body[3] = 100
	elseif (size_type == 'xxl') then
        body[3] = 200
    end

    -- 난이도별 레벨 설정
    local t_drop = TABLE:get('drop')[self.m_stageID]
    local level = level + t_drop['level']
    
    local scale = 1
    local offset_y = (body[3] * 1.5)
    local hp_ui_offset = {0, -offset_y}
    local animator_scale = t_monster['scale'] or 1

    -- Monster 생성
    local monster = self:tryPatternMonster(t_monster, body)
    if (not monster) then
        monster = Enemy(t_monster['res'], body)
        monster:initAnimatorMonster(t_monster['res'], t_monster['attr'])
    end

    monster:initDragonSkillManager('enemy', monster_id, 6) -- monster는 skill_1~skill_6을 모두 사용
    monster:initState()
    monster:initStatus(t_monster, level)
    monster:changeState('move')
    
    monster.m_animator.m_node:setScale(animator_scale)
    monster.m_animator:setFlip(true)

    -- 피격 처리
    monster:addDefCallback(function(attacker, defender, i_x, i_y)
        monster:undergoAttack(attacker, defender, i_x, i_y, 0)
    end)

    self:addToUnitList(monster)
    monster:makeHPGauge(hp_ui_offset)
    
	return monster
end

-------------------------------------
-- function tryPatternMonster
-- @brief 패턴을 가진 적군
-- ex) 'pattern_' + rarity + type
--     'pattern_boss_queenssnake'
-------------------------------------
function GameWorld:tryPatternMonster(t_monster, body)
    local rarity = t_monster['rarity']
    local type = t_monster['type']
    local script_name = 'pattern_' .. rarity .. '_' .. type    

    -- 임시 구현
    if (type == 'giantdragon') then
        local monster = Monster_GiantDragon(t_monster['res'], body)
        monster:initAnimatorMonster(t_monster['res'], t_monster['attr'])
        monster:initScript(script_name)

        return monster
    end

    -- 테이블이 없을 경우 return
    local script = TABLE:loadJsonTable(script_name)
	local is_pattern_ignore = (t_monster['pattern'] == 'ignore')
	
    if (not script) or is_pattern_ignore then
        return nil
    end

    local monster = EnemyLua_Boss(t_monster['res'], body)
    monster:initAnimatorMonster(t_monster['res'], t_monster['attr'])
    monster:initScript(script_name)

    return monster
end