local PARENT = UI

-------------------------------------
-- class UI_SupplyProductInfoPopup_QuestDouble
-------------------------------------
UI_SupplyProductInfoPopup_QuestDouble = class(PARENT,{
        m_buyCb = 'function',
        m_isPromote = 'boolean',
        m_structProduct = 'StructProduct',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SupplyProductInfoPopup_QuestDouble:init(is_promote, cb_func)
    local vars = self:load('supply_product_info_popup_quest_double.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_SupplyProductInfoPopup_QuestDouble'
    self.m_buyCb = cb_func
    self.m_isPromote = is_promote

    local t_supply = TableSupply:getSupplyData_dailyQuest()
    local product_id = t_supply['product_id']
    self.m_structProduct = g_shopDataNew:getTargetProduct(product_id) -- StructProduct

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SupplyProductInfoPopup_QuestDouble')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SupplyProductInfoPopup_QuestDouble:initUI()
    local vars = self.vars
    local struct_product = self.m_structProduct
    -- 상품 가격 표기
    local is_tag_attached = ServerData_IAP.getInstance():setGooglePlayPromotionSaleTag(self, nil)
    local is_sale_price_written = false
    if (is_tag_attached == true) then
        is_sale_price_written = ServerData_IAP.getInstance():setGooglePlayPromotionPrice(self, struct_product, nil)
    end

    if (is_sale_price_written == false) then
        vars['priceLabel']:setString(struct_product:getPriceStr())
    end -- // 상품 가격 표기

    -- 단순 구매팝업의 경우 타이틀에 상품명만 출력
    -- 판매촉진의 경우 이 팝업이 왜 갑자기 나왔는지 설명 필요 : ex) 상품명+목적(소개)
    if (self.m_isPromote) then
        vars['titleLabel']:setString(Str('14일 동안 일일 퀘스트 보상을 2배씩 받을 수 있는 상품을 소개합니다!'))
    else
        vars['titleLabel']:setString(Str('14일 동안 일일 퀘스트 보상 2배'))
    end

    do -- 다이아 즉시 획득량
        local t_supply = TableSupply:getSupplyData_dailyQuest()
        local package_item_str = t_supply['product_content']
        local count = ServerData_Item:getItemCountFromPackageItemString(package_item_str, ITEM_ID_CASH)
        local str = Str('즉시 획득 {1}', comma_value(count))
        vars['obtainLabel']:setString(str)
    end


    do -- 초기 값 설정 (퀘스트 정보를 받아오지 못한 경우 대비)
        vars['goldLabel']:setString(Str('골드') .. '\n' .. Str('{1}개', '5,320,000'))
        vars['amethystLabel']:setString(Str('자수정') .. '\n' .. Str('{1}개', '2,800'))
        vars['staminas_stLabel']:setString(Str('날개') .. '\n' .. Str('{1}개', '700'))
        vars['cashLabel']:setString(Str('다이아') .. '\n' .. Str('{1}개', '10,500'))
        vars['fpLabel']:setString(Str('우정의 징표') .. '\n' .. Str('{1}개', '1,120'))
        vars['clancoinLabel']:setString(Str('클랜코인') .. '\n' .. Str('{1}개', '14'))
    end

    -- 일일 퀘스트 보상 개수(아이템별) 합산한 맵 
    local t_quest_max_map = self:addAllReward_dailyQuest()

    local table_item = TableItem()
    for id, value in pairs(t_quest_max_map) do
        local item_type = table_item:getItemType(id)
        if (item_type) then
            local label_name = item_type .. 'Label' -- lua_name : 아이템타입+Label  ex) goldLabel, cashLabel

            -- 최대 보상 개수 : 일일 보상 합산 x 상품 지속 기간
            -- 2018-11-21 상품 지속 기간 14일
            local max_value = tonumber(value) * 14

            -- 라벨에 들어갈 문구 조합  -- ex) 골드\n10000개
            if (vars[label_name]) then
                local item_name = Str(table_item:getItemName(id))
                local value_str = comma_value(Str('{1}개', max_value))
                local full_str = item_name .. '\n' .. value_str
                vars[label_name]:setString(full_str)
            end
        end 
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SupplyProductInfoPopup_QuestDouble:initButton()
    local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function addAllReward_dailyQuest
-- @return  일일 퀘스트 보상에서 아이템별로 보상 갯수를 합산하여 [item_id] = count 형태의 맵 반환   
-------------------------------------
function UI_SupplyProductInfoPopup_QuestDouble:addAllReward_dailyQuest()
    local l_quest = g_questData:getDailyQuestList()
    local max_count_map = {}
    for _, v in ipairs(l_quest) do
        -- 퀘스트 중 type이 일일 보상인 경우
        if (v['reward']) then
            -- reward = '700001;1,700002;1'
            local reward = v['reward']
            local comma_split_list = plSplit(reward, ',') -- 아이템별로 리스트 생성
            for i, each_reward_str in pairs(comma_split_list) do
                local semi_split_list = plSplit(each_reward_str, ';') -- 아이템 id와 count 분리한 리스트 생성
                local reward_id = tonumber(semi_split_list[1])
                local reward_count = semi_split_list[2]
                -- 아이템 개수 초기화 
                if (not max_count_map[reward_id]) then
                    max_count_map[reward_id] = tonumber(reward_count)
                -- 아이템 개수 합산
                else
                    max_count_map[reward_id] = max_count_map[reward_id] + tonumber(reward_count)
                end
            end
        end
    end

    return max_count_map
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SupplyProductInfoPopup_QuestDouble:refresh()
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_SupplyProductInfoPopup_QuestDouble:click_buyBtn()
	self.m_structProduct:buy(self.m_buyCb)
    self:close()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SupplyProductInfoPopup_QuestDouble:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_SupplyProductInfoPopup_QuestDouble)
