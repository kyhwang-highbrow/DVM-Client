local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())
-------------------------------------
-- class UI_DragonRunesEnhance
-------------------------------------
UI_DragonRunesEnhance = class(PARENT,{
        m_runeObject = 'StructRuneObject',
        m_changeOptionList = 'list',
        m_optionLabel = 'ui',

		-- 연속 강화
		m_optionRadioBtn = 'UIC_RadioButton',
		m_enhanceOptionLv = 'num',
		m_coroutineHelper = 'CoroutinHelepr',

        -- 연속 강화 버튼 리스트
        m_enhanceBtnList = 'UICSortList',

        m_runeGrindClass = 'UI_DragonRuneGrind',

        -- 축복 강화 여부
        m_isBlessEnhance = 'boolean',
    })

UI_DragonRunesEnhance.ENHANCE = 'enhance' -- 특성 레벨업
UI_DragonRunesEnhance.GRIND = 'grind' -- 특성 스킬

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonRunesEnhance:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonRunesEnhance'
    self.m_bVisible = true
    self.m_titleStr = Str('룬 강화')
    self.m_subCurrency = 'grindstone'
    self.m_bUseExitBtn = false
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesEnhance:init(rune_obj, attr)
    self.m_runeObject = rune_obj
    self.m_changeOptionList = {}
    self.m_optionLabel = nil
    self.m_enhanceBtnList = nil
    
    local vars = self:load('rune_upgrade_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonRunesEnhance')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

	-- 룬 강화 레벨 초기화
	self.m_enhanceOptionLv = 0

    self:initUI(attr)
    self:initButton()
    self:initTab()
    self:initButtonList()
    self:refresh_enhance()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesEnhance:initUI(attr)
    local vars = self.vars

    -- 배경이 존재하는 경우에만
    if (attr) then
        local animator = ResHelper:getUIDragonBG(attr or 'earth', 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end
    
    local rune_obj = self.m_runeObject
    vars['runeNameLabel']:setString(rune_obj['name'])

	self:initOptionRadioBtn()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_DragonRunesEnhance:initTab()
    local vars = self.vars
    self:addTabAuto(UI_DragonRunesEnhance.ENHANCE, vars, vars['enhanceMenu'])
    self:addTabAuto(UI_DragonRunesEnhance.GRIND, vars, vars['grindMenu'])
    self:setTab(UI_DragonRunesEnhance.ENHANCE)

	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-- @brief
-------------------------------------
function UI_DragonRunesEnhance:onChangeTab(tab, first)
    local vars = self.vars

    if (tab == 'enhance') then
        self:refresh_enhance()
        self:setSeqEnhanceVisible(true)
    else
        if (first) then
            self.m_runeGrindClass = UI_DragonRunesGrind(self)
        else
            self.m_runeGrindClass:refresh_grind()
        end
        self:setSeqEnhanceVisible(false)
    end
end

-------------------------------------
-- function setSeqEnhanceVisible
-- @brief 연속 강화는 룬 강화 영역이지만 tab할 때 안바뀜, 탭할 때마다 바뀌는 부분 설정
-------------------------------------
function UI_DragonRunesEnhance:setSeqEnhanceVisible(is_visible)
    local vars = self.vars

    vars['difficultyBtn']:setVisible(is_visible)
    if (self.m_enhanceBtnList) then
        self.m_enhanceBtnList.m_node:setVisible(is_visible)
    end
 end

-------------------------------------
-- function initOptionRadioBtn
-- @brief 일반 강화/ 축복 강화 라디오 버튼 초기화
-------------------------------------
function UI_DragonRunesEnhance:initOptionRadioBtn()
	local vars = self.vars

    -- 일반 강화/ 축복 강화 라디오 버튼
    local radio_button = UIC_RadioButton()
    radio_button:setChangeCB(function(option_type)   
        self.m_isBlessEnhance = (option_type ~= 'normalOpt')
        self:setEnhancePriceLabel()
    end)

	local btn = vars['normalOptBtn']
    local sprite = vars['normalOptSprite']
	radio_button:addButton('normalOpt', btn, sprite)

    local btn = vars['runeBlessOptBtn']
    local sprite = vars['runeBlessOptSprite']
	radio_button:addButton('runeBlessOpt', btn, sprite)
    
    radio_button:setSelectedButton('normalOpt')

    --[[
    -- 강화 radio button 선언
    local radio_button = UIC_RadioButton()
	radio_button:setChangeCB(function(option_type)
        self.m_enhanceOptionLv = option_type * 3
    end)
	self.m_optionRadioBtn = radio_button

    -- 버튼 등록
	-- local btn, sprite = nil, nil
	for idx = 0, 5 do
		local btn = vars['enhanceOptionBtn' .. idx]
        local sprite = vars['enhanceOptionSprite' .. idx]
		if (idx ~= 0) then
			local label = vars['enhanceOptionLabel' .. idx]
			label:setString(Str(label:getString(), idx * 3))
		end
		radio_button:addButton(idx, btn, sprite)
	end
    -- default : 첫 번째 버튼 선택
	radio_button:setSelectedButton(0)
    --]]
end

-------------------------------------
-- function initButtonList
-- @brief 연속 강화 버튼 리스트
-------------------------------------
function UI_DragonRunesEnhance:initButtonList()
	local vars = self.vars
    
    self.m_enhanceBtnList = MakeUICSortList_RuneEnhance(vars['difficultyBtn'], vars['difficultyLabel'], UIC_SORT_LIST_BOT_TO_TOP)

    -- 버튼을 통해 필터 타입이 변경되었을 경우
    local function sort_change_cb(filter_type)
        local seq_enhance_cnt = string.match(filter_type, '%d+') -- ex) enhance_cnt_9
        self.m_enhanceOptionLv = tonumber(seq_enhance_cnt)
    end

    self.m_enhanceBtnList:setSortChangeCB(sort_change_cb)
    self.m_enhanceBtnList:setSelectSortType('enhance_cnt_0')
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesEnhance:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
	vars['stopBtn']:registerScriptTapHandler(function() self:click_stopBtn() end)
    vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
end

-------------------------------------
-- function refresh_enhance
-------------------------------------
function UI_DragonRunesEnhance:refresh_enhance()
    local vars = self.vars  
    local rune_obj = self.m_runeObject
    
    self:refresh_common(self)

    -- 룬 옵션 세팅
    if (not self.m_optionLabel) then
        self.m_optionLabel = rune_obj:getOptionLabel()
        vars['runeInfo']:addChild(self.m_optionLabel.root)
    end
    rune_obj:setOptionLabel(self.m_optionLabel, 'use', true) -- param : ui, label_format, show_change

    -- 바뀐 룬 옵션이 있을 경우 라벨 애니메이션 동작
    self:showChangeLabelEffect(self.m_changeOptionList)

    -- 강화 성공 시 옵션 추가되는 경우 
    local max_lv = RUNE_LV_MAX
    local curr_lv = rune_obj['lv']

    vars['bonusEffectLabel']:setVisible((curr_lv ~= max_lv - 1) and (curr_lv % 3 == 2))
    vars['maxLvEffectLabel']:setVisible((curr_lv == max_lv - 1))

    -- 소모 골드
    self:setEnhancePriceLabel()
    

    -- 할인 이벤트
    local only_value = true
    g_hotTimeData:setDiscountEventNode(HOTTIME_SALE_EVENT.RUNE_ENHANCE, vars, 'enhanceEventSprite', only_value)

    if (self.m_enhanceBtnList) then
        -- 현재 레벨보다 작은 단계 버튼은 다 뺀다
        for i = 1, 5 do
            if ((i * 3) <= curr_lv)  then
                self.m_enhanceBtnList:subFromSortList('enhance_cnt_' .. (i * 3))
            end
        end
    end

    --[[
	-- 연속 강화 옵션 처리
	for idx = 1, 5 do
		if (curr_lv >= idx * 3) then
			self.m_optionRadioBtn:disable(idx)
		end
	end
    --]]

	-- 강화 만렙 처리
    local is_max_lv = rune_obj:isMaxRuneLv()
    vars['enhanceBtn']:setVisible(not is_max_lv)
	vars['enhanceOptionNode']:setVisible(false)
    vars['difficultyBtn']:setVisible(not is_max_lv)
    vars['enhanceOptionMenu']:setVisible(not is_max_lv)
    vars['enhanceBtnMenu']:setVisible(not is_max_lv)

end



-------------------------------------
-- function showUpgradeResult
-------------------------------------
function UI_DragonRunesEnhance:showUpgradeResult(is_success)
    local vars = self.vars
    local rune_obj = self.m_runeObject
    
   if (is_success) then
        self:refresh_enhance()
        UIManager:toastNotificationGreen(Str('{1}강화를 성공하였습니다.', rune_obj['lv']))
    else
		vars['enhanceBtn']:setVisible(true)
        UIManager:toastNotificationRed(Str('{1}강화를 실패하였습니다.', rune_obj['lv'] + 1))
    end
end

-------------------------------------
-- function setChangeOptionList
-------------------------------------
function UI_DragonRunesEnhance:setChangeOptionList(old_data, new_data)
    self.m_changeOptionList = {}
    
    local function compare_func(key)
        if (old_data[key] ~= new_data[key]) then
            table.insert(self.m_changeOptionList, key)
        end
    end

    -- 주 옵션
    compare_func('mopt')
    
    -- 유니크
    compare_func('uopt')

    -- 보조 옵션
    local sopt_cnt = 4
    for i = 1, sopt_cnt do
        local key = 'sopt_'..i
        compare_func(key)
    end
end

-------------------------------------
-- function click_stopBtn
-------------------------------------
function UI_DragonRunesEnhance:click_stopBtn()
	if (self.m_coroutineHelper) then
		self.m_coroutineHelper.ESCAPE()
	end
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_DragonRunesEnhance:click_enhanceBtn()

    if (self.m_isBlessEnhance) then
        local block_ui = UI_BlockPopup()

		local function cb_func(is_success)
            self:showUpgradeResult(is_success)
			block_ui:close()
		end
		
        self:request_bless(cb_func)
	
    -- 일회 강화
	elseif (self.m_enhanceOptionLv == 0) then
		local block_ui = UI_BlockPopup()

		local function cb_func(is_success)
            self:showUpgradeResult(is_success)
			block_ui:close()
		end
		
        self:request_enhance(cb_func)
		return
	end

	-- 연속 강화
	local function coroutine_function(dt)
		local vars = self.vars

		local co = CoroutineHelper()
		self.m_coroutineHelper = co

		-- 코루틴 종료 콜백
		local function close_cb()
			--self.m_optionRadioBtn:setSelectedButton(0)
			self.m_coroutineHelper = nil
			vars['countNode']:setVisible(false)
			vars['stopBtn']:setVisible(false)
			-- 터치 블럭 해제
            UIManager:blockBackKey(false)

            -- 연속 강화 끝나면 반복 없음 으로 초기화
            if (self.m_enhanceBtnList) then
                self.m_enhanceBtnList:setSelectSortType('enhance_cnt_0')
            end
		end
		co:setCloseCB(close_cb)

        -- 터치 블럭
        UIManager:blockBackKey(true)

		-- UI 처리
		vars['countNode']:setVisible(true)
		vars['stopBtn']:setVisible(true)
		vars['enhanceBtn']:setVisible(false)

		-- 연속 강화 루프
		local enhance_cnt = 0
        while (self.m_runeObject:getLevel() < self.m_enhanceOptionLv) do -- 연속 강화 옵션 목표 레벨 달성 시 종료
            co:work()
			local cb_func = function(is_success)
                self:showUpgradeResult(is_success)
                co.NEXT()       
            end
			-- 강화 시도
            self:request_enhance(cb_func)	

			-- 강화 횟수 증가
			enhance_cnt = enhance_cnt + 1
			vars['countLabel']:setString(Str('{1}회 강화 중', enhance_cnt))
            if co:waitWork() then return end
        end

		-- 코루틴 종료
        co:close()
        
	end

	Coroutine(coroutine_function, 'Rune Enhancing Continuously')
end

-------------------------------------
-- function request_enhance
-- @param cb_func : block ui 또는 CoroutinHelper 제어용
-------------------------------------
function UI_DragonRunesEnhance:request_enhance(cb_func)
    -- 골드가 충분히 있는지 확인
    local req_gold = self.m_runeObject:getRuneEnhanceReqGold()
    if (not ConfirmPrice('gold', req_gold)) then

		-- 연속 강화 인 경우
		if (self.m_coroutineHelper) then
			self.m_coroutineHelper:close()
			self.vars['enhanceBtn']:setVisible(true)
		-- 단일 강화
		elseif (cb_func) then
			cb_func()
		end

        return false
    end
	
	-- 통신 시작
    local rune_obj = self.m_runeObject
    local owner_doid = rune_obj['owner_doid']
    local roid = rune_obj['roid']

    local function finish_cb(ret)
        local success = ret['lvup_success']
        if (success) then
            self.m_runeObject = g_runesData:getRuneObject(roid)
            self:setChangeOptionList(rune_obj, self.m_runeObject)
        end
        self:show_upgradeEffect(success, cb_func)
    end

    g_runesData:request_runeLevelup(owner_doid, roid, finish_cb)
end

-------------------------------------
-- function request_bless
-- @param cb_func : block ui 또는 CoroutinHelper 제어용
-------------------------------------
function UI_DragonRunesEnhance:request_bless(cb_func)
    -- 골드가 충분히 있는지 확인
    local req_gold = self:calcReqGoldForBless()

    local req_rune_bless = self.m_runeObject:getRuneBlessReqItem()
    local cur_rune_bless_cnt = g_userData:get('rune_bless')
    
    if (not ConfirmPrice('gold', req_gold) or (cur_rune_bless_cnt < req_rune_bless)) then		
	    cb_func()
        return false
    end
	
	-- 통신 시작
    local rune_obj = self.m_runeObject
    local owner_doid = rune_obj['owner_doid']
    local roid = rune_obj['roid']

    local function finish_cb(ret)
        self.m_runeObject = g_runesData:getRuneObject(roid)
        self:setChangeOptionList(rune_obj, self.m_runeObject)
        self:show_upgradeEffect(true, cb_func)
    end

    g_runesData:request_runeBless(owner_doid, roid, finish_cb)
end

-------------------------------------
-- function getRuneObject
-------------------------------------
function UI_DragonRunesEnhance:calcReqGoldForBless()
    local rune_obj = self.m_runeObject
    local cur_lv = rune_obj['lv']
    local cur_grade = rune_obj['grade']
    local sum_req_gold = 0

    for i = cur_lv, (RUNE_LV_MAX-1) do
        sum_req_gold = sum_req_gold + rune_obj:calcReqGoldForEnhance(i, cur_grade)
    end

    return sum_req_gold
end

-------------------------------------
-- function getRuneObject
-------------------------------------
function UI_DragonRunesEnhance:getRuneObject()
    return self.m_runeObject
end

-------------------------------------
-- function setRuneObject
-------------------------------------
function UI_DragonRunesEnhance:setRuneObject(rune_obj)
    self.m_runeObject = rune_obj
end

-------------------------------------
-- function setEnhancePriceLabel
-------------------------------------
function UI_DragonRunesEnhance:setEnhancePriceLabel()
    local vars = self.vars
    local rune_obj = self.m_runeObject
    local enhance_type

    local req_gold
    if (self.m_isBlessEnhance) then
        req_gold = self:calcReqGoldForBless()
        enhance_type = Str('축복 강화')
    else
        req_gold = rune_obj:getRuneEnhanceReqGold()
        enhance_type = Str('일반 강화')
    end
       
    vars['enhancePriceLabel']:setString(comma_value(req_gold))
    cca.uiReactionSlow(vars['enhancePriceLabel'])

    vars['enhanceTypeLabel']:setString(enhance_type)
end













-------------------------------------
-- @brief UI_DragonRunesGrind와 함께 사용하는 함수들
-------------------------------------

-------------------------------------
-- function refresh_common
-------------------------------------
function UI_DragonRunesEnhance:refresh_common()
    local vars = self.vars

    local rune_obj = self.m_runeObject

    -- 룬 아이템 카드 세팅
    vars['runeNode']:removeAllChildren()
    local ui = UI_RuneCard(rune_obj)
    cca.uiReactionSlow(ui.root)
    vars['runeNode']:addChild(ui.root)

end

-------------------------------------
-- function showChangeLabelEffect 
-- @brief 변경된 옵션 라벨에 애니메이션 효과
-------------------------------------
function UI_DragonRunesEnhance:showChangeLabelEffect(change_list)
    local vars = self.m_optionLabel.vars

    -- 변경된 옵션이 있다면 애니메이션 효과
    for i, v in ipairs(change_list) do
        local option_label_str = string.format('%s_useLabel', v) -- label 형식: ex) sopt_useLabel
       
        if (vars[option_label_str]) then
            self:showLabelEffect(vars[option_label_str])
        end
    end
end

-------------------------------------
-- function showLabelEffect 
-- @brief 라벨 애니메이션 효과(빙글 도는)
-------------------------------------
function UI_DragonRunesEnhance:showLabelEffect(label)
    if (not label) then
        return
    end
    
    local find_node = label
    -- 자연스러운 액션을 위해 앵커포인트 변경
    -- 폰트 스케일 변경 때문에 연출끝나면 앵커포인트 다시 변경
    local orgAnchor = find_node:getAnchorPoint()
    local function onFinish(node)
        changeAnchorPointWithOutTransPos(node, orgAnchor)
    end
    changeAnchorPointWithOutTransPos(find_node, cc.p(0.5, 0.5))
    cca.stampShakeActionLabel(find_node, 1.5, 0.1, 0, 0)
    cca.reserveFunc(find_node, 0.1, onFinish)

end

-------------------------------------
-- function show_upgradeEffect
-- @param cb_func : 단일 강화시 block_ui를 제어하며 연속 강화시 CoroutineHelper를 종료시킨다
-------------------------------------
function UI_DragonRunesEnhance:show_upgradeEffect(is_success, cb_func, is_grind)
    local vars = self.vars

    local top_visual = vars['enhanceTopVisual']
    local bottom_visual = vars['enhanceBottomVisual']

    top_visual:setVisible(true)
    bottom_visual:setVisible(true)

    local ani_name = (is_success) and 'success' or 'fail'
    top_visual:changeAni(ani_name..'_top', false)
    bottom_visual:changeAni(ani_name..'_bottom', false)
    
    if (is_grind) then
        top_visual:changeAni('grind_1', false)
        bottom_visual:setVisible(false)
    end
    
    top_visual:addAniHandler(function()
        top_visual:setVisible(false)
        bottom_visual:setVisible(false)

		if (cb_func) then
			cb_func(is_success)
		end
    end)

    if (is_success) then
        SoundMgr:playEffect('UI', 'ui_rune_success')
    else
        SoundMgr:playEffect('UI', 'ui_rune_fail')
    end
end