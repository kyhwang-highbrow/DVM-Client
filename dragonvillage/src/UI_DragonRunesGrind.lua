
-------------------------------------
-- class UI_DragonRunesGrind
-------------------------------------
UI_DragonRunesGrind = class({     
        m_optionGrindRadioBtn = 'UIC_RadioButton',   -- 연마할 옵션 선택하는 라디오 버튼
        m_seletedGrindOption = 'option_type',        -- 연마하기로 결정된 옵션 (최초에만 라디오 버튼으로 선택, 한 번 연마한 후에는 서버에서 저장된 값 사용)
        m_optionLabel = 'ui',

        -- 연마 보조 아이템 : 옵션 유지권, MAX 확정권
        m_grindItemRadioBtn = 'UIC_RadioButton',   -- 연마 보조 아이템 선택하는 라디오 버튼
        m_selectOptionItem = 'item_name_str',       -- 라디오 버튼으로 선택한 보조 아이템 이름
        
        m_runeEnhanceClass = 'UI_DragonRuneEnhance',
    })


GRIND_ITEM_RADIO_LIST = { none_select = 'notSelect', max_fixed_ticket = 'maxFixed', opt_keep_ticket = 'optKeep'} -- UI의 lua_name = '아이템 명',
local GRIND_ITEM_ID = 704900

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesGrind:init(enhance_class)
    self.m_runeEnhanceClass = enhance_class
    self.m_optionLabel = nil

    self:initUI()
    self:initButton()
    self:initOptionRadioBtn()
    self:refresh_grind()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesGrind:initUI()
    local enhance_class = self.m_runeEnhanceClass
	local vars = enhance_class.vars

    -- 룬 연마석 아이콘 추가
    local grindstone_card = UI_ItemCard(GRIND_ITEM_ID, 0)
    grindstone_card:setEnabledClickBtn(false)
    grindstone_card.root:setScale(0.8)
	vars['grindStoneNode']:addChild(grindstone_card.root)
end

-------------------------------------
-- function setPackageGora
-- @brief 연마 옵션라벨 버튼 초기화
-------------------------------------
function UI_DragonRunesGrind:setPackageGora()
    local is_package_buyable = false
    local enhance_class = self.m_runeEnhanceClass
	local vars = enhance_class.vars

    -- 연마석이 0개일때만 노출
    local grind_stone_cnt = g_userData:get('grindstone') or 0
    if (grind_stone_cnt > 0) then
        vars['buyBtn']:setVisible(false)
        return
    end

    -- product_id 하드코딩 : 룬 연마 패키지(옵션 유지권), 룬 연마 패키지(MAX 확정권)
    -- 둘 중 하나라도 판매중이면 패키지 팝업을 열어줌
	local l_pid = {110131, 110132}
    for i, pid in ipairs(l_pid) do
	    local struct_product = g_shopDataNew:getProduct('package', pid)
        if (struct_product) then
            if (struct_product:checkMaxBuyCount()) then
                is_package_buyable = true
                break
            end
        end
    end

    vars['buyBtn']:setVisible(is_package_buyable)
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_DragonRunesGrind:click_buyBtn()
	local ui = UI_Package_Bundle('package_rune_grind', true) -- is_popup

	-- @mskim 익명 함수를 사용하여 가독성을 높이는 경우라고 생각..!
	-- 구매 후 간이 우편함 출력
	-- 간이 우편함 닫을 때 패키지UI 닫고 룬UI 갱신
	ui:setBuyCB(function() 
		UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.ITEM_GOOD, function()
			self:refresh_grind()
            ui:close()		
		end)
	end)
end

-------------------------------------
-- function initOptionRadioBtn
-- @brief 연마 옵션라벨 버튼 초기화
-------------------------------------
function UI_DragonRunesGrind:initOptionRadioBtn()
    local enhance_class = self.m_runeEnhanceClass
	local vars = enhance_class.vars

    -- 연마할 옵션 radio button 선언
    local rune_obj = enhance_class:getRuneObject()
    local grind_radio_button = UIC_RadioButton()

    -- 라디오 버튼 변경 콜백 함수 셋팅
	grind_radio_button:setChangeCB(function(option_type)
        self:refresh_grindOptionRadioBtn()
        
        -- 선택한 옵션 저장
        self.m_seletedGrindOption = option_type
        local rune_obj = enhance_class:getRuneObject()
        
        --선택한 옵션 색상만 노란색으로 변경
        for i, opt_type in ipairs(StructRuneObject.OPTION_LIST) do
            if (i > 2) then
                local option_label = string.format('%s_label', opt_type)    -- ex) sopt_1_label
                local opt_desc = ''
                if (self.m_seletedGrindOption == opt_type) then
                    opt_desc = self:makeRuneDesc_grind(opt_type, '{@r_opt_selected}')
                else
                    opt_desc = self:makeRuneDesc_grind(opt_type, nil)
                end

                vars[option_label]:setString(opt_desc)
            end
        end
        
        -- 연마 정보 버튼 위치 세팅
        self:setGrindInfo()
    end)
	self.m_optionGrindRadioBtn = grind_radio_button

    -- 룬 연마 옵션 정보 버튼 활성화
    vars['runeGrindBtn']:setVisible(true)

    -- 연마 아이템(Max확정권, 옵션 유지권) radio button 선언
    local grind_item_radio_button = UIC_RadioButton()
	grind_item_radio_button:setChangeCB(function(option_item_type)
        self.m_selectOptionItem = option_item_type
        
        -- 아이템 선택할 때마다 해당 아이템의 설명이 나옴       
        local is_optKepp = (option_item_type == 'opt_keep_ticket')
        local is_maxFixed = (option_item_type == 'max_fixed_ticket')
        vars['optKeepDescLabel']:setVisible(is_optKepp)
        vars['maxFixedDescLabel']:setVisible(is_maxFixed)
        vars['grindNotiLabel2']:setVisible((is_optKepp or is_maxFixed))
        vars['grindNotiLabel']:setVisible(not (is_optKepp or is_maxFixed))
        self:refresh_grindItemRadioBtn()
    end)

    self.m_grindItemRadioBtn = grind_item_radio_button

    -- 연마 아이템 라디오 버튼 등록
     for item_name, ui_name in pairs(GRIND_ITEM_RADIO_LIST) do
        local option_item_btn = string.format('%sBtn', ui_name)
        local option_item_sprite = string.format('%sSprite', ui_name)
        local option_item_node = string.format('%sNode', ui_name)
        local option_item_label = string.format('%sNameLabel', ui_name)
        
        if (not grind_item_radio_button:existButton(opt_type)) then -- 없는 버튼이면 등록
            grind_item_radio_button:addButton(item_name, vars[option_item_btn], vars[option_item_sprite])
        end
    end
    
    -- 연마 보조 아이템 디폴트 값 설정
    grind_item_radio_button:setSelectedButton('none_select')

end


-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesGrind:initButton()
    local vars = self.m_runeEnhanceClass.vars
    -- 룬 연마
    vars['grindBtn']:registerScriptTapHandler(function() self:click_grind() end)
    vars['grindItemBtn']:registerScriptTapHandler(function() self:click_grindItemBtn() end)
    vars['runeGrindBtn']:registerScriptTapHandler(function() self:click_grindinfo() end)

    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
	cca.pickMePickMe(vars['buyBtn'], 10)
end

-------------------------------------
-- function refresh_grind
-------------------------------------
function UI_DragonRunesGrind:refresh_grind()
    local enhance_class = self.m_runeEnhanceClass
	local vars = enhance_class.vars
    local rune_obj = enhance_class:getRuneObject()
    local rune_grinded_opt = rune_obj:getGrindedOption()

    -- 룬 카드 갱신
    enhance_class:refresh_common(self)
    
    -- 룬 오브젝트에 grindoption정보가 있다면 그 옵션만 선택되어 있도록 고정, 없다면 sopt_1로 고정
    local grinded_option = rune_obj:getGrindedOption()
    if (grinded_option) then
        self.m_seletedGrindOption = grinded_option
    else
        self.m_seletedGrindOption = 'sopt_1'       
    end
    local select_grind_opt = self.m_seletedGrindOption


    -- 연마할 라벨에 애니메이션 효과
    local changed_label_str = string.format('%s_label', select_grind_opt)
    local changed_label = vars[changed_label_str]
    UI_DragonRunesEnhance:showLabelEffect(changed_label)


    -- 라디오 버튼 정보 갱신
    local grind_radio_button = self.m_optionGrindRadioBtn
    self:refresh_grindOptionRadioBtn()

    -- 라디오 버튼 디폴트 값 설정
    if (rune_obj:existOptionType(select_grind_opt)) then
        grind_radio_button:setSelectedButton(select_grind_opt)
    end

    self:refresh_grindItemRadioBtn()
    
    -- 룬 연마석 정보 갱신
    self:refresh_grindstoneCount()

    -- 필요한 골드 정보 갱신
    local req_gold = rune_obj:getRuneGrindReqGold()
    vars['grindPriceLabel']:setString(req_gold)

    -- 룬 연마 패키지 홍보 고라 갱신
    self:setPackageGora()
end

-------------------------------------
-- function showUpgradeResult
-------------------------------------
function UI_DragonRunesGrind:showUpgradeResult()  
    local enhance_class = self.m_runeEnhanceClass
    local vars = enhance_class.vars
    
    self:refresh_grind()
    UIManager:toastNotificationGreen(Str('연마를 완료했습니다.'))

    -- 라벨을 스치는 애니메이션
    local grind_label_visual = vars['grindEffectVisual']
    local changed_label_str = string.format('%s_btn', self.m_seletedGrindOption)
    
    -- 연마할 옵션 위치에 애니메이션 셋팅
    local opt_pos_x, opt_pos_y = vars[changed_label_str]:getPosition()
    grind_label_visual:setPositionY(opt_pos_y)
    
    grind_label_visual:setVisible(true)
    grind_label_visual:changeAni('grind_2')
    grind_label_visual:addAniHandler(function()
        grind_label_visual:setVisible(false)
    end)
end

-------------------------------------
-- function refresh_grindItemRadioBtn
-------------------------------------
function UI_DragonRunesGrind:refresh_grindItemRadioBtn()
    local enhance_class = self.m_runeEnhanceClass
    local vars = enhance_class.vars

    -- 연마 보조아이템 라디오 버튼 갱신
    local grind_item_radio_button = self.m_grindItemRadioBtn
 
    for item_name, ui_name in pairs(GRIND_ITEM_RADIO_LIST) do
        local option_item_btn = string.format('%sBtn', ui_name)
        local option_item_sprite = string.format('%sSprite', ui_name)
        local option_item_node = string.format('%sNode', ui_name)
        local option_item_not_sprite = string.format('%sNotSprite', ui_name)
           
        -- max 확정권, 옵션 유지권은 보유 갯수 갱신
        if (item_name ~= 'none_select') then
            local option_item_id = TableItem:getItemIDFromItemType(item_name)
            local option_item_cnt = g_userData:get(item_name)
            local option_item_card = UI_ItemCard(option_item_id, option_item_cnt)
            option_item_card:setEnabledClickBtn(false)
            vars[option_item_node]:removeAllChildren()
            vars[option_item_node]:addChild(option_item_card.root)

            if (option_item_cnt == 0) then
                local cb_func = function(t_radio_data)
                    vars[option_item_not_sprite]:setVisible(true)
                    vars[option_item_btn]:setEnabled(false)
                end
                self.m_grindItemRadioBtn:disable(item_name, cb_func) -- item_name, cb_func(비활성화 일 때 따로 처리)
                -- 선택 중이던 라디오 버튼이 비활성화 되었을 경우 포커스를 none_select로 옮김
                if (self.m_selectOptionItem == item_name) then
                    grind_item_radio_button:setSelectedButton('none_select')
                end
            else
                vars[option_item_not_sprite]:setVisible(false)
            end
        end
    end
end

-------------------------------------
-- function refresh_grindOptionRadioBtn
-------------------------------------
function UI_DragonRunesGrind:refresh_grindOptionRadioBtn()
    local enhance_class = self.m_runeEnhanceClass
    local vars = enhance_class.vars
    local rune_obj = enhance_class:getRuneObject()

    -- 라디오 버튼 정보 갱신
    local grind_radio_button = self.m_optionGrindRadioBtn

    for i, opt_type in ipairs(StructRuneObject.OPTION_LIST) do
        if (i>2) then   -- 전체 옵션 중에서 sopt만 연마, 
            local option_btn = string.format('%s_btn', opt_type)       -- ex) sopt_1_btn
            local option_sprite = string.format('%s_sprite', opt_type)  -- ex) sopt_1_sprite
            local option_label = string.format('%s_label', opt_type)    -- ex) sopt_1_label
            local opt_desc = self:makeRuneDesc_grind(opt_type, nil)

            -- 룬 설명 정보가 있다면 갱신
            if (opt_desc ~= '') then
                vars[option_label]:setString(opt_desc)               
                if (not grind_radio_button:existButton(opt_type)) then -- 없는 버튼이면 등록
                    grind_radio_button:addButton(opt_type, vars[option_btn], vars[option_sprite])
                end
                vars[option_btn]:setVisible(true)
            else
                vars[option_btn]:setVisible(false)
            end

            local grinded_option = rune_obj:getGrindedOption()
            -- 연마된 옵션이 있다면, 해당 옵션 빼고 라디오 기능 모두 끄기
            if (grinded_option) then
                local disable_cb = function(t_data)
                    t_data['button']:setColor(cc.c4b(127,127,127,255))
                end
                if (opt_type ~= grinded_option and grind_radio_button:existButton(opt_type)) then
                    self.m_optionGrindRadioBtn:disable(opt_type, disable_cb)
                -- 연마된 옵션 라벨 색상 노랑
                elseif (self.m_seletedGrindOption == opt_type) then
                    opt_desc = self:makeRuneDesc_grind(opt_type, '{@r_opt_selected}')
                    vars[option_label]:setString(opt_desc)   
                end
            end
        end
    end
    
    -- 연마 정보 버튼 위치 세팅
    self:setGrindInfo()
end

-------------------------------------
-- function checkGrindCondition
-------------------------------------
function UI_DragonRunesGrind:checkGrindCondition()
    local rune_obj = self.m_runeEnhanceClass:getRuneObject()
    
    -- 강화 레벨 확인
    local level = rune_obj:getLevel()
    
    if (not level) then
        return false
    end
    
    if (level < UI_DragonRunesEnhance.GRIND_ABLE_LV) then
        UIManager:toastNotificationRed(Str('12강화 이상의 룬만 연마 할 수 있습니다.'))
        return false
    end
    
    -- 재료 확인
    local req_grind_stone = rune_obj:getRuneGrindReqGrindstone()
    local grind_stone_cnt = g_userData:get('grindstone')
    
    -- 값이 하나라도 nil이면 연마 실행 x
    if (not req_grind_stone or not grind_stone_cnt) then
        return false
    end
    
    -- 값이 하나라도 부족하면 연마 실행x
    local req_gold = rune_obj:getRuneGrindReqGold()
    local confirm_grindstone_price = (req_grind_stone <= grind_stone_cnt)   
    if ((not ConfirmPrice('gold', req_gold)) or (not confirm_grindstone_price)) then
        UIManager:toastNotificationRed(Str('재료가 부족합니다.'))
        self:showPackageGoraBig()
        return false
    end

    return true
end

-------------------------------------
-- function showPackageGoraBig
-------------------------------------
function UI_DragonRunesGrind:showPackageGoraBig()
    local enhance_class = self.m_runeEnhanceClass
    local vars = enhance_class.vars
    local ori_pos_y = 40
    cca.pickMeBig(vars['buyBtn'], 10, ori_pos_y)
end

-------------------------------------
-- function click_grind
-------------------------------------
function UI_DragonRunesGrind:click_grind()
    local rune_obj = self.m_runeEnhanceClass:getRuneObject() 

    if (not self:checkGrindCondition()) then
        return
    end
    
    local start_grind_cb = function()

        -- 통신 전, 블럭 팝업 생성
        local block_ui = UI_BlockPopup()

        -- 통신 후, 결과 출력&블럭 팝업 닫기
	    local function cb_func(is_success)
            self:showUpgradeResult(is_success)
	    	block_ui:close()

            local after_rune_grind_cnt = g_userData:get('grindstone')
            if (after_rune_grind_cnt <= 0) then
                self:showPackageGoraBig()
            end
	    end

        -- 통신 시작
        self:request_grind(cb_func)
    end

    -- 첫 연마라면 연마 확인 팝업 생성
    if (not rune_obj:getGrindedOption()) then
        UI_DragonRunesGrindFirstPopup(self.m_seletedGrindOption, rune_obj, start_grind_cb, false, self.m_selectOptionItem) -- selected_opt, rune_obj, ok_cb, is_info, item_type
    else
        start_grind_cb()
    end

end

-------------------------------------
-- function click_grindinfo
-------------------------------------
function UI_DragonRunesGrind:click_grindinfo()
    local rune_obj = self.m_runeEnhanceClass:getRuneObject()
    UI_DragonRunesGrindFirstPopup(self.m_seletedGrindOption, rune_obj, nil, true, self.m_selectOptionItem) -- selected_opt, rune_obj, ok_cb, is_info, item_type
end

function UI_DragonRunesGrind:click_grindItemBtn()
    UI_ItemInfoPopup(GRIND_ITEM_ID)
end

-------------------------------------
-- function setGrindInfo
-------------------------------------
function UI_DragonRunesGrind:setGrindInfo()
    local vars = self.m_runeEnhanceClass.vars
    
    local changed_label_str = string.format('%s_label', self.m_seletedGrindOption)
    local str_width = vars[changed_label_str]:getStringWidth() + 5
    
    local changed_btn_str = string.format('%s_btn', self.m_seletedGrindOption)
    local opt_pos_x, opt_pos_y = vars[changed_btn_str]:getPosition()
    vars['runeGrindBtn']:setPosition(opt_pos_x + str_width - 40 , opt_pos_y)
end
-------------------------------------
-- function refresh_grindstoneCount
-------------------------------------
function UI_DragonRunesGrind:refresh_grindstoneCount()
    local rune_obj = self.m_runeEnhanceClass:getRuneObject()
    local vars = self.m_runeEnhanceClass.vars

    -- 룬 연마석 정보 갱신
    local grind_stone_cnt = g_userData:get('grindstone') or 0
    local req_grind_stone_cnt = rune_obj:getRuneGrindReqGrindstone()
    local grindstone_cnt_str = Str('{1}/{2}', grind_stone_cnt, req_grind_stone_cnt)
    if (grind_stone_cnt <= 0) then
        grindstone_cnt_str = '{@impossible}' .. grindstone_cnt_str
    else
        grindstone_cnt_str = '{@possible}' .. grindstone_cnt_str
    end
    vars['quantityLabel']:setString(grindstone_cnt_str)
end

-------------------------------------
-- function request_grind
-------------------------------------
function UI_DragonRunesGrind:request_grind(cb_func)
    local rune_obj = self.m_runeEnhanceClass:getRuneObject() 
    local select_grind_opt = self.m_seletedGrindOption
    local owner_doid = rune_obj['owner_doid']
    local roid = rune_obj['roid']

    local finish_func = function()
        -- 룬 연마석 갯수, 사용하자마자 갱신
        self:refresh_grindstoneCount()

        rune_obj = g_runesData:getRuneObject(roid)
        self.m_runeEnhanceClass:setRuneObject(rune_obj)
        self.m_runeEnhanceClass:show_upgradeEffect(true, cb_func, true)
    end

    -- request_runeGrind param으로 보조 아이템 id 요구, 없다면 nil
    local item_id = TableItem:getItemIDFromItemType(self.m_selectOptionItem)
    if (not item_id) then
        item_id = nil
    end

    -- request_runeGrind의 param ex) sopt : 1
    local select_sopt_number = string.match(select_grind_opt, '%d+')
    
    -- 통신 시작
    g_runesData:request_runeGrind(owner_doid, roid, select_sopt_number, tonumber(item_id), finish_func, nil) -- owner_doid, roid, sopt_slot, using_item_id finish_cb, fail_cb
end

-------------------------------------
-- function makeRuneDesc_grind
-------------------------------------
function UI_DragonRunesGrind:makeRuneDesc_grind(opt_type, color_str)
    if (not opt_type) then
        return
    end

    local rune_obj = self.m_runeEnhanceClass:getRuneObject()    
    local rune_desc_str = rune_obj:makeEachRuneDescRichText(opt_type, false)

    --  Max 표시
    local is_max = rune_obj:isMaxOption(opt_type, rune_desc_str)
    if (is_max) then
        rune_desc_str = rune_desc_str .. '{@yellow} [MAX]'  
    end

    if (color_str) then
        rune_desc_str = color_str .. rune_desc_str
    end

    return rune_desc_str
end

-------------------------------------
-- function showItemDsc
-------------------------------------
function UI_DragonRunesGrind:showItemDsc(item_name)
    local item_id = nil
    item_id = TableItem:getItemIDFromItemType(item_name)
    if (item_id) then
        UI_ItemInfoPopup(item_id, 1, nil)
    end
end