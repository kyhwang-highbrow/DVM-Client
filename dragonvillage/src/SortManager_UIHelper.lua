-------------------------------------
-- class SortManager_UIHelper
-- @breif 정렬 관리자
-------------------------------------
SortManager_UIHelper = class({
        m_sortManager = 'SortManager',

        m_currSortTypeLabel = 'cc.Label',

        m_ascendingSprite = 'cc.Sprite',

        m_cbOnChange = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function SortManager_UIHelper:init(sort_manager)
    self.m_sortManager = sort_manager
end

-------------------------------------
-- function setCurrSortTypeLabel
-------------------------------------
function SortManager_UIHelper:setCurrSortTypeLabel(label)
    self.m_currSortTypeLabel = label
    self:refreshCurrSortTypeLabel()
end

-------------------------------------
-- function setExtendMenu
-- @brief 확장 버튼
-------------------------------------
function SortManager_UIHelper:setExtendMenu(extend_btn, extend_menu)
    local function click_func()
        extend_menu:runAction(cc.ToggleVisibility:create())
    end
    extend_btn:registerScriptTapHandler(click_func)
end

-------------------------------------
-- function setAscendingUI
-- @brief 오름차순, 내림차순 버튼
-------------------------------------
function SortManager_UIHelper:setAscendingUI(ascending_btn, ascending_sprite)
    local function click_func()
        local ascending = (not self.m_sortManager.m_defaultSortAscending)
        self.m_sortManager:setAllAscending(ascending)
        self:onChangeSortType()
    end
    ascending_btn:registerScriptTapHandler(click_func)
    self.m_ascendingSprite = ascending_sprite
    self:refreshAscendingSprite()
end

-------------------------------------
-- function setSortBtn
-------------------------------------
function SortManager_UIHelper:setSortBtn(sort_btn, sort_type)
    local function click_func()
        self.m_sortManager:pushSortOrder(sort_type)
        self:onChangeSortType()
    end
    sort_btn:registerScriptTapHandler(click_func)
end

-------------------------------------
-- function refreshCurrSortTypeLabel
-- @brief 현재 선택된 정렬 타입 라벨 갱신
-------------------------------------
function SortManager_UIHelper:refreshCurrSortTypeLabel()
    if (not self.m_sortManager) then
        return
    end

    if (not self.m_currSortTypeLabel) then
        return
    end

    local sort_name = self.m_sortManager:getTopSortingName()
    self.m_currSortTypeLabel:setString(sort_name)
end

-------------------------------------
-- function refreshAscendingSprite
-- @brief 오름차순, 내림차순 화살표 아이콘 갱신
-------------------------------------
function SortManager_UIHelper:refreshAscendingSprite()
    if (not self.m_sortManager) then
        return
    end

    if (not self.m_ascendingSprite) then
        return
    end

    local ascending = self.m_sortManager.m_defaultSortAscending
    self.m_ascendingSprite:stopAllActions()

    if ascending then
        self.m_ascendingSprite:runAction(cc.RotateTo:create(0.15, 180))
    else
        self.m_ascendingSprite:runAction(cc.RotateTo:create(0.15, 0))
    end
end

-------------------------------------
-- function setOnChangeCB
-- @brief 정렬이 변경되었을 때 콜백 함수
-------------------------------------
function SortManager_UIHelper:setOnChangeCB(func)
    self.m_cbOnChange = func
end

-------------------------------------
-- function onChangeSortType
-- @brief 정렬이 변경되었을 때 호출되는 함수
-------------------------------------
function SortManager_UIHelper:onChangeSortType()
    self:refreshCurrSortTypeLabel()
    self:refreshAscendingSprite()

    if self.m_cbOnChange then
        self.m_cbOnChange()
    end
end