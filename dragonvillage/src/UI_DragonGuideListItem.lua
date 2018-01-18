local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_DragonGuideListItem
-------------------------------------
UI_DragonGuideListItem = class(PARENT, {
        m_data = '',
        m_doid = '',
        m_link_list = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonGuideListItem:init(t_data)
    local vars = self:load('dragon_guide_item.ui')

    self.m_data = t_data
    self.m_doid = t_data['dragon_data']['id']
    self.m_link_list = t_data['link']

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_cellSize = cc.size(150, 400)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonGuideListItem:initUI()
    local vars = self.vars

    local data = self.m_data
    local dragon_data = data['dragon_data']

    -- 드래곤 카드
    local card = UI_DragonCard(dragon_data)
	vars['dragonNode']:addChild(card.root)

    -- 육성 가이드 버튼 처리
    local link_list = self.m_link_list
    for i, link in ipairs(link_list) do
        vars['linkBtn'..i]:setVisible(true)

        local text = DragonGuideNavigator:getText(link)
        vars['linkLabel'..i]:setString(text)
    end

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGuideListItem:initButton()
    local vars = self.vars
    vars['linkBtn1']:registerScriptTapHandler(function() self:click_linkBtn(1) end)
    vars['linkBtn2']:registerScriptTapHandler(function() self:click_linkBtn(2) end)
    vars['linkBtn3']:registerScriptTapHandler(function() self:click_linkBtn(3) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonGuideListItem:refresh()
end

-------------------------------------
-- function click_linkBtn
-------------------------------------
function UI_DragonGuideListItem:click_linkBtn(idx)
    local target = self.m_link_list[idx]

    -- 여기선 백버튼 누르면 다시 게임결과 화면으로  
    -- ## UINavigator로 처리안함
    if (target) then
        local doid = self.m_doid
        local ui = UI_DragonManageInfo(doid, target)
        ui.m_force_close = true
    end
end