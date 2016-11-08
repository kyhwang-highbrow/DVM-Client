ANIMATOR_TYPE_PNG = 0
ANIMATOR_TYPE_VRP = 1 
ANIMATOR_TYPE_SPINE = 2

-------------------------------------
-- class Animator
-------------------------------------
Animator = class({
        m_node = 'cc.Node', -- Sprite, Vrp, Spine
        m_type = 'ANIMATOR_TYPE',
        m_resName = 'string',
        m_currAnimation = 'string',
        m_bFlip = 'boolean',

        m_aniName = '',
        m_posX = 'number',
        m_posY = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function Animator:init(file_name)
    self.m_resName = file_name
    self.m_bFlip = false
end

-------------------------------------
-- function setSkin
-------------------------------------
function Animator:setSkin(skin_name)
end

-------------------------------------
-- function changeAni
-------------------------------------
function Animator:changeAni(animation_name, loop, checking)
end

-------------------------------------
-- function aniHandlerChain
-------------------------------------
function Animator:aniHandlerChain(...)

    -- 함수 리스트를 args에 담는다
    local args = {...}
    local idx = 1

    -- 재귀적으로 사용하기 위해 임시 변수 추가
    local func = nil

    -- 재귀함수 구현
    local func_ = function()
        -- 이전 idx의 함수가 있을 경우 호출
        if args[idx-1] then
            args[idx-1]()
        end

        -- 지금 idx의 함수가 있을 경우 aniHandler에 추가
        if args[idx] then
            self:addAniHandler(func)
        end
        idx = idx + 1
    end

    func = func_

    -- 최초 실행
    func()
end

-------------------------------------
-- function addAniHandler
-------------------------------------
function Animator:addAniHandler(cb)
    -- TBD : cb을 즉시 실행? or Action으로 특정시간 후에 실행?
    cb()
end

-------------------------------------
-- function setEventHandler
-------------------------------------
function Animator:setEventHandler(cb)
    if (not self.m_node) then
        return
    end

    if cb then
        cb()
    end
end

-------------------------------------
-- function getVisualList
-------------------------------------
function Animator:getVisualList()
    return {}
end

-------------------------------------
-- function getEventList
-- @brief 에니메이션에 포함된 이벤트 리스트 리턴 (Spine에서 활용)
-------------------------------------
function Animator:getEventList(animation_name, event_name)
    return {}
end

-------------------------------------
-- function getDuration
-------------------------------------
function Animator:getDuration()
    return 0
end

-------------------------------------
-- function setIgnoreLowEndMode
-------------------------------------
function Animator:setIgnoreLowEndMode(ignore)
end

-------------------------------------
-- function isIgnoreLowEndMode
-------------------------------------
function Animator:isIgnoreLowEndMode(ignore)
    return false
end

-------------------------------------
-- function setTimeScale
-------------------------------------
function Animator:setTimeScale(time_scale)
end

-------------------------------------
-- function getTimeScale
-------------------------------------
function Animator:getTimeScale()
    return 1
end



-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-------------------------------------
-- function setPosition
-------------------------------------
function Animator:setPosition(x, y)
    if (not self.m_node) then
        return
    end

    self.m_node:setPosition(x, y)

    self.m_posX = x
    self.m_posY = y
end

-------------------------------------
-- function setPositionX
-------------------------------------
function Animator:setPositionX(x)
    if (not self.m_node) then
        return
    end

    self.m_node:setPositionX(x)

    self.m_posX = x
end

-------------------------------------
-- function setPositionY
-------------------------------------
function Animator:setPositionY(y)
    if (not self.m_node) then
        return
    end

    self.m_node:setPositionY(y)

    self.m_posY = y
end

-------------------------------------
-- function setPosition
-------------------------------------
function Animator:setDockPoint(x, y)
    if (not self.m_node) then
        return
    end
    self.m_node:setDockPoint(cc.p(x, y))
end

-------------------------------------
-- function setPosition
-------------------------------------
function Animator:setAnchorPoint(x, y)
    if (not self.m_node) then
        return
    end
    self.m_node:setAnchorPoint(cc.p(x, y))
end

-------------------------------------
-- function setRotation
-- @brief 
-- @param degree
-------------------------------------
function Animator:setRotation(degree)
    if (not self.m_node) then
        return
    end

    local rotation = (-(degree - 90))
    self.m_node:setRotation(rotation)
end

-------------------------------------
-- function getRotation
-- @param degree
-------------------------------------
function Animator:getRotation()
    if (not self.m_node) then
        return 0
    end

    return self.m_node:getRotation()
end

-------------------------------------
-- function getAlpha
-------------------------------------
function Animator:getAlpha()
    if (not self.m_node) then
        return 1
    end

    local opacity = self.m_node:getOpacity()
    local alpha = opacity / 255
    return alpha
end

-------------------------------------
-- function setAlpha
-- @param alpha 0~1
-------------------------------------
function Animator:setAlpha(alpha)
    if (not self.m_node) then
        return
    end

    local opacity = 255 * alpha
    opacity = math_floor(opacity)
    self.m_node:setOpacity(opacity)
end

-------------------------------------
-- function setScale
-------------------------------------
function Animator:setScale(scale)
    if (not self.m_node) then
        return
    end

    if self.m_bFlip then 
        self.m_node:setScaleX(-scale)
        self.m_node:setScaleY(-scale)
    else
        self.m_node:setScale(scale)
    end
end

-------------------------------------
-- function getScale
-------------------------------------
function Animator:getScale()
    if (not self.m_node) then
        return 1
    end

    return self.m_node:getScaleY()
end

-------------------------------------
-- function runAction
-------------------------------------
function Animator:runAction(action)
    if (not self.m_node) then
        return
    end

    return self.m_node:runAction(action)
end

-------------------------------------
-- function setFlip
-------------------------------------
function Animator:setFlip(flip)
    if (not self.m_node) then
        return
    end

    self.m_bFlip = flip
    local scale_x = self.m_node:getScaleX()

    if self.m_bFlip then 
        self.m_node:setScaleX(-scale_x)
    else
        self.m_node:setScaleX(scale_x)
    end
end

-------------------------------------
-- function setVisible
-------------------------------------
function Animator:setVisible(visible)
    if self.m_node then
        self.m_node:setVisible(visible)
    end
end

-------------------------------------
-- function scheduleUpdate
-------------------------------------
function Animator:scheduleUpdate(func)
    if self.m_node then
        self.m_node:scheduleUpdateWithPriorityLua(func, 0)
    end
end


-------------------------------------
-- function release
-------------------------------------
function Animator:release()
    if self.m_node then
        self.m_node:removeFromParent(true)
        self.m_node = nil
    end
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-------------------------------------
-- function MakeAnimator
-- @breif 파일 확장자에 따라 타입별 Animator 생성
-------------------------------------
function MakeAnimator(file_name)
    local animator = nil

    if (not file_name) or (file_name == '') then
        animator = Animator()
        animator.m_node = cc.Node:create()

    -- Spine
    elseif string.match(file_name, '%.spine') then
        animator = AnimatorSpine(file_name)

    -- VRP
    elseif string.match(file_name, '%.vrp') then
        animator = AnimatorVrp(file_name)

    -- PNG
    elseif string.match(file_name, '%.png') then
        animator = AnimatorPng(file_name)
    
    -- Spine
    elseif string.match(file_name, '%.json') then
        animator = AnimatorSpine(file_name, true)
    end

    -- 파일 로드 실패 시 로그 출력
    if file_name and (file_name ~= '') then
        if (not animator) or (not animator.m_node) then
            cclog('##############################################################')
            cclog('##############################################################')
            cclog('## ERROR!!!!!!! MakeAnimator(file_name)')
            cclog('## ' .. file_name)
            cclog('##############################################################')
            cclog('##############################################################')
        end
    end

    return animator
end

-------------------------------------
-- function setLowEndMode
-- @breif 저사양 모드 설정
-------------------------------------
function setLowEndMode(low_end_mode)
    sp.SkeletonAnimation:setLowEndMode(low_end_mode)
    cc.AzVRP:setLowEndMode(low_end_mode)
end

-------------------------------------
-- function isLowEndMode
-- @breif 저사양 모드 확인
-------------------------------------
function isLowEndMode()
    return (sp.SkeletonAnimation:isLowEndMode() and cc.AzVRP:isLowEndMode())
end