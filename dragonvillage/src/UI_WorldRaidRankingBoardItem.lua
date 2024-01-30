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
    self:load('world_raid_ranking_board.ui')
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaidRankingBoardItem:initUI()
    local vars = self.vars

    local node = IconHelper:getItemIcon(700001)
    vars['iconNode']:removeAllChildren()
    vars['iconNode']:addChild(node)

    -- vars['listBtn']:registerScriptTapHandler(function () 
    --     SafeFuncCall(self.m_clickCB)
    -- end)

    local tint_action = cca.buttonShakeAction(1 ,3.0)
    self.root:stopAllActions()
    self.root:runAction(tint_action)
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
    local is_available_reward = g_worldRaidData:isAvailableWorldRaidReward()
    vars['notiSprite']:setVisible(is_available_reward)
end

--@CHECK
UI:checkCompileError(UI_WorldRaidRankingBoardItem)
