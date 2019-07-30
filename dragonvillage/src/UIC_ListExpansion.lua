local PARENT = UIC_Node

-------------------------------------
-- class UIC_ListExpansion
-- 참고 UI https://uimovement.com/design/list-expansion/
--
-- 루아 네임 규칙
-- expandedNode_{별칭}       확장된 사이즈 (보통 상단 메뉴로 하면 된다) <-최상위 노드(메뉴)여야 하고 anchor_point가 TOP_CENTER여야 한다.
-- collapsedNode_{별칭}      축소된 사이즈 (Node로 사이즈를 알려주기 위한 용도)
-- clippingNode_{별칭}       확장, 축소되었을 때 비지블
-- expansionBtn_{별칭}       확장, 축소 버튼
-------------------------------------
UIC_ListExpansion = class(PARENT, {
        m_node = 'cc.Node',
        vars = '',

        m_itemUIList = 'table', -- 위쪽부터 정렬된 순서
        m_itemUIMap = 'table', -- 이름으로 정렬된 순서
        m_itemListInterval = 'number', -- 아이템간의 간격
    })

local THIS = UIC_ListExpansion

-------------------------------------
-- function init
-------------------------------------
function UIC_ListExpansion:init(node)
    self.m_node = node
end

-------------------------------------
-- function configListExpansion
-- @param vars UI클래스에서 사용하는 vars
-- @param item_name_list 아이템 리스트의 스트링 리스트
--                       {'role', 'rarity', 'attr'}
-- @param item_list_interval 아이템 리스트 간격
-------------------------------------
function UIC_ListExpansion:configListExpansion(vars, item_name_list, item_list_interval)
    self.vars = vars

    self.m_itemUIList = {}
    self.m_itemUIMap = {}
    self.m_itemListInterval = item_list_interval or 5

    for _, item_name in ipairs(item_name_list) do
        local expandedNode = vars['expandedNode_' .. item_name]
        local collapsedNode = vars['collapsedNode_' .. item_name]
        local clippingNode = vars['clippingNode_' .. item_name]
        local duration = 0.2
        local expanded = false

        local list_expansion_item = UIC_ListExpansionItem(expandedNode)
        table.insert(self.m_itemUIList, list_expansion_item)
        self.m_itemUIMap[item_name] = list_expansion_item

        list_expansion_item:configExpansionItem(item_name, expandedNode, collapsedNode, clippingNode, duration, expanded)

        vars['expansionBtn_' .. item_name]:registerScriptTapHandler(function() self:click_listItemBtn(item_name) end)
    end

    self:sortExpantionItemList(true) -- param : is_immediately
end

-------------------------------------
-- function setDefaultSelectedListItem
-------------------------------------
function UIC_ListExpansion:setDefaultSelectedListItem(item_name)
    self.m_itemUIMap[item_name]:setExpansion(true, true) -- param : is_expanded, is_immediately

    -- 다른 아이템은 모두 닫아준다.
    for i,v in ipairs(self.m_itemUIList) do
        if (item_name ~= v.m_itemName) then
            v:setExpansion(false, true) -- param : is_expanded, is_immediately
        end
    end 

    self:sortExpantionItemList(true) -- param : is_immediately
end

-------------------------------------
-- function click_listItemBtn
-------------------------------------
function UIC_ListExpansion:click_listItemBtn(item_name)
    local expanded = self.m_itemUIMap[item_name]:toggleExpantionState()

    -- 클릭된 리스트 아이템이 펼쳐질 경우 다른 아이템은 모두 닫아준다.
    if expanded then
        for i,v in ipairs(self.m_itemUIList) do
            if (item_name ~= v.m_itemName) then
                v:setExpansion(false)
            end
        end 
    end

    self:sortExpantionItemList()
end

-------------------------------------
-- function sortExpantionItemList
-------------------------------------
function UIC_ListExpansion:sortExpantionItemList(is_immediately)
    -- 아이템 리스트들의 총 높이를 구한다.
    local total_height = 0
    for i,v in ipairs(self.m_itemUIList) do
        total_height = total_height + v:getCurrHeight()
        if (i ~= 1) then
            total_height = total_height + self.m_itemListInterval
        end
    end 

    -- 계산된 위치로 이동시킨다
    local iter_y = total_height / 2
    for i,v in ipairs(self.m_itemUIList) do

        if (is_immediately == true) then
            v.m_node:setPosition(0, iter_y)
        else
            v.m_node:stopAllActions()
            local move_to = cc.MoveTo:create(0.2, cc.p(0, iter_y))
            local action = cc.EaseInOut:create(move_to, 2)
            v.m_node:runAction(action)
        end
        
        iter_y = iter_y - v:getCurrHeight() - self.m_itemListInterval
    end
end