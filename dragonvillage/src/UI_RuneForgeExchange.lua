local PARENT = UI_IndivisualTab
-------------------------------------
-- class UI_RuneForgeExchange
-------------------------------------
UI_RuneForgeExchange = class(PARENT,{
    m_TabCount = 'number',  --탭 개수
    m_myTab = 'number',     --바라보고있는 탭번호
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeExchange:init(owner_ui)
    local vars = self:load('rune_forge_exchange.ui')
    --[1]:일반 [2]:고대
    self.m_TabCount = 2 
    self.m_myTab = 1    --기본은 일반
    self:refresh()
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeExchange:onEnterTab(first)
    self.m_ownerUI:showNpc() -- NPC 등장

    if (first == true) then
        self:initUI()
    end

    self:refresh()

end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeExchange:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeExchange:initUI()
    local vars = self.vars
    local package_rune = g_shopDataNew:getTargetPackage('package_rune_box')

    if package_rune then
        vars['buyBtn']:registerScriptTapHandler(function() UI_Package(package_rune:getProductList(), true) end)
    else
        vars['buyBtn']:setVisible(false)
    end
    vars['gachaBtn']:registerScriptTapHandler(function() self:click_gachaBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() UI_RuneForgeGachaInfo(self.m_myTab) end)

    --룬 뽑기 버튼 설정
    for index = 1, self.m_TabCount do
        vars['runeSelectBtn'..index]:registerScriptTapHandler(function() self:click_ChangeBtn(index) end)
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_RuneForgeExchange:update(dt)
    local vars = self.vars
end

-------------------------------------
-- function click_gachaBtn
-------------------------------------
function UI_RuneForgeExchange:click_gachaBtn()
    -- 조건 체크
    local rune_ticket_count = g_userData:get('rune_ticket') or 0
    if (rune_ticket_count <= 0) then
        UIManager:toastNotificationRed(Str('{1} 이(가) 부족합니다.'))
        return
    end

    local item_name = TableItem:getItemNameFromItemType('rune_ticket') -- 룬 교환 티켓
    local item_value = 1
    local msg = Str('{@item_name}"{1} x{2}"\n{@default}사용하시겠습니까?', item_name, comma_value(item_value))

    MakeSimplePopup_Confirm('rune_box', item_value, msg, function() self:request_runeGacha() end)
end

-------------------------------------
-- function subsequentSummons
-- @brief 이어서 뽑기 설정
-------------------------------------
function UI_RuneForgeExchange:subsequentSummons(gacha_result_ui)
    local vars = gacha_result_ui.vars
	-- 다시하기 버튼 등록
    vars['againBtn']:registerScriptTapHandler(function()
        gacha_result_ui:close()
        self:request_runeGacha()
    end)
end

-------------------------------------
-- function request_runeGacha
-------------------------------------
function UI_RuneForgeExchange:request_runeGacha()
    local myTab = tostring(self.m_myTab)
    -- 룬 최대 보유 수량 체크
    if (not g_runesData:checkRuneGachaMaximum(10)) then
        return
    end

    local function close_cb()
        self.m_ownerUI:refresh_highlight()
        self:refresh()
    end

    local function finish_cb(ret)
		local gacha_type = 'rune_ticket'
        local l_rune_list = ret['runes']

        local ui = UI_GachaResult_Rune(gacha_type, l_rune_list)
        
        ui:setCloseCB(close_cb)

        -- 이어서 뽑기 설정
        self:subsequentSummons(ui)
    end
    
    local is_bundle = true
    local is_cash = false

    g_runesData:request_runeGachaExchange(is_bundle, is_cash, myTab, finish_cb, nil) -- param: is_bundle, finish_cb, fail_cb
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeExchange:refresh()
    local vars = self.vars

    --룬 상자 이미지
    vars['runeBoxNode']:removeAllChildren()
    vars['runeBoxNode']:addChild(self:getRuneBoxIcon())

    --룬 상자 텍스트
    self:setRuneBoxString()

    --룬 버튼 상태
    local myTab = self.m_myTab
    for i = 1, self.m_TabCount do
        vars['runeSelectBtn'..i]:setEnabled(not (myTab == i))
    end
end

-------------------------------------
-- function click_ChangeBtn
-------------------------------------
function UI_RuneForgeExchange:click_ChangeBtn(myTab)
    local vars = self.vars
    self.m_myTab = myTab

    self:refresh()
end

-------------------------------------
-- function getRuneBoxIcon
-- @breif 탭에 맞는 룬상자 리소스 리턴
-------------------------------------
function UI_RuneForgeExchange:getRuneBoxIcon()
    local myTab = self.m_myTab
    local res = 'res/ui/icons/rune_forge_gacha/rune_forge_020'..myTab..'.png'
    local sprite = IconHelper:getIcon(res)
    return sprite
end

-------------------------------------
-- function setRuneBoxString
-- @breif 탭에 맞는 룬상자 텍스트 설정
-------------------------------------
function UI_RuneForgeExchange:setRuneBoxString()
    local vars = self.vars
    local myTab = self.m_myTab
    local item_name = TableItem:getItemNameFromItemType('rune_ticket')  -- 룬 교환 티켓

    local text = ''
    if (myTab == 1) then        --일반
        text = item_name
    elseif (myTab == 2) then    --고대
        text = Str('고대 {1}', item_name)
    end
    vars['runeLabel']:setString(text)
end