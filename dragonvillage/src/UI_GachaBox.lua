local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_GachaBox
-------------------------------------
UI_GachaBox = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GachaBox:init()
    local vars = self:load('gift_box.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_GachaBox')

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
function UI_GachaBox:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_GachaBox'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_GachaBox:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_GachaBox:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GachaBox:initButton()
    local vars = self.vars
    
    -- 고급 상자
    vars['premiumDrawBtn']:registerScriptTapHandler(function() self:click_premiumDrawBtn() end)
    vars['premiumDrawFreeBtn']:registerScriptTapHandler(function() self:click_premiumDrawFreeBtn() end)

    -- 일반 상자
    vars['regularDrawBtn']:registerScriptTapHandler(function() self:click_regularDrawBtn() end)
    vars['regularDrawFreeBtn']:registerScriptTapHandler(function() self:click_regularDrawFreeBtn() end)
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_GachaBox:refresh()
    local vars = self.vars

    do -- 일반 상자
        local t_gacha_info = g_gachaData:getGachaInfo('box_normal')
        local can_free, type, remain_time = g_gachaData:canFreeGacha('box_normal')

        vars['regularDrawFreeBtn']:setVisible(can_free)
        vars['regularDrawBtn']:setVisible(not can_free)

        if can_free then
            -- 일일무료 횟수 표시
            vars['regularDrawFreeLabel']:setString(Str('{1}/{2}', t_gacha_info['free_cnt'], t_gacha_info['free_per_day']))
        else
            -- 가격 표기
            vars['regularDrawPriceLabel']:setString(comma_value(t_gacha_info['price_value']))
            -- 일일무료 횟수 표시
            vars['regularFreeDscLabel']:setString(Str('일일무료 ({1}/{2})', t_gacha_info['free_cnt'], t_gacha_info['free_per_day']))

            if (type == 'max') then
                vars['regularDrawTimeLabel']:setString('')
            elseif (type == 'cool') then
                vars['regularDrawTimeLabel']:setString(datetime.makeTimeDesc(remain_time, true))
            end
        end
    end

    do -- 고급 상자
        local t_gacha_info = g_gachaData:getGachaInfo('box_premium')
        local can_free, type, remain_time = g_gachaData:canFreeGacha('box_premium')

        vars['premiumDrawFreeBtn']:setVisible(can_free)
        vars['premiumDrawBtn']:setVisible(not can_free)

        if can_free then
            -- 일일무료 횟수 표시
            vars['premiumDrawFreeLabel']:setString(Str('{1}/{2}', t_gacha_info['free_cnt'], t_gacha_info['free_per_day']))
        else
            -- 가격 표기
            vars['premiumDrawPriceLabel']:setString(comma_value(t_gacha_info['price_value']))
            -- 일일무료 횟수 표시
            vars['premiumFreeDscLabel']:setString(Str('일일무료 ({1}/{2})', t_gacha_info['free_cnt'], t_gacha_info['free_per_day']))

            if (type == 'max') then
                vars['premiumDrawTimeLabel']:setString('')
            elseif (type == 'cool') then
                vars['premiumDrawTimeLabel']:setString(datetime.makeTimeDesc(remain_time, true))
            end
        end
    end
end

-------------------------------------
-- function click_regularDrawBtn
-- @breif 일반 드래곤 뽑기
-------------------------------------
function UI_GachaBox:click_regularDrawBtn()
    local function finish_cb(ret)
        self:refresh()
    end

    local is_gold = true
    g_gachaData:request_boxGachaNormal(is_gold, finish_cb)
end

-------------------------------------
-- function click_regularDrawFreeBtn
-- @breif 일반 드래곤 뽑기 (무료)
-------------------------------------
function UI_GachaBox:click_regularDrawFreeBtn()
    local function finish_cb(ret)
        self:refresh()
    end

    local is_gold = false
    g_gachaData:request_boxGachaNormal(is_gold, finish_cb)
end

-------------------------------------
-- function click_premiumDrawBtn
-- @breif 고급 드래곤 뽑기
-------------------------------------
function UI_GachaBox:click_premiumDrawBtn()
    local function finish_cb(ret)
        self:refresh()
    end

    local is_cash = true
    g_gachaData:request_boxGachaPremium(is_cash, finish_cb)
end

-------------------------------------
-- function click_premiumDrawFreeBtn
-- @breif 고급 드래곤 뽑기 (무료)
-------------------------------------
function UI_GachaBox:click_premiumDrawFreeBtn()
    local function finish_cb(ret)
        self:refresh()
    end

    local is_cash = false
    g_gachaData:request_boxGachaPremium(is_cash, finish_cb)
end


--@CHECK
UI:checkCompileError(UI_GachaBox)
