-------------------------------------
-- class UI_WaveMaker
-------------------------------------
UI_WaveMaker = class(UI, {
	m_bgName = '',
	m_scene = '',      
	m_animator = '',  
	m_visualNameList = '',
	m_currVisualIdx = '',
	m_visualName = '',
	m_touchNode = '', 
})

---------------------------------------
-- cpp로 전달하기 위한 전역 변수
---------------------------------------
g_selectedCell = ''
g_stage_name = ''
g_script = nil

-------------------------------------
-- local function makeSprite
-------------------------------------
local function makeSprite(path)
	local sprite = cc.Sprite:create(path)
	if sprite then
		sprite:setAnchorPoint(cc.p(0.5, 0.5))
		sprite:setDockPoint(cc.p(0.5, 0.5))
		sprite:setPosition(cc.p(0, 0))
	end
	return sprite
end

-------------------------------------
-- function init
-------------------------------------
function UI_WaveMaker:init(game_scene)
	self:load('empty.ui')
	UIManager:open(self, UIManager.NORMAL)

	self.m_bgName = 'res/bg/forest/bg_forest_1_a.png'

    self.m_touchNode = cc.Node:create()
    self.m_touchNode:setPosition(0, 0)
    self.m_touchNode:setDockPoint(cc.p(0.5, 0.5))
    self.root:addChild(self.m_touchNode, 10)

	self:makeUI()
	self:makeTouchLayer(self.m_touchNode)

	--self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 1)
end

-------------------------------------
-- function makeUI
-------------------------------------
function UI_WaveMaker:makeUI()
	-- 배경
	self.vars['bg'] = makeSprite(self.m_bgName)
	self.vars['bg']:setScale(0.9); 
	self.vars['bg']:setScaleY(0.4); 
	self.root:addChild(self.vars['bg'], -1)

	--hero
	local ENTRY_FILE = 'res/character/dragon/godaeshinryong_01/godaeshinryong_01.json'
	self:makeHeroVisual(ENTRY_FILE);

end

-------------------------------------
-- function makeHeroVisual
-------------------------------------
function UI_WaveMaker:makeHeroVisual(vrp_res_name)

    if self.m_animator then
        self.m_animator:release()
        self.m_animator = nil
    end

    -- 초기화
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	cc.AzVisual:removeCacheAll()
	cc.AzVRP:removeCacheAll()
    sp.SkeletonAnimation:removeCacheAll()

    self.m_animator = self:MakeAnimator(self:getResName(vrp_res_name))
    self.m_animator:setPosition(0, 0)
    self.m_animator.m_node:setDockPoint(cc.p(0.5, 0.5))
    self.m_touchNode:addChild(self.m_animator.m_node)

    self.m_visualNameList = self.m_animator:getVisualList()
	
    self.m_currVisualIdx = 3
    self:changeVisual(false)
end

-------------------------------------
-- function getResName
-------------------------------------
function UI_WaveMaker:getResName(res_name)
    local res_name = string.gsub(res_name, '\\', '/')
    return res_name
end


-------------------------------------
-- function MakeAnimator
-------------------------------------
function UI_WaveMaker:MakeAnimator(res_name)

    local org_res = res_name

    -- 기본 이름으로 검색
    local animator = MakeAnimator(res_name)
    if animator and animator.m_node then
        return animator
    end

    -- 드래곤 캐릭터 검색
    local res_name = 'res/spine/' .. org_res .. '/' .. org_res .. '.spine'
    animator = MakeAnimator(res_name)
    if animator and animator.m_node then
        return animator
    end

    -- missile 리소스 검색
    local res_name = 'res/missile/' .. org_res .. '/' .. org_res .. '.spine'
    animator = MakeAnimator(res_name)
    if animator and animator.m_node then
        return animator
    end

    -- missile 리소스 검색
    local res_name = 'res/missile/' .. org_res .. '/' .. org_res .. '.vrp'
    animator = MakeAnimator(res_name)
    if animator and animator.m_node then
        return animator
    end


    return MakeAnimator(ENTRY_FILE)
end

-------------------------------------
-- function changeVisual
-------------------------------------
function UI_WaveMaker:changeVisual(b_next)

	if not self.m_animator then
		return
	end

	if #self.m_visualNameList then

		if b_next then
			self.m_currVisualIdx = self.m_currVisualIdx + 1
		else
			self.m_currVisualIdx = self.m_currVisualIdx - 1
		end

		if self.m_currVisualIdx > #self.m_visualNameList then
			self.m_currVisualIdx = 1
		elseif self.m_currVisualIdx <= 0 then
			self.m_currVisualIdx = #self.m_visualNameList
		end
	end

	self.m_visualName = self.m_visualNameList[self.m_currVisualIdx]
	self.m_animator:changeAni(self.m_visualName, true, false)
end

-------------------------------------
-- function makeTouchLayer
-------------------------------------
function UI_WaveMaker:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    --listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    --listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)

	local eventDispatcher = target_node:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function UI_WaveMaker:onTouchBegan(touch, event)
    return true
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function UI_WaveMaker:onTouchMoved(touch, event)
    local delta = touch:getDelta()
    local x, y = self.m_touchNode:getPosition()
    self.m_touchNode:setPosition(x + delta['x'], y + delta['y'])
end
