local PARENT = UI

-------------------------------------
-- class UI_ExplorationLocationButton
-------------------------------------
UI_ExplorationLocationButton = class(PARENT,{
        m_eprID = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ExplorationLocationButton:init(epr_id)
    self.m_eprID = epr_id

    local vars = self:load('exploration_map_list.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ExplorationLocationButton:initUI()
    local vars = self.vars
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    vars['orderLabel']:setString(Str(location_info['order']))
    if (status == 'idle') then
        vars['locationLabel']:setString(Str(location_info['t_name']))

    elseif (status == 'lock') then
        vars['locationLabel']:setString(Str('진입불가'))

    elseif (status == 'ing') then
        vars['locationLabel']:setString(Str('{1} 탐험 중', location_info['t_name']))
    end

    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExplorationLocationButton:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExplorationLocationButton:refresh()
end

--@CHECK
UI:checkCompileError(UI_ExplorationLocationButton)
