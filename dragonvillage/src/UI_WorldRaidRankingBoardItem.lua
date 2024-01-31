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
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 1)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaidRankingBoardItem:initUI()
    local vars = self.vars

    local node = IconHelper:getItemIcon(700001)
    vars['iconNode']:removeAllChildren()
    vars['iconNode']:addChild(node)

    node = IconHelper:getItemIcon(700001)
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
function UI_WorldRaidRankingBoardItem:update()
	local vars = self.vars
    vars['iconNode']:setVisible(false)
    vars['eventLabel']:setVisible(false)
    vars['descLabel']:setVisible(false)
    vars['notiSprite']:setVisible(false)
    vars['effectVisual']:setVisible(false)

    if g_worldRaidData:isAvailableWorldRaidRewardRanking() == true then
        vars['descLabel']:setString(Str('랭킹 보상 획득 가능!'))
        vars['descLabel']:setVisible(true)
        vars['notiSprite']:setVisible(true)
        vars['effectVisual']:setVisible(true)

    elseif g_worldRaidData:isAvailableWorldRaidRewardCompliment() == true then
        vars['eventLabel']:setVisible(true)
        vars['iconNode']:setVisible(true)
        vars['notiSprite']:setVisible(true)
        vars['effectVisual']:setVisible(true)

    else
        vars['descLabel']:setString(Str('월드 레이드 게시판'))
        vars['descLabel']:setVisible(true)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WorldRaidRankingBoardItem:refresh()
	local vars = self.vars
end

--@CHECK
UI:checkCompileError(UI_WorldRaidRankingBoardItem)
