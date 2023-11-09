local PARENT = class(UI, ITableViewCell:getCloneTable())

--------------------------------------------------------------------------
--- @class UI_ResearchItem
--------------------------------------------------------------------------
UI_ResearchItem = class(PARENT, {
    m_researchId = 'number',
    m_type = 'number',
})

--------------------------------------------------------------------------
--- @function init 
--------------------------------------------------------------------------
function UI_ResearchItem:init(data)
    self.m_researchId = data
    self.m_type = TableResearch:getInstance():getResearchType(data)
    self:load(string.format('research_item_%d.ui', self.m_type))
    self:initUI()
    self:initButton()
    self:refresh()
end

--------------------------------------------------------------------------
--- @function initUI 
--------------------------------------------------------------------------
function UI_ResearchItem:initUI()
    local vars = self.vars
    local research_id = self.m_researchId

    do -- 이름
        local name =  TableResearch:getInstance():getResearchName(research_id)
        if (IS_TEST_MODE() == true) then
            vars['nameLabel']:setString(string.format('(%d)%s',research_id%10000, name))
        else
            vars['nameLabel']:setString(name)
        end
    end

    do -- 아이콘
        local res_icon =  TableResearch:getInstance():getResearchIconRes(research_id)
        local animator = MakeAnimator(res_icon)
        vars['itemNode']:removeAllChildren()
        vars['itemNode']:addChild(animator.m_node)
    end
end

--------------------------------------------------------------------------
--- @function initButton 
--------------------------------------------------------------------------
function UI_ResearchItem:initButton()
    local vars = self.vars
end

--------------------------------------------------------------------------
--- @function refresh 
--------------------------------------------------------------------------
function UI_ResearchItem:refresh()
    local vars = self.vars
end