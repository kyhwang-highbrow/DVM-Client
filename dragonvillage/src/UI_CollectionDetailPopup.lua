local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_CollectionDetailPopup
-------------------------------------
UI_CollectionDetailPopup = class(PARENT,{
        m_lDragonsData = 'list',
        m_currIdx = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionDetailPopup:init(l_dragons_data, init_idx)
    self.m_lDragonsData = l_dragons_data
    self.m_currIdx = init_idx

    local vars = self:load('collection_detail_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey ÁöÁ¤
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CollectionDetailPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionDetailPopup:initUI()
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionDetailPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CollectionDetailPopup:refresh()
    self:setTab('adult')
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_CollectionDetailPopup:initTab()
    local vars = self.vars
    self:addTab('hatch', vars['evolutionBtn1'])
    self:addTab('hatchling', vars['evolutionBtn2'])
    self:addTab('adult', vars['evolutionBtn3'])
end

--@CHECK
UI:checkCompileError(UI_CollectionDetailPopup)
