local PARENT = class(UI, ITableViewCell:getCloneTable())

--------------------------------------------------------------------------
--- @class UI_ResearchItem
--------------------------------------------------------------------------
UI_ResearchItem = class(PARENT, {
    m_researchId = 'number',
    m_researchType = 'number',
})

--------------------------------------------------------------------------
--- @function init 
--------------------------------------------------------------------------
function UI_ResearchItem:init(data)
    self.m_researchId = data
    self.m_researchType = TableResearch:getInstance():getResearchType(data)
    self:load(string.format('research_item_%d.ui', self.m_researchType))
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
        --vars['nameLabel']:setString(string.format('%d.%s',research_id%10000, name))
        vars['nameLabel']:setString(name)
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
    local last_research_id = g_researchData:getLastResearchId(self.m_researchType)

    -- 잠금해제가 가능한 상태
    local is_unlock_available = g_researchData:isAvailableResearchId(self.m_researchId)
    vars['notiSprite']:setVisible(is_unlock_available)

    -- 잠금된 상태
    local is_locked = self.m_researchId > last_research_id and is_unlock_available == false
    vars['lockSprite']:setVisible(is_locked)

    -- 해제 상태 - 완료 체크
    local is_unlocked = self.m_researchId <= last_research_id
    vars['clearSprite']:setVisible(is_unlocked)
end