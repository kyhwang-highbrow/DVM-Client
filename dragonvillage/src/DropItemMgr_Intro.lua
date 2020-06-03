local PARENT = DropItemMgr

-------------------------------------
-- class DropItemMgr_Intro
-------------------------------------
DropItemMgr_Intro = class(PARENT, {
    m_bEnableTouch = 'boolean',
    m_firstItem = 'DropItem',

    m_animatorGuide = 'cc.AzVRP',
})

-------------------------------------
-- function init
-------------------------------------
function DropItemMgr_Intro:init(world)
    self.m_bEnableTouch = false
    self.m_firstItem = nil
end

-------------------------------------
-- function update
-------------------------------------
function DropItemMgr_Intro:update(dt)
    local t_remove = {}
    for i, v in ipairs(self.m_lItemlist) do

        -- 일시 정지 상태가 아닌 경우에만 업데이트
        if (v.m_temporaryPause) then
            v:setTemporaryPause(false)

        else
            -- update 리턴값이 true이면 객체 삭제
            if (v:update(dt) == true) then
                table.insert(t_remove, 1, i)
                v:release()
            end
        end
    end

    for i,v in ipairs(t_remove) do
        table.remove(self.m_lItemlist, v)
    end
end

-------------------------------------
-- function designateDropMonster
-- @brief 드랍 몬스터 지정
-------------------------------------
function DropItemMgr_Intro:designateDropMonster()
    -- 총 드랍할 개수를 지정
    self.m_remainItemCnt = 1

    -- 웨이브 정보를 얻어옴
    local wave_script = self.m_world.m_waveMgr.m_scriptData
    local wave_list = wave_script['wave']
    if (not wave_list) then
        error('wave is nil. stage_id = ' .. stage_id)
    end
    
    -- 몬스터에 드랍 여부를 지정
    -- (2웨이브에서 등장하는 모든 몬스터가 아이템을 드랍할 수 있도록 함)
    local t_wave = wave_list[2]
    local time_list = t_wave['wave']

    for _, monster_list in pairs(time_list) do
        for i, monster in ipairs(monster_list) do
            monster_list[i] = monster_list[i] .. '@item'
        end
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function DropItemMgr_Intro:onEvent(event_name, t_event, ...)
    if (event_name == 'character_dead') then
        local arg = {...}
        local enemy = arg[1]

        if (enemy.m_hasItem and 0 < self.m_remainItemCnt) then
            local item = self:dropItem(enemy.pos.x, enemy.pos.y)

            if (not self.m_firstItem) then
                self.m_firstItem = item
            end

            enemy.m_hasItem = false
            self.m_remainItemCnt = (self.m_remainItemCnt - 1)
        end
    end
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function DropItemMgr_Intro:onTouchBegan(touch, event)
    if (not self.m_bEnableTouch) then return false end

    if (g_gameScene.m_nIdx == 3) then
        self:onTouchBeganForIntro(touch, event)
    end
end

-------------------------------------
-- function onTouchBeganForIntro
-------------------------------------
function DropItemMgr_Intro:onTouchBeganForIntro(touch, event)
    -- 월드상의 터치 위치 얻어옴
    local location = touch:getLocation()

    -- item들은 game node 2에 위치함
    local node_pos = self.m_world.m_gameNode2:convertToNodeSpace(location)

    local select_item = self:getItemFromPos(node_pos['x'], node_pos['y'])
    if (select_item == self.m_firstItem and not select_item:isObtained()) then
        if (self.m_animatorGuide) then
            self.m_animatorGuide:release()
            self.m_animatorGuide = nil
        end
        
        self:obtainItem(select_item)

        select_item:makeObtainEffect()
        select_item:changeState('dying')

        g_gameScene:next_intro()
    end
end

-------------------------------------
-- function obtainItem
-------------------------------------
function DropItemMgr_Intro:obtainItem(item)
    if (item:isObtained()) then
        return
    end

    local type = 'gold'
    local count = 20
    item:setObtained(type, count)

    -- 정보 저장
    table.insert(self.m_obtainedItemList, {type, count})
end

-------------------------------------
-- function startIntro
-------------------------------------
function DropItemMgr_Intro:startIntro()
    self:setEnableTouch(true)

    self.m_firstItem:setTemporaryPause(false)

    self.m_world.m_gameHighlight:addForcedHighLightList(self.m_firstItem)

    -- 가이드 비주얼
    self.m_animatorGuide = MakeAnimator('res/ui/a2d/tutorial/tutorial.vrp')
    self.m_animatorGuide:changeAni('hand_0101', true)
    self.m_animatorGuide:setPosition(self.m_firstItem.pos.x, self.m_firstItem.pos.y + 20)

    g_gameScene.m_gameIndicatorNode:addChild(self.m_animatorGuide.m_node)
end

-------------------------------------
-- function setEnableTouch
-------------------------------------
function DropItemMgr_Intro:setEnableTouch(b)
    self.m_bEnableTouch = b
end