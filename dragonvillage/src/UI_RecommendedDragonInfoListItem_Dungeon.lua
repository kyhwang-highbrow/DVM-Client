local PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_RecommendedDragonInfoListItem_Dungeon
-------------------------------------
UI_RecommendedDragonInfoListItem_Dungeon = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dungeon:init(info)
    self:load('dragon_ranking.ui')

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RecommendedDragonInfoListItem_Dungeon')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dungeon:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dungeon:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dungeon:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dungeon:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_RecommendedDragonInfoListItem_Dungeon)
