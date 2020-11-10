-------------------------------------
-- class AnimatorPng
-------------------------------------
AnimatorPng = class(Animator, {
    })

-------------------------------------
-- function init
-------------------------------------
function AnimatorPng:init(file_name)
    self.m_node = cc.Sprite:create(file_name)
    
    if self.m_node then
        self.m_node:setAnchorPoint(0.5, 0.5)
    end

    self.m_type = ANIMATOR_TYPE_PNG
end

-------------------------------------
-- function setSkin
-------------------------------------
function AnimatorPng:setSkin(skin_name)
end

-------------------------------------
-- function changeAni
-------------------------------------
function AnimatorPng:changeAni(animation_name, loop, checking)
end

-------------------------------------
-- function addAniHandler
-------------------------------------
function AnimatorPng:addAniHandler(cb)
    -- TBD : cb을 즉시 실행? or Action으로 특정시간 후에 실행?
    cb()
end

-------------------------------------
-- function getVisualList
-------------------------------------
function AnimatorPng:getVisualList()
    return {}
end

-------------------------------------
-- function setMix
-------------------------------------
function AnimatorPng:setMix(from, to, mix_ratio)
end