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

        -- 일반 강화/룬 축복서
        m_enhanceTypeRadioBtn = 'UIC_RadioButton',

        -- 축복 강화 여부
        m_isBlessEnhance = 'boolean',

        --강화 창 여부
        m_isEnhance = 'boolean',
    })

UI_DragonRunesEnhance.ENHANCE = 'enhance' -- 특성 레벨업
UI_DragonRunesEnhance.GRIND = 'grind' -- 특성 스킬
UI_DragonRunesEnhance.GRIND_ABLE_LV = 12
UI_DragonRunesEnhance.GRIND_ABLE_GRADE = 6

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
    self.m_isEnhance = true --기본 강화
    
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
    self:refresh_enhance()

    self:showGrindPackagePopup()
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
    self:initButtonList()
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
        self.m_isEnhance = true
        self:setSeqEnhanceVisible(true)
        self:refresh_enhance()
    else
        -- 연마가 불가능한 룬이면 다시 강화탭으로 보냄
        local rune_obj = self.m_runeObject
        self.m_isEnhance = false

        local grade = rune_obj['grade']
        if (grade > UI_DragonRunesEnhance.GRIND_ABLE_GRADE) then
            self:setTab('enhance')
            UIManager:toastNotificationRed(Str('7등급 룬은 연마가 불가능합니다.'))
            return
        end

        
        local cur_lv = rune_obj['lv']
        if (cur_lv<UI_DragonRunesEnhance.GRIND_ABLE_LV) then
            self:setTab('enhance')
            UIManager:toastNotificationRed(Str('12강화 이상의 룬만 연마 할 수 있습니다.'))
            return
        end
        
        if (not self.m_runeGrindClass) then
            self.m_runeGrindClass = UI_DragonRunesGrind(self)
        else
            self.m_runeGrindClass:refresh_grind()
        end
        self:setSeqEnhanceVisible(false)
    end
end

-------------------------------------
-- function onFocus
-- @brief
-------------------------------------
function UI_DragonRunesEnhance:onFocus()
    local vars = self.vars
    self:refresh_enhance()

    if (self.m_runeGrindClass) then           
        self.m_runeGrindClass:refresh_grind()
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
    local cur_rune_bless_cnt = g_userData:get('rune_bless')

    -- 일반 강화/ 축복 강화 라디오 버튼
    local radio_button = UIC_RadioButton()
    radio_button:setChangeCB(function(option_type)   
        
        -- 일반/축복 강화 여부 저장
        self.m_isBlessEnhance = (option_type ~= 'normalOpt')
        self:setEnhancePriceLabel()
        
        -- 선택에 따른 주 옵션 수치 변화값 설정
        self:refresh_runeStat()

        -- 축복서일 경우, 연속강화 버튼리스트 숨김(못 누르게)&& 아이템 설명라벨 출력
        if (option_type ~= 'normalOpt') then
            self.m_enhanceBtnList:hide()
            vars['runeBlessOptDescLabel']:setVisible(true)
        else
            vars['runeBlessOptDescLabel']:setVisible(false)
        end
    end)

    do -- 일반/축복 강화 버튼 등록
	    local btn = vars['normalOptBtn']
        local sprite = vars['normalOptSprite']
	    radio_button:addButton('normalOpt', btn, sprite)

        local btn = vars['runeBlessOptBtn']
        local sprite = vars['runeBlessOptSprite']
	    radio_button:addButton('runeBlessOpt', btn, sprite)
    end

    -- 디폴트로 일반 강화 선택
    radio_button:setSelectedButton('normalOpt')  
    
    self.m_enhanceTypeRadioBtn = radio_button  

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

    -- 선택된 버튼 정보 저장
    local function sort_change_cb(filter_type)
        local seq_enhance_cnt = string.match(filter_type, '%d+') -- ex) enhance_cnt_9 에서 숫자 9를 추출
        self.m_enhanceOptionLv = tonumber(seq_enhance_cnt)
    end

    self.m_enhanceBtnList:setSortChangeCB(sort_change_cb)
    self.m_enhanceBtnList:setSelectSortType('enhance_cnt_0') -- enhance_cnt_0 : 반복 없음
    
    local function click_extend_btn()
        self.m_enhanceTypeRadioBtn:setSelectedButton('normalOpt')
    end
    self.m_enhanceBtnList:setExtendBtnCb(click_extend_btn)
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
-- function refresh_runeStat
-- @brief 룬 옵션 세팅
-------------------------------------
function UI_DragonRunesEnhance:refresh_runeStat()
    local vars = self.vars  
    local rune_obj = self.m_runeObject

    if (not self.m_optionLabel) then
        self.m_optionLabel = rune_obj:getOptionLabel()
        vars['runeDscNode']:addChild(self.m_optionLabel.root)
    end
    local target_level = (self.m_isBlessEnhance == true) and RUNE_LV_MAX or (rune_obj['lv'] + 1) 
    rune_obj:setOptionLabel(self.m_optionLabel, 'use', target_level) -- param : ui, label_format, target_level

    -- 다음 강화에 대한 설명 (옵션 추가  or 주옵션 크게 증가)
    local max_lv = RUNE_LV_MAX
    local curr_lv = rune_obj['lv']
    local target_lv = (self.m_isBlessEnhance == true) and RUNE_LV_MAX or (rune_obj['lv'] + 1) 

    -- 보조 옵션에 변화가 생길 가능성이 있다면
    vars['bonusEffectLabel']:setVisible(((target_lv ~= max_lv) and (target_lv % 3 == 0)) or ((target_lv == max_lv) and (curr_lv < 12)))
    if (vars['bonusEffectLabel']:isVisible()) then
        local duration = 1.8
        --local tint_action = cca.repeatTintToRuneOpt(duration, 255, 104, 32)
        local tint_action = cca.repeatFadeInOutRuneOpt(duration, 255, 104, 32)
        vars['bonusEffectLabel'].m_node:runAction(tint_action)
    end

    vars['maxLvEffectLabel']:setVisible((target_level == max_lv) and (curr_lv >= 12))
end

-------------------------------------
-- function refresh_enhance
-------------------------------------
function UI_DragonRunesEnhance:refresh_enhance()
    local vars = self.vars  
    local rune_obj = self.m_runeObject
    
    -- 룬 상태 갱신
    self:refresh_common(self)

    -- 룬 옵션 세팅
    self:refresh_runeStat()

    -- 바뀐 룬 옵션이 있을 경우 라벨 애니메이션 동작
    self:showChangeLabelEffect(self.m_changeOptionList)

    -- 다음 강화에 대한 설명 (옵션 추가  or 주옵션 크게 증가)
    local max_lv = RUNE_LV_MAX
    local curr_lv = rune_obj['lv']

    -- 소모 골드
    self:setEnhancePriceLabel()
    
    -- 할인 이벤트
    local only_value = true
    g_hotTimeData:setDiscountEventNode(HOTTIME_SALE_EVENT.RUNE_ENHANCE, vars, 'enhanceEventSprite', only_value)

    -- 연속 강화 버튼 리스트 중에서, 현재 레벨보다 작은 단계 버튼은 다 뺀다
    if (self.m_enhanceBtnList) then
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
    vars['enhanceOptionMenu']:setVisible(not is_max_lv)
    vars['enhanceBtnMenu']:setVisible(not is_max_lv)

    --강화창이고 만렙이 아닌 경우 반복 버튼 출력
    local isVisible_DifficultyBtn = (self.m_isEnhance and (not is_max_lv))
    vars['difficultyBtn']:setVisible(isVisible_DifficultyBtn)


    -- 룬 축복서 아이템 카드
    vars['runeBlessIconNode']:removeAllChildren()
    local cur_rune_bless_cnt = g_userData:get('rune_bless')
    local rune_bless_card = UI_ItemCard(704903, cur_rune_bless_cnt) -- 룬 축복서
    rune_bless_card:setRareCountText(cur_rune_bless_cnt) -- 0일 때 숫자 그대로 출력되도록 (기존에는 0이면 출력 안됨)
    rune_bless_card:setEnabledClickBtn(false)
    vars['runeBlessIconNode']:addChild(rune_bless_card.root)   
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
    -- 축복 강화
    if (self.m_isBlessEnhance) then
        if (not self:checkBlessCondition()) then
            return
        end

        local block_ui = UI_BlockPopup()

		local function cb_func(is_success)
            self:showUpgradeResult(is_success)
			block_ui:close()
		end
		
        self:request_bless(cb_func)
	    return

    -- 일회 강화
	elseif (self.m_enhanceOptionLv == 0) then
		local block_ui = UI_BlockPopup()

		local function cb_func(is_success)
            self:showUpgradeResult(is_success)
			block_ui:close()
		end
		
        self:request_enhance(cb_func)
		return

	-- 연속 강화
    else
        self:startSeqEnhance() 
    end
end

-------------------------------------
-- function startSeqEnhance
-------------------------------------
function UI_DragonRunesEnhance:startSeqEnhance()
    
    local click_cb = function()
        -- 블록 팝업 닫을 때 '중지' 함수 콜백
        self:click_stopBtn()
    end

    -- 연속 강화할 동안 버튼 클릭을 막음
    local block_ui = self:makeRuneEnhanceBlockPopup(click_cb)
    
    -- 연속 강화
	local function coroutine_function(dt)
		local vars = self.vars

		local co = CoroutineHelper()
		self.m_coroutineHelper = co

        -- 코루틴 도중에 라디오 버튼 클릭 방지
        self:isEnhanceRadioBtnEnabled(false)
		
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
            -- 라디오 버튼 클릭 가능
            self:isEnhanceRadioBtnEnabled(true)
            block_ui:close()
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
	
	-- 통신 시작
    local rune_obj = self.m_runeObject
    local owner_doid = rune_obj['owner_doid']
    local roid = rune_obj['roid']

    local function finish_cb(ret)
        self.m_runeObject = g_runesData:getRuneObject(roid)
        self:setChangeOptionList(rune_obj, self.m_runeObject)
        self:show_blessEffect(true, cb_func)
    end

    g_runesData:request_runeBless(owner_doid, roid, finish_cb)
end

-------------------------------------
-- function calcReqGoldForBless
-- @brief 현재 강화레벨 ~  MAX강화까지 소모되는 골드 모두 합산
-------------------------------------
function UI_DragonRunesEnhance:calcReqGoldForBless()
    local rune_obj = self.m_runeObject
    local cur_lv = rune_obj['lv']
    local cur_grade = rune_obj['grade']
    local sum_req_gold = 0

    for i = cur_lv, (RUNE_LV_MAX-1) do
        sum_req_gold = sum_req_gold + rune_obj:calcReqGoldForEnhance(i, cur_grade)
    end

    return math.floor(sum_req_gold * 2.5)
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
-- function isEnhanceRadioBtnEnabled
-------------------------------------
function UI_DragonRunesEnhance:isEnhanceRadioBtnEnabled(is_enabled)
    local vars = self.vars
    vars['normalOptBtn']:setEnabled(is_enabled)
    vars['runeBlessOptBtn']:setEnabled(is_enabled)
    vars['difficultyBtn']:setEnabled(is_enabled)
end

-------------------------------------
-- function checkBlessCondition
-------------------------------------
function UI_DragonRunesEnhance:checkBlessCondition()
    -- 골드와 축복서 충분히 있는지 확인
    local req_gold = self:calcReqGoldForBless()

    local req_rune_bless = self.m_runeObject:getRuneBlessReqItem()
    
    if (not ConfirmPrice_original('rune_bless', req_rune_bless)) then
        UIManager:toastNotificationRed(Str('{1}가 부족합니다.', Str('룬 축복서')))       
        return false
    end

    if (not ConfirmPrice('gold', req_gold)) then
        UIManager:toastNotificationRed(Str('{1}가 부족합니다.', Str('골드')))
        return false
    end

    return true
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

-------------------------------------
-- function show_blessEffect
-------------------------------------
function UI_DragonRunesEnhance:show_blessEffect(is_success, cb_func)
    local vars = self.vars

    local bless_visual = vars['runeBlessVisual']

    bless_visual:setVisible(true)

    local ani_name = (is_success) and 'success' or 'fail'
    bless_visual:changeAni('top_appear', false)
    bless_visual:setIgnoreLowEndMode(true)
    
    bless_visual:addAniHandler(function()
        bless_visual:setVisible(false)

		if (cb_func) then
			cb_func(is_success)
		end
    end)


    SoundMgr:playEffect('UI', 'ui_rune_success')   
end


-------------------------------------
-- function setBlessRadioBtnState
-- @brief 룬 축복서 갯수가 모자르다면 버튼을 죽인다
-------------------------------------
function UI_DragonRunesEnhance:setBlessRadioBtnState()
    local vars =  self.vars

    local cur_rune_bless_cnt = g_userData:get('rune_bless')
    if (cur_rune_bless_cnt < 1) then
        local kill_cb = function(t_button_data)
            vars['runeBlessOptNotSprite']:setVisible(true)
        end
        self.m_enhanceTypeRadioBtn:killBtn('runeBlessOpt', kill_cb)    
    end
end







-------------------------------------
-- function makeRuneEnhanceBlockPopup
-- @breif 연속 강화가 진행되는 동안 클릭을 막음
-------------------------------------
function UI_DragonRunesEnhance:makeRuneEnhanceBlockPopup(cb_func, is_grind)
    local block_ui = UI()
    block_ui:load('rune_enhance_block.ui')
    block_ui.m_uiName = 'UI_RuneEnhanceBlock'
    UIManager:open(block_ui, UIManager.POPUP, true)

    local function stop_callback()
        block_ui:close() 

        if cb_func then
            cb_func()
        end
    end

    -- 기존 강화탭과 동일한 중지 버튼, 블록 팝업을 닫음
    if is_grind then
        block_ui.vars['grindAutoStopBtn']:registerScriptTapHandler(stop_callback)
    else
        block_ui.vars['stopBtn']:registerScriptTapHandler(stop_callback)
    end

    g_currScene:pushBackKeyListener(block_ui, stop_callback, 'UI_RuneEnhanceBlock')

    return block_ui
end

-------------------------------------
-- function showGrindPackagePopup
-- @brief 주간 판매하는 룬 연마 패키지를 주마다 과금 유저에게 보여줘서 상품 구매를 유도
-------------------------------------
function UI_DragonRunesEnhance:showGrindPackagePopup()
	-- 1.룬 연마 패키지를 구매 가능한가
	do
		if (not UI_DragonRunesGrind.isBuyable()) then
			return 
		end
	end

	-- 2.누적 금액 50,000원 이상
	do
		local sum_money = UserStatusAnalyser.userStatus.sum_money
		if (sum_money < 50000) then
			return
		end
	end

    -- 3.레벨 50 이상
	do
        local lv = g_userData:get('lv')
        if (lv < 50) then
            return
        end
    end

    -- 4.쿨타임 7일 지났는지
    do
        local expired_time = g_settingData:getPromoteExpired('rune_grind_package')
        local cur_time = Timer:getServerTime()
        if (cur_time < expired_time) then
            return
        end

        -- 2019-07-30 룬 연마 상품 판매 촉진하는 팝업 쿨타임 7일
        local next_cool_time = cur_time + datetime.dayToSecond(7)
        -- 쿨 타임 만료시간 갱신
        g_settingData:setPromoteCoolTime('rune_grind_package', next_cool_time)
    end
    
	-- 룬 연마 팝업 보여줌
	local ui = UI_Package_Bundle('package_rune_grind', true) -- is_popup

    -- @UI_ACTION(룬 연마 풀팝업 scale 액션)
    ui:doActionReset()
    ui:doAction(nil, false)
end