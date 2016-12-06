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

    local hero = Hero(nil, {0, 0, 20})
    hero.m_bLeftFormation = bLeftFormation

    hero:setDragonSkillLevelList(t_dragon_data['skill_0'], t_dragon_data['skill_1'], t_dragon_data['skill_2'], t_dragon_data['skill_3'])
    hero:initDragonSkillManager('dragon', dragon_id, evolution)
    hero:initActiveSkillCoolTime() -- 액티브 스킬 쿨타임 지정
    hero.m_tDragonInfo = t_dragon_data
    hero:initAnimatorHero(t_dragon['res'], evolution, attr)
    hero.m_animator:setScale(0.5 * t_dragon['scale'])
    hero:initState()
    hero:initStatus(t_dragon, lv, grade, evolution, doid)

    -- 기본 정보 저장
    hero.m_dragonID = dragon_id
    hero.m_charTable = t_dragon

    if bLeftFormation then
        hero:changeState('idle')
    else
        hero:changeState('move')
        hero.m_animator:setFlip(true)
    end
    
    -- 피격 처리
    hero:addDefCallback(function(attacker, defender, i_x, i_y)
        hero:undergoAttack(attacker, defender, i_x, i_y)
    end)

    self:addToUnitList(hero)
    hero:makeHPGauge({0, -80})

    return hero
end

-------------------------------------
-- function makeEnemyNew
-------------------------------------
function GameWorld:makeEnemyNew(enemy_id, level)

    local table_enemy = TABLE:get('enemy')
    local t_enemy = table_enemy[enemy_id]

    if (not t_enemy) then
        error(tostring('다음 ID는 존재하지 않습니다 : ' .. enemy_id))
    end

    local body = {0, 0, 50}

    -- 사이즈 타입별 피격박스 반지름 변경
    local size_type = t_enemy['size_type']
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
    local animator_scale = t_enemy['scale'] or 1

    -- Enemy 생성
    local enemy = self:tryPatternEnemy(t_enemy, body)
    if (not enemy) then
        enemy = Enemy(t_enemy['res'], body)
        enemy:initAnimatorMonster(t_enemy['res'], t_enemy['attr'])
    end

    enemy:initDragonSkillManager('enemy', enemy_id, 6) -- monster는 skill_1~skill_6을 모두 사용
    enemy:initState()
    enemy:initStatus(t_enemy, level)
    enemy:changeState('move')
    --[[
    -- 죽음 콜백 등록
    enemy:addListener('character_dead', self)

    -- 등장 완료 콜백 등록
    enemy:addListener('enemy_appear_done', self.m_gameState)

    -- 스킬 캐스팅 중 취소시 콜백 등록
    enemy:addListener('character_casting_cancel', self.m_tamerSpeechSystem)
    enemy:addListener('character_casting_cancel', self.m_gameFever)
    ]]--
    enemy.m_animator.m_node:setScale(animator_scale)
    enemy.m_animator:setFlip(true)

    -- 피격 처리
    enemy:addDefCallback(function(attacker, defender, i_x, i_y)
        enemy:undergoAttack(attacker, defender, i_x, i_y, 0)
    end)

    self:addToUnitList(enemy)
    enemy:makeHPGauge(hp_ui_offset)
    
	return enemy
end

-------------------------------------
-- function tryPatternEnemy
-- @brief 패턴을 가진 적군
-- ex) 'pattern_' + rarity + type
--     'pattern_boss_queenssnake'
-------------------------------------
function GameWorld:tryPatternEnemy(t_enemy, body)
    local rarity = t_enemy['rarity']
    local type = t_enemy['type']
    local script_name = 'pattern_' .. rarity .. '_' .. type    

    -- 임시 구현
    if (type == 'giantdragon') then
        local enemy = Monster_GiantDragon(t_enemy['res'], body)
        enemy:initAnimatorMonster(t_enemy['res'], t_enemy['attr'])
        enemy:initScript(script_name)

        return enemy
    end

    -- 테이블이 없을 경우 return
    local script = TABLE:loadJsonTable(script_name)
	local is_pattern_ignore = (t_enemy['pattern'] == 'ignore')
	
    if (not script) or is_pattern_ignore then
        return nil
    end

    local enemy = EnemyLua_Boss(t_enemy['res'], body)
    enemy:initAnimatorMonster(t_enemy['res'], t_enemy['attr'])
    enemy:initScript(script_name)

    return enemy
end