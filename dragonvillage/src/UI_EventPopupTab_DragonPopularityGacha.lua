local PARENT = UI--class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_EventPopupTab_DragonPopularityGacha
-------------------------------------
UI_EventPopupTab_DragonPopularityGacha = class(PARENT,{
        m_eventVersion = '',
        m_seasonId = 'string',
        m_ticketItemKey = 'string',
        m_gachaMap = 'table',
        m_mGoodsInfo = 'ui',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:init(is_fullpopup, is_not_show_go_stage)
    self.m_eventVersion = nil
    self.m_ticketItemKey = 'event_popularity_ticket'
    
    self.m_gachaMap = self:makeGachaMap()
    self.m_mGoodsInfo = nil

    self.m_uiName = 'UI_EventPopupTab_DragonPopularityGacha'
    self:load('event_popularity.ui')

    if is_fullpopup ~= true then
        self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.5)
        self:doActionReset()
        self:doAction(nil, false)

        self:initUI()
        self:initButton()
        self:refresh()
    end
end

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:open()
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventPopupTab_DragonPopularityGacha')

    self:initUI()
    self:initButton()
    self:refresh()

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self.vars['closeBtn']:setVisible(true)
end

-------------------------------------
-- function makeGachaMap
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:makeGachaMap()
    local gacha_map = {}

    local t_data_10 = {
        ['name'] = Str('인기 신화 드래곤 확률업 소환 10회'),
        ['egg_id'] = TableItem:getItemIDFromItemType(self.m_ticketItemKey),
        ['egg_res'] = 'res/item/egg/egg_cash_mystery/egg_cash_mystery.vrp',
        ['ui_type'] = 'cash11',
        ['bundle'] = false,
        ['draw_cnt'] = 10,
        ['price_type'] = self.m_ticketItemKey,
        ['price'] = 10,
    }
    
    local t_data_1 = {
        ['name'] = Str('인기 신화 드래곤 확률업 소환'),
        ['egg_id'] = TableItem:getItemIDFromItemType(self.m_ticketItemKey),
        ['egg_res'] = 'res/item/egg/egg_cash_mystery/egg_cash_mystery.vrp',
        ['ui_type'] = 'cash',
        ['draw_cnt'] = 1,
        ['bundle'] = false,
        ['is_ad'] = false,
        ['price_type'] = self.m_ticketItemKey,
        ['price'] = 1,
        ['free_target'] = false --무료 뽑기 대상 알
    }

    gacha_map[1] = t_data_1
    gacha_map[10] = t_data_10
    
    return gacha_map
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:initUI()
    local vars = self.vars
    local currency = self.m_ticketItemKey

--[[     do -- 드래곤 스파인
        local dragon_animator = UIC_DragonAnimator()
        dragon_animator:setDragonAnimator(did, 3)
        dragon_animator:setTalkEnable(false)
        vars['dragonNode']:removeAllChildren()
        vars['dragonNode']:addChild(dragon_animator.m_node)
    end

    do -- 드래곤 카드
        local dragon_card = MakeSimpleDragonCard(did, {})
        dragon_card.root:setScale(100/150)
        dragon_card.vars['attrNode']:setVisible(false)

        vars['ceilingIconNode']:removeAllChildren()
        vars['ceilingIconNode']:addChild(dragon_card.root)
        dragon_card.vars['clickBtn']:setEnabled(false)
    end
 ]]



    do -- 상단 재화
        local ui = UI_GoodsInfo(currency)
        vars['ticketNode']:removeAllChildren()
        vars['ticketNode']:addChild(ui.root)
        self.m_mGoodsInfo = ui
    end

    do -- 하단 재화
        local item_icon_1 = IconHelper:getItemIcon(currency)
        vars['itemNode_1']:removeAllChildren()
        vars['itemNode_1']:addChild(item_icon_1)

        local item_icon_10 = IconHelper:getItemIcon(currency)
        vars['itemNode_10']:removeAllChildren()
        vars['itemNode_10']:addChild(item_icon_10)
    end

    local function update(dt)
        self.m_mGoodsInfo:refresh()
    end

    self.root:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:initButton()
    local vars = self.vars
    vars['summonBtn_1']:registerScriptTapHandler(function() self:click_summonBtn(1) end)
    vars['summonBtn_10']:registerScriptTapHandler(function() self:click_summonBtn(10) end)

    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    vars['rankingBtn']:registerScriptTapHandler(function() self:click_rankingBtn() end)    
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:refresh()
    local vars = self.vars
    local struct_product = self:getMileageProduct()

    self.m_mGoodsInfo:refresh()

--[[     do -- 마일리지
        local mileage_count = g_userData:get('event_popularity_mileage')
        vars['mileageLabel']:setStringArg(mileage_count)
    end ]]

    -- 마일리지 상품
    if struct_product ~= nil then 
        -- 상품 이름
        local product_name = Str(struct_product['t_name'])
        vars['itemLabel']:setString(product_name)

        -- 상품 아이콘
        local icon = struct_product:makeProductIcon()
        if (icon) then
            vars['rewardNode']:removeAllChildren()
            vars['rewardNode']:addChild(icon)
        end

        local curr_count = g_userData:get('event_popularity_mileage')
        local need_count = struct_product:getPrice()
        local percent = (curr_count/need_count)*100

        -- 게이지
        local gauge_node = vars['mileageGauge']
        gauge_node:setPercentage(percent)

        -- 게이지 수치
        vars['mileageLabel']:setStringArg(comma_value(curr_count), comma_value(need_count))
    end

    do -- 이름
--[[         local did =  
        local table_dragon = TableDragon()
        local ceil_count = g_eventDragonStoryDungeon:getStoryDungeonSeasonGachaCeilCount()
        local dragon_name = table_dragon:getDragonName(did)
        vars['ceilingLabel']:setStringArg(dragon_name, ceil_count) ]]
    end

    vars['ticketLabel_txt_10']:setStringArg(10)
    vars['ticketLabel_txt_1']:setStringArg(1)
end


-------------------------------------
-- function getMileageProduct
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:getMileageProduct()
    local struct_product_list = g_shopDataNew:getProductList('event_popularity')
    local struct_product =  table.getFirst(struct_product_list)
    return struct_product
end

-------------------------------------
-- function subsequentSummons
-- @brief 이어서 뽑기 설정
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:subsequentSummons(gacha_result_ui, count)
    local vars = gacha_result_ui.vars
    if (not vars['againBtn']) then return end

	-- 다시하기 버튼 등록
    vars['againBtn']:registerScriptTapHandler(function()
        self:click_summonBtn(count, gacha_result_ui) -- is_again
    end)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_dragonBtn
-- @brief 드래곤
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:click_dragonBtn()
    --local did =  
    --UI_BookDetailPopup.openWithFrame(did, 6, 3, 1, true)
end

-------------------------------------
-- function click_rewardBtn
-- @brief 마일리지 상품 구매
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:click_rewardBtn()
    local struct_product = self:getMileageProduct()
    if struct_product == nil then
        return
    end

    local cb_func = function ()
        self:refresh()
    end

    struct_product:buy(cb_func)
end

-------------------------------------
-- function click_rankingBtn
-- @brief 랭킹 버튼
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:click_rankingBtn()
    UI_EventVoteRankingResult.open()
end

-------------------------------------
-- function click_infoBtn
-- @brief 도움말
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:click_infoBtn()
    --local did =  
    --local table_dragon = TableDragon()
    --local dragon_name = table_dragon:getDragonName(did)

    require('UI_HacheryInfoBtnPopup')
    local ui = UI_HacheryInfoBtnPopup('event_popularity_rate_popup.ui')
    --ui.vars['dragonName']:setStringArg(dragon_name)
end

-------------------------------------
-- function click_summonBtn
-- @brief 소환
-------------------------------------
function UI_EventPopupTab_DragonPopularityGacha:click_summonBtn(count, gacha_result_ui)
    local t_gacha = self.m_gachaMap[count]   
    local msg = Str('"{1}" 진행하시겠습니까?', t_gacha['name'])

    local ok_cb = function ()
        local goods_type = self.m_ticketItemKey
        if (not ConfirmPrice(goods_type, count)) then
            return
        end

        local success_cb = function (ret)
            local gacha_type = self.m_ticketItemKey
            local l_dragon_list = ret['added_dragons']
            local l_slime_list = ret['added_slimes']
            local egg_id = t_gacha['egg_id']
            local egg_res = t_gacha['egg_res']
            local added_mileage = ret['added_mileage'] or 0
            
            if gacha_result_ui ~= nil then
                gacha_result_ui:close()
            end

            local ui
            if count == 1 then
                ui = UI_GachaResult_Dragon(gacha_type, l_dragon_list, l_slime_list, egg_id, egg_res, t_gacha, added_mileage)
            else
                require('UI_GachaResult_StoryDungeonDragon10')
                ui = UI_GachaResult_StoryDungeonDragon10(gacha_type, l_dragon_list, t_gacha)
            end

            local function close_cb()
                self:refresh()
                --신화 드래곤 팝업
                g_getDragonPackage:PopUp_GetDragonPackage()
            end

            ui:setCloseCB(close_cb)
            self:subsequentSummons(ui, count)
        end
    
        local draw_cnt = count
        g_eventPopularityGacha:request_popularity_gacha(draw_cnt, success_cb)
    end

    if gacha_result_ui ~= nil then
        ok_cb()
    else
        MakeSimplePopup_SummonConfirm(self.m_ticketItemKey, count, msg, ok_cb)
    end
end
