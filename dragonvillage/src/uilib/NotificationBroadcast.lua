-------------------------------------
-- class NotificationBroadcast
-------------------------------------
NotificationBroadcast = class{
        m_root = '',
        m_label = '',
        m_msg = '',
    }

-------------------------------------
-- function init
-------------------------------------
function NotificationBroadcast:init(msg, color)
    local width = 1300
    local height = 100

    local rect = cc.rect(0, 0, 0, 0)
    local node = cc.Scale9Sprite:create(rect, 'res/ui/frames/base_frame_0101.png')
    node:setAnchorPoint(cc.p(0.5, 0.5))
    node:setDockPoint(cc.p(0.5, 0.5))
    node:setNormalSize(width, height)

    local label = cc.Label:createWithTTF(msg or 'label', Translate:getFontPath(), 25, 0, cc.size(width, height-10), 1, 1)
    label:setDockPoint(cc.p(0.5, 0.5))
    label:setAnchorPoint(cc.p(0.5, 0.5))

    if color then
        label:setColor(color)
    end
    node:addChild(label)

    self.m_root = node
    self.m_label = label
    self.m_msg = msg
end
