local PARENT = Structure

----------------------------------------------------------------------
-- class StructProductGroup
-- brief 패키지 상점의 왼쪽 탭 버튼을 위해 talbe_package_bundle.csv의 데이터를 binding
----------------------------------------------------------------------
StructProductGroup = class(PARENT, {
	bid = 'number',		-- 1, 2, 3, ...

	t_name = 'string',	-- package_something
	t_desc = 'string',	-- 패키지 이름
	type = 'string', 	-- '', single, group, bundle

	row_num = 'number',

	t_pids = 'string',

	is_detail = 'boolean',
	use_desc = 'boolean',

	buyable_from_lv = 'number',
	buyable_to_lv  = 'number',
	buyable_unlock_content = 'string',
	
	select_one = '',

	scroll_direction = 'string', -- vertical, horizontal
	dock_point = 'number', -- 1 or 

	m_structProductList = 'List[StructProduct]',
})


----------------------------------------------------------------------
-- function createTableView
----------------------------------------------------------------------
function StructProductGroup:init(data)
	self:convertPidsToStructProducts()
end


----------------------------------------------------------------------
-- function getClassName
----------------------------------------------------------------------
function StructProductGroup:getClassName()
	return 'StructProductGroup'
end


----------------------------------------------------------------------
-- function 
----------------------------------------------------------------------
function StructProductGroup:getThis()
	return StructProductGroup
end

----------------------------------------------------------------------
-- function 
----------------------------------------------------------------------
function StructProductGroup:getProductName()
	return self.t_name
end


----------------------------------------------------------------------
-- function 
----------------------------------------------------------------------
function StructProductGroup:getDesc()
	return Str(self.t_desc)
end


----------------------------------------------------------------------
-- function 
----------------------------------------------------------------------
function StructProductGroup:getType()
	return self.type
end

----------------------------------------------------------------------
-- function 
-- TODO : Need to change name, not a row_name
----------------------------------------------------------------------
function StructProductGroup:getRowNum()
	return self.row_num
end



----------------------------------------------------------------------
-- function convertPidsToStructProducts
-- TODO : Need to check every structProduct is able to purchase.
-- 	  If there is any product which is not available, then remove it from the list.
----------------------------------------------------------------------
function StructProductGroup:convertPidsToStructProducts()
	local pid_list = pl.stringx.split(self.t_pids, ',')
	local result = {}
	local pid_index_list = {}
	local removal_list = {} -- 

	-- 카테고리 별로 등록된 pid 리스트
	for _, product_id in pairs(pid_list) do
		local struct_product = g_shopDataNew:getTargetProduct(tonumber(product_id))
    
		-- pid에 해당하는 상품이 있고, 그것이 패키지 상품인 경우
		if struct_product and (struct_product:getTabCategory() == 'package') then
			-- TODO (YJK_210622) : isItBuyable으로 체크할지 말지 table_shop_list에서 상품별로 체크하도록
			-- 상품 구매 횟수 체크
			if (struct_product:isItBuyable()) or (self['t_name'] == 'package_daily') then
				table.insert(result, struct_product)

				pid_index_list[tonumber(product_id)] = #result

				-- check dependency between packages
				local dependency = struct_product:getDependency()
				if dependency then
					removal_list[tonumber(product_id)] = tonumber(dependency)
				end
			end
		end
	end	

	-- 카테고리에 포함된 상품이 하나라도 있으면
	if (not table.isEmpty(result)) then
		for target_id, dependent_id in pairs(removal_list) do
			local dependent_index = pid_index_list[dependent_id]
			local target_index = pid_index_list[target_id]

			result[dependent_index] = result[target_index]
			result[target_index] = nil
		end

		self.m_structProductList = table.MapToList(result)
	end
end

----------------------------------------------------------------------
-- function isIncludeProduct
----------------------------------------------------------------------
function StructProductGroup:isIncludeProduct(product_id)
	for index, struct_product in pairs(self.m_structProductList) do
		if (struct_product:getProductID() == product_id) then
			return true
		end
	end

	return false
end


----------------------------------------------------------------------
-- function convertPidsToStructProducts
-- TODO : Need to check every structProduct is able to purchase.
-- 	  If there is any product which is not available, then remove it from the list.
----------------------------------------------------------------------
function StructProductGroup:setTargetUI(parent_node, buy_callback, is_refresh_dependency)
	if (not self.m_structProductList) or table.isEmpty(self.m_structProductList) then
		return nil
	end
	
	local ui_type = self:getType()

	for index, struct_product in pairs(self.m_structProductList) do
		local ui

		-- 구형 방식 : PackageManager에서 패키지마다 해당하는 UI class를 if문으로 찾아 리턴하는 방식
		if (ui_type == '') then
			local package_name = TablePackageBundle:getPackageNameWithPid(struct_product['product_id'])
			ui = PackageManager:getTargetUI(package_name, false)
		else
			-- UI_Package 가 아닌 별도의 파일을 쓰는지 체크
			local package_class = struct_product['package_class']

			-- UI_Package가 아닌 경우 파일 읽어옴
			if package_class and (package_class ~= '') then
				if (not _G[package_class]) then
					require(package_class)
				end

				package_class = _G[package_class]
			else
				package_class = nil
			end

			-- 그 외엔 전부 UI_Package
			if (not package_class) then
				package_class = UI_Package
			end

			local product_list

			if (ui_type == 'bundle') then
				product_list = self.m_structProductList
			else
				product_list = {struct_product}
			end

			ui = package_class(product_list,  false, self:getProductName())
		end

		if ui then
			if buy_callback and checkMemberInMetatable(ui, 'setBuyCB') then
				ui:setBuyCB(function()
					buy_callback()
				end)
			end
			
            if is_refresh_dependency and checkMemberInMetatable(ui, 'setRefreshDependency') then
                ui:setRefreshDependency()
            end
			
			parent_node:addChild(ui.root)
		end

		if (ui_type == '') or (ui_type == 'bundle') then
            break
        end
	end
end

----------------------------------------------------------------------
-- function getTargetUITest
----------------------------------------------------------------------
function StructProductGroup:getTargetUITest(parent_node, buy_callback)
	if (not self.m_structProductList) or table.isEmpty(self.m_structProductList) then
		return nil
	end

	for index, struct_product in pairs(self.m_structProductList) do
		local ui
		local ui_type = self:getType()

		-- 구형 방식 : PackageManager에서 패키지마다 해당하는 UI class를 if문으로 찾아 리턴하는 방식
		if (ui_type == '') then
			local package_name = TablePackageBundle:getPackageNameWithPid(struct_product['product_id'])
			ui = PackageManager:getTargetUI(package_name, false)
		else
			-- UI_Package 가 아닌 별도의 파일을 쓰는지 체크
			local package_class = struct_product['package_class']

			-- UI_Package가 아닌 경우 파일 읽어옴
			if package_class and (package_class ~= '') then
				if (not _G[package_class]) then
					require(package_class)
				end

				package_class = _G[package_class]
			else
				package_class = nil
			end

			-- 그 외엔 전부 UI_Package
			if (not package_class)  then
				package_class = UI_Package
			end

			local product_list

			if (ui_type == 'bundle') then
				product_list = self.m_structProductList
			else
				product_list = {struct_product}
			end

			ui = package_class(product_list,  false, self:getProductName())
		end

		if ui then
			if buy_callback and checkMemberInMetatable(ui, 'setBuyCB') then
				ui:setBuyCB(function()
					buy_callback()
				end)
			end
			
			return ui
		end
	end
end

----------------------------------------------------------------------
-- function getProductIdList
----------------------------------------------------------------------
function StructProductGroup:getProductList()
	return self.m_structProductList
end

----------------------------------------------------------------------
-- function isStraightPurchase
-- return boolean
----------------------------------------------------------------------
function StructProductGroup:isStraightPurchase()
	return (self.is_detail) and (self.is_detail ~= 0) and (self.is_detail ~= '')
end

----------------------------------------------------------------------
-- function isUsingDesc
-- brief 아이템 구성품 설명 
-- 		0: table_shop_cash에서 mail_content 사용
-- 		1: table_shop_cash에서 t_desc 사용
-- return boolean
----------------------------------------------------------------------
function StructProductGroup:isUsingDesc()
	return (self.use_desc) and (self.use_desc ~= 0) and (self.use_desc ~= '')
end

----------------------------------------------------------------------
-- function isBuyable
-- return boolean
----------------------------------------------------------------------
function StructProductGroup:isBuyable()
	if (not self.m_structProductList) or (#self.m_structProductList < 1) then return false end

	local lower_limit = self.buyable_from_lv and (self.buyable_from_lv ~= '') and self.buyable_from_lv or 1
	local upper_limit = self.buyable_to_lv and (self.buyable_to_lv ~= '') and self.buyable_to_lv or 999

	local user_level = g_userData:get('lv')

	if (user_level < lower_limit) or (user_level > upper_limit) then
		return false
	end

	local content_name = self.buyable_unlock_content or ''

	if (content_name ~= '') then
		if g_contentLockData:isContentLock(content_name) then
			return false
		end
	end

	return true
end


----------------------------------------------------------------------
-- function isSelectOnePackage
----------------------------------------------------------------------
function StructProductGroup:isSelectOnePackage()
	return self.select_one and (self.select_one ~= 0) and (self.select_one ~= '')
end
