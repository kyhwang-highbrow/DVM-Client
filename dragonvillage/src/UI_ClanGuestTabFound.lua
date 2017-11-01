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

    local editbox = vars['nameEditBox']
    local clan_name = editbox:getText()

    local work_check_name
    local work_check_price
    local wrok_request
    local work_response
    local work_refresh

    -- 클랜명 검증
    work_check_name = function()
        if self:clanNameCheck(editbox) then
            work_check_price()
        end
    end

    -- 클랜 창설 비용 확인
    work_check_price = function()
        local price_type, price_value = g_clanData:getClanCreatePriceInfo()
        local msg = Str('클랜을 창설하시겠습니까?')
        MakeSimplePopup_Confirm(price_type, price_value, msg, wrok_request)
    end

    -- 통신 요청
    wrok_request = function()
        g_clanData:request_clanCreate(work_response, nil, clan_name)
    end
    
    -- 통신 응답
    work_response = function(ret)
        if (ret['status'] == 0) then
            local msg = Str('축하합니다. 클랜이 창설되었습니다.')
            local sub_msg = Str('(클랜 설정 화면으로 이동합니다. 클랜의 상세 정보를 설정해주세요)')
            MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg, work_refresh)
        end
    end

    -- 클랜 정보 갱신
    work_refresh = function()
        if g_clanData:isNeedClanInfoRefresh() then
            UINavigator:closeClanUI()
            UINavigator:goTo('clan')
        end
    end

    work_check_name()
end