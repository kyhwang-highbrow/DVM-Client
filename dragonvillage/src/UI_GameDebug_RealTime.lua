-------------------------------------
-- class UI_GameDebug_RealTime
-- @brief 
-------------------------------------
UI_GameDebug_RealTime = class(UI, {
		m_debugLayer = 'cc.Scale9Sprite',
		m_debugLabel = 'cc.LabelTTF',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GameDebug_RealTime:init()
	-- debug 정보 표시 영역 초기화
	local rect = cc.rect(0, 0, 0, 0)
	self.m_debugLayer = cc.Scale9Sprite:create(rect, 'res/ui/toast_notification.png')
	self.m_debugLayer:setDockPoint(cc.p(0.5, 0))
    self.m_debugLayer:setAnchorPoint(cc.p(0.5, 0))
	self.m_debugLayer:setNormalSize(320, 180)
    self.m_debugLayer:setPositionY(10)
	self.m_debugLayer:setOpacity(150)

	-- debug label
	self.m_debugLabel = cc.Label:createWithTTF('----','res/font/common_font_01.ttf', 22, 1, cc.size(600, 50), 1, 1)
	self.m_debugLabel:setDockPoint(cc.p(0.5, 0.5))
    self.m_debugLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_debugLayer:addChild(self.m_debugLabel)

	self.m_debugLayer:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function setDebugText
-- @brief
-------------------------------------
function UI_GameDebug_RealTime:setDebugText(str)
	-- debug 영역이 없을 시 탈출
	if (not self.m_debugLayer) then
		return 
	end
	-- @TODO 임시로 메모리값만 출력 .. 추후에 필요한것을 자유롭게 추가할 수 있도록 수정
	if (str == 'memory') then 
		str = string.format('on memory : %.2f MB', collectgarbage('count') / 1024) .. '\n' .. '_g count : ' .. table.count(_G)
	end
	-- set 
	self.m_debugLabel:setString(str)
end

-------------------------------------
-- function update
-------------------------------------
function UI_GameDebug_RealTime:update(dt)
	self:setDebugText('memory')
end