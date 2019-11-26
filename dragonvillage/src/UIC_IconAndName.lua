-------------------------------------
-- class UIC_IconAndName
-- @brief 아이콘과 이름이 같이 표시되는 UI 요소
--        예시) 클랜 아이콘 + 클랜명
--          
-------------------------------------
UIC_IconAndName = class({
        m_parentNode = '',
        m_iconNode = '',
        m_nameLabelAreaNode = '',
        m_nameLabel = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_IconAndName:init()
end

-------------------------------------
-- function setComponent
-------------------------------------
function UIC_IconAndName:setComponent(parent_node, icon_node, name_label_area_node, name_label)
    self.m_parentNode = parent_node
    self.m_iconNode = icon_node
    self.m_nameLabelAreaNode = name_label_area_node
    self.m_nameLabel = name_label
end

-------------------------------------
-- function refresh
-------------------------------------
function UIC_IconAndName:refresh()
    local parent_node = self.m_parentNode
    local icon_node = self.m_iconNode
    local name_label_area_node = self.m_nameLabelAreaNode
    local name_label = self.m_nameLabel

    local align = 'center' -- 정렬 'left', 'center', 'right'
    local spacing = 5 -- 아이콘과 라벨간의 간격

    -- 동작을 위해 가운데 정렬로 사용
    name_label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    --local ret = name_label.m_node:getTextAlignment()
    --ccdump(ret)
    --setAlignment

    name_label:setString('창천')
    --name_label:setString('난공불락이야이게?길이가말도안되면?')

    -- 1. 아이콘 길이 체크 (아이콘을 붙이는 node는 scale을 사용하는 경우가 많아 이부분을 고려해서 계산)
    local icon_width = 0
    local icon_height = 0
    do
        local size = icon_node:getContentSize()
        local scale = icon_node:getScale()

        icon_width = size['width'] * scale
        icon_height = size['height'] * scale
    end

    -- spacing 계산 (아이콘과 라벨 영역간의 간격으로 사용)
    do
        local icon_right_x = icon_node:getPositionX() + (icon_width / 2)
        local label_area_left_x = name_label_area_node:getPositionX() - (name_label_area_node:getContentSize()['width'] / 2)
        --local _scasing = (label_area_left_x - icon_right_x)
        if (icon_right_x <= label_area_left_x) then
            spacing = (label_area_left_x - icon_right_x)
        end
    end

    -- 2. 라벨 길이 체크
    local label_width = 0
    do
        local str_width = name_label:getStringWidth()

        local area_size = name_label_area_node:getContentSize()
        local area_width = area_size['width']

        -- 영역이 충분할 경우 정사이즈로 출력현다.
        if (str_width <= area_width) then
            name_label:setScaleX(1)
            label_width = str_width

        -- 영역이 부족할 경우 라벨 scale을 줄인다.
        else
            local scale = (area_width / str_width)
            name_label:setScale(scale)
            label_width = area_width
        end
    end

    -- 아이콘, 간격, 라벨의 넓이 총합
    local total_width = (icon_width + spacing + label_width)

    -- 3. 정렬
    do
        local size = parent_node:getContentSize()
        local start_pos_x = 0
        if (align == 'left') then
            start_pos_x = -(size['width'] / 2)

        elseif (align == 'right') then
            start_pos_x = (size['width'] / 2) - (total_width)

        else--if (align == 'center') then
            start_pos_x = -(total_width / 2)
        end

        -- 아이콘 위치
        local icon_pos_x = start_pos_x + (icon_width / 2)
        icon_node:setPositionX(icon_pos_x)

        -- 라벨 위치 (아이콘에서 spacing만큼 떨어진 위치)
        local label_pos_x = (start_pos_x + icon_width) + spacing + (label_width / 2)
        name_label_area_node:setPositionX(label_pos_x)
    end
end


-------------------------------------
-- function sampleCode
-------------------------------------
function UIC_IconAndName:sampleCode()
    local ui = UI()
    ui:load('clan_icon_and_name.ui')
    UIManager:open(ui, UIManager.SCENE)

    local icon_and_name = UIC_IconAndName()
    local parent_node = ui.vars['clan_name_menu']
    local icon_node = ui.vars['clan_icon_node']
    local name_label_area_node = ui.vars['clan_name_label_area']
    local name_label = ui.vars['clan_name_label']
    icon_and_name:setComponent(parent_node, icon_node, name_label_area_node, name_label)
    icon_and_name:refresh()
end