local PARENT = UI

-------------------------------------
-- class UI_AcquisitionRegionInformation
-------------------------------------
UI_AcquisitionRegionInformation = class(PARENT, {
        m_itemID = 'item_id',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AcquisitionRegionInformation:init(item_id)
    self.m_itemID = item_id

    local vars = self:load('location_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_AcquisitionRegionInformation')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AcquisitionRegionInformation:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_AcquisitionRegionInformation:initUI()
    local vars = self.vars
    local item_id = self.m_itemID

    -- 아이템 아이콘
    local item = UI_ItemCard(item_id)
    vars['itemNode']:addChild(item.root)
    
    -- 아이템 이름
    local name = TableItem():getValue(item_id, 't_name')
    vars['itemLabel']:setString(Str(name))

    self:regionListView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AcquisitionRegionInformation:initButton(t_user_info)
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_AcquisitionRegionInformation:refresh(t_user_info)
    local vars = self.vars
end

-------------------------------------
-- function regionListView
-- @brief
-------------------------------------
function UI_AcquisitionRegionInformation:regionListView()
    local node = self.vars['listNode']

	local l_region = self:makeRegionList()

    -- 셀 아이템 생성 콜백
    local function create_func(ui, data)
        --[[
        ui.vars['selectBtn']:registerScriptTapHandler(function()
                UIManager:toastNotificationGreen(Str('"고니"가 선택되었습니다.'))
            end)
        --]]
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(520, 100)
    table_view:setCellUIClass(UI_AcquisitionRegionListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_region)

    -- 아이템 등장 연출
    local content_size = node:getContentSize()
    table_view.m_cellUIAppearCB = function(ui)
        local x, y = ui.root:getPosition()
        local new_x = x + content_size['width']
        ui.root:setPosition(new_x, y)

        ui:cellMoveTo(0.5, cc.p(x, y))
    end
end

-------------------------------------
-- function makeRegionList
-- @brief
-------------------------------------
function UI_AcquisitionRegionInformation:makeRegionList()
    local item_id = self.m_itemID
	local item_type = TableItem:getItemType(item_id)
	local l_region = {}

	-- 드래곤
	if (item_type == 'dragon') then
		local t_item = TableItem():get(item_id)
		local did = t_item['did']

		-- 뽑기 체크
		local t_dragon = TableDragon():get(did)
		if (t_dragon) then
			-- 일반 소환
			if (t_dragon['pick_weight'] > 0) then
				local birth_grade = t_dragon['birthgrade']
				if (birth_grade >= 3) then
					table.insert(l_region, 'pick_high')
				end
				if (birth_grade <= 3) then
					table.insert(l_region, 'pick_low')
				end
			end
			-- 우정 부화
			if (t_dragon['fp_weight'] > 0) then
				table.insert(l_region, 'friend')
			end
			-- 마일리지
			if (t_dragon['mg_weight'] > 0) then
				table.insert(l_region, 'mileage')
			end
		end
		
		-- 조합 체크
		local t_combine = TableDragonCombine():get(did)
		if (t_combine) then
			table.insert(l_region, 'combine')
		end

		-- 인연 체크
		local is_relation = TableSecretDungeon():getObtainableDragonList()[tostring(did)]
		if (is_relation) then
			table.insert(l_region, 'relation')
		end

		-- 아무것도 없다면 하나 출력해준다... 뭐...
		if (#l_region == 0) then
			table.insert(l_region, 'empty')
		end

	-- 슬라임
	elseif (item_type == 'slime') then
		local t_item = TableItem():get(item_id)
		local did = t_item['did']

		-- 뽑기 체크
		local t_slime = TableSlime():get(did)
		if (t_slime) then
			-- 일반 소환
			if (t_slime['pick_weight'] > 0) then
				local birth_grade = t_slime['birthgrade']
				if (birth_grade >= 3) then
					table.insert(l_region, 'pick_high')
				end
				if (birth_grade <= 3) then
					table.insert(l_region, 'pick_low')
				end
			end
			-- 우정 부화
			if (t_slime['fp_weight'] > 0) then
				table.insert(l_region, 'friend')
			end
			-- 마일리지
			if (t_slime['mg_weight'] > 0) then
				table.insert(l_region, 'mileage')
			end
		end

		-- 슬라임은 조합이나 인연이 없다.

		-- 아무것도 없다면 하나 출력해준다... 뭐...
		if (#l_region == 0) then
			table.insert(l_region, 'empty')
		end

	-- 룬
	elseif (item_type == 'rune') then
		l_region = TableItem:getRegionList(item_id)

	end

	return l_region
end

--@CHECK
UI:checkCompileError(UI_AcquisitionRegionInformation)
