local PARENT = Structure

-------------------------------------
-- class StructPickup
-------------------------------------
StructPickup = class(PARENT, {
    list_id = 'number',
    
    ui_priority = 'number',
    did = 'number',
    
    start_date = 'pl.Date',
    end_date = 'pl.Date',
    date_format = 'string',
    
    res_text = 'string',
    res_btn = 'string',
    res_bg = 'string', 
})

-------------------------------------
-- function init
-------------------------------------
function StructPickup:init(data)
    self.date_format = 'yyyy-mm-dd HH:MM:SS'
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructPickup:getClassName()
    return 'StructPickup'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructPickup:getThis()
    return StructPickup
end


-------------------------------------
-- function getListID
-------------------------------------
function StructPickup:getListID()
    return self.list_id
end


-------------------------------------
-- function getUIPriority
-------------------------------------
function StructPickup:getUIPriority()
    return self.ui_priority
end


-------------------------------------
-- function getTargetDragonID
-------------------------------------
function StructPickup:getTargetDragonID()
    return self.did
end

-------------------------------------
-- function getTextResourceStr
-------------------------------------
function StructPickup:getTextResourceStr()
    return pl.stringx.replace(self.res_text, '#', g_localData:getLang(), 1) 
end


-------------------------------------
-- function getButtonResourceStr
-------------------------------------
function StructPickup:getButtonResourceStr()
    return self.res_btn
end


-------------------------------------
-- function getBackgroundResourceStr
-------------------------------------
function StructPickup:getBackgroundResourceStr()
    return self.res_bg
end

-------------------------------------
-- function getButtonNormalSprite
-------------------------------------
function StructPickup:getButtonNormalSprite()
    local res = self:getButtonResourceStr()

    return cc.Sprite:create(res)
end

-------------------------------------
-- function getButtonDisableSprite
-------------------------------------
function StructPickup:getButtonDisabledSprite()
    local res = self:getButtonResourceStr()
    local disabled_res = pl.stringx.replace(res, '1.png', '2.png', 1)

    return cc.Sprite:create(disabled_res)
end
