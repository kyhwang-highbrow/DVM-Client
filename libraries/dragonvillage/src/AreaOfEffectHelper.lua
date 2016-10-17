local T_AREA_OF_EFFECT = {}
table.insert(T_AREA_OF_EFFECT, {suffix='s', radius=75})
table.insert(T_AREA_OF_EFFECT, {suffix='m', radius=150})
table.insert(T_AREA_OF_EFFECT, {suffix='l', radius=225})

-------------------------------------
-- table AreaOfEffectHelper
-------------------------------------
AreaOfEffectHelper = {}

-------------------------------------
-- function getAOEData
-------------------------------------
function AreaOfEffectHelper:getAOEData(radius)
    local t_data = nil
    local gap = nil

    for i,v in pairs(T_AREA_OF_EFFECT) do
        local _gap = math_abs(radius - v['radius'])

        if (gap == nil) or (_gap < gap) then
            t_data = v
            gap = _gap
        end
    end

    local suffix = t_data['suffix']
    local scale = (radius/t_data['radius'])

    return suffix, scale
end