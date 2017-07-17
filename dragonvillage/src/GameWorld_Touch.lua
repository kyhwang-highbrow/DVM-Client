-------------------------------------
-- function makeTouchLayer_GameWorld
-------------------------------------
function GameWorld.makeTouchLayer_GameWorld(self, target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self.onTouchMoved_GameWorld(self, touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self.onTouchMoved_GameWorld(self, touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self.onTouchEnded_GameWorld(self, touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self.onTouchEnded_GameWorld(self, touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)
                
    local eventDispatcher = target_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouchMoved_GameWorld
-------------------------------------
function GameWorld.onTouchMoved_GameWorld(self, touch, event)
    local location = touch:getLocation()
    local node_pos = self.m_worldNode:convertToNodeSpace(location)
    
    -- 이전 위치가 없을 경우 현재 위치로 간주
    if (not self.m_touchPrevPos) then
        self.m_touchPrevPos = node_pos
    end

    -- 이전 위치와 현재 위치 사이의 점들을 구함
    local distance = getDistance(node_pos['x'], node_pos['y'], self.m_touchPrevPos['x'], self.m_touchPrevPos['y'])
    local dir = getDegree(node_pos['x'], node_pos['y'], self.m_touchPrevPos['x'], self.m_touchPrevPos['y'])
    local offset = getPointFromAngleAndDistance(dir, 50)

    local iter_x = node_pos['x']
    local iter_y = node_pos['y']

    local cnt = math.floor(distance / 50)
    cnt = math_max(1, cnt)

    -- 슬라이드 위치부터 50픽셀 반경을 가격, 0.1초 간격으로 다단히트, 체력의 2%의 퍼센트 데미지
    local b_attack = false
    local b_get_gold = false
    local time = socket.gettime()
    for i=1, cnt do

        -- 적군과의 충돌 처리
        if self:isOnFight() then
            for _,enemy in pairs(self:getEnemyList()) do
                if self:loopAttackEnemy(enemy, iter_x, iter_y, time) then
                    b_attack = true
                end
            end
        end

        iter_x = iter_x + offset['x']
        iter_y = iter_y + offset['y']
    end

    -- 공격이 이루어 졌으면 사운드 재생
    if b_attack then
        --SoundMgr:playEffect('EFFECT', 'option_magicsword_2')
    end

    -- 동전을 획득했으면 사운드 재생
    if b_get_gold then
        --SoundMgr:playEffect('EFFECT', 'gold_get')
    end

    -- 모션스트릭 효과 위치 갱신
    self.m_touchMotionStreak:setPosition(node_pos['x'], node_pos['y'])
    self.m_touchPrevPos = node_pos

    return true
end

-------------------------------------
-- function loopAttackEnemy
-------------------------------------
function GameWorld:loopAttackEnemy(enemy, x, y, time)
    -- Seong-goo Kim 2016.10.11 대표님 요청으로 기능 제거
    if true then
        return
    end

    if (enemy:isDead()) then
        return false
    end

    if (not enemy.enable_body) then
        return false
    end

    -- 시간 체크 (0.1초 안에는 다시 맞지 않도록)
    if (self.m_tCollisionTime[enemy.phys_idx]) then
        local time_gap = (time - (self.m_tCollisionTime[enemy.phys_idx]))
        if (time_gap < 0.1) then
            return false
        end
    end

    -- 거리 체크 (50픽셀)
    local dist = getDistance(enemy.pos.x, enemy.pos.y, x, y)
    if (50 < dist) then
        return false
    end

    -- 퍼센트 데미지 수치 계산
    local enemy_rarity = enemy.m_charTable['rarity']
    local rarity_num = monsterRarityStrToNum(enemy_rarity)
    local per_dmg_rate = getMonsterSlicePerDamageRate(rarity_num)

    -- 데미지 가함
    local damage = math_floor(enemy.m_maxHp * per_dmg_rate)
    enemy:setDamage(nil, nil, x, y, damage, nil)
    self.m_tCollisionTime[enemy.phys_idx] = time

    return true
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function GameWorld.onTouchEnded_GameWorld(self, touch, event)
    self.m_touchPrevPos = nil
end

-------------------------------------
-- function init_motionStreak
-------------------------------------
function GameWorld.init_motionStreak(self)
    --self.m_touchMotionStreak = cc.MotionStreak:create(0.3, -1, 50, cc.c3b(255, 255, 255), 'res/common/motion_streak.png')
    self.m_touchMotionStreak = cc.MotionStreak:create(0.4, 3, 32, cc.c3b(0, 255, 0), 'res/common/motion_streak.png')
    
    self:addChild2(self.m_touchMotionStreak, DEPTH_ITEM_GOLD)

    local colorAction = cc.RepeatForever:create(cc.Sequence:create(cc.TintTo:create(0.2, 255, 0, 0),
                                                cc.TintTo:create(0.2, 0, 255, 0),
                                                cc.TintTo:create(0.2, 0, 0, 255),
                                                cc.TintTo:create(0.2, 0, 255, 255),
                                                cc.TintTo:create(0.2, 255, 255, 0),
                                                cc.TintTo:create(0.2, 255, 255, 255)))

    self.m_touchMotionStreak:runAction(colorAction)
end