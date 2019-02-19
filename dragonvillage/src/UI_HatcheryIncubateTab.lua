local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_HatcheryIncubateTab
-------------------------------------
UI_HatcheryIncubateTab = class(PARENT,{
        m_eggPicker = '',
        m_focus_id = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HatcheryIncubateTab:init(owner_ui, focus_id)
    local vars = self:load('hatchery_incubate.ui')
    self.m_focus_id = focus_id

	-- @ TUTORIAL : 1-1 end, 102
	local tutorial_key = TUTORIAL.FIRST_END
	local check_step = 102
	TutorialManager.getInstance():continueTutorial(tutorial_key, check_step, self)
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_HatcheryIncubateTab:onEnterTab(first)
    self.m_ownerUI:showNpc() -- NPC 등장

    if first then
		self:initUI()
        self:initButton()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_HatcheryIncubateTab:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HatcheryIncubateTab:initUI()
	local vars = self.vars
	local parent_node = vars['eggPickerNode']

	-- UIC_EggPicker 생성
	local egg_picker = UIC_EggPicker:create(parent_node)

	egg_picker.m_itemWidth = 250 -- 알의 가로 크기
	egg_picker.m_nearItemScale = 0.66
	self.m_eggPicker = egg_picker

	local function click_egg(t_item, idx)
		self:click_eggItem(t_item, idx)
	end
	egg_picker:setItemClickCB(click_egg)


	local function onChangeCurrEgg(t_item, idx)
		self:onChangeCurrEgg(t_item, idx)
	end
	egg_picker:setChangeCurrFocusIndexCB(onChangeCurrEgg)

	self:refreshEggList()

	-- @ Tutorial : 1-1 end 부화소 세팅
	if (TutorialManager.getInstance():isDoing()) then
		-- tutorial 에서 접근하기 위함
		self.m_ownerUI.vars['tutorialEggPicker'] = vars['eggPickerNode']
		self.m_ownerUI.vars['UIC_EggPicker'] = self.m_eggPicker
		self.m_eggPicker:focusEggByID(703027)

    --  @ focus_id
	elseif (self.m_focus_id) then
        local id = tonumber(self.m_focus_id)
        self.m_eggPicker:focusEggByID(id)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HatcheryIncubateTab:initButton()
    local vars = self.vars
    
    -- 알도감 (바로가기)
    vars['eggInfoBtn']:setVisible(false)
end

-------------------------------------
-- function click_eggItem
-------------------------------------
function UI_HatcheryIncubateTab:click_eggItem(t_item, idx)
    local t_data = t_item['data']
	
	-- 상점으로 보내주는 알
	if t_data['is_shop'] then
		local function close_cb()
			-- 리스트 갱신
			self:refreshEggList()
		end
		g_shopDataNew:openShopPopup('mileage', close_cb)
		return
	end
	
	-- 10개 꾸러미와 1개 구분하여 처리
	local function request_incubate(count)
		local egg_id = t_data['egg_id']
		local cnt = count or t_data['count']

		self:requestIncubate(egg_id, cnt)
	end
	local count = t_data['count']
	if (count) and (count > 1) then
		local ui = UI_EggPopup(t_data, request_incubate)
	else
		request_incubate()
	end
end

-------------------------------------
-- function requestIncubate
-------------------------------------
function UI_HatcheryIncubateTab:requestIncubate(egg_id, cnt, old_ui)
    -- 드래곤 최대치 보유가 넘었는지 체크
    local summon_cnt = cnt
    if (not g_dragonsData:checkDragonSummonMaximum(summon_cnt)) then
        return
    end

    local function finish_cb(ret)

        -- 이어서 뽑기를 했을 때 이전 결과 UI가 통신 후에 닫히도록 처리
        if (old_ui) then
            old_ui:setCloseCB(nil)
            old_ui:close()
        end

		local gacha_type = 'incubate'
        local l_dragon_list = ret['added_dragons']
        local l_slime_list = ret['added_slimes']
        local egg_res = TableItem:getEggRes(egg_id)
		local t_summon_data = {
			['count'] = cnt,
			['remain_cnt'] = g_eggsData:getEggCount(egg_id)
		}
        local ui = UI_GachaResult_Dragon(gacha_type, l_dragon_list, l_slime_list, egg_id, egg_res, t_summon_data)

        local function close_cb()
            self:sceneFadeInAction()
        end
        ui:setCloseCB(close_cb)

        -- 리스트 갱신
        self:refreshEggList()

        -- 알 포커스 이동
        local egg_picker = self.m_eggPicker
        if egg_picker.m_currFocusIndex then
            egg_picker:setFocus(egg_picker.m_currFocusIndex, 0.5)
        end

		-- 이어서 부화하기 설정
		if (cnt == 1) and (1 <= t_summon_data['remain_cnt']) then
			ui.vars['summonBtn']:registerScriptTapHandler(function()
				self:requestIncubate(egg_id, cnt, ui)
			end)
		end

        -- 하일라이트 노티 갱신을 위해 호출
        self.m_ownerUI:refresh_highlight()

		-- @ GOOGLE ACHIEVEMENT
        local t_data = {['clear_key'] = 'egg'}
        GoogleHelper.updateAchievement(t_data)
    end

    local function fail_cb()

    end

    g_eggsData:request_incubate(egg_id, cnt, finish_cb, fail_cb)
end

-------------------------------------
-- function onChangeCurrEgg
-------------------------------------
function UI_HatcheryIncubateTab:onChangeCurrEgg(t_item, idx)
    local vars = self.vars
    local t_data = t_item['data']

    if t_data['is_shop'] then
        vars['nameLabel']:setString(Str('상점'))
        vars['descLabel']:setString(Str('토파즈, 마일리지, 명예를 사용하여 알을 구매할 수 있습니다'))
        return
    end

    local egg_id = tonumber(t_data['egg_id'])
    local cnt = t_data['count']

    local table_item = TableItem()
    local name = table_item:getItemName(egg_id)

    if (1 < cnt) then
        name = name .. 'X' .. cnt
    end
    vars['nameLabel']:setString(name)

    local desc = table_item:getItemDesc(egg_id)
    vars['descLabel']:setString(desc)
end

-------------------------------------
-- function refreshEggList
-------------------------------------
function UI_HatcheryIncubateTab:refreshEggList()
    local egg_picker = self.m_eggPicker

    egg_picker:clearAllItems()
        
    local l_item_list = g_eggsData:getEggListForUI()
    local table_item = TableItem()
    
    -- Shop Egg 추가
    do
        local scale = 0.8
        local animator = MakeAnimator('res/item/egg/egg_shop/egg_shop.vrp')
        animator:setScale(scale)
        animator:changeAni('egg', true)

        local data = {['is_shop']=true}

        local ui = {}
        ui.root = animator.m_node

        egg_picker:addEgg(data, ui)
    end

    -- 알들 추가
    for i,v in ipairs(l_item_list) do
        local egg_id = tonumber(v['egg_id'])
        local _res = table_item:getValue(egg_id, 'full_type')
        if (v['count'] == 10) then
            _res = _res .. '_10'
        end
        local res = 'res/item/egg/' .. _res .. '/' .. _res .. '.vrp'

        local scale = 0.8
        local animator = MakeAnimator(res)
        animator:setScale(scale)
        animator:changeAni('egg')

        local data = v

        local ui = {}
        ui.root = animator.m_node

        if (not ui.root) then
            error('res : ' .. res)
        end
            
        egg_picker:addEgg(data, ui)
    end

    -- 2번째 아이템을 포커스 (1번째 아이템은 "상점")
    egg_picker:setFocus(2)
end
