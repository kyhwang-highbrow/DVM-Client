local PARENT = StatusEffect_Bleed

-------------------------------------
-- class StatusEffect_Poison
-------------------------------------
StatusEffect_Poison = class(PARENT, {
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Poison:init(file_name, body)
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_Poison:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    self:addTrigger('char_do_atk', function(t_event, ...)
        self:doDamage()
    end)
end