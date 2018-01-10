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
		local icon, is_exist = IconHelper:getStatusEffectIcon(status_effect_type)
        if (not is_exist) then return nil end
		icon:setScale(0.375)
        char.m_statusNode:addChild(icon, 0)
		self.m_icon = icon
	
	    if (self.m_icon) then
		    local label = cc.Label:createWithTTF('', Translate:getFontPath(), 40, 0)
		    label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		    label:setAnchorPoint(cc.p(0.5, 0.5))
		    label:setDockPoint(cc.p(0.5, 0.5))
		    label:setPosition(0, 0)
		    label:enableOutline(cc.c4b(0, 0, 0, 255), 3)
		    self.m_icon:addChild(label)
		    self.m_label = label
        else
            error('StatusEffectIcon:init status_effect_type : ' .. status_effect_type)
	    end
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

    if (self.m_label) then
	    if (overlab_cnt > 1) then
		    self.m_label:setString(overlab_cnt)
        else
            self.m_label:setString('')
	    end
    end
end

-------------------------------------
-- function checkDuration
-------------------------------------
function StatusEffectIcon:checkDuration()
    -- 주체 대상이 해당 statusEffect를 가지고 있지 않은 상태라면 삭제 시킴
    if (self.m_char.m_mStatusEffect[self.m_statusEffectName] == nil) then
        self:release()
		self.m_char:removeStatusIcon(self.m_statusEffect)
		self.m_bDelete = true 
        return
    end

    -- 점멸 설정 함수
    local function setBlink(b)
        if (not self.m_icon) then return end
        if (b == self.m_bBlink) then return end

        if (b) then
            local sequence = cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5))
			self.m_icon:runAction(cc.RepeatForever:create(sequence))
        else
            self.m_icon:setOpacity(255)
		    self.m_icon:stopAllActions()
        end

        self.m_bBlink = b
    end
    
	-- 1. 제한 시간이 있는 상태 효과 
	if (self.m_statusEffect:isInfinity()) then 
        setBlink(false)
    else
		-- 2. 남은 시간이 3초 이상인데 점멸 상태인 경우 -> 점멸 해제
		if (self.m_statusEffect:getLatestTimer() > 3) then
			setBlink(false)
		-- 3. 남은 시간이 3초 이하인데 점멸 상태가 아닌 경우 -> 점멸 시킴
		elseif (self.m_statusEffect:getLatestTimer() < 3) then 
			setBlink(true)
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
    if (self.m_label) then
	    self.m_label:removeFromParent(true)
	    self.m_label = nil
    end
	if (self.m_icon) then
	    self.m_icon:removeFromParent(true)
	    self.m_icon = nil
    end
end