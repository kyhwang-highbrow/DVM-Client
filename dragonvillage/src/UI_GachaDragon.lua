local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_GachaDragon
-------------------------------------
UI_GachaDragon = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GachaDragon:init()
    local vars = self:load('shop_dragon.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_GachaDragon')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_GachaDragon:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_GachaDragon'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_GachaDragon:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_GachaDragon:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GachaDragon:initButton()
    local vars = self.vars

    -- 일반 드래곤 소환
    vars['regularDrawBtn1']:registerScriptTapHandler(function() self:click_regularDrawBtn1() end)
    vars['regularDrawBtn2']:registerScriptTapHandler(function() self:click_regularDrawBtn2() end)

    -- 고급 드래곤 소환
    vars['premiumDrawBtn1']:registerScriptTapHandler(function() self:click_premiumDrawBtn1() end)
    vars['premiumDrawBtn2']:registerScriptTapHandler(function() self:click_premiumDrawBtn2() end)

    -- 마일리지 교환
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_GachaDragon:refresh()
    local vars = self.vars

    -- 일반 드래곤 소환
    local t_gacha_info = g_gachaData:getGachaInfo('dragon_normal')
    vars['regularDrawPriceLabel1']:setString(comma_value(t_gacha_info['multi_price_value']))
    vars['regularDrawPriceLabel2']:setString(comma_value(t_gacha_info['price_value']))

    -- 고급 드래곤 소환
    local t_gacha_info = g_gachaData:getGachaInfo('dragon_premium')
    vars['premiumDrawPriceLabel1']:setString(comma_value(t_gacha_info['multi_price_value']))
    vars['premiumDrawPriceLabel2']:setString(comma_value(t_gacha_info['price_value']))
    

    do -- 마일리지
        local mileage = g_gachaData.m_dragonPremiumMileage['mileage']
        vars['mileageLabel']:setString(comma_value(mileage))
        vars['mileageGuage']:setPercentage((mileage / 150) * 100)
    end

end

-------------------------------------
-- function click_regularDrawBtn1
-- @breif 일반 드래곤 11연차 뽑기
-------------------------------------
function UI_GachaDragon:click_regularDrawBtn1()
    local function finish_cb(ret)
        self:refresh()
        local l_dragon_list = ret['added_dragons']
        UI_DragonGachaResult(l_dragon_list)
    end

    g_gachaData:request_dragonGachaNormalMulti(finish_cb)
end


-------------------------------------
-- function click_regularDrawBtn2
-- @breif 일반 드래곤 뽑기
-------------------------------------
function UI_GachaDragon:click_regularDrawBtn2()
    local function finish_cb(ret)
        self:refresh()
        local l_dragon_list = ret['added_dragons']
        UI_DragonGachaResult(l_dragon_list)
    end

    g_gachaData:request_dragonGachaNormal(finish_cb)
end


-------------------------------------
-- function click_premiumDrawBtn1
-- @breif 고급 드래곤 11연차 뽑기
-------------------------------------
function UI_GachaDragon:click_premiumDrawBtn1()
    local function finish_cb(ret)
        self:refresh()
        local l_dragon_list = ret['added_dragons']
        UI_DragonGachaResult(l_dragon_list)
    end

    g_gachaData:request_dragonGachaPremiumMulti(finish_cb)
end


-------------------------------------
-- function click_premiumDrawBtn2
-- @breif 고급 드래곤 뽑기
-------------------------------------
function UI_GachaDragon:click_premiumDrawBtn2()
    local function finish_cb(ret)
        self:refresh()
        local l_dragon_list = ret['added_dragons']
        UI_DragonGachaResult(l_dragon_list)
    end

    g_gachaData:request_dragonGachaPremium(finish_cb)
end

-------------------------------------
-- function click_rewardBtn
-- @breif 마일리지 보상 받기
-------------------------------------
function UI_GachaDragon:click_rewardBtn()
    local function finish_cb(ret)
        self:refresh()
        
        local item_id = ret['sent_item_id'] or 703004
        local item_name = TableItem():getValue(item_id, 't_name')
        MakeSimplePopup(POPUP_TYPE.OK, Str('[{1}]이 우편함으로 발송되었습니다.', Str(item_name)))
    end

    g_gachaData:request_mileageReward(finish_cb)
end



--@CHECK
UI:checkCompileError(UI_GachaDragon)
