local PARENT = MonsterLua_Boss

local CHARACTER_ACTION_TAG__DYING = 99

-------------------------------------
-- class Monster_WorldOrderMachine
-------------------------------------
Monster_WorldOrderMachine = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Monster_WorldOrderMachine:init(file_name, body, ...)
	self:addPhysObject(self.phys_key, {0, 0, 50}, -220, -220)
end
