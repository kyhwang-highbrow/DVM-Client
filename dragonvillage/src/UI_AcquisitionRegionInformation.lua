local PARENT = UI

-------------------------------------
-- class UI_AcquisitionRegionInformation
-------------------------------------
UI_AcquisitionRegionInformation = class(PARENT, {
        m_itemID = 'item_id',
    })

-------------------------------------
-- function create
-------------------------------------
function UI_AcquisitionRegionInformation:create(item_id)
    local l_region = self:makeRegionList(item_id)
    if (#l_region <= 0) then
        UIManager:toastNotificationRed(Str('획득 장소 정보가 없습니다.'))
        return
    end

    local ui = UI_AcquisitionRegionInformation(item_id)
end

-------------------------------------
-- function init
-------------------------------------
function UI_AcquisitionRegionInformation:init(item_id)
    self.m_itemID = item_id

    self.m_uiName = 'UI_AcquisitionRegionInformation'
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

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(520, 100)
    table_view:setCellUIClass(UI_AcquisitionRegionListItem)
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
function UI_AcquisitionRegionInformation:makeRegionList(item_id)
    local item_id = item_id or self.m_itemID
	local item_type = TableItem:getItemType(item_id)
	local l_region = {}

	-- 드래곤
	if (item_type == 'dragon') then
		local t_item = TableItem():get(item_id)
		local did = t_item['did']

		-- 뽑기 체크
		local t_dragon = TableDragon():get(did)
		if (t_dragon) then
			-- 일반 소환 or 고급소환
            if (t_dragon['rarity'] == 'myth') then
                if (t_dragon['pick_weight'] > 0) then
                    table.insert(l_region, 'pick_gacha')
                else
                    table.insert(l_region, 'empty')
                end
			elseif (t_dragon['pick_weight'] > 0) then
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

            -- 쿠폰 체크
            if (t_dragon['c_coupon'] > 0) then
                table.insert(l_region, 'coupon' .. t_dragon['c_coupon'])
            end
		end
		
		-- 조합 체크
        local skip_error_msg = true
		local t_combine = TableDragonCombine():get(did, skip_error_msg)
		if (t_combine) then
			table.insert(l_region, 'combine')
		end

		-- 인연 체크
		local is_relation = TableSecretDungeon():getObtainableDragonList()[tostring(did)]
		if (is_relation) then
			table.insert(l_region, 'relation')
		end

        -- 토파즈
		local category = TableDragon():getDragonCartegory(did)
		if (category == 'cardpack') then
			table.insert(l_region, 'cardpack')
		end

        -- 차원문
		if (category == 'dmgate') then
			table.insert(l_region, 'dmgate')
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

        -- 슈퍼 슬라임 종류는 합성으로 획득 가능
        if (t_slime['material_type'] == 'upgrade') then
            table.insert(l_region, 'slime_combine')
        end

		-- 슬라임은 조합이나 인연이 없다.

		-- 아무것도 없다면 하나 출력해준다... 뭐...
		if (#l_region == 0) then
			table.insert(l_region, 'empty')
		end

    -- 룬 연마석
	elseif (item_type == 'grindstone') then
        table.insert(l_region, 'arena_new')

	-- 룬, 과일, 진화재료 및 기타 다른것들
	else
		l_region = TableItem:getRegionList(item_id)
	end

    -- 룬 합성과 가챠 체크
    -- 리스트 상단, 하단에 배치할 것인지
    -- 리스트에 아무것도 없을 때만 노출시킬 것인지
    -- Make your choise
    if (item_type == 'rune') then

        -- 1성룬 합성 불가
        -- 뽑기 획등 가능한 룬은 6성 이상
        local grade = getDigit(item_id, 1, 1)

        -- 고대룬은 획득 불가
        local is_ancient = (getDigit(item_id, 100, 2) > 8) and true or false

        -- 고대룬이 아니면
        -- 이야기를 계속해보지.
        if not is_ancient then

            -- 뽑기에서는 6성 이상만 획득 가능하네.
            if (grade >= 6) then
                table.insert(l_region, 'rune_gacha')
            end

            -- 합성은 2성 이상 가능하네
            if (grade >= 2) then
                table.insert(l_region, 'rune_combine')
            end
        end
    end

	return l_region
end

--@CHECK
UI:checkCompileError(UI_AcquisitionRegionInformation)
