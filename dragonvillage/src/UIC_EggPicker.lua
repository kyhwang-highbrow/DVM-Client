local PARENT = UIC_Node

-------------------------------------
-- class UIC_EggPicker
-------------------------------------
UIC_EggPicker = class(PARENT, {
        m_focusItemScale = 'number', -- 현재 포커스된 아이템의 스케일 100%
        m_nearItemScale = 'number',  -- 현재 포커스된 아이템 양 옆 아이템의 스케일 80%
        m_restItemScale = 'number',  -- 기타 아이템의 스케일 40%

        m_lItemList = 'table',
        m_itemWidth = 'number',

        m_itemAreaTotalWidth = 'number',
        m_itemAreaMinX = 'number',
        m_itemAreaMaxX = 'number',

        m_containerOffsetX = 'number',

        m_itemInterval = 'number',
        m_lItemPosLIst = 'list[pos_x]',

        m_currFocusIndex = 'number',

        -- 퍼포먼스 이슈
        m_showItemList = '',

        m_itemClickCB = 'function',
        m_changeCurrFocusIndexCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_EggPicker:init()
    self.m_focusItemScale = 1 -- 현재 포커스된 아이템의 스케일 100%
    self.m_nearItemScale = 0.8 -- 현재 포커스된 아이템 양 옆 아이템의 스케일 80%
    self.m_restItemScale = (self.m_nearItemScale * 0.5) -- 기타 아이템의 스케일 40%


    self.m_lItemList = {}
    self.m_itemWidth = 100

    self.m_currFocusIndex = nil

    self.m_showItemList = {}
    self.m_containerOffsetX = 0
end

-------------------------------------
-- function create
-------------------------------------
function UIC_EggPicker:create(parent)
    -- 인스턴스 생성
    local egg_picker = UIC_EggPicker()
    
    -- 스크롤뷰 생성
    local scroll_view = cc.ScrollView:create()
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    egg_picker.m_node = scroll_view

    parent:addChild(egg_picker.m_node)


    do
        local content_size = parent:getContentSize()

        -- 실질적인 테이블 뷰 사이즈 설정
        scroll_view:setViewSize(content_size)
        scroll_view:setDockPoint(cc.p(0.5, 0.5))
        scroll_view:setAnchorPoint(cc.p(0.5, 0.5))
        scroll_view:setDelegate()

        -- 스크롤 handler
        local scrollViewDidScroll = function()
            egg_picker:scrollViewDidScroll(view)
        end
        scroll_view:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)

        -- relocate handler
        local scrollViewDidRelocate = function()
            if egg_picker.m_currFocusIndex then
                egg_picker:setFocus(egg_picker.m_currFocusIndex, 0.5)
            end
        end
        scroll_view:registerScriptHandler(scrollViewDidRelocate, cc.EVENT_CUSTOM_SCROLLVIEW_RELOCATE)
    end

    do  -- 컨테이너 비주얼로 보이게
        --local _container = scroll_view:getContainer()
        --UIC_Node(_container):initGLNode()
    end

    return egg_picker
end

-------------------------------------
-- function sample
-------------------------------------
function UIC_EggPicker:sample(scene)
    -- GL Calls와 fps를 보기 위해 on
    cc.Director:getInstance():setDisplayStats(true)

    -- UIMaker에서 전달될 부모 더미 노드 임시 생성
    local node = UIC_Node:create()
    node:setNormalSize(400, 200)
    scene:addChild(node.m_node)
    node:initGLNode()

    -- UIC_EggPicker 생성
    local egg_picker = UIC_EggPicker:create(node)

    -- 200개의 아이템 임시 추가
    for i=1, 200 do
        local scale = 0.8
        local res = 'res/ui/icons/colosseum_match.png'
        local ui = cc.Sprite:create(res)
        ui:setDockPoint(cc.p(0.5, 0.5))
        ui:setAnchorPoint(cc.p(0.5, 0.5))
        ui:setScale(scale)

        egg_picker:addEgg({}, ui)
    end

    -- 10번째 아이템을 포커스
    egg_picker:setFocus(10)
end

-------------------------------------
-- function calcTotalWidth
-- @brief
-------------------------------------
function UIC_EggPicker:calcTotalWidth(count, item_width)
    if (count <= 0) then
        return 0
    end

    -- 어느 상황에서건 길이를 같게 하기 위해 2개를 더함 (따라서 처음과 마지막 index는 사용 불가)
    count = count + 2

    local total_width = 0

    -- 가운데 아이템 크기
    if (1 <= count) then
        total_width = (total_width + (item_width * self.m_focusItemScale))
    end

    -- 가운데의 양쪽 아이템의 크기
    local both_side_cnt = math_clamp((count - 1), 0, 2)
    total_width = (total_width + (both_side_cnt * item_width * self.m_nearItemScale))

    -- 기타 아이템의 크기
    local else_cnt = math_max(0, count-3)
    total_width = (total_width + (else_cnt * item_width * self.m_restItemScale))

    return total_width
end


-------------------------------------
-- function addEgg
-------------------------------------
function UIC_EggPicker:addEgg(data, ui)

    local normal_size = cc.size(self:getNormalSize())
    local size = cc.size(self.m_itemWidth, normal_size['height'])
    
    local menu = cc.Menu:create()
    menu:setDockPoint(cc.p(0, 0.5)) -- 좌중간
    menu:setAnchorPoint(cc.p(0.5, 0.5))
    menu:setNormalSize(size)
    menu:setPosition(0, 0)
    menu:setVisible(false) -- 실시간으로 보여질 애들만 true로 설정함
    self:addChild(menu)

    do -- 버튼
        local idx = (#self.m_lItemList + 1)
        local node = cc.MenuItemImage:create(EMPTY_PNG, nil, nil, 1)
        node:setContentSize(size['width'], size['height'])
        node:setDockPoint(cc.p(0.5, 0.5))
        node:setAnchorPoint(cc.p(0.5, 0.5))
        menu:addChild(node)
        menu:setSwallowTouch(false)
        node:registerScriptTapHandler(function()
                self:click_egg(idx)
            end)
    end

    local t_item = {}
    t_item['data'] = data
    t_item['ui'] = ui
    t_item['menu'] = menu
    table.insert(self.m_lItemList, t_item)

    menu:addChild(ui.root)
    menu:setUpdateChildrenTransform()

    do -- 컨테이너 사이즈 조절
        local count = #self.m_lItemList
        local item_width = self.m_itemWidth
        local total_width = self:calcTotalWidth(count, item_width)
        --cclog('total_width ' .. total_width)

        -- 아이템이 나열되는 영역
        self.m_itemAreaTotalWidth = total_width

        -- 첫 아이템은 선택할 수 없음
        self.m_itemAreaMinX = (item_width * self.m_nearItemScale) + (item_width * self.m_focusItemScale * 0.5) -- 가운데 정렬이므로

        -- 마지막 아이템은 선택할 수 없음
        self.m_itemAreaMaxX = total_width - ((item_width * self.m_nearItemScale) + (item_width * self.m_focusItemScale * 0.5)) -- 가운데 정렬이므로

        -- 컨테이너 사이즈
        local view_size = self.m_node:getViewSize()
        local size = cc.size(total_width, normal_size['height'])
        self.m_containerOffsetX = (view_size['width'] / 2) - self.m_itemAreaMinX
        size['width'] = size['width'] + (self.m_containerOffsetX * 2)
        self:setContentSize(size)
    end

    do
        -- 첫 아이템은 선택할 수 없음
        local min_x = self.m_itemAreaMinX

        -- 마지막 아이템은 선택할 수 없음
        local max_x = self.m_itemAreaMaxX

        local interval = 0
        local item_count = #self.m_lItemList
        if (1 < item_count) then
            interval = (max_x - min_x) / (item_count - 1)
        end
        self.m_itemInterval = interval

        local item_pos = {}
        for i=1, item_count do
            local x = min_x + (i-1) * interval
            item_pos[i] = x
            --item_list[i]:setPositionX(pos_x)
        end
        self.m_lItemPosLIst = item_pos
    end

    -- 위치 갱신
    self:scrollViewDidScroll()
end

-------------------------------------
-- function scrollViewDidScroll
-------------------------------------
function UIC_EggPicker:scrollViewDidScroll()
    local item_count = #self.m_lItemList
    if (item_count <= 0) then
        return
    end


    local offset = self.m_node:getContentOffset()

    local view_size = self.m_node:getViewSize()

    -- 화면 가운데의 포지션
    local pos_x = (offset['x'] * -1) + (view_size['width'] / 2) - self.m_containerOffsetX
    --cclog('pos_x ' .. pos_x)
    local item_width = self.m_itemWidth

    -- 첫 아이템은 선택할 수 없음
    local min_x = self.m_itemAreaMinX

    -- 마지막 아이템은 선택할 수 없음
    local max_x = self.m_itemAreaMaxX


    local interval = self.m_itemInterval
    local item_pos = self.m_lItemPosLIst


    local item_list = self.m_lItemList
    pos_x = math_clamp(pos_x, min_x, max_x)

    local idx
    if (interval == 0) then
        idx = 1
    else
        idx = ((pos_x - min_x) / interval) + 1
    end
    idx = math_round(idx) -- 사사오입

    self:setCurrFocusIndex(idx)
    local l_curr_pos = {}
    l_curr_pos[idx] = item_pos[idx]

    do -- 일단 딱 맞는다고 가정하고 짜보자
        local z_order = 10000
        item_list[idx]['menu']:setLocalZOrder(z_order)            

        -- 왼쪽 계산
        local x = item_pos[idx]
        local local_z_order = z_order
        for i=idx-1, 1, -1 do
            if (i == (idx -1)) then
                x = x - (item_width * self.m_focusItemScale / 2) - (item_width * self.m_nearItemScale / 2)
                l_curr_pos[i] = x
                item_list[i]['menu']:setPositionX(self.m_containerOffsetX + x)
                item_list[i]['menu']:setScale(self.m_nearItemScale)
            else
                x = x - (item_width * self.m_restItemScale)
                l_curr_pos[i] = x
                item_list[i]['menu']:setPositionX(self.m_containerOffsetX + x)
                item_list[i]['menu']:setScale(self.m_nearItemScale)
            end
            local_z_order = local_z_order - 1
            item_list[i]['menu']:setLocalZOrder(local_z_order)
        end

        -- 오른쪽 계산
        local x = item_pos[idx]
        local local_z_order = z_order
        for i=idx+1, item_count, 1 do
            if (i == (idx +1)) then
                x = x + (item_width * self.m_focusItemScale / 2) + (item_width * self.m_nearItemScale / 2)
                l_curr_pos[i] = x
                item_list[i]['menu']:setPositionX(self.m_containerOffsetX + x)
                item_list[i]['menu']:setScale(self.m_nearItemScale)
            else
                x = x + (item_width * self.m_restItemScale)
                l_curr_pos[i] = x
                item_list[i]['menu']:setPositionX(self.m_containerOffsetX + x)
                item_list[i]['menu']:setScale(self.m_nearItemScale)
            end
            local_z_order = local_z_order - 1
            item_list[i]['menu']:setLocalZOrder(local_z_order)
        end
    end

    do -- 실제 테스트
        local container_pos_x = pos_x -- 컨테이너의 현재 위치
        local first_std_pos_x = item_pos[idx] -- 첫 번째 아이템이 가운데일 경우 위치
        local x = nil

        local gap = first_std_pos_x - container_pos_x
        --cclog('gap ' .. gap)

        local rate
        if (interval == 0) then
            rate = 0
        else
            rate = (gap / interval)
        end
            
        --local dist = (item_width * self.m_focusItemScale / 2) - (item_width * self.m_nearItemScale / 2)
        local dist = (item_width * self.m_focusItemScale / 2) + (item_width * self.m_nearItemScale / 2) - interval
        x = item_pos[idx] + (dist * rate)
        item_list[idx]['menu']:setPositionX(self.m_containerOffsetX + x)
        local std_scale = self.m_nearItemScale + (self.m_focusItemScale - self.m_nearItemScale) * (1 - math_abs(rate))
        item_list[idx]['menu']:setScale(std_scale)
 
        -- 오른쪽 아이템 위치 보정
        if (rate <= 0) then
            local _idx = idx + 1
            if item_list[_idx] then
                -- 크기 조정
                local _scale = self.m_nearItemScale + (self.m_focusItemScale - self.m_nearItemScale) * (rate/-1)
                item_list[_idx]['menu']:setScale(_scale)

                -- 위치 조정
                _x = l_curr_pos[_idx] + (dist * rate)
                item_list[_idx]['menu']:setPositionX(self.m_containerOffsetX + _x)
            end
        -- 왼쪽 아이템 위치 보정
        elseif (rate > 0) then
            local _idx = idx - 1
            if item_list[_idx] then
                -- 크기 조정
                local _scale = self.m_nearItemScale + (self.m_focusItemScale - self.m_nearItemScale) * (rate/1)
                item_list[_idx]['menu']:setScale(_scale)

                -- 위치 조정
                _x = l_curr_pos[_idx] + (dist * rate)
                item_list[_idx]['menu']:setPositionX(self.m_containerOffsetX + _x)
            end
        end
    end

    do -- 퍼포먼스 이슈 대충 처리
        for i,v in pairs(self.m_showItemList) do
            v['menu']:setVisible(false)
        end
        self.m_showItemList = {}

        local std_idx = self.m_currFocusIndex
        local cnt = 5

        local start_idx = math_clamp(std_idx - cnt, 1, item_count)
        local end_idx = math_clamp(std_idx + cnt, 1, item_count)

        for i=start_idx, end_idx do
            if item_list[i] then
                item_list[i]['menu']:setVisible(true)
                table.insert(self.m_showItemList, item_list[i])
            end
        end
    end
end

-------------------------------------
-- function setFocus
-------------------------------------
function UIC_EggPicker:setFocus(idx, duration)
    local pos = self.m_lItemPosLIst[idx] 
    if (not pos) then
        return
    end

    duration = (duration or 0.2)
    local animated = true
    local view_size = self.m_node:getViewSize()
    local offset_x = -(pos - ((view_size['width'] / 2) - self.m_containerOffsetX))

    --self.m_node:setContentOffset(cc.p(offset_x, 0), animated);

    -- 컨테이너가 이동 중이었으면 stop
    local container = self.m_node:getContainer()
    container:stopAllActions()

    self.m_node:setContentOffsetInDuration(cc.p(offset_x, 0), duration);
end

-------------------------------------
-- function click_egg
-------------------------------------
function UIC_EggPicker:click_egg(idx)
    if (self.m_currFocusIndex == idx) then
        if self.m_itemClickCB then
            local t_item = self.m_lItemList[idx]
            self.m_itemClickCB(t_item, idx)
        end
    else
        self:setFocus(idx)
    end
end

-------------------------------------
-- function setItemClickCB
-------------------------------------
function UIC_EggPicker:setItemClickCB(func)
    self.m_itemClickCB = func
end

-------------------------------------
-- function addItemClickCB
-------------------------------------
function UIC_EggPicker:addItemClickCB(func)
	local old_func = self.m_itemClickCB
	local function add_func(t_item, idx)
		old_func(t_item, idx)
		func(t_item, idx)
	end
	self.m_itemClickCB = add_func
end

-------------------------------------
-- function clearAllItems
-------------------------------------
function UIC_EggPicker:clearAllItems()
    for i,v in pairs(self.m_lItemList) do
        v['menu']:removeFromParent()
    end

    self.m_lItemList = {}
    self.m_showItemList = {}
    self.m_currFocusIndex = nil

    self:scrollViewDidScroll()
end

-------------------------------------
-- function setChangeCurrFocusIndexCB
-------------------------------------
function UIC_EggPicker:setChangeCurrFocusIndexCB(func)
    self.m_changeCurrFocusIndexCB = func
end

-------------------------------------
-- function setCurrFocusIndex
-------------------------------------
function UIC_EggPicker:setCurrFocusIndex(idx)
    if (self.m_currFocusIndex == idx) then
        return
    end

    self.m_currFocusIndex = idx

    if self.m_changeCurrFocusIndexCB then
        local t_item = self.m_lItemList[idx]
        self.m_changeCurrFocusIndexCB(t_item, idx)
    end
end