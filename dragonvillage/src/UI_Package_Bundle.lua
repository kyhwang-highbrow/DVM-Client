local PARENT = UI

-------------------------------------
-- class UI_Package_Bundle
-------------------------------------
UI_Package_Bundle = class(PARENT,{
        m_isPopup = 'boolean',
        m_cbBuy = 'function',
        m_data = 'table',
        m_pids = 'table',

        m_package_name = 'string',

        m_mailSelectType = "MAIL_SELECT_TYPE",

        m_customStruct = 'StructProduct',

        m_isFullPopup = 'boolean',

        m_obtainResultCloseCb = 'function',
    })



-------------------------------------
-- function init
-------------------------------------
function UI_Package_Bundle:init(package_name, is_popup, custom_struct, is_full_popup)
    self.m_package_name = package_name
    self.m_customStruct = custom_struct
    self.m_isFullPopup = is_full_popup

    local vars

    if (custom_struct) then
        vars = self:load(custom_struct['package_res'])
        self.m_data = TablePackageBundle:getDataWithName(package_name)
        self.m_pids = {custom_struct['product_id']}
    else
        vars = self:load(string.format('%s.ui', package_name))
        self.m_data = TablePackageBundle:getDataWithName(package_name) 
        self.m_pids = TablePackageBundle:getPidsWithName(package_name) 
    end
    
    self.m_isPopup = is_popup or false
	
	self.m_uiName = 'UI_Package_Bundle'
    self.m_mailSelectType = MAIL_SELECT_TYPE.NONE

    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_Bundle')
    end

    self:initUI()
	self:initButton()
    self:refresh()

    self:customInit(package_name, is_popup)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_Bundle:initUI()
    local vars = self.vars
    if (not self.m_isPopup) then
        vars['closeBtn']:setVisible(false)
    end

    if (vars['allSpecVisual']) then
        vars['allSpecVisual']:setIgnoreLowEndMode(true) -- 저사양 모드 무시
    end

    -- 만원의 행복
    if (self.m_package_name == 'package_lucky_box') then        
        -- 랜덤 박스에 지난 가격을 출력하는 부분이 있음(지난 가격과 비교하기 위해)
        if (self.vars['changeLabel']) then
            local ori_struct_product = g_shopDataNew:getTargetProduct(119990)
            if (ori_struct_product) then
                local price = ori_struct_product:getPriceStr()
                vars['changeLabel']:setString(price)
            else
                vars['changeLabel']:setString('')
            end
        end
    end

    -- 딸랑거리는 액션 추가
    if (vars['percentSprite'] ~= nil) then
        local action = cca.buttonShakeAction()
        vars['percentSprite']:runAction(action)
    end

    if (vars['timeLabel']) then vars['timeLabel']:setString('') end
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_Bundle:initButton()
    local vars = self.vars
    local t_pids = self.m_pids

    -- 클릭시 패키지 상세 팝업이 뜨는 경우 (즉시 구매가 아닌 경우)
    if (self.m_data['is_detail'] == 1) then 
        for idx, pid in ipairs(t_pids) do
            local pid = tonumber(pid)
            vars['buyBtn'..idx]:registerScriptTapHandler(function() self:click_openShop(pid) end)
        end
    end


    -- 레이드 패키지 자세히보기
    if (string.find(self.m_package_name, 'league_raid') or string.find(self.m_package_name, 'winter')) then
        -- 자세히 보기
        if (vars['infoBtn']) then
            vars['infoBtn']:registerScriptTapHandler(function() self:click_leagueRaidInfoBtn() end)
        end
    end

    -- 자세히 보기
    if (vars['contractBtn']) then
        vars['contractBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    end

    -- 보상 보기
    if (vars['rewardBtn']) then
		vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
	end

    -- 바로 가기
    if (vars['quickBtn']) then
        
        -- 팝업일 땐 숨긴다.
        if (self.m_isPopup == true) then
            vars['quickBtn']:setVisible(false)
        
        else
            vars['quickBtn']:setVisible(true)
            vars['quickBtn']:registerScriptTapHandler(function() self:click_quickBtn() end)

            cca.pickMePickMe(vars['quickBtn'], 10)
        end
    end

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function getProductList
-- @brief bundle형태는 package카테고리의 상품을 사용하다가 etc 카테고리 상품도 추가함
-------------------------------------
function UI_Package_Bundle:getProductList()    
    local l_item_list = {}
    local l_item_list_package = g_shopDataNew:getProductList('package')
    local l_item_list_etc = g_shopDataNew:getProductList('etc')

    for producdt_id, struct_product in pairs(l_item_list_package) do
        l_item_list[producdt_id] = struct_product
    end

    for producdt_id, struct_product in pairs(l_item_list_etc) do
        l_item_list[producdt_id] = struct_product
    end

    return l_item_list
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_Bundle:refresh()
    local vars = self.vars
    local l_item_list = self:getProductList()
    local target_product = self.m_pids
    if (not target_product) then
        return
    end

    local function setLabelString(target_key, idx, str)
        if (vars[target_key..idx]) then
            vars[target_key..idx]:setString(str)

        -- 단일 패키지도 table_bundle_package에서 관리, UI 네이밍 예외 검사
        elseif (idx == 1) and (vars[target_key]) then
            vars[target_key]:setString(str)
        end
    end

    local function setNodeVisible(target_key, idx, visible)
        if (vars[target_key..idx]) then
            vars[target_key..idx]:setVisible(visible)

        -- 단일 패키지도 table_bundle_package에서 관리, UI 네이밍 예외 검사
        elseif (idx == 1) and (vars[target_key]) then
            vars[target_key]:setVisible(visible)
        end
    end
        
    for idx, pid in ipairs(target_product) do
        local pid = tonumber(pid)
        local struct_product = l_item_list[pid]

        setLabelString('itemLabel', idx, '')
        -- 다이아 할인 풀팝업 전용 패키지 번들 - 추후 리팩토링 필요함
        -- 패키지가 아니지만 묶음 처리로 체크를 위해 패키지 번들에 등록한 케이스 
        if (self.m_package_name == 'event_dia_discount') or (self.m_package_name == 'event_gold_bonus') then
            local struct_product = g_shopDataNew:getTargetProduct(pid)
            if (struct_product) then
                local time_label = vars['timeLabel']
                local end_date = struct_product:getEndDateStr()
                if (time_label) then
                    if (end_date) then
                        time_label:setString(end_date)
                    else    
                        time_label:setString('')
                    end
                end

                local discount_value = struct_product:getBonusRate()              
                vars['bonusLabel1']:setString(Str('다이아 {1}% 보너스 상품 판매!', discount_value))
                vars['bonusLabel2']:setString(Str('{1}%\n보너스', discount_value))

                -- 하드 코딩 수정 필요(like 다이아 보너스율)
                if (self.m_package_name == 'event_gold_bonus') then
                    local discount_value = 50
                    vars['bonusLabel1']:setString(Str('골드 {1}% 보너스 상품 판매!', discount_value))
                    vars['bonusLabel2']:setString(Str('{1}%\n보너스', discount_value))
                end
            end

            return
        end

        -- 상품 정보가 없다면 구매제한을 넘겨 서버에서 준 정보가 없는 경우라 판단
        -- 월간 패키지, 주말 패키지는 구매제한 넘겨도 값을 주는데 다른 패키지는 주지 않음?
        if (not struct_product) then
            setLabelString('itemLabel', idx, Str('구매 완료'))

            setNodeVisible('priceNode', idx, false)
            setNodeVisible('buyLabel', idx, false)
            setNodeVisible('priceLabel', idx, false)
            setNodeVisible('buyBtn', idx, false)
            setNodeVisible('completeNode', idx, true)
        else
            -- 판매종료시간 있는 경우 표시
            local time_label = vars['timeLabel']
            local end_date = struct_product:getEndDateStr()
            if (time_label) then
                if (end_date) then
                    time_label:setString(end_date)
                else    
                    time_label:setString('')
                end
            end

            -- 구성품 t_desc 표시
            if (self.m_data['use_desc'] == 1) then
                local desc_str = Str(struct_product['t_desc'])
                setLabelString('itemLabel', idx, desc_str)

            -- 구성품 mail_content 표시
            else
                local full_str = ServerData_Item:getPackageItemFullStr(struct_product['mail_content'], true)
                setLabelString('itemLabel', idx, full_str)
            end

            -- 가격
            local price = struct_product:getPriceStr()
            setLabelString('priceLabel', idx, price)
            
            -- 구매 제한
            if (TablePackageBundle:isSelectOnePackage(self.m_package_name) and not self.m_customStruct) then
                local is_buy = PackageManager:isBuyAll(self.m_package_name)
				if (is_buy) then
					vars['buyLabel']:setString('')
                else
					vars['buyLabel']:setString('{@available}' .. Str('구매 가능'))
                end

                -- 구매 완료 표시
                vars['completeNode']:setVisible(is_buy)    
                vars['buyBtn']:setEnabled(not is_buy)
            else
                -- 구매 가능/불가능 텍스트 컬러 변경
                local str = struct_product:getMaxBuyTermStr()
                local is_buy_all = struct_product:isBuyAll()
                local color_key = is_buy_all and '{@impossible}' or '{@available}'
                local rich_str = color_key .. str
                setLabelString('buyLabel', idx, rich_str)

                -- 구매 완료 표시
                if (vars['completeNode' .. idx]) then
                    vars['completeNode' .. idx]:setVisible(struct_product:isBuyAll())
    
                elseif (idx == 1) and (vars['completeNode']) then   
                    vars['completeNode']:setVisible(struct_product:isBuyAll())    
                end
            end

            -- 즉시 구매라면
            if (self.m_data['is_detail'] == 0) then
                if (vars['buyBtn' .. idx]) then
				vars['buyBtn' .. idx]:registerScriptTapHandler(function() self:click_buyBtn(struct_product) end)

			    elseif (idx == 1) and (vars['buyBtn']) then   
                    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn(struct_product) end)
                end
            end
        end
    end
end

-------------------------------------
-- function click_openShop
-------------------------------------
function UI_Package_Bundle:click_openShop(product_id)
    local l_item_list = g_shopDataNew:getProductList('package')
    local struct_product = l_item_list[product_id]

	-- 슬라임 패키지, 속성 패키지 등지에서 콜백이 물리지 않아 ui 갱신이 되지 않는다.
	-- 차후에 콜백 구조를 걷어내고 dirty나 옵저버? 형태로 가면 좋을듯 하다
    if (struct_product) then
        local is_popup = true
        local ui = UI_Package(struct_product, is_popup)
		ui:setBuyCB(self.m_cbBuy)
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_Bundle:click_buyBtn(struct_product)
    local vars = self.vars

	local function cb_func(ret)
        if (self.m_cbBuy) then
            self.m_cbBuy(ret)
        end

        -- 만원의 행복은 구입 즉시 지급되므로 기본재화들도 결과 보여줌
        local show_all = false
        if (string.find(self.m_package_name, 'package_lucky_box')) then
            show_all = true
        end

        -- 캡슐 코인 패키지 상품 구매시 우편함 팝업 출력
        if (self.m_package_name == 'package_capsule_coin') then
            ItemObtainResult_ShowMailBox(ret, MAIL_SELECT_TYPE.GOODS, self.m_obtainResultCloseCb)
        
        -- 룬 상자 패키지 상품 구매시 우편함 팝업 출력
        elseif (self.m_package_name == 'package_rune_box') then
            ItemObtainResult_ShowMailBox(ret, MAIL_SELECT_TYPE.RUNE_BOX, self.m_obtainResultCloseCb)

        -- 슬라임 군단 패키지 상품 구매시 우편함 팝업 출력        
        elseif (self.m_package_name == 'package_super_slime_swarm') then
            ItemObtainResult_ShowMailBox(ret, MAIL_SELECT_TYPE.SUPER_SLIME, self.m_obtainResultCloseCb)

        else
            -- 아이템 획득 결과창
            if (self.m_mailSelectType == MAIL_SELECT_TYPE.NONE) then
                ItemObtainResult_Shop(ret, show_all, self.m_obtainResultCloseCb)
            else
                ItemObtainResult_ShowMailBox(ret, self.m_mailSelectType, self.m_obtainResultCloseCb)
            end
        end

        -- m_package_name
        -- 일단은 버튼부터 막는다
        --[[
        if (ret['status'] == 0) then
            if (vars['buyBtn']) then vars['buyBtn']:setEnabled(false) end
            if (vars['buyBtn1']) then vars['buyBtn1']:setEnabled(false) end
            if (vars['buyBtn2']) then vars['buyBtn2']:setEnabled(false) end
            if (vars['buyBtn3']) then vars['buyBtn3']:setEnabled(false) end
        end]]

        if (self.m_isFullPopup) then
            self:refresh()
            g_eventData.m_bDirty = true
            return
        end

        -- 뒷 패키지가 있으면?
        -- 그런데 풀팝업에서는 리프레시 해줘야 한다
        if (not self.m_isPopup and struct_product:getDependency() and struct_product:getDependency() ~= '') then
            return
        end

        -- 갱신이 필요한 상태일 경우
        if ret['need_refresh'] then
            self:refresh()
            g_eventData.m_bDirty = true

        elseif (self.m_isPopup == true) then
            self:close()
		end
	end
    
    struct_product:buy(cb_func)
end

------------------------------------- 
-- function click_rewardBtn
-- @brief 보상 안내 = 상품 안내 팝업을 출력한다 
-------------------------------------
function UI_Package_Bundle:click_rewardBtn()
    local category 

    -- 만원의 행복
    if (self.m_package_name == 'package_lucky_box') then
        category = 'luckybox'
    elseif (self.m_package_name == 'package_lucky_box_9.9k') then
        category = 'luckybox_9.9k'
    elseif (self.m_package_name == 'package_lucky_box_9.9k_02') then
        category = 'luckybox_9.9k_02'
    elseif (self.m_package_name == 'package_lucky_box_dia') then
        category = 'luckybox_9.9k_03'
    
    -- 드래곤 100개 뽑기 패키지 
    elseif (self.m_package_name == 'package_dragon_summon_100') then
        MakePopup('package_dragon_summon_100_info.ui', nil)
        return
    end

    -- 아이템 리스트 출력
    if (category) then
        local finish_cb = function(ret)
            local l_item = ret[category]
            if (l_item) then
                UI_PackageRandomBoxInfo(l_item, self.m_package_name)
            end
        end
        g_shopDataNew:request_randomBoxInfo(finish_cb)
    end
end

-------------------------------------
-- function click_quickBtn
-- @brief 바로 가기 버튼을 누른 경우 
-------------------------------------
function UI_Package_Bundle:click_quickBtn()
    if (string.find(self.m_package_name, 'rune')) then
        UINavigator:goTo('rune_forge', 'gacha')
    elseif (self.m_package_name == 'package_super_slime_swarm') then
        UINavigator:goTo('slime_combine')
    end
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_Package_Bundle:click_infoBtn()
    GoToAgreeMentUrl()
end



-------------------------------------
-- function click_leagueRaidInfoBtn
-------------------------------------
function UI_Package_Bundle:click_leagueRaidInfoBtn()
    UI_Package_LeagueRaidHelp()

end


-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Package_Bundle:click_closeBtn()
    self:close()
end

-------------------------------------
-- function setBuyCB
-------------------------------------
function UI_Package_Bundle:setBuyCB(func)
    self.m_cbBuy = func
end

-------------------------------------
-- function customInit
-------------------------------------
function UI_Package_Bundle:customInit(package_name, is_popup)
    local vars = self.vars

    -- 주말 패키지에 테이머 표시
    if (package_name == 'package_weekly_02') then
        -- 해상도가 낮아서 이미지로 대체함
        --vars['tamerNode']:removeAllChildren()
        ----local l_cid = {730101, 730102, 730201, 730202, 730302, 730303, 730402, 730403, 730501, 730602}
        ----local cid = l_cid[math_random(1, #l_cid)]
        --local cid = 730403
        --local res = TableTamerCostume:getTamerResSD(cid)
        --local ani_tamer = AnimatorHelper:makeTamerAnimator(res)
        --vars['tamerNode']:addChild(ani_tamer.m_node)
    end
end

-------------------------------------
-- function setMailSelectType
-------------------------------------
function UI_Package_Bundle:setMailSelectType(type)
    if (type > MAIL_SELECT_TYPE.NONE) and (type <= MAIL_SELECT_TYPE.SUPER_SLIME) then
        self.m_mailSelectType = type
    end
end


-------------------------------------
-- function setObtainResultCloseCb
-------------------------------------
function UI_Package_Bundle:setObtainResultCloseCb(cb)
    self.m_obtainResultCloseCb = cb
end









-------------------------------------
-- class UI_Package_LeagueRaidHelp
-------------------------------------
UI_Package_LeagueRaidHelp = class(UI,{
    })

    

-------------------------------------
-- function init
-------------------------------------
function UI_Package_LeagueRaidHelp:init()
    local vars = self:load('package_league_raid_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Package_LeagueRaidHelp')

    self.m_uiName = 'UI_Package_LeagueRaidHelp' 

    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end