local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_RuneForgeCombineItem
-------------------------------------
UI_RuneForgeCombineItem = class(PARENT,{
        m_ownerUI = 'UI_RuneForgeCombineTab',
        ---------------------------------
        m_runeCombineData = 'StructRuneCombine',
        m_mRuneCardUI = 'map', -- 현재 생성되어있는 룬 카드 UI, map[index] = UI_RuneCard
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeCombineItem:init(owner_ui, struct_rune_combine)
    local vars = self:load('rune_forge_combine_item.ui')
    
    self.m_ownerUI = owner_ui
    self.m_runeCombineData = struct_rune_combine
    self.m_mRuneCardUI = {}

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeCombineItem:initUI()
    local vars = self.vars
   
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneForgeCombineItem:initButton()
    local vars = self.vars

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeCombineItem:refresh()
    local vars = self.vars

    local t_rune_combine_data = self.m_runeCombineData

    for idx = 1, RUNE_COMBINE_REQUIRE do
        local is_blank_index = t_rune_combine_data:isBlankIndex(idx)
        
        if (is_blank_index) then
           vars['itemNode' .. idx]:removeAllChildren() -- 제거
           self.m_mRuneCardUI[idx] = nil

        else
            if (self.m_mRuneCardUI[idx] == nil) then -- 룬 정보가 있는데 UI 카드가 없던 경우생성
                local t_rune_data = t_rune_combine_data:getRuneDataFromIndex(idx)
                local rune_card_ui = UI_RuneCard(t_rune_data)
                rune_card_ui.root:setSwallowTouch(false)
                rune_card_ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_rune(t_rune_data) end)
                vars['itemNode' .. idx]:addChild(rune_card_ui.root)
                
                cca.uiReactionSlow(rune_card_ui.root, 1, 1, 1.3)
                self.m_mRuneCardUI[idx] = rune_card_ui
            end
        end
    end

    if (t_rune_combine_data:isFull()) then
        vars['allSelectMenu']:setVisible(true)
    else
        vars['allSelectMenu']:setVisible(false)
    end
end

-------------------------------------
-- function click_rune
-- @brief 룬 선택
-------------------------------------
function UI_RuneForgeCombineItem:click_rune(data)
    local owner_ui = self.m_ownerUI
    owner_ui:click_rune(data)
end