local PARENT = Structure

-------------------------------------
-- class StructCapsuleBox
-------------------------------------
StructCapsuleBox = class(PARENT, {
		box_key = 'string',
		contents = 'table',
		curr = 'number',
		box_total = 'number',
		price = 'table',
        title = 'string',
    })

local THIS = StructCapsuleBox
-------------------------------------
-- function init
-------------------------------------
function StructCapsuleBox:init(data)
    if data then
        self:applyData(data)
    end
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructCapsuleBox:getClassName()
    return 'StructCapsuleBox'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructCapsuleBox:getThis()
    return THIS
end

-------------------------------------
-- function setBoxKey
-------------------------------------
function StructCapsuleBox:setBoxKey(box_key)
	self['box_key'] = box_key
end

-------------------------------------
-- function getBoxKey
-------------------------------------
function StructCapsuleBox:getBoxKey()
	return self['box_key']
end

-------------------------------------
-- function getCurrentTotal
-------------------------------------
function StructCapsuleBox:getCurrentTotal()
	return self['curr']
end

-------------------------------------
-- function isDone
-------------------------------------
function StructCapsuleBox:isDone()
	return (self['curr'] == 0)
end

-------------------------------------
-- function getTopRewardProb
-- @brief 좋은 보상이 나올 확률 계산
-------------------------------------
function StructCapsuleBox:getTopRewardProb()
	-- 모두 소진
	if (self:isDone()) then
		return '0.00%'
	end

	-- 현재 총 수량
	local curr_total = self:getCurrentTotal()

	-- 추출
	local top_count = 0
	local rank, count
	for _, struct_reward in pairs(self['contents']) do
		rank = struct_reward['rank']
		-- 규칙이 없어서... 나중에 플래그 던지도록 할듯
		if (rank <= 2) or (struct_reward['id'] == '20308') then
			count = struct_reward['count']
			top_count = top_count + count
		end
	end

	local prob = top_count / curr_total * 100

	return string.format('%.2f%%', prob)
end

-------------------------------------
-- function setPrice
-------------------------------------
function StructCapsuleBox:setPrice(price_str)
	local l_price_list = {}
	
	-- 여러가지 타입의 가격을 처리할수 있도록...
	for _, each_price in ipairs(plSplit(price_str, ',')) do
		local t_price = {}
		local l_split = plSplit(each_price, ';')
		t_price['type'] = l_split[1]
		t_price['value'] = l_split[2]
		table.insert(l_price_list, t_price)
	end

	self['price'] = l_price_list
end

-------------------------------------
-- function getPrice
-------------------------------------
function StructCapsuleBox:getPrice(idx)
	return self['price'][idx]
end

-------------------------------------
-- function getPriceList
-------------------------------------
function StructCapsuleBox:getPriceList()
	return self['price']
end

-------------------------------------
-- function setContents
-- @brief 상품 내역 저장
-------------------------------------
function StructCapsuleBox:setContents(t_content)
	if (not self['contents']) then
		self['contents'] = {}
	end

	for gift_id, item_str in pairs(t_content) do
		local struct_reward = StructCapsuleBoxReward()
		struct_reward:setGiftID(gift_id)
		struct_reward:setItem(item_str)

		self['contents'][gift_id] = struct_reward
	end
end

-------------------------------------
-- function setCapsuleTitle
-------------------------------------
function StructCapsuleBox:setCapsuleTitle(title_str)
    self['title'] = title_str
end

-------------------------------------
-- function getLegendCapsuleTitle
-------------------------------------
function StructCapsuleBox:getCapsuleTitle()
    local title_str = self['title']
    if (not title_str) then
        return ''
    end

    return Str('{1} 캡슐', Str(title_str))
end

-------------------------------------
-- function setTotal
-------------------------------------
function StructCapsuleBox:setTotal(t_total)
	local box_total = 0
	for gift_id, struct_reward in pairs(self['contents']) do
		local total = tonumber(t_total[gift_id])
		if (total) then
			struct_reward:setTotal(total)
			box_total = box_total + total
		end
	end

	self['box_total'] = box_total
end

-------------------------------------
-- function setContentCount
-- @brief 각 상품의 갯수 저장
-------------------------------------
function StructCapsuleBox:setContentCount(t_count)
	local curr_capsule = 0
	for gift_id, count in pairs(t_count) do
		local struct_reward = self['contents'][gift_id]
		if (struct_reward) then
			struct_reward:setCount(count)
		end
		curr_capsule = curr_capsule + count
	end

	self['curr'] = curr_capsule
end

-------------------------------------
-- function getContents
-------------------------------------
function StructCapsuleBox:getContents()
	local l_content = {}
	for _, content in pairs(self['contents']) do
		table.insert(l_content, content)
	end
	table.sort(l_content, function(a, b)
		local a_num = tonumber(a['id'])
		local b_num = tonumber(b['id'])
		return a_num < b_num
	end)

	return l_content
end

-------------------------------------
-- function getRankRewardList
-- @brief 특정 랭크의 상품만 리턴
-------------------------------------
function StructCapsuleBox:getRankRewardList(rank)
	local l_reward = {}
	for _, struct_reward in pairs(self['contents']) do
		if (struct_reward['rank'] == rank) then
			table.insert(l_reward, struct_reward)
		end
	end
	-- id 순서대로 정렬
	table.sort(l_reward, function(a, b)
		local a_num = tonumber(a['id'])
		local b_num = tonumber(b['id'])
		return a_num < b_num
	end)

	return l_reward
end

-------------------------------------
-- function getRateByRankTable
-- @brief 랭크별 비율 리스트 반환
-------------------------------------
function StructCapsuleBox:getRateByRankTable()
	local curr_total = self['box_total']

	-- 랭크별 갯수를 산출한다.
	local l_count = {}
	local rank, count
	for _, struct_reward in pairs(self['contents']) do
		rank = struct_reward['rank']
		count = struct_reward['total']

		if (l_count[rank]) then
			l_count[rank] = l_count[rank] + count
		else
			l_count[rank] = count
		end
	end

	-- 산출된 갯수로 비율을 구해준다.
	local l_rate = {}
	for rank, count in pairs(l_count) do
		l_rate[rank] = count/curr_total
	end

	return l_rate
end