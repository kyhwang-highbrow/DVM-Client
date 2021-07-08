local PARENT = UI_IndivisualTab

local MIN_CLAN_NAME = 2
local MAX_CLAN_NAME = 10

-------------------------------------
-- class UI_ClanGuestTabFound
-- @brief 드래곤 조합
-------------------------------------
UI_ClanGuestTabFound = class(PARENT,{
        m_ownerUI = '',
        vars = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanGuestTabFound:init(owner_ui)
    self.m_ownerUI = owner_ui
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

    -- 클랜 창설 UI에서 진입 연출을 위해 추가
    self.m_ownerUI:doActionReset()
    self.m_ownerUI:doAction()
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
				local clan_name = editbox:getText()

				local function proceed_func()
				end
				local function cancel_func()
					editbox:setText('')
				end
				local is_clan = true
				CheckNickName(clan_name, proceed_func, cancel_func, is_clan)
            end
        end

        vars['nameEditBox']:setMaxLength(MAX_CLAN_NAME)
        vars['nameEditBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
    end
    
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
    local work_request
    local work_response
    local work_refresh

    -- 클랜명 검증
    work_check_name = function()
		if (clan_name == '') then
			UIManager:toastNotificationRed(Str('클랜 이름을 입력하세요.'))
		else
			work_check_price()
		end
    end

    -- 클랜 창설 비용 확인
    work_check_price = function()
        local price_type, price_value = g_clanData:getClanCreatePriceInfo()
        local msg = Str('클랜을 창설하시겠습니까?')
        MakeSimplePopup_Confirm(price_type, price_value, msg, work_request)
    end

    -- 통신 요청
    work_request = function()
        g_clanData:request_clanCreate(work_response, nil, clan_name)
    end
    
    -- 통신 응답
    work_response = function(ret)
        if (ret['status'] == 0) then
            g_highlightData:setDirty(true)

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
            SoundMgr:playEffect('UI', 'ui_grow_result')
        end
    end

    work_check_name()
end