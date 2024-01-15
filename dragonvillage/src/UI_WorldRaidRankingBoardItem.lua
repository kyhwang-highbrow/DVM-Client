local PARENT = UI
-------------------------------------
--- @class UI_WorldRaidRankingBoardItem
-------------------------------------
UI_WorldRaidRankingBoardItem = class(PARENT,{
    m_clickCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_WorldRaidRankingBoardItem:init(click_cb)
    self.m_clickCB = click_cb
    local vars = self:load('world_raid_ranking_board.ui')
    --if (UIManager.m_toastPopup) then
    --    UIManager.m_toastPopup:closeWithAction()
    --end
	--UIManager.m_toastPopup = self

	-- -- @UI_ACTION
    -- self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.5)
    -- self:doActionReset()
    -- self:doAction(nil, false)

	--self.m_toastMsg = toast_str or Str('보상을 수령하였습니다')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaidRankingBoardItem:initUI()
    local vars = self.vars
    vars['listBtn']:registerScriptTapHandler(function () 
        SafeFuncCall(self.m_clickCB)
    end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_WorldRaidRankingBoardItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WorldRaidRankingBoardItem:refresh()
	local vars = self.vars
end

--@CHECK
UI:checkCompileError(UI_WorldRaidRankingBoardItem)
