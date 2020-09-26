local PARENT = Structure

-------------------------------------
-- class StructEventLFBag
-- @brief 복주머니
-------------------------------------
StructEventLFBag = class(PARENT, {
        -- raw data      
        lucky_fortune = 'number',
        score = 'number',
        this_items = 'string',
        this_step = 'number',
        end_time = 'timestamp',
        
        -- proc data
        l_cum_item_list = 'table',
    })

local THIS = StructEventLFBag
local MAX_LV = 10
-------------------------------------
-- function init
-------------------------------------
function StructEventLFBag:init()
    self['lucky_fortune'] = 0
    self['score'] = 0
    self['this_items'] = ''
    self['this_step'] = 0
    self['end_time'] = 0
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructEventLFBag:getClassName()
    return 'StructEventLFBag'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructEventLFBag:getThis()
    return THIS
end

-------------------------------------
-- function apply
-------------------------------------
function StructEventLFBag:apply(t_data)
    for i, v in pairs(self) do
        if (t_data[i] ~= nil) then
            if (i == 'end_time') then
                self[i] = t_data[i] / 1000
            else
                self[i] = t_data[i]
            end
        end
    end
end

-------------------------------------
-- function getScore
-------------------------------------
function StructEventLFBag:getScore()
    return self['score']
end

-------------------------------------
-- function getCount
-------------------------------------
function StructEventLFBag:getCount()
    return self['lucky_fortune']
end

-------------------------------------
-- function getProb
-------------------------------------
function StructEventLFBag:getProb()
    return 0
end

-------------------------------------
-- function getLv
-------------------------------------
function StructEventLFBag:getLv()
    return self['this_step']
end

-------------------------------------
-- function isMax
-------------------------------------
function StructEventLFBag:isMax()
    return self['this_step'] >= MAX_LV
end

-------------------------------------
-- function getEndTime
-------------------------------------
function StructEventLFBag:getEndTime()
    return self['end_time']
end

-------------------------------------
-- function getCumluativeItemList
-------------------------------------
function StructEventLFBag:getCumluativeItemList()
    local l_item = g_itemData:parsePackageItemStr(self['this_items'])
    return l_item
end