local PARENT = UI
-------------------------------------
--- @class UI_WorldRaidBoardMilestonItem
-------------------------------------
UI_WorldRaidBoardMilestonItem = class(PARENT,{
    m_arrowAnimator = 'Animator',
    m_lobbyTamer = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_WorldRaidBoardMilestonItem:init(tamer)
    self.m_arrowAnimator = nil
    self.m_lobbyTamer = tamer
    self:load('world_raid_ranking_board_milestone.ui')
    self:initUI()
    self:initButton()
    self:refresh()

    --self.root:setVisible(true)
    self.root:scheduleUpdateWithPriorityLua(function () self:update() end, 1)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_WorldRaidBoardMilestonItem:initUI()
    local vars = self.vars
    self.m_arrowAnimator = vars['arrowVisual']
    -- local node = IconHelper:getItemIcon(700001)
    -- vars['iconNode']:removeAllChildren()
    -- vars['iconNode']:addChild(node)

    -- -- vars['listBtn']:registerScriptTapHandler(function () 
    -- --     SafeFuncCall(self.m_clickCB)
    -- -- end)

    -- local tint_action = cca.buttonShakeAction(1 ,3.0)
    -- self.root:stopAllActions()
    -- self.root:runAction(tint_action)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_WorldRaidBoardMilestonItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_WorldRaidBoardMilestonItem:refresh()
	local vars = self.vars
end

-------------------------------------
-- function checkAvailable
-------------------------------------
function UI_WorldRaidBoardMilestonItem:checkAvailable()
    -- 월드 레이드 기간인지
    if g_worldRaidData:isAvailableWorldRaid() == false then
        return false
    end

    -- 보상이 가능한지
    if g_worldRaidData:isAvailableWorldRaidReward() == false then
        return false
    end

    return true
end

-------------------------------------
--- @function refresh
-------------------------------------
function UI_WorldRaidBoardMilestonItem:update(dt)
	local vars = self.vars

    self.root:setVisible(false)
    if self:checkAvailable() == false then
        return
    end

    local lobby_map = self.m_lobbyTamer:getLobbyMap()

    if lobby_map == nil then
        return
    end

    if lobby_map.m_groudNode == nil then 
        return
    end

    self.root:setVisible(true)

    local board_world_pos = lobby_map.m_groudNode:convertToWorldSpaceAR(cc.p(650, 200))
    --board_world_pos.y = 0

    local tamer_world_pos = convertToWorldSpace(self.m_lobbyTamer.m_rootNode)
    --tamer_world_pos.y = 0

    local diff_x = board_world_pos.x - tamer_world_pos.x

    if diff_x < 0 then
        self:setLeftArrow()
    else
        self:setRightArrow()
    end
end

-------------------------------------
--- @function setLeftArrow
-------------------------------------
function UI_WorldRaidBoardMilestonItem:setLeftArrow()
    if self.root:getPositionX() == -150  then
        return
    end

    self.root:setPosition(cc.p(-150, 100))
    self.m_arrowAnimator:changeAni('arrow_left', true)
end

-------------------------------------
--- @function setRightArrow
-------------------------------------
function UI_WorldRaidBoardMilestonItem:setRightArrow()
    if self.root:getPositionX() == 150  then
        return
    end

    self.root:setPosition(cc.p(150, 100))
    self.m_arrowAnimator:changeAni('arrow_right', true)
end


--@CHECK
UI:checkCompileError(UI_WorldRaidBoardMilestonItem)
