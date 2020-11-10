-------------------------------------
-- class AnimatorVrp
-------------------------------------
AnimatorVrp = class(Animator, {
    })

-------------------------------------
-- function init
-------------------------------------
function AnimatorVrp:init(file_name)
    if (file_name) then
        local file_name = string.gsub(file_name, '%.vrp', '')

		-- plist 등록 (loadPlistFiles에서 알아서 호출함 2017-07-04 sgkim)
        --cc.SpriteFrameCache:getInstance():addSpriteFrames(file_name .. '.plist')

        -- vrp 생성
        self.m_node = cc.AzVRP:create(file_name .. '.vrp')
        if self.m_node then
            self.m_node:loadPlistFiles('')
            self.m_node:buildSprite('')
        end
        self:changeAni('idle', true, true)
    end

    self.m_type = ANIMATOR_TYPE_VRP
end

-------------------------------------
-- function setSkin
-------------------------------------
function AnimatorVrp:setSkin(skin_name)
end

-------------------------------------
-- function changeAni
-------------------------------------
function AnimatorVrp:changeAni(animation_name, loop, checking)
    if (not self.m_node) then
		self:printAnimatorError()
        return
    end

    if (self.m_aniAttr) then
        if animation_name then
            animation_name = self:getAniNameAttr(animation_name)
        end
    end

    if (self.m_aniAddName) then
        if animation_name then
            animation_name = self:getAniAddName(animation_name)
        end
    end

    if (not checking) then
        if animation_name then
            if (not self.m_node:setVisual('group', animation_name)) then
                self.m_node:setVisual('group', self.m_defaultAniName)
            end
            self.m_node:setRepeat(loop)
        end
        self.m_currAnimation = animation_name
    else
        if animation_name and (self.m_currAnimation ~= animation_name) then
            if (not self.m_node:setVisual('group', animation_name)) then
                self.m_node:setVisual('group', self.m_defaultAniName)
            end
            self.m_node:setRepeat(loop)
        end
        self.m_currAnimation = animation_name
    end

    self:addAniHandler(nil)
    self:setEventHandler(nil)

	self.m_aniName = animation_name
end

-------------------------------------
-- function addAniHandler
-------------------------------------
function AnimatorVrp:addAniHandler(cb)
    if (not self.m_node) then
		self:printAnimatorError()
        return
    end

    --cca.stopAction(self.m_node, ANIMATOR_ACTION_TAG__END)

    if (cb) then
        -- 애니메이션 시간이 0일 경우 즉시 콜백함수 호출
        local duration = self.m_node:getDuration()
        if (duration == 0) then
            --local action = cc.CallFunc:create(function(node) cb() end)
            --cca.runAction(self.m_node, action, ANIMATOR_ACTION_TAG__END)
            cb()
        else
            self.m_node:registerScriptLoopHandler(cb)
        end
	else
		self.m_node:unregisterScriptLoopHandler()
	end
end

-------------------------------------
-- function getVisualList
-------------------------------------
function AnimatorVrp:getVisualList()
    if (not self.m_node) then
		self:printAnimatorError()
        return
    end

    local visual = self.m_node

    local content = visual:getVisualListLuaTable()
    local data = loadstring('return ' .. content)()

    local ret_data = {}
    for i,v in ipairs(data) do
        --[[
        -- 그룹명까지 저장할 경우
        local group = v['group']
        local name = v['name']
        if ret_data[group] == nil then
            ret_data[group] = {}
        end
        ret_data[group][name] = true
        --]]
        local name = v['name']
        table.insert(ret_data, name)
    end

    return ret_data
end

-------------------------------------
-- function setMix
-------------------------------------
function AnimatorVrp:setMix(from, to, mix_ratio)
end

-------------------------------------
-- function getDuration
-------------------------------------
function AnimatorVrp:getDuration()
    if (not self.m_node) then
		self:printAnimatorError()
        return 0
    end

    return self.m_node:getDuration()
end

-------------------------------------
-- function setIgnoreLowEndMode
-------------------------------------
function AnimatorVrp:setIgnoreLowEndMode(ignore)
    if (not self.m_node) then
		self:printAnimatorError()
        return
    end

    self.m_node:setIgnoreLowEndMode(ignore)
end

-------------------------------------
-- function isIgnoreLowEndMode
-------------------------------------
function AnimatorVrp:isIgnoreLowEndMode(ignore)
    if (not self.m_node) then
		self:printAnimatorError()
        return false
    end

    return self.m_node:isIgnoreLowEndMode()
end

-------------------------------------
-- function setTimeScale
-------------------------------------
function AnimatorVrp:setTimeScale(time_scale)
    self.m_timeScale = time_scale

    if (not self.m_node) then
		self:printAnimatorError()
        return false
    end

    local ret
    if pause then
        ret = self.m_node:setTimeScale(0)
    else
        ret = self.m_node:setTimeScale(self.m_timeScale)
    end

    return ret
end

-------------------------------------
-- function setAnimationPause
-------------------------------------
function AnimatorVrp:setAnimationPause(pause)
    if (self.m_bAnimationPause == pause) then
        return
    end

    self.m_bAnimationPause = pause

    if (not self.m_node) then
		self:printAnimatorError()
        return
    end

    if pause then
        self.m_node:setTimeScale(0)
    else
        self.m_node:setTimeScale(self.m_timeScale)
    end
end






-------------------------------------
-------------------------------------
-- UI에서 사용될 경우를 위해 함수 추가
-------------------------------------
function AnimatorVrp:setVisual(group, visual)
    return self.m_node:setVisual(group, visual)
end
function AnimatorVrp:registerScriptLoopHandler(func)
    return self.m_node:registerScriptLoopHandler(func)
end
function AnimatorVrp:unregisterScriptLoopHandler()
    return self.m_node:unregisterScriptLoopHandler()
end
function AnimatorVrp:setRepeat(loop)
    return self.m_node:setRepeat(loop)
end
function AnimatorVrp:setFrame(frame)
    return self.m_node:setFrame(frame)
end
function AnimatorVrp:getContentSize()
    return {width = 0, height = 0}
end
function AnimatorVrp:setContentSize()
    -- nothing to do
end
-------------------------------------
-------------------------------------