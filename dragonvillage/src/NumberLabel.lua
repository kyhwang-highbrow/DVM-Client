-------------------------------------
-- class NumberLabel
-------------------------------------
NumberLabel = class({
        m_label = 'cc.Label',
        m_actionDuration = 'number',
        m_number = 'number',
        m_orgColor = 'c3b',
        m_orgScaleX = 'number',
        m_orgScaleY = 'number',

		m_isScaleAction = 'boolean',
		m_isTintAction = 'boolean',

        m_tweenCallback = 'function',

        m_tweenFinishCallback = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function NumberLabel:init(label, number, actionDuration)
    self.m_label = label
    self.m_number = (number or 0)
    self.m_actionDuration = (actionDuration or 1)
    self.m_orgColor = label:getColor()
    self.m_orgScaleX = label:getScaleX()
    self.m_orgScaleY = label:getScaleY()
	self.m_isScaleAction = false
	self.m_isTintAction = false

    label:setString(self.getNumberStr(self.m_number))

    -- UI가 enter로 진입되었을 때 update함수 호출
    label:registerScriptHandler(function(event)
        if (event == 'enter') then
            local number = self.m_number
            self.m_number = 0
            self:setNumber(number, true)
        end
    end)
end

-------------------------------------
-- function setNumber
-------------------------------------
function NumberLabel:setNumber(number, immediately, suffix_str)
    if (self.m_number == number) then
        local number_str = self.getNumberStr(self.m_number)
        local result_str = suffix_str and (number_str .. suffix_str) or number_str
        self.m_label:setString(result_str)
        return
    end
	-- setNumber 예외처리
	if (not number) then
		number = 0
		--cclog('NumberLabel:setNumber number가 nil로 들어왔습니다')
	end

    local prev_number = self.m_number
    local curr_number = number

    self.m_number = number
    self.m_label:stopAllActions()

    -- 숫자 변화
    if immediately then
        self:getTweenCallback()(curr_number, self.m_label)

        if (self.m_tweenFinishCallback) then
            self.m_tweenFinishCallback(curr_number, self.m_label)
        end 

        return
    elseif (self.m_actionDuration <= 0) then
        self:getTweenCallback()(curr_number, self.m_label)

        if (self.m_tweenFinishCallback) then
            self.m_tweenFinishCallback(curr_number, self.m_label)
        end 
    else
        local tween = cc.ActionTweenForLua:create(self.m_actionDuration, prev_number, curr_number, self:getTweenCallback())
        self.m_label:runAction(tween)
        
        -- tween연출 후 숫자가 정확히 지정되지 않는 경우가 있다. 0.03초 후 정확한 숫자를 설정하기 위해 추가한다.
        cca.reserveFunc(self.m_label, self.m_actionDuration + 0.03, function() self:getTweenCallback()(curr_number, self.m_label) end)

        if (self.m_tweenFinishCallback) then
            cca.reserveFunc(self.m_label, self.m_actionDuration + 0.03, function() self.m_tweenFinishCallback(curr_number, self.m_label) end)
        end 
    end

    -- 색상 변화
	if (self.m_isTintAction) then
		if (prev_number < curr_number) then
			self.m_label:setColor(cc.c3b(0, 255, 0))
		else
			self.m_label:setColor(cc.c3b(255, 0, 0))
		end
		local action = cc.TintTo:create(self.m_actionDuration, self.m_orgColor['r'], self.m_orgColor['g'], self.m_orgColor['b'])
		self.m_label:runAction(action)
	end

    -- 크기 변화
	if (self.m_isScaleAction) then
		local scale_action = cc.Sequence:create(cc.ScaleTo:create(0.1, self.m_orgScaleX * 1.2, self.m_orgScaleY * 1.2), cc.ScaleTo:create(0.1, self.m_orgScaleX * 1, self.m_orgScaleY * 1))
		self.m_label:runAction(scale_action)
	end
end

-------------------------------------
-- function tweenCallback
-------------------------------------
function NumberLabel.tweenCallback(number, label)
    label:setString(NumberLabel.getNumberStr(number))
end

-------------------------------------
-- function getNumberStr
-------------------------------------
function NumberLabel.getNumberStr(number)
    local number = math_floor(number)
    local number_str = comma_value(number)
    return number_str
end

-------------------------------------
-- function setScaleAction
-------------------------------------
function NumberLabel:setScaleAction(b)
	self.m_isScaleAction = b
end

-------------------------------------
-- function setTintAction
-------------------------------------
function NumberLabel:setTintAction(b)
	self.m_isTintAction = b
end

-------------------------------------
-- function setTweenCallback
-- @param function tween_cb(number, label)
-------------------------------------
function NumberLabel:setTweenCallback(tween_cb)
	self.m_tweenCallback = tween_cb

    if tween_cb then
        tween_cb(self.m_number, self.m_label)
    end
end

-------------------------------------
-- function setTweenFinishCallback
-- @param function tween_finish_cb(number, label)
-------------------------------------
function NumberLabel:setTweenFinishCallback(tween_finish_cb)
	self.m_tweenFinishCallback = tween_finish_cb

    if tween_finish_cb then
        tween_finish_cb(self.m_number, self.m_label)
    end
end

-------------------------------------
-- function getTweenCallback
-------------------------------------
function NumberLabel:getTweenCallback()
    if self.m_tweenCallback then
        return self.m_tweenCallback
    else
        return NumberLabel.tweenCallback
    end
end


-------------------------------------
-- class NumberLabel_Percent
-------------------------------------
NumberLabel_Percent = class(NumberLabel, {
    })


-------------------------------------
-- function init
-------------------------------------
function NumberLabel_Percent:init(label, number, actionDuration)
    self:setTweenCallback(NumberLabel_Percent.tweenCallback)
end

-------------------------------------
-- function tweenCallback
-------------------------------------
function NumberLabel_Percent.tweenCallback(number, label)
    local str = comma_value(string.format('%.1f', number)) .. '%'
    label:setString(str)
end
