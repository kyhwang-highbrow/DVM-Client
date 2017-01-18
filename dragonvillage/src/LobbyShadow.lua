local PARENT = class(IEventDispatcher:getCloneClass(), IEventListener:getCloneTable())

-------------------------------------
-- class LobbyShadow
-------------------------------------
LobbyShadow = class(PARENT, {
        m_rootNode = 'cc.Node',
        m_shadowSprite = 'cc.Sprite',
     })

-------------------------------------
-- function init
-------------------------------------
function LobbyShadow:init(scale)
    -- rootNode 생성
    self.m_rootNode = cc.Node:create()

    -- 그림자 이미지 생성
    self.m_shadowSprite = cc.Sprite:create('res/character/char_shadow.png')
    self.m_shadowSprite:setDockPoint(cc.p(0.5, 0.5))
    self.m_shadowSprite:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_shadowSprite:setScale(scale)
    self.m_shadowSprite:setOpacity(0.5 * 255)
    self.m_rootNode:addChild(self.m_shadowSprite)
end

-------------------------------------
-- function onEvent
-------------------------------------
function LobbyShadow:onEvent(event_name, t_event, ...)
    if (event_name == 'lobby_character_move') then
        local arg = {...}
        local lobby_tamer = arg[1]
        local x = arg[2]
        local y = arg[3]

        self.m_rootNode:setPosition(x, y)

        self:dispatch('lobby_shadow_move', {}, self, x, y)
    end
end

-------------------------------------
-- function release
-------------------------------------
function LobbyShadow:release()
    if self.m_rootNode then
        self.m_rootNode:removeFromParent(true)
    end
    
    self.m_rootNode = nil

    PARENT.release_EventDispatcher(self)
    PARENT.release_EventListener(self)
end