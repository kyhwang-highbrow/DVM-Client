local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_DragonGuideListItem
-------------------------------------
UI_DragonGuideListItem = class(PARENT, {
        m_data = '',
        m_doid = '',
        m_link_list = '',
        m_refreshCB = 'function',
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

    do -- 드래곤 카드
        local card = UI_DragonCard(dragon_data)
	    vars['dragonNode']:addChild(card.root)
    end

    
    do -- 희귀도 표시
        local rarity = dragon_data:getRarity()

        -- 아이콘
        vars['rarityIconNode']:removeAllChildren()
        local icon = IconHelper:getRarityIconButton(rarity, dragon_data)
        vars['rarityIconNode']:addChild(icon)

        -- 라벨
        vars['rarityLabel']:setString(dragonRarityName(rarity))
        vars['rarityLabel']:setColor(COLOR[rarity])
        self:alignRarityNode()
    end

    do -- 육성 가이드 버튼 처리
        local link_list = self.m_link_list
        for i, link in ipairs(link_list) do
            local suffix = ''
            if (link == 'level_up') then
                suffix = '_highlight'
            end
            vars['linkBtn' .. i .. suffix]:setVisible(true)

            local text = DragonGuideNavigator:getText(link)
            vars['linkLabel' .. i .. suffix]:setString(text)
        end
    end
end

-------------------------------------
-- function alignRarityNode
-- @brief 희귀도 아이콘, 라벨 정렬
-------------------------------------
function UI_DragonGuideListItem:alignRarityNode()
    local vars = self.vars

    if (vars['rarityIconNode'] == nil) then
        return
    end

    if (vars['rarityLabel'] == nil) then
        return
    end

    local interval_x = 10
    
    -- 아이콘 넓이 계산
    local icon_width = 0
    do
        local content_size = vars['rarityIconNode']:getContentSize()
        local scale_x = vars['rarityIconNode']:getScaleX()
        icon_width = (content_size['width'] * scale_x)
    end

    -- 드래곤 라벨 넓이 계산
    local label_width = 0
    do
        local string_width = vars['rarityLabel']:getStringWidth()
        local scale_x = vars['rarityLabel']:getScaleX()
        label_width = (string_width * scale_x)
    end

    -- 총 넓이, 시작 x위치 계산
    local total_width = icon_width + interval_x + label_width
    local left_x = -(total_width / 2)

    -- node 위치 조정
    vars['rarityIconNode']:setPositionX(left_x + (icon_width/2))
    vars['rarityLabel']:setPositionX(left_x + icon_width + interval_x + (label_width/2))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonGuideListItem:initButton()
    local vars = self.vars
    vars['linkBtn1']:registerScriptTapHandler(function() self:click_linkBtn(1) end)
    vars['linkBtn1_highlight']:registerScriptTapHandler(function() self:click_linkBtn(1) end)
    vars['linkBtn2']:registerScriptTapHandler(function() self:click_linkBtn(2) end)
    vars['linkBtn2_highlight']:registerScriptTapHandler(function() self:click_linkBtn(2) end)
    vars['linkBtn3']:registerScriptTapHandler(function() self:click_linkBtn(3) end)
    vars['linkBtn3_highlight']:registerScriptTapHandler(function() self:click_linkBtn(3) end)
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

        ui:setCloseCB(self.m_refreshCB)
    end
end