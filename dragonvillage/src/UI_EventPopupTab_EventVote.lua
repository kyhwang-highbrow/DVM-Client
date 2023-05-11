local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_EventVote
-------------------------------------
UI_EventPopupTab_EventVote = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_EventVote:init(is_full_popup)
    local vars = self:load('event_vote_ticket.ui')
    self:initUI()
	self:initButton()
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_EventVote:onEnterTab()
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_EventPopupTab_EventVote:initUI()
    local vars = self.vars
	local struct_product = self.m_structProduct

    local is_popup = false
    local ui = PackageManager:getTargetUI(struct_product, is_popup)

    if (ui) then
        local node = vars['shopNode']
        node:addChild(ui.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_EventVote:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_EventVote:refresh()
    local vars = self.vars
end
