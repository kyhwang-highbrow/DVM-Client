
-- @TODO 사용 안함 - 확인 후 정리


-------------------------------------
-- class SkillChainLightning
-------------------------------------
SkillChainLightning = class(Entity, {
        m_owner = 'Character',
        m_offsetX = 'number',
        m_offsetY = 'number',

		m_res = '',

        m_tTargetList = 'List',
        m_tEffectList = 'List',

        m_physGroup = 'string',
        m_activityCarrier = 'AttackDamage',
        m_loopCnt = 'number',               -- 에니메이션 재생 횟수
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillChainLightning:init(file_name, body, ...)
    self.m_loopCnt = 0
    
    self:initState()
end

-------------------------------------
-- function init_SkillChainLightning
-------------------------------------
function SkillChainLightning:init_SkillChainLightning(owner, t_skill, x, y)
    self.m_owner = owner

    -- 리소스
    self.m_res = string.gsub(t_skill['res_1'], '@', owner:getAttribute())

    self:setPosition(self.pos.x + x, self.pos.y - y)

    self.m_activityCarrier = owner:makeAttackDamageInstance()
    self.m_activityCarrier.m_skillCoefficient = (t_skill['power_rate'] / 100)

    local count = t_skill['val_2']
    local t_targets = self:getTargetList(count)

    self.m_tTargetList = t_targets
    self.m_tEffectList = {}

    self:changeState('idle')
end

-------------------------------------
-- function initState
-------------------------------------
function SkillChainLightning:initState()
    self:addState('idle', SkillChainLightning.st_idle, 'idle', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillChainLightning.st_idle(owner, dt)
    local x = owner.m_owner.pos.x + owner.m_offsetX
    local y = owner.m_owner.pos.y + owner.m_offsetY
    owner:setPosition(x, y)

    owner:updatePos()

	if (owner.m_stateTimer == 0) then
        owner:runAttack()
    end
	-- aniHandler로 이펙트에 changeState('dying') 붙임
end

-------------------------------------
-- function getTargetList
-------------------------------------
function SkillChainLightning:getTargetList(count)
    local world = self.m_world

    local target_type = 'enemy' or 'hero'
    if (self.m_physGroup == 'missile_h') then
        target_type = 'enemy'
    elseif (self.m_physGroup == 'missile_e') then
        target_type = 'hero'
    end

    local t_target_list = {}
    local t_target_phys_list = {}

    local x = self.pos.x
    local y = self.pos.y

    for i=1, count do
        local target = world:findTarget(target_type, x, y, t_target_phys_list)
        if target then
            table.insert(t_target_list, target)
            table.insert(t_target_phys_list, target.phys_idx)

            x = target.pos.x
            y = target.pos.y
        end
    end

    return t_target_list
end

-------------------------------------
-- function runAttack
-------------------------------------
function SkillChainLightning:runAttack()
    for i,target_char in ipairs(self.m_tTargetList) do
        -- 공격
        self:attack(target_char)

        -- 이펙트 생성
        local effect = self:makeEffect(i, self.m_res)
        table.insert(self.m_tEffectList, effect)

		local info = self.m_activityCarrier:getDamagedInfo()
		local isCritical = info['critical'] or false
		if (i == 1) and (not isCritical) then return end
    end
end

-------------------------------------
-- function makeEffect
-------------------------------------
function SkillChainLightning:makeEffect(idx, res)
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
			self:changeState('dying')
        end)
    end

    self.m_rootNode:addChild(link_effect.m_node)

    return link_effect
end

-------------------------------------
-- function updatePos
-------------------------------------
function SkillChainLightning:updatePos()
    local x = 0
    local y = 0

    for i,v in ipairs(self.m_tTargetList) do
        local effect = self.m_tEffectList[i]
		if (nil == effect) then return end 

        -- 상대좌표 사용
        local tar_x = (v.pos.x - self.pos.x)
        local tar_y = (v.pos.y - self.pos.y)

		LinkEffect_refresh(effect, x, y, tar_x, tar_y)

        x = tar_x
        y = tar_y
    end
end