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

        m_defaultAniName = 'string',
        m_aniName = 'string',
        m_posX = 'number',
        m_posY = 'number',

		m_aniRepeatIdx = 'number',
        m_timeScale = 'number', -- 0.0 ~ 1.0
        m_bAnimationPause = 'boolean',

        m_aniMap = 'map',
        m_aniAttr = 'string',
        m_aniAddName = 'string',

        m_bUseSchedule = 'boolean',

        m_baseShaderKey = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function Animator:init(file_name)
    self.m_defaultAniName = 'idle'
    self.m_resName = file_name
    self.m_bFlip = false
	self.m_aniRepeatIdx = 1
    self.m_timeScale = 1
    self.m_bAnimationPause = false
    self.m_bUseSchedule = false

    self.m_baseShaderKey = cc.SHADER_POSITION_TEXTURE_COLOR
end

-------------------------------------
-- function setBaseShader
-------------------------------------
function Animator:setBaseShader(shader_key)
    if (shader_key) then
        self.m_baseShaderKey = shader_key
    end

    local shader = ShaderCache:getShader(self.m_baseShaderKey)
    self.m_node:setGLProgram(shader)
end

-------------------------------------
-- function setSkin
-------------------------------------
function Animator:setSkin(skin_name)
end

-------------------------------------
-- function setDefaultAniName
-------------------------------------
function Animator:setDefaultAniName(ani_name)
    self.m_defaultAniName = ani_name
end

-------------------------------------
-- function changeAni
-------------------------------------
function Animator:changeAni(animation_name, loop, checking)
end

-------------------------------------
-- function changeAni2
-- @brief animation_name1에니 1번 재생 후 animation_name2를 재생하는 함수
-------------------------------------
function Animator:changeAni2(animation_name1, animation_name2, loop)
    self:changeAni(animation_name1, false)

    local function ani_handler()
        self:changeAni(animation_name2, loop)
    end

    self:addAniHandler(ani_handler)
end

-------------------------------------
-- function changeAni_Repeat
-- @param1 l_ani_name_list : 변경할 애니메이션 명을 담은 리스트
-- @param2 loop : 애니메이션 리스트를 전부 돈 후에 반복할지 여부
-------------------------------------
function Animator:changeAni_Repeat(l_ani_name_list, loop, final_cb_func)
	local max_idx = #l_ani_name_list

	-- 해당 인덱스의 애니메이션으로 변경
	if (l_ani_name_list[self.m_aniRepeatIdx]) then
		self:changeAni(l_ani_name_list[self.m_aniRepeatIdx], false)
	end
        
	-- 인덱스 증가 및 반복 여부 체크해서 최대치라면 처음으로 되돌림
	self.m_aniRepeatIdx = self.m_aniRepeatIdx + 1
	if (self.m_aniRepeatIdx > max_idx) then
		if (loop) then
			self.m_aniRepeatIdx = 1
		else
			if (final_cb_func) then
				self:addAniHandler(final_cb_func)
			end
		end
	end

	-- 다음 인덱스 애니메이션 재생 할 재귀함수 콜백 등록
	if (l_ani_name_list[self.m_aniRepeatIdx]) then
		local function cb_func()
			self:changeAni_Repeat(l_ani_name_list, loop, final_cb_func)
		end
        self:addAniHandler(cb_func)
	else
		self.m_aniRepeatIdx = 1
    end
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
    self.m_timeScale = time_scale
end

-------------------------------------
-- function getTimeScale
-------------------------------------
function Animator:getTimeScale()
    return self.m_timeScale
end

-------------------------------------
-- function setAnimationPause
-------------------------------------
function Animator:setAnimationPause(pause)
    self.m_bAnimationPause = pause
end

-------------------------------------
-- function setAniAttr
-------------------------------------
function Animator:setAniAttr(attr)
    self.m_aniAttr = attr
end

-------------------------------------
-- function getAniNameAttr
-------------------------------------
function Animator:getAniNameAttr(ani, attr)
	if (not ani) then 
		return 
	end

	if (not self.m_aniMap) then
		local l_ani = self:getVisualList()
		self.m_aniMap = {}
		for i,v in pairs(l_ani) do
			self.m_aniMap[v] = true
		end
	end

	local attr = attr or self.m_aniAttr

	if (not attr) then
		return ani
	end

	local key = attr .. '_' .. ani
	if self.m_aniMap[key] then
		return key
	else
		return ani
	end
end

-------------------------------------
-- function setAniAddName
-------------------------------------
function Animator:setAniAddName(add_name)
    self.m_aniAddName = add_name
end

-------------------------------------
-- function getAniAddName
-------------------------------------
function Animator:getAniAddName(ani)
    if (not ani) then 
		return 
	end
    if (not self.m_aniMap) then
		local l_ani = self:getVisualList()
		self.m_aniMap = {}
		for i,v in pairs(l_ani) do
			self.m_aniMap[v] = true
		end
	end

    if (not self.m_aniAddName) then
		return ani
	end

    local key = ani .. self.m_aniAddName
	if self.m_aniMap[key] then
		return key
	else
		return ani
	end
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

    self.m_node:setPosition(cc.p(x, y))

    self.m_posX = x
    self.m_posY = y
end

-------------------------------------
-- function getPosition
-------------------------------------
function Animator:getPosition()
    if (not self.m_node) then
        return
    end

    return self.m_node:getPosition()
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
-- function getPositionX
-------------------------------------
function Animator:getPositionX()
    if (not self.m_node) then
        return
    end

    return self.m_node:getPositionX()
end

-------------------------------------
-- function getPositionY
-------------------------------------
function Animator:getPositionY()
    if (not self.m_node) then
        return
    end

    return self.m_node:getPositionY()
end

-------------------------------------
-- function setDockPoint
-------------------------------------
function Animator:setDockPoint(x, y)
    if (not self.m_node) then
        return
    end
    self.m_node:setDockPoint(cc.p(x, y))
end

-------------------------------------
-- function setAnchorPoint
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
        self.m_node:setScaleY(scale)
    else
        self.m_node:setScale(scale)
    end
end

-------------------------------------
-- function setScaleX
-------------------------------------
function Animator:setScaleX(scale)
    if (not self.m_node) then
        return
    end
	if self.m_bFlip then
		scale = -scale
	end
    self.m_node:setScaleX(scale)
end

-------------------------------------
-- function setScaleY
-------------------------------------
function Animator:setScaleY(scale)
    if (not self.m_node) then
        return
    end

    self.m_node:setScaleY(scale)
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
-- function getScaleX
-------------------------------------
function Animator:getScaleX()
    if (not self.m_node) then
        return
    end

    return self.m_node:getScaleX()
end

-------------------------------------
-- function getScaleY
-------------------------------------
function Animator:getScaleY()
    if (not self.m_node) then
        return
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
-- function stopAllActions
-------------------------------------
function Animator:stopAllActions()
    if (not self.m_node) then
        return
    end

    self.m_node:stopAllActions()
end

-------------------------------------
-- function setFlip
-------------------------------------
function Animator:setFlip(flip)
    if (not self.m_node) then
        return
    end

    self.m_bFlip = flip
    local scale_x = math_abs(self.m_node:getScaleX())

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
-- function isVisible
-------------------------------------
function Animator:isVisible()
    if self.m_node then
        return self.m_node:isVisible()
	else
		return false
    end
end

-------------------------------------
-- function scheduleUpdate
-------------------------------------
function Animator:scheduleUpdate(func)
    if self.m_node then
        self.m_node:scheduleUpdateWithPriorityLua(func, 0)

        self.m_bUseSchedule = true
    end
end


-------------------------------------
-- function release
-------------------------------------
function Animator:release()
    if self.m_node then
        if (self.m_bUseSchedule) then
            self.m_node:unscheduleUpdate()
        end

        self.m_node:removeFromParent(true)
        self.m_node = nil
    end
end

-------------------------------------
-- function setColor
-------------------------------------
function Animator:setColor(color)
    if self.m_node then
        self.m_node:setColor(color)
    end
end

-------------------------------------
-- function addChild
-------------------------------------
function Animator:addChild(node)
    if self.m_node then
        self.m_node:addChild(node)
    end
end

-------------------------------------
-- function setLocalZOrder
-------------------------------------
function Animator:setLocalZOrder(z_order)
    if self.m_node then
        return self.m_node:setLocalZOrder(z_order)
    end
end

-------------------------------------
-- function getContentSize
-------------------------------------
function Animator:getContentSize()
    if self.m_node then
        return self.m_node:getContentSize()
    end
end

-------------------------------------
-- function setContentSize
-------------------------------------
function Animator:setContentSize(width, height)
    if self.m_node then
        return self.m_node:setContentSize(width, height)
    end
end

-------------------------------------
-- function setOpacity
-------------------------------------
function Animator:setOpacity(opacity)
    if self.m_node then
        return self.m_node:setOpacity(opacity)
    end
end

-------------------------------------
-- function printAnimatorError
-------------------------------------
function Animator:printAnimatorError()
	cclog('#####################################')
	cclog('해당 파일이 없거나 비정상입니다.')
	cclog(self.m_resName)
	cclog('#####################################')
end
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

-------------------------------------
-- function MakeAnimator
-- @breif 파일 확장자에 따라 타입별 Animator 생성
-------------------------------------
function MakeAnimator(file_name, skip_error_msg)
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

    -- a2d .. 는 개발 중 테스트용
    elseif string.match(file_name, '%.a2d') then
        animator = AnimatorVrp()
        animator.m_node = cc.AzVisual:create(file_name)
        animator.m_node:loadPlistFiles('')
        animator.m_node:buildSprite('')
        animator:changeAni('idle', true, true)

    -- PNG
    elseif string.match(file_name, '%.png') then
        animator = AnimatorPng(file_name)
    
    -- Spine
    elseif string.match(file_name, '%.json') then
        animator = AnimatorSpine(file_name, true)
    end

    -- 파일 로드 실패 시 로그 출력
    if file_name and (file_name ~= '') and (not skip_error_msg) then
        if (not animator) or (not animator.m_node) then
            cclog('##############################################################')
            cclog('##############################################################')
            cclog('## ERROR!!!!!!! MakeAnimator(file_name)')
            cclog('## ' .. file_name)
            cclog('##############################################################')
            cclog('##############################################################')

			-- @E.T.
			g_errorTracker:appendFailedRes(file_name)
        end
    end

    if animator.m_node then
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
    end

    return animator
end


-------------------------------------
-- function MakeAnimatorSpineToIntegrated
-- @breif 하나의 json으로 모든 속성을 공유하는 spine animator를 생성
-------------------------------------
function MakeAnimatorSpineToIntegrated(org_file_name)
    -- org_file_name 예시 : res/character/dragon/abyssedge_all_03/abyssedge_water_03.spine
    local spine_file_name
    local atlas_file_name
    local animator = nil

    -- spine 파일과 atlas 파일의 이름을 얻는다
    do
        local path, file_name, extension = string.match(org_file_name, "(.-)([^//]-)(%.[^%.]+)$")
        local add_path = file_name
                
        -- 파일 이름은 속성 문자를 all로 대체시킴
        for _, attr in pairs(T_ATTR_LIST) do
            file_name = string.gsub(file_name, '_' .. attr, '_all')
        end
        --file_name = string.match(path, "[^//]-([%a_]+)/$")

        spine_file_name = path .. file_name .. extension
        atlas_file_name = path .. add_path .. '/' .. file_name
    end

    -- Spine
    if (string.match(spine_file_name, '%.spine')) then
        animator = AnimatorSpine(spine_file_name, nil, atlas_file_name)
    -- Spine
    elseif (string.match(spine_file_name, '%.json')) then
        animator = AnimatorSpine(spine_file_name, true, atlas_file_name)
    end

    animator.m_resName = org_file_name
    
    if (animator.m_node) then
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
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