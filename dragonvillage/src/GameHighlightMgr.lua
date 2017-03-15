GAME_HIGHLIGHT_MODE_HIDE = 0
GAME_HIGHLIGHT_MODE_DRAGON_SKILL = 1
GAME_HIGHLIGHT_MODE_FEVER = 2

-------------------------------------
-- class GameHighlightMgr
-------------------------------------
GameHighlightMgr = class({
        m_world = 'GameWorld',

        m_mode = 'number',

        m_lCharList = 'table',
        m_lMissileList = 'table',

        m_darkLayer = '',

        m_node1 = '',
        m_node2 = '',
        m_node3 = '',
     })

-------------------------------------
-- function init
-------------------------------------
function GameHighlightMgr:init(world)
    self.m_world = world

    self.m_mode = GAME_HIGHLIGHT_MODE_HIDE
    
    self.m_lCharList = {}
    self.m_lMissileList = {}

    self.m_darkLayer = g_gameScene.m_colorLayerForSkill
    self.m_darkLayer:setOpacity(0)
    self.m_darkLayer:setVisible(true)

    self.m_node1 = g_gameScene.m_gameHighlightNode
    self.m_node2 = g_gameScene.m_gameHighlightNode2
    self.m_node3 = g_gameScene.m_gameHighlightNode3
end

-------------------------------------
-- function setMode
-------------------------------------
function GameHighlightMgr:setMode(mode)
    if (self.m_mode ~= mode) then
        self.m_mode = mode        
        self:clear()
    end
end

-------------------------------------
-- function addChar
-------------------------------------
function GameHighlightMgr:addChar(char, zorder)
    if (self.m_mode == GAME_HIGHLIGHT_MODE_HIDE) then return end
    if (char.m_bDead) then return end
    if (char.m_bHighlight) then return end

    local node = char:getRootNode()
    if (not node) then return end

    local t_data = {}
    t_data['parent'] = char.m_world.m_worldNode
    t_data['zorder'] = node:getLocalZOrder()
    self.m_lCharList[char] = t_data

    -- root 노드
    node:retain()
    node:removeFromParent(false)
    self.m_node1:addChild(node, zorder or 0)
    node:release()

    -- UI 노드
    if (char.m_hpNode) and (char.m_charTable['rarity'] ~= 'boss') then 
		t_data['ui_parent'] = char.m_hpNode:getParent()
		t_data['ui_zorder'] = char.m_hpNode:getLocalZOrder()
		char.m_hpNode:retain()
		char.m_hpNode:removeFromParent(false)
		self.m_node1:addChild(char.m_hpNode, t_data['ui_zorder'])
		char.m_hpNode:release()
	end

	-- 캐스팅 노드
	if (char.m_castingNode) then 
		t_data['ui_casting_parent'] = char.m_castingNode:getParent()
		t_data['ui_casting_zorder'] = char.m_castingNode:getLocalZOrder()
		char.m_castingNode:retain()
		char.m_castingNode:removeFromParent(false)
		self.m_node1:addChild(char.m_castingNode, t_data['ui_casting_zorder'])
		char.m_castingNode:release()
	end

    char.m_bHighlight = true
end

-------------------------------------
-- function removeChar
-------------------------------------
function GameHighlightMgr:removeChar(char)
    if (not char.m_bHighlight) then return end
    
    local t_data = self.m_lCharList[char]
    if (not t_data) then return end

    self.m_lCharList[char] = nil

    if (char.m_bDead) then return end

    -- @TODO slave character 가 있을 때 처리 
    if (char.m_isSlaveCharacter) then 
        if (char.m_masterCharacter.m_bHighlight) then
            return
        end 
    end

	if (char.m_bInitAdditionalPhysObject) then
		for slave_char, _  in pairs(char.m_lAdditionalPhysObject) do 
            if (slave_char.m_bHighlight) then
                return
            end
        end
    end

    -- 루트 노드
	if (t_data['parent']) then 
		local node = char:getRootNode()
		node:retain()
		node:removeFromParent(false)
		t_data['parent']:addChild(node, t_data['zorder'])
		node:release()
	end

    -- UI 노드
	if (t_data['ui_parent']) then 
		local node = char.m_hpNode
		node:retain()
		node:removeFromParent(false)
		t_data['ui_parent']:addChild(node, t_data['ui_zorder'])
		node:release()
	end

	-- 캐스팅 노드
	if (t_data['ui_casting_parent']) then 
		local node = char.m_castingNode
		node:retain()
		node:removeFromParent(false)
		t_data['ui_casting_parent']:addChild(node, t_data['ui_casting_zorder'])
		node:release()
	end
    
    char.m_bHighlight = false
end

-------------------------------------
-- function addMissile
-------------------------------------
function GameHighlightMgr:addMissile(missile)
    if (self.m_mode ~= GAME_HIGHLIGHT_MODE_DRAGON_SKILL) then return end
    if (not isInstanceOf(missile, Skill) and not isInstanceOf(missile, Missile) and not isInstanceOf(missile, Buff)) then return end
    
    local node = missile.m_rootNode
    if (not node) then
        cclog('GameHighlightMgr:addMissile missile.m_rootNode == nil')
    end
    
    local t_data = {}
    t_data['parent'] = node:getParent()
    t_data['zorder'] = node:getLocalZOrder()
    self.m_lMissileList[missile] = t_data

    local target_node

    if (t_data['parent'] == self.m_world.m_missiledNode) then
        target_node = self.m_node2
    else
        target_node = self.m_node1
    end

    -- root 노드
    node:retain()
    node:removeFromParent(false)
    target_node:addChild(node, node:getLocalZOrder())
    node:release()
end

-------------------------------------
-- function removeMissile
-------------------------------------
function GameHighlightMgr:removeMissile(missile)
    local t_data = self.m_lMissileList[missile]
    if (not t_data) then return end

    self.m_lMissileList[missile] = nil

    if (t_data['parent']) then 
		local node = missile.m_rootNode
        if (node) then
            node:retain()
		    node:removeFromParent(false)
		    t_data['parent']:addChild(node, t_data['zorder'])
		    node:release()
        end
	end
end

-------------------------------------
-- function addEffect
-- @brief 이펙트 형태는 하이라이트 상태를 계속 유지시킴
-------------------------------------
function GameHighlightMgr:addEffect(effect)
    if (self.m_mode ~= GAME_HIGHLIGHT_MODE_DRAGON_SKILL) then return end
    
    local node = effect.m_node
    
    local target_node = self.m_node2

    -- root 노드
    node:retain()
    node:removeFromParent(false)
    target_node:addChild(node, node:getLocalZOrder())
    node:release()
end

-------------------------------------
-- function addDamage
-------------------------------------
function GameHighlightMgr:addDamage(node)
    if (self.m_mode ~= GAME_HIGHLIGHT_MODE_DRAGON_SKILL) then return end
    
    local node = node
    
    local target_node = self.m_node3

    -- root 노드
    node:retain()
    node:removeFromParent(false)
    target_node:addChild(node, node:getLocalZOrder())
    node:release()
end

-------------------------------------
-- function clear
-------------------------------------
function GameHighlightMgr:clear()
    for char, _ in pairs(self.m_lCharList) do
        self:removeChar(char)
    end

    for missile, _ in pairs(self.m_lMissileList) do
        self:removeMissile(missile)
    end
end

-------------------------------------
-- function changeDarkLayerColor
-------------------------------------
function GameHighlightMgr:changeDarkLayerColor(opacity, duration)
    local dark_layer = self.m_darkLayer
    local duration = duration or 0

    dark_layer:stopAllActions()

    -- 현재 카메라에 따른 위치 변경
    local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
    dark_layer:setPosition(cameraHomePosX, cameraHomePosY)
    
    dark_layer:runAction( cc.FadeTo:create(duration, opacity) )
end