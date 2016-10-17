-------------------------------------
-- class Thunder
-------------------------------------
Thunder = class(Entity, {

        m_physGroup = '',

        m_activityCarrier = '',

        m_loopCnt = '',
        m_bFinish = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Thunder:init(file_name, body, ...)
    self.m_loopCnt = 0
    self.m_bFinish = false
    self:initState()
end

-------------------------------------
-- function init_Thunder
-------------------------------------
function Thunder:init_Thunder(res, count)

    local t_targets = self:getTargetList(count)

    for i,target_char in ipairs(t_targets) do

        -- 공격
        self:runAtkCallback(target_char, target_char.pos.x, target_char.pos.y)
        target_char:runDefCallback(self, target_char.pos.x, target_char.pos.y)

        -- 이펙트 생성
        self:makeEffect(i, res, target_char.pos.x, target_char.pos.y)
    end
end

-------------------------------------
-- function initState
-------------------------------------
function Thunder:initState()
    self:addState('idle', Thunder.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('idle')
end

-------------------------------------
-- function st_idle
-------------------------------------
function Thunder.st_idle(owner, dt)
end

-------------------------------------
-- function getTargetList
-------------------------------------
function Thunder:getTargetList(count)
    local world = self.m_world

    local tar_list = nil
    if (self.m_physGroup == 'missile_h') then
        tar_list = world.m_tEnemyList
    elseif (self.m_physGroup == 'missile_e') then
        tar_list = world.m_participants
    end

    local t_rand = {}
    local char_cnt = #tar_list
    for i,v in ipairs(tar_list) do
        table.insert(t_rand, i)
    end

    local t_ret = {}
    for i=1, count do
        if #t_rand < 1 then
            break
        end

        local rand = math_random(1, #t_rand)
        table.insert(t_ret, tar_list[rand])
        table.remove(t_rand, rand)
    end

    return t_ret
end

-------------------------------------
-- function makeEffect
-------------------------------------
function Thunder:makeEffect(idx, res, x, y)
    local file_name = res
    local start_ani = 'start_idle'
    local link_ani = 'bar_idle'
    local end_ani = 'end_idle'

    local link_effect = LinkEffect(file_name, link_ani, start_ani, end_ani, 200, 200)
    link_effect.m_bRotateEndEffect = false

    link_effect.m_startPointNode:setScale(0.15)
    link_effect.m_endPointNode:setScale(0.3)

    if (idx == 1) then
        link_effect.m_effectNode:addAniHandler(function()
                if (not self.m_bFinish) then
                    self.m_loopCnt = self.m_loopCnt + 1
                    if (self.m_loopCnt >= 2) then
                        self:changeState('dying')
                        self.m_bFinish = true
                    end
                end
            end)
    end

    self.m_rootNode:addChild(link_effect.m_node)

    local tar_x = x - self.pos.x
    local tar_y = y - self.pos.y

    LinkEffect_refresh(link_effect, 0, 0, tar_x, tar_y)
end