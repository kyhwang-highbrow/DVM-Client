local PARENT = Structure

-------------------------------------
-- class StructPickup
-------------------------------------
StructPickup = class(PARENT, {
    pickup_id = 'string',
    
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
-- function getPickupID
-------------------------------------
function StructPickup:getPickupID()
    return tostring(self.pickup_id)
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

-------------------------------------
-- function getRemainingTimeStr
-------------------------------------
function StructPickup:getRemainingTimeStr()
    local parser = pl.Date.Format(self.date_format)


    if self.end_date and (self.end_date ~= '') then
        local temp = parser:parse(self.end_date)
        local curr_time = Timer:getServerTime()
        local end_time = temp['time']

        if (not end_time) then
            return ''
        end

        local time = (end_time - curr_time)

        return Str('남은 시간 : {1}', datetime.makeTimeDesc(time, true))
    end

    return ''

    -- local curr_time = Timer:getServerTime()
    -- local end_time = (self.end_date / 1000)

    -- if (curr_time < end_time) then
    --     local _curr_time = Timer:getServerTime_Milliseconds()
    --     local _end_time = self.end_date
    --     local time_millisec = math_max(_end_time - _curr_time, 0)
    --     local time_str = datetime.makeTimeDesc_timer(time_millisec, true) -- param : milliseconds, day_special
    --     local str = Str('남은 시간 : {1}', '{@green}' .. time_str)
    --     return str
    -- else
    --     return ''
    -- end
end

