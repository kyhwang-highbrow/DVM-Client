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
    self.m_ownerUI:hideNpc() -- NPC 등장

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

	egg_picker.m_itemWidth = 350 -- 알의 가로 크기
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
    local vars = self.m_ownerUI.vars
    
    -- 알도감 (바로가기)
    vars['eggInfoBtn']:registerScriptTapHandler(function() self:click_eggInfoBtn() end)
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
		g_shopData:openShopPopup('mileage', close_cb)
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
            local last_ui = UIManager:getLastUI()
            last_ui:sceneFadeInAction()
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

        local function close_cb()
            --신화 드래곤 팝업
            g_getDragonPackage:PopUp_GetDragonPackage()
        end
        ui:setCloseCB(close_cb)

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

    -- @brief using_bundle_label
    -- 알이 10개 이상일 경우 10개 묶음 이미지가 사용되지만, 해당 이미지가 없는 알들의 경우는 'x10'라벨로 대체한다.
    -- 이 경우에 해당 라벨을 사용할지 여부를 결정하는 변수
    local using_bundle_label = false

    -- 알들 추가
    for i,v in ipairs(l_item_list) do
        local egg_id = tonumber(v['egg_id'])
        local _res = table_item:getValue(egg_id, 'full_type')
        local res = string.format('res/item/egg/%s/%s.vrp', _res, _res)
        if (v['count'] == 10) then
            local _res_10 = string.format('res/item/egg/%s_10/%s_10.vrp', _res, _res)
            -- 10개 묶음 이미지 파일이 있다면 그 이미지 파일을 사용
            if (LuaBridge:isFileExist(_res_10)) then
                res = _res_10   
            else
                using_bundle_label = true
            end
        end

        local scale = 0.8
        local animator = MakeAnimator(res)
        animator:setScale(scale)
        animator:changeAni('egg')

        -- 10개 꾸러미 리소스 없을 경우 'x10' 라벨 붙임
        if (using_bundle_label) then
            local sprite = self.makeBundleLabelImage()
            animator.m_node:addChild(sprite)
            using_bundle_label = false
        end

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

-------------------------------------
-- function click_eggInfoBtn
-------------------------------------
function UI_HatcheryIncubateTab:click_eggInfoBtn()
    local ui = UI_BookEgg()
    -- 바로가기 기능
    ui.m_shortcutsFunc = function(focus_id)
        local id = tonumber(focus_id)
        self.m_eggPicker:focusEggByID(id)
    end
end

-------------------------------------
-- function makeBundleLabelImage
-------------------------------------
function UI_HatcheryIncubateTab.makeBundleLabelImage()
    local bundle_label_image = cc.Sprite:create('res/ui/icons/item/egg_bundle.png')
    bundle_label_image:setPosition(115, -145)
    return bundle_label_image
end
