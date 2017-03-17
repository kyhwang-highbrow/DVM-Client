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

        m_gameNode1 = '',
        m_gameNode2 = '',
        m_gameNode3 = '',

        m_groundNode = '',
        m_worldNode = '',
        m_missiledNode = '',
        m_unitInfoNode = '',
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

    local worldLayer = g_gameScene.m_gameHighlightNode
    
    do -- 게임 레이어 (배경, 유닛, 미사일 용)
	    self.m_gameNode1 = cc.Node:create()
	    worldLayer:addChild(self.m_gameNode1)

	    -- 게임 레이어 (이펙트 및 폰트 용)
	    self.m_gameNode2 = cc.Node:create()
	    worldLayer:addChild(self.m_gameNode2)

	    -- 게임 레이어 (pause 제외 이펙트 및 폰트 용)
	    self.m_gameNode3 = cc.Node:create()
	    worldLayer:addChild(self.m_gameNode3)


        self.m_groundNode = cc.Node:create()
        self.m_gameNode1:addChild(self.m_groundNode)

        self.m_worldNode = cc.Node:create()
        self.m_gameNode1:addChild(self.m_worldNode)

        self.m_missiledNode = cc.Node:create()
        self.m_gameNode1:addChild(self.m_missiledNode)
	
	    self.m_unitInfoNode = cc.Node:create()
        self.m_gameNode1:addChild(self.m_unitInfoNode)
    end
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

    -- root 노드
    local t_data = {}
    t_data['parent'] = char.m_world.m_worldNode -- 5챕터 보스 이슈로...
    t_data['zorder'] = node:getLocalZOrder()
    node:retain()
    node:removeFromParent(false)
    self.m_worldNode:addChild(node, zorder or 0)
    node:release()

    if (char.m_unitInfoNode) then
        t_data['unit_parent'] = char.m_unitInfoNode:getParent()
		t_data['unit_zorder'] = char.m_unitInfoNode:getLocalZOrder()
		char.m_unitInfoNode:retain()
		char.m_unitInfoNode:removeFromParent(false)
		self.m_unitInfoNode:addChild(char.m_unitInfoNode, t_data['unit_zorder'])
		char.m_unitInfoNode:release()
    end
    
    self.m_lCharList[char] = t_data

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

    if (t_data['unit_parent']) then 
		local node = char.m_unitInfoNode
		node:retain()
		node:removeFromParent(false)
		t_data['unit_parent']:addChild(node, t_data['unit_zorder'])
		node:release()
	end
        
    char.m_bHighlight = false
end

-------------------------------------
-- function addMissile
-------------------------------------
function GameHighlightMgr:addMissile(missile)
    if (self.m_mode ~= GAME_HIGHLIGHT_MODE_DRAGON_SKILL) then return end
    if (not isInstanceOf(missile, Skill) and not isInstanceOf(missile, Missile) and not isInstanceOf(missile, StatusEffect)) then return end
    
    local node = missile.m_rootNode
    if (not node) then
        cclog('GameHighlightMgr:addMissile missile.m_rootNode == nil')
    end
    
    local t_data = {}
    t_data['parent'] = node:getParent()
    t_data['zorder'] = node:getLocalZOrder()
    self.m_lMissileList[missile] = t_data

    local target_node = self:getHighLightNode(t_data['parent'])
    
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

    if (not missile.m_rootNode) then return end

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
    local target_node = self:getHighLightNode(node:getParent())

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
    local target_node = self:getHighLightNode(node:getParent())

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

-------------------------------------
-- function getHighLightNode
-------------------------------------
function GameHighlightMgr:getHighLightNode(orgParentNode)
    local world = self.m_world
    local highLightNode

    local temp = {
        'm_gameNode2',
        'm_gameNode3',

        'm_groundNode',
        'm_worldNode',
        'm_missiledNode',
        'm_unitInfoNode',
    }
    
    for i, k in ipairs(temp) do
        if (orgParentNode == world[k]) then
            highLightNode = self[k]
            break
        end
    end

    return highLightNode
end