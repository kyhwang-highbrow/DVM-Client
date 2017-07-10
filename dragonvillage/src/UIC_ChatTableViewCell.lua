local PARENT = ITableViewCell:getCloneClass()

-------------------------------------
-- class UIC_ChatTableViewCell
-------------------------------------
UIC_ChatTableViewCell = class(PARENT, {
        root = 'cc.Menu',
        vars = 'ui',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_ChatTableViewCell:init(data)

    self.root = cc.Menu:create()
    --self.root:setNormalSize(150, 150)
    self.root:setDockPoint(CENTER_POINT)
    self.root:setAnchorPoint(CENTER_POINT)
    self.root:setPosition(0, 0)

    self.vars = {}
end