local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonRunesEnhance
-------------------------------------
UI_DragonRunesEnhance = class(PARENT,{
        m_runeObject = 'StructRuneObject',
        m_changeOptionList = 'list',

		-- 연속 강화
		m_isContinuous = 'bool',
		m_coroutineHelper = 'CoroutinHelepr',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonRunesEnhance:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonRunesEnhance'
    self.m_bVisible = true
    self.m_titleStr = Str('룬 강화')
    self.m_bUseExitBtn = false
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesEnhance:init(rune_obj, attr)
    self.m_runeObject = rune_obj
    self.m_changeOptionList = {}

    local vars = self:load('dragon_rune_enhance.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonRunesEnhance')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

	-- initilize
	self.m_isContinuous = false

    self:initUI(attr)
    self:initButton()
    self:refresh()
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

	vars['checkSprite']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesEnhance:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
	vars['checkBtn']:registerScriptTapHandler(function() self:click_checkBtn() end)
	vars['stopBtn']:registerScriptTapHandler(function() self:click_stopBtn() end)
    vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesEnhance:refresh()
    local vars = self.vars

    local rune_obj = self.m_runeObject

    -- 룬 아이콘
    vars['runeNode']:removeAllChildren()
    local ui = UI_RuneCard(rune_obj)
    cca.uiReactionSlow(ui.root)
    vars['runeNode']:addChild(ui.root)

    -- 능력치 출력
    local for_enhance = true
    local option_label = vars['optionLabel']
    option_label:setString(rune_obj:makeRuneDescRichText(for_enhance))
    
    -- 변경된 옵션이 있다면 애니메이션 효과
    local change_list = self.m_changeOptionList
    for i, v in ipairs(change_list) do
        local node_list = option_label:findContentNodeWithkey(v)
        if (#node_list > 0) then
            for _i, _v in ipairs(node_list) do
                local find_node = _v
                -- 자연스러운 액션을 위해 앵커포인트 변경
                --폰트 스케일 변경 때문에 연출끝나면 앵커포인트 다시 변경
                local orgAnchor = find_node:getAnchorPoint()
                local function onFinish(node)
                    changeAnchorPointWithOutTransPos(node, orgAnchor)
                end
                changeAnchorPointWithOutTransPos(find_node, cc.p(0.5, 0.5))
                cca.stampShakeActionLabel(find_node, 1.5, 0.1, 0, 0)
                cca.reserveFunc(find_node, 0.1, onFinish)
            end
        end
    end

    -- 강화 성공시 옵션 추가되는 경우 
    local max_lv = RUNE_LV_MAX
    local curr_lv = rune_obj['lv']

    vars['bonusEffectLabel']:setVisible((curr_lv ~= max_lv - 1) and (curr_lv % 3 == 2))
    vars['maxLvEffectLabel']:setVisible((curr_lv == max_lv - 1))

    -- 소모 골드
    local req_gold = rune_obj:getRuneEnhanceReqGold()
    vars['enhancePriceLabel']:setString(comma_value(req_gold))
    cca.uiReactionSlow(vars['enhancePriceLabel'])

    -- 할인 이벤트
    local only_value = true
    g_hotTimeData:setDiscountEventNode(HOTTIME_SALE_EVENT.RUNE_ENHANCE, vars, 'enhanceEventSprite', only_value)

    local is_max_lv = rune_obj:isMaxRuneLv()
    vars['enhanceBtn']:setVisible(not is_max_lv)
	vars['checkNode']:setVisible(not is_max_lv)
end

-------------------------------------
-- function show_upgradeEffect
-- @param cb_func : 단일 강화시 block_ui를 제어하며 연속 강화시 CoroutineHelper를 종료시킨다
-------------------------------------
function UI_DragonRunesEnhance:show_upgradeEffect(is_success, cb_func)
    local vars = self.vars
    local top_visual = vars['enhanceTopVisual']
    local bottom_visual = vars['enhanceBottomVisual']

    top_visual:setVisible(true)
    bottom_visual:setVisible(true)

    local ani_name = (is_success) and 'success' or 'fail'
    top_visual:changeAni(ani_name..'_top', false)
    bottom_visual:changeAni(ani_name..'_bottom', false)

    top_visual:addAniHandler(function()
        top_visual:setVisible(false)
        bottom_visual:setVisible(false)

        local rune_obj = self.m_runeObject
        if (is_success) then
            self:refresh()
            UIManager:toastNotificationGreen(Str('{1}강화를 성공하였습니다.', rune_obj['lv']))
        else
			vars['enhanceBtn']:setVisible(true)
            UIManager:toastNotificationRed(Str('{1}강화를 실패하였습니다.', rune_obj['lv'] + 1))
        end

		if (cb_func) then
			cb_func()
		end
    end)

    if (is_success) then
        SoundMgr:playEffect('UI', 'ui_rune_success')
    else
        SoundMgr:playEffect('UI', 'ui_rune_fail')
    end
end

-------------------------------------
-- function checkChangeSubOption
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
-- function click_checkBtn
-------------------------------------
function UI_DragonRunesEnhance:click_checkBtn()
	self.m_isContinuous = not self.m_isContinuous
	self.vars['checkSprite']:setVisible(self.m_isContinuous)
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
	-- 일회 강화
	if (not self.m_isContinuous) then
		local block_ui = UI_BlockPopup()
		local function cb_func()
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
			self.m_coroutineHelper = nil
			vars['countNode']:setVisible(false)
			vars['stopBtn']:setVisible(false)
			-- 터치 블럭 해제
            UIManager:blockBackKey(false)
		end
		co:setCloseCB(close_cb)

        -- 터치 블럭
        UIManager:blockBackKey(true)

		-- 레벨업 비교용 레벨
		local curr_lv = self.m_runeObject:getLevel()
		
		-- UI 처리
		vars['countNode']:setVisible(true)
		vars['stopBtn']:setVisible(true)

		-- 연속 강화 루프
		local enhance_cnt = 10
        while (enhance_cnt > 0) do
            co:work()
			
			-- 레벨업 시 종료
			if (curr_lv ~= self.m_runeObject:getLevel()) then
				co.NEXT()
				break
			end

			vars['enhanceBtn']:setVisible(false)
			
			-- 강화 시도
            self:request_enhance(co.NEXT)	

			-- 회수 처리
			enhance_cnt = enhance_cnt - 1
			vars['countLabel']:setString(Str('{1}회 남음', enhance_cnt))

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
