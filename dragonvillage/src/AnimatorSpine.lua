-------------------------------------
-- class AnimatorSpine
-------------------------------------
AnimatorSpine = class(Animator, {
        m_cacheJsonName = 'string', -- Spine 리소스 캐시에 사용되는 key값
        m_cacheAtlasName = 'string', -- Spine 리소스 캐시에 사용되는 key값
    })

-------------------------------------
-- function init
-------------------------------------
function AnimatorSpine:init(file_name, is_json, atlas_file_name)
    local file_name_ = nil
    local atlas_file_name_ = nil

    if is_json then
        file_name_ = string.gsub(file_name, '%.json', '')

        if (atlas_file_name) then
            atlas_file_name_ = string.gsub(atlas_file_name, '%.json', '')
        end
    else
        file_name_ = string.gsub(file_name, '%.spine', '')

        if (atlas_file_name) then
            atlas_file_name_ = string.gsub(atlas_file_name, '%.spine', '')
        end
    end

    if (not atlas_file_name_) then
        atlas_file_name_ = file_name_
    end

    self.m_cacheJsonName = file_name_ .. '.json'
    self.m_cacheAtlasName = atlas_file_name_ .. '.atlas'
    self.m_node = sp.SkeletonAnimation:create(self.m_cacheJsonName, self.m_cacheAtlasName, 1)
    if (not self.m_node) then
        cclog('error file_name_ : ' .. file_name_)
        cclog('error atlas_file_name_ : ' .. atlas_file_name_)
    end
    self:changeAni('idle', true, true)

    self.m_type = ANIMATOR_TYPE_SPINE

    -- Spine 리소스 캐시 매니저에 등록
    SpineCacheManager:getInstance():registerSpineAnimator(self)
end

-------------------------------------
-- function setSkin
-------------------------------------
function AnimatorSpine:setSkin(skin_name)
    if (not self.m_node) then
		self:printAnimatorError()
        return
    end

    self.m_node:setSkin(skin_name)
end

-------------------------------------
-- function changeAni
-------------------------------------
function AnimatorSpine:changeAni(animation_name, loop, checking)
    if (not self.m_node) then
		self:printAnimatorError()
        return
    end

    if self.m_aniAttr then
        animation_name = self:getAniNameAttr(animation_name)
    end

    if self.m_aniAddName then
        animation_name = self:getAniAddName(animation_name)
    end

    if (not checking) then
        if animation_name then
            if (not self.m_node:setAnimation(0, animation_name, loop)) then
                self.m_node:setAnimation(0, self.m_defaultAniName, loop)
            end
            self.m_node:setToSetupPose()
            self.m_node:update(0)
        end
        self.m_currAnimation = animation_name
    else
        if animation_name and (self.m_currAnimation ~= animation_name) then
            if (not self.m_node:setAnimation(0, animation_name, loop)) then
                self.m_node:setAnimation(0, self.m_defaultAniName, loop)
            end
            self.m_node:setToSetupPose()
            self.m_node:update(0)
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
function AnimatorSpine:addAniHandler(cb)
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
            self.m_node:registerSpineEventHandler(cb, sp.EventType.ANIMATION_COMPLETE)
        end
    else
        self.m_node:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
    end
end

-------------------------------------
-- function setEventHandler
-------------------------------------
function AnimatorSpine:setEventHandler(cb)
    if (not self.m_node) then
		self:printAnimatorError()
        return
    end

    if cb then
        local ret = self.m_node:registerSpineEventHandler(cb, sp.EventType.ANIMATION_EVENT)
    else
        self.m_node:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
    end
end

-------------------------------------
-- function getVisualList
-------------------------------------
function AnimatorSpine:getVisualList()
    local node = self.m_node

    local content = node:getAnimationListLuaTable()
    local data = loadstring('return ' .. content)()

    local ret_data = {}
    for i,v in ipairs(data) do
        local name = v['name']
        table.insert(ret_data, name)
    end

    return ret_data
end

-------------------------------------
-- function getEventList
-- @brief 에니메이션에 포함된 이벤트 리스트 리턴 (Spine에서 활용)
-------------------------------------
function AnimatorSpine:getEventList(animation_name, event_name)
    local node = self.m_node

    local content = node:getEventListLuaTable(animation_name, event_name)
    content = string.gsub(content, '\n', '') -- stringValue에 '\n'이 포함되어 있는 경우가 있음
    local l_event_list = loadstring('return ' .. content)()

    -- l_event_list 예시
    --{
    --        {
    --                ['frames']=0.5666;
    --                ['floatValue']=0;
    --                ['intValue']=0;
    --                ['name']='attack';
    --                ['stringValue']='150,28';
    --        };
    --}

    return l_event_list
end

-------------------------------------
-- function getSlotList
-------------------------------------
function AnimatorSpine:getSlotList()
    local node = self.m_node

    local content = node:getSlotNameListLuaTable()
    local data = loadstring('return ' .. content)()

    local ret_data = {}
    for i,v in ipairs(data) do
        local name = v['name']
        table.insert(ret_data, name)
    end

    return ret_data
end

-------------------------------------
-- function getDuration
-------------------------------------
function AnimatorSpine:getDuration()
    if (not self.m_node) then
		self:printAnimatorError()
        return 0
    end

    return self.m_node:getDuration()
end

-------------------------------------
-- function setIgnoreLowEndMode
-------------------------------------
function AnimatorSpine:setIgnoreLowEndMode(ignore)
    if (not self.m_node) then
		self:printAnimatorError()
        return
    end

    self.m_node:setIgnoreLowEndMode(ignore)
end

-------------------------------------
-- function isIgnoreLowEndMode
-------------------------------------
function AnimatorSpine:isIgnoreLowEndMode(ignore)
    if (not self.m_node) then
		self:printAnimatorError()
        return false
    end

    return self.m_node:isIgnoreLowEndMode()
end

-------------------------------------
-- function setTimeScale
-------------------------------------
function AnimatorSpine:setTimeScale(time_scale)
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
function AnimatorSpine:setAnimationPause(pause)
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
-- function setMix
-------------------------------------
function AnimatorSpine:setMix(from, to, mix_ratio)
	self.m_node:setMix(from, to, mix_ratio)
end