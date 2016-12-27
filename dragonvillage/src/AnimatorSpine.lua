-------------------------------------
-- class AnimatorSpine
-------------------------------------
AnimatorSpine = class(Animator, {
    })

-------------------------------------
-- function init
-------------------------------------
function AnimatorSpine:init(file_name, is_json)
    local file_name_ = nil

    if is_json then
        file_name_ = string.gsub(file_name, '%.json', '')
    else
        file_name_ = string.gsub(file_name, '%.spine', '')
    end

    self.m_node = sp.SkeletonAnimation:create(file_name_ .. '.json', file_name_ ..  '.atlas', 1)
    self:changeAni('idle', true, true)

    self.m_type = ANIMATOR_TYPE_SPINE
end

-------------------------------------
-- function setSkin
-------------------------------------
function AnimatorSpine:setSkin(skin_name)
    if (not self.m_node) then
        return
    end

    local skin_name = tostring(skin_name) or '6'
    self.m_node:setSkin(skin_name)
end

-------------------------------------
-- function changeAni
-------------------------------------
function AnimatorSpine:changeAni(animation_name, loop, checking)
    if (not self.m_node) then
        return
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
        return
    end

    if cb then
        self.m_node:registerSpineEventHandler(cb, sp.EventType.ANIMATION_COMPLETE)
    else
        self.m_node:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
    end
end

-------------------------------------
-- function setEventHandler
-------------------------------------
function AnimatorSpine:setEventHandler(cb)
    if (not self.m_node) then
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
        return 0
    end

    return self.m_node:getDuration()
end

-------------------------------------
-- function setIgnoreLowEndMode
-------------------------------------
function AnimatorSpine:setIgnoreLowEndMode(ignore)
    if (not self.m_node) then
        return
    end

    self.m_node:setIgnoreLowEndMode(ignore)
end

-------------------------------------
-- function isIgnoreLowEndMode
-------------------------------------
function AnimatorSpine:isIgnoreLowEndMode(ignore)
    if (not self.m_node) then
        return false
    end

    return self.m_node:isIgnoreLowEndMode()
end

-------------------------------------
-- function setTimeScale
-------------------------------------
function AnimatorSpine:setTimeScale(time_scale)
    if (not self.m_node) then
        return false
    end

    return self.m_node:setTimeScale(time_scale)
end

-------------------------------------
-- function getTimeScale
-------------------------------------
function AnimatorSpine:getTimeScale()
    if (not self.m_node) then
        return 1
    end

    return self.m_node:getTimeScale()
end