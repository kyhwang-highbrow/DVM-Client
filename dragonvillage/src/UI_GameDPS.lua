-------------------------------------
-- class UI_GameDPS
-------------------------------------
UI_GameDPS = class(UI, {
        m_world = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GameDPS:init(world)
    self.m_world = world
	
	local vars = self:load('ingame_dps_info.ui')

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameDPS:initUI()
	local vars = self.vars
	local l_dragon = self.m_world:getDragonList()

end


-------------------------------------
-- function initButton
-------------------------------------
function UI_GameDPS:initButton()
	local vars = self.vars

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_GameDPS:refresh()
	local vars = self.vars

end