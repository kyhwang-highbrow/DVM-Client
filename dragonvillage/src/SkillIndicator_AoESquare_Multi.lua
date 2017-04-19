local PARENT = SkillIndicator_AoESquare

-------------------------------------
-- class SkillIndicator_AoESquare_Multi
-------------------------------------
SkillIndicator_AoESquare_Multi = class(PARENT, {
        m_lIndicatorEffectList = 'list',
		m_lineCnt = 'num',
		m_space = 'num',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicator_AoESquare_Multi:init(hero, t_skill, target_type)
end

-------------------------------------
-- function init_indicator
-------------------------------------
function SkillIndicator_AoESquare_Multi:init_indicator(t_skill, target_type)
	PARENT.init_indicator(self, t_skill)

	self.m_skillWidth = g_constant:get('SKILL', 'WONDER_CLAW_WIDTH')
	self.m_indicatorScale = self.m_skillWidth/300

	self.m_space = g_constant:get('SKILL', 'WONDER_CLAW_SPACE')
	self.m_lineCnt = t_skill['hit']
	self.m_lIndicatorEffectList = {}
end

-------------------------------------
-- function setIndicatorPosition
-------------------------------------
function SkillIndicator_AoESquare_Multi:setIndicatorPosition(touch_x, touch_y, pos_x, pos_y)
	local scr_size = cc.Director:getInstance():getWinSize()
	local indicator_y = -(scr_size.height/2) - 100
	local l_pos_x = SkillHelper:calculatePositionX(self.m_lineCnt, self.m_space, touch_x - pos_x)
    
	for i, indicator in pairs(self.m_lIndicatorEffectList) do
		indicator:setPosition(l_pos_x[i], indicator_y)
	end
end

-------------------------------------
-- function initIndicatorNode
-------------------------------------
function SkillIndicator_AoESquare_Multi:initIndicatorNode()
    if (not SkillIndicator.initIndicatorNode(self)) then
        return
    end

    local root_node = self.m_indicatorRootNode

    for i = 1, self.m_lineCnt do
		local indicator_res = g_constant:get('INDICATOR', 'RES', 'square_height')
        local indicator = MakeAnimator(indicator_res)
		
		indicator:setColor(COLOR['light_green'])
        indicator.m_node:setScaleX(self.m_indicatorScale)

        root_node:addChild(indicator.m_node)
		table.insert(self.m_lIndicatorEffectList, indicator)
    end
end

-------------------------------------
-- function onChangeTargetCount
-------------------------------------
function SkillIndicator_AoESquare_Multi:onChangeTargetCount(old_target_count, cur_target_count)
	-- 활성화
	if (cur_target_count > 0) then
		-- 타겟수에 따른 보너스 등급 저장
		self.m_bonus = DragonSkillBonusHelper:getBonusLevel(self.m_hero, cur_target_count)

		if (self.m_preBonusLevel ~= self.m_bonus) then
			for _, indicator in pairs(self.m_lIndicatorEffectList) do
				self:onChangeIndicatorEffect(indicator, self.m_bonus, self.m_preBonusLevel)
			end
		end

	-- 비활성화
	elseif (old_target_count > 0) and (cur_target_count == 0) then
		self.m_bonus = -1
		for _, indicator in pairs(self.m_lIndicatorEffectList) do
			self:initIndicatorEffect(indicator)
		end
	end

	self.m_preBonusLevel = self.m_bonus
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillIndicator_AoESquare_Multi:findTarget(x, y)
    local l_target = self:getProperTargetList()
    
    local t_ret = {}
    local t_ret_bodys = {}
    local t_temp = {}
    local t_temp_bodys = {}

    local std_width = (self.m_skillWidth / 2)
	local std_height = (self.m_skillHeight / 2)

	-- 좌우로 나열하기 위해 x 좌표값 리스트를 계산한다.
	local l_pos_x = SkillHelper:calculatePositionX(self.m_lineCnt, self.m_space, x)

	-- x 좌표값 리스트를 따라 충돌체크를 하여 맵형태로 저장
    for i, v in ipairs(l_target) do
        local phys_idx = v['phys_idx']

		for i, pos_x in pairs(l_pos_x) do
            local b, bodys = isCollision_Rect(v, pos_x, y, std_width, std_height)
			if (b) then
                t_temp[phys_idx] = v

                if (not t_temp_bodys[phys_idx]) then
                    t_temp_bodys[phys_idx] = {}
                end

                for _, body_key in pairs(bodys) do
                    t_temp_bodys[phys_idx][body_key] = true
                end
			end
		end
    end

    -- 인덱스 테이블로 다시 담는다
	for _, object in pairs(t_temp) do
		table.insert(t_ret, object)

        local body_keys = {}
        for body_key, _ in pairs(t_temp_bodys[object['phys_idx']]) do
            table.insert(body_keys, body_key)
	    end

        table.insert(t_ret_bodys, body_keys)
	end

    return t_ret, t_ret_bodys
end
