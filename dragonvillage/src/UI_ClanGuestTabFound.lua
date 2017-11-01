local PARENT = UI_IndivisualTab

local MIN_CLAN_NAME = 2
local MAX_CLAN_NAME = 10

-------------------------------------
-- class UI_ClanGuestTabFound
-- @brief 드래곤 조합
-------------------------------------
UI_ClanGuestTabFound = class(PARENT,{
        vars = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanGuestTabFound:init(owner_ui)
    self.root = owner_ui.vars['foundMenu']
    self.vars = owner_ui.vars
    
    --local vars = self:load('hatchery_combine_01.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_ClanGuestTabFound:onEnterTab(first)
    if first then
        self:initUI()
    end

    --self.m_ownerUI:showNpc() -- NPC 등장
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_ClanGuestTabFound:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanGuestTabFound:initUI()
    local vars = self.vars
    vars['foundBtn']:registerScriptTapHandler(function() self:click_foundBtn() end)


    local price_type, price_value = g_clanData:getClanCreatePriceInfo()
    local price_icon = IconHelper:getPriceIcon(price_type)
    vars['priceNode']:addChild(price_icon)
    vars['priceLabel']:setString(comma_value(price_value))

    -- 가격 아이콘 및 라벨, 배경 조정
	--UIHelper:makePriceNodeVariable(vars['priceBg'],  vars['priceNode'], vars['priceLabel'])


    do
        -- editBox handler 등록
	    local function editBoxTextEventHandle(strEventName, pSender)
            if (strEventName == "return") then
                local editbox = pSender
                self:clanNameCheck(editbox)
            end
        end

        vars['nameEditBox']:setMaxLength(MAX_CLAN_NAME)
        vars['nameEditBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
    end
    
end

-------------------------------------
-- function clanNameCheck
-------------------------------------
function UI_ClanGuestTabFound:clanNameCheck(editbox)
    local str = editbox:getText()
	local len = uc_len(str)

    local is_name = true
    if (len < MIN_CLAN_NAME) or (len > MAX_CLAN_NAME) or (not IsValidText(str, is_name)) then
        editbox:setText('')

        local msg = Str('클랜 이름은 한글, 영어, 숫자를 사용하여 최소{1}자부터 최대 {2}자까지 생성할 수 있습니다. \n \n 특수문자, 한자, 비속어는 사용할 수 없으며, 중간에 띄어쓰기를 할 수 없습니다.', MIN_CLAN_NAME, MAX_CLAN_NAME)
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return false
    end

    return true
end

-------------------------------------
-- function click_foundBtn
-------------------------------------
function UI_ClanGuestTabFound:click_foundBtn()
    local vars = self.vars

    -- 닉네임 검증
    local editbox = vars['nameEditBox']
    if (not self:clanNameCheck(editbox)) then
        return
    end

    -- 창설 비용 검증
    local price_type, price_value = g_clanData:getClanCreatePriceInfo()
    if (not ConfirmPrice(price_type, price_value)) then
        return
    end

    local function finish_cb(ret)
        if (ret['status'] == 0) then
            
            --MakeSimplePopup2(
        end
    end

    local clan_name = editbox:getText()
    g_clanData:request_clanCreate(finish_cb, nil, clan_name)
end