local PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_RecommendedDragonInfoListItem_Dragon
-------------------------------------
UI_RecommendedDragonInfoListItem_Dragon = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dragon:init(info)
    self:load('dragon_ranking.ui')

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RecommendedDragonInfoListItem_Dragon')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dragon:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dragon:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dragon:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dragon:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_RecommendedDragonInfoListItem_Dragon)
