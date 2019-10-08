local PARENT = class(UI, ITableViewCell:getCloneTable())
local T_DAY = {}
T_DAY['mon'] = '월요일'
T_DAY['tue'] = '화요일'
T_DAY['wed'] = '수요일'
T_DAY['thu'] = '목요일'
T_DAY['fri'] = '금요일'
T_DAY['sat'] = '토요일'
T_DAY['sun'] = '일요일'

-------------------------------------
-- class UI_NestDungeonSelectingListItem
-------------------------------------
UI_NestDungeonSelectingListItem = class(PARENT, {
        m_tData = 'nestDungeonInfo',
        m_remainTimeText = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_NestDungeonSelectingListItem:init(t_data)
    self.m_tData = t_data

    local vars = self:load('dungeon_day_item_01.ui')
    
    if (not t_data) then
        return
    end

    self:initUI(t_data)
    self:initButton()
    self:refresh()

    self.root:setDockPoint(cc.p(0, 0))
    self.root:setAnchorPoint(cc.p(0, 0))

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.root:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
        end
    end)
end
-------------------------------------
-- function initUI
-------------------------------------
function UI_NestDungeonSelectingListItem:initUI(t_data)
    local vars = self.vars

    -- 리스트 아이템 이미지 지정
    -- 이 아이템에서만 새로 만든 vrp를 사용 ex) ui/a2d/dungeon_dragon_02/dungeon_dragon_02.vrp
    local dungeon_key = 'dungeon_dragon'
    if (self:isDungeonTree()) then
        dungeon_key = 'dungeon_tree'
    end

    local res = 'res/ui/a2d/' .. dungeon_key .. '_02/' .. dungeon_key .. '_02.vrp'
    local ani = dungeon_key .. '_' .. t_data['ani']
    local animator = MakeAnimator(res)
    
    if (animator) then
        animator:changeAni(ani, true)
        vars['itemNode']:addChild(animator.m_node)
    end
    -- 시간 표기
    local dungeon_id = t_data['mode_id']
	local time_str = self:getTimeStr(dungeon_id)
	
	vars['timeLabel']:setString(time_str)
	vars['closeSprite']:setVisible(self.m_tData['is_open'] ~= 1)
	self:setDropItemCard(dungeon_id)
end

-------------------------------------
-- function setDropItemCard
-------------------------------------
function UI_NestDungeonSelectingListItem:setDropItemCard(dungeon_id)
	local vars = self.vars

	-- 드롭되는 아이템카드
	-- 모든 스테이지에서 드랍되는 아이템을 맵으로 저장(아이템 id가 키라서 중복은 걸러짐)
	local stage_list = g_nestDungeonData:getNestDungeon_stageListForUI(dungeon_id)
	local t_drop_item = {}
	for idx, data in ipairs(stage_list) do
		local drop_helper = DropHelper(data['stage'])
		local l_item_list = drop_helper:getDisplayItemList()
		for _, item_id in ipairs(l_item_list) do
			t_drop_item[item_id] = item_id
		end
	end
	
	-- 드롭되는 아이템 맵을 리스트로 변환
	local l_dragon_item = table.MapToList(t_drop_item)
	table.sort(l_dragon_item, function(a, b)
        return tonumber(a) < tonumber(b)
    end)

	-- 거목, 진화용 던전 구분
    local is_tree = self:isDungeonTree()

	--UI_ItemCard 생성
	for idx, item_id in ipairs(l_dragon_item) do
		local item_count = 0
		if (not is_tree) then
			item_count = g_userData:get('evolution_stones', tostring(item_id)) or 0
		else
			item_count = g_userData:getFruitCount(item_id) or 0
		end
		
		local ui_card = UI_ItemCard(item_id, item_count)
		ui_card:showZeroCount()
		vars['rewardNode' .. idx]:addChild(ui_card.root)
	end
end

-------------------------------------
-- function getTimeStr
-------------------------------------
function UI_NestDungeonSelectingListItem:getTimeStr(dungeon_id)
	local text, dirty = g_nestDungeonData:getNestDungeonRemainTimeText(dungeon_id)

	if (self.m_tData['is_open'] == 1) then
		text = '{@green}' .. text
	else
		text = '{@apricot}' .. text
	end
	return text
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_NestDungeonSelectingListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NestDungeonSelectingListItem:refresh()
    local vars = self.vars

    vars['dayLabel']:setString('')
    vars['titleLabel']:setString(Str(self.m_tData['t_name']))

    -- 요일 정보 출력
    self:refresh_dayLabel(self.m_tData['major_day'], self.m_tData['days'], self.m_tData['mode'])

    -- 보너스 정보 출력
    self:refresh_bonusInfo()
end

-------------------------------------
-- function refresh_dayLabel
-------------------------------------
function UI_NestDungeonSelectingListItem:refresh_dayLabel(major_day, days, mode)
    local vars = self.vars


    local l_days = pl.stringx.split(days, ',')

    -- 모든 요일이 다 포함되어 있을 경우 상시 오픈 던전으로 간주 (월~일)
    if (table.count(l_days) >=7) then
        vars['daySprite']:setVisible(false)
        vars['timeSprite']:setVisible(false)
        return
    end
    
    local t_days = {}
    t_days['mon'] = 1
    t_days['tue'] = 2
    t_days['wed'] = 3
    t_days['thu'] = 4
    t_days['fri'] = 5
    t_days['sat'] = 6
    t_days['sun'] = 7
    
    table.sort(l_days, function(a, b)
        return t_days[a] < t_days[b]
    end)

	local day_str = ''
    for _, day in ipairs(l_days) do
		day_str = day_str .. '\n' .. Str(T_DAY[day])
	end

	-- 던전 속성에 따라 라벨 색상 변경
	local attr = self.m_tData['ani']
	day_str = '{@' .. attr .. '}' .. day_str
    vars['dayLabel']:setString(day_str)
end

-------------------------------------
-- function refresh_bonusInfo
-- @brief "거목 던전"에서 해당하는 요일에 추가 보상을 준다는 것을 알려줌
-------------------------------------
function UI_NestDungeonSelectingListItem:refresh_bonusInfo()
    local vars = self.vars
	--[[
    -- 보너스가 없을 경우 리턴 
    local bonus_rate = self.m_tData['bonus_rate'] or 0
    if (bonus_rate <= 0) then
        return
    end

    -- 등록된 보너스 아이템이 없을 경우 리턴
    local l_bonus_value = seperate(self.m_tData['bonus_value'], ',')
    if (#l_bonus_value <= 0) then
        return
    end

    vars['bonusSprite']:setVisible(true)

    -- 첫 번째 아이템의 속성을 얻어옴
    local table_item = TABLE:get('item')
    local first_bonus_item = tonumber(l_bonus_value[1])
    local t_item = table_item[first_bonus_item]
    local attr = t_item['attr']

    -- 속성에 따라 문구 결정
    local attr_str = dragonAttributeName(attr)
    local str = Str('{1}의 열매 추가 제공 중!', attr_str)
    vars['bonusLabel']:setString(str)
	--]]
end

-------------------------------------
-- function update
-------------------------------------
function UI_NestDungeonSelectingListItem:update(dt)
    local dungeon_id = self.m_tData['mode_id']
    local text = self:getTimeStr(dungeon_id)

    -- 텍스트가 변경되었을 때에만 문자열 변경
    if (self.m_remainTimeText ~= text) then
        self.m_remainTimeText = text
        self.vars['timeLabel']:setString(text)
    end
end

-------------------------------------
-- function isDungeonTree
-- @brief "거목 던전" "진화용 던전" 구별
-- @brief 2 가지 던전에만 사용되는 class임
-------------------------------------
function UI_NestDungeonSelectingListItem:isDungeonTree()
	-- 거목, 진화용 던전 구분
	local t_dungeon_info = g_nestDungeonData:parseNestDungeonID(self.m_tData['mode_id'])
    local dungeon_mode = t_dungeon_info['dungeon_mode']
    local is_tree = false
	if (dungeon_mode == NEST_DUNGEON_TREE) then
		is_tree = true
	end

    return is_tree
end