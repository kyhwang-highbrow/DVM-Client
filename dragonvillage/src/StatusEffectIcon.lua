-------------------------------------
-- class StatusEffectIcon
-------------------------------------
StatusEffectIcon = class({
		m_statusEffect = 'status effect',
		m_char = 'Character',
		m_icon = 'icon',

		m_label = 'cc.Label',
		m_statusEffectName = 'str',

		m_bDelete = 'bool',
		m_bBlink = 'bool',
     })

-------------------------------------
-- function init
-------------------------------------
function StatusEffectIcon:init(char, status_effect)
	self.m_statusEffect = status_effect
	self.m_char = char
	self.m_bDelete = false
	self.m_bBlink = false

	local status_effect_type = status_effect:getTypeName()
	self.m_statusEffectName = status_effect_type

	if (char.m_statusNode) then
		local icon = IconHelper:getStatusEffectIcon(status_effect_type)
		icon:setScale(0.375)
        char.m_statusNode:addChild(icon, 0)
		self.m_icon = icon
	end

	char.m_lStatusIcon[status_effect_type] = self
	
	do
		local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 40, 0)
		label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		label:setAnchorPoint(cc.p(0.5, 0.5))
		label:setDockPoint(cc.p(0.5, 0.5))
		label:setPosition(0, 0)
		label:enableOutline(cc.c4b(0, 0, 0, 255), 3)
		self.m_icon:addChild(label)
		self.m_label = label
	end
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffectIcon:update(dt)
	self:setOverlabText()
	self:checkDuration()
end

-------------------------------------
-- function setOverlabText
-------------------------------------
function StatusEffectIcon:setOverlabText()
	local overlab_cnt = self.m_statusEffect.m_overlabCnt

	if (overlab_cnt > 1) then
		self.m_label:setString(overlab_cnt)
	end
end

-------------------------------------
-- function checkDuration
-------------------------------------
function StatusEffectIcon:checkDuration()
	-- 1. 제한 시간이 있는 상태 효과 
	if (self.m_statusEffect.m_duration ~= -1) then 
		-- 2. 남은 시간이 3초 이상인데 점멸 상태인 경우 -> 점멸 해제
		if (self.m_statusEffect.m_durationTimer > 3) and (self.m_bBlink) then
			self.m_icon:setOpacity(255)
			self.m_icon:stopAllActions()
			self.m_bBlink = false
		-- 3. 남은 시간이 3초 이하인데 점멸 상태가 아닌 경우 -> 점멸 시킴
		elseif (self.m_statusEffect.m_durationTimer < 3) and (not self.m_bBlink) then 
			local sequence = cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5))
			self.m_icon:runAction(cc.RepeatForever:create(sequence))
			self.m_bBlink = true 
		end
	end

	if (self.m_statusEffect.m_state == 'end') and (not self.m_bDelete) then
		self:release()
		self.m_char:removeStatusIcon(self.m_statusEffect)
		self.m_bDelete = true 
	end
end

-------------------------------------
-- function release
-------------------------------------
function StatusEffectIcon:release()
	self.m_label:removeFromParent(true)
	self.m_label = nil
	
	self.m_icon:removeFromParent(true)
	self.m_icon = nil
end