local PARENT = UI

-------------------------------------
-- class UI_ClanSetting
-------------------------------------
UI_ClanSetting = class(PARENT, {
        m_bChangedClanSet = 'bool',
        m_bRet = 'bool',

        -- clan value
        m_structClanMark = 'StructClanMark',
        m_clanAutoJoin = 'boolean',
        m_clanIntroText = 'string',

        m_joinLv = 'number',

        m_clanJoinRadioBtn = 'UIC_RadioBtn',
     })

local STR_MAX_LENGTH = 70
local JOIN_MAX_LV = 70

-------------------------------------
-- function init
-------------------------------------
function UI_ClanSetting:init()
    local vars = self:load('clan_setting_new.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_ClanSetting'
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanSetting')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
    self:sceneFadeInAction()

    g_clanData.m_needClanSetting = false
    self.m_bRet = false
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanSetting:click_exitBtn()
    -- 가입 방식은 종료 직전에 변화 여부를 검사한다.
    self:checkJoinTypeChanged()

    local function close_cb()
        self:close()
    end

    -- 변경사항이 있다면 닫기 전에 되묻는다.
    if (self.m_bChangedClanSet) then
        local msg = Str('변경사항이 있습니다. 클랜관리 화면을 닫으시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, close_cb)
    else
        close_cb()
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanSetting:initUI()
    local vars = self.vars

    self:initJoinLv()
    self:initNecessaryContents()
    self:initSlideBar()
    self:initEditBox()
    self:initJoinRadioBtn()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanSetting:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['disbandBtn']:registerScriptTapHandler(function() self:click_disbandBtn() end)
    vars['leaveBtn']:registerScriptTapHandler(function() self:click_leaveBtn() end)
    vars['markBtn']:registerScriptTapHandler(function() self:click_markBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)

    vars['quantityBtn1']:registerScriptTapHandler(function() self:click_minusBtn() end)
    vars['quantityBtn3']:registerScriptTapHandler(function() self:click_plusBtn() end)
    vars['quantityBtn4']:registerScriptTapHandler(function() self:click_maxBtn() end)

    vars['introduceChangeBtn']:registerScriptTapHandler(function() self:click_introduceChangeBtn() end)

    -- 필수 카테고리
    for i = 1, 4 do
        vars['contentBtn'..i]:registerScriptTapHandler(function() self:click_contentBtn(i) end)
    end
end

-------------------------------------
-- function initEditBox
-------------------------------------
function UI_ClanSetting:initEditBox()
    local vars = self.vars

    -- intro editBox handler 등록
	local function intro_event_handler(event_name, p_sender)
        if (event_name == "began") then
            if (CppFunctions:isIos()) then
                vars['introduceLabel']:setString('')
            end
        
        elseif (event_name == "return") then
            local editbox = p_sender
            local str = editbox:getText()

            -- 서버에서 ''을 nil과 같이 처리하기 때문에 임의로 공백을 부여
            if (str == '') then
                str = ' '
            end

			-- 비속어 필터링
			local function proceed_func()
				vars['introduceLabel']:setString(str)
                self.m_clanIntroText = str
                self.m_bChangedClanSet = true
			end
			local function cancel_func()
			end
			CheckBlockStr(str, proceed_func, cancel_func)
        end
    end
    vars['introduceEditBox']:registerScriptEditBoxHandler(intro_event_handler)
    vars['introduceEditBox']:setMaxLength(STR_MAX_LENGTH)
end

-------------------------------------
-- function initJoinLv
-- @brief 지원 레벨
-------------------------------------
function UI_ClanSetting:initJoinLv()
    local vars = self.vars
    vars['quantityGuage']:setPercentage(0)

    local struct_clan = g_clanData:getClanStruct()
    local join_lv = struct_clan:getJoinLv()
    self:setCurrCount(join_lv)
end

-------------------------------------
-- function initNecessaryContents
-- @brief 필수 참여 컨텐츠
-------------------------------------
function UI_ClanSetting:initNecessaryContents()
    local vars = self.vars

    local struct_clan = g_clanData:getClanStruct()
    local l_category = struct_clan['category']
    for i, v in ipairs(l_category) do
        local idx = g_clanData:getNeedCategryIdxWithName(v)
        if idx then
            local sprite = vars['contentSprite'..idx]
            if sprite then
                sprite:setVisible(true)
            end
        end
    end
end

-------------------------------------
-- function initJoinRadioBtn
-- @brief
-------------------------------------
function UI_ClanSetting:initJoinRadioBtn()
	local vars = self.vars

	-- radio button 선언
    local radio_button = UIC_RadioButton()
	radio_button:setChangeCB(function(join_type)
        self.m_clanAutoJoin = join_type
    end)
	self.m_clanJoinRadioBtn = radio_button

    -- 버튼 등록
	for i, join_type in ipairs({true, false}) do
		local join_btn = vars['joinTypeBtn' .. i]
        local join_sprite = vars['joinTypeSprite' .. i]
		radio_button:addButton(join_type, join_btn, join_sprite)
	end
end

-------------------------------------
-- function initSlideBar
-- @brief 터치 레이어 생성
-------------------------------------
function UI_ClanSetting:initSlideBar()
    local node = self.vars['sliderBar']

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)
                
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end


-------------------------------------
-- function onTouchBegan
-------------------------------------
function UI_ClanSetting:onTouchBegan(touch, event)
    local vars = self.vars

    local location = touch:getLocation()

    -- 진형을 설정하는 영역을 벗어났는지 체크
    local bounding_box = vars['quantityBtn2']:getBoundingBox()
    local local_location = vars['quantityBtn2']:getParent():convertToNodeSpace(location)
    local is_contain = cc.rectContainsPoint(bounding_box, local_location)

    return is_contain
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function UI_ClanSetting:onTouchMoved(touch, event)
    local vars = self.vars

    local location = touch:getLocation()

    -- 진형을 설정하는 영역을 벗어났는지 체크
    local bounding_box = vars['quantityBtn2']:getBoundingBox()
    local local_location = vars['quantityBtn2']:getParent():convertToNodeSpace(location)

    local content_size = vars['quantityBtn2']:getParent():getContentSize()

    local x = math_clamp(local_location['x'], 0, content_size['width'])
    local percentage = x / content_size['width']

    vars['quantityBtn2']:stopAllActions()
    vars['quantityBtn2']:setPositionX(x)

    vars['quantityGuage']:stopAllActions()
    vars['quantityGuage']:setPercentage(percentage * 100)

    local count = math_floor(JOIN_MAX_LV * percentage)
    local ignore_slider_bar = true
    self:setCurrCount(count, ignore_slider_bar)
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function UI_ClanSetting:onTouchEnded(touch, event)
end

-------------------------------------
-- function setCurrCount
-------------------------------------
function UI_ClanSetting:setCurrCount(count, ignore_slider_bar)
    local vars = self.vars
    local count = math_clamp(count, 1, JOIN_MAX_LV)
    
    if (self.m_joinLv == count) then
        return
    end

    self.m_joinLv = count
    self.m_bChangedClanSet = true

    -- 지원 레벨
    vars['quantityLabel']:setString(comma_value(self.m_joinLv))

    -- 퍼센트 지정
    if (not ignore_slider_bar) then
        local percentage = (self.m_joinLv / JOIN_MAX_LV) * 100
        vars['quantityGuage']:stopAllActions()
        vars['quantityGuage']:runAction(cc.ProgressTo:create(0.2, percentage))
    
        local pos_x = 230 * (self.m_joinLv / JOIN_MAX_LV)
        vars['quantityBtn2']:stopAllActions()
        vars['quantityBtn2']:runAction(cc.MoveTo:create(0.2, cc.p(pos_x, 0)))
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanSetting:refresh()
    local vars = self.vars

    local struct_clan = g_clanData:getClanStruct()

    -- 클랜 마크
    self:refresh_mark()

    -- 클랜 이름
    local clan_name = struct_clan:getClanName()
    vars['nameLabel']:setString(clan_name)

    -- 클랜 가입 방식
    local clan_join = struct_clan:isAutoJoin()
    self.m_clanJoinRadioBtn:setSelectedButton(clan_join)

    -- 클랜 소개
    local clan_intro = struct_clan:getClanIntroText()
    vars['introduceLabel']:setString(clan_intro)

    -- 탈퇴 / 해체 버튼 처리
    self:refresh_auth()

    -- 초기화도 한번 해준다.
    self.m_bChangedClanSet = false
    self.m_structClanMark = nil
    self.m_clanAutoJoin = nil
    self.m_clanIntroText = nil
end

-------------------------------------
-- function refresh_mark
-- @brief 마크만 갱신
-------------------------------------
function UI_ClanSetting:refresh_mark()
    local vars = self.vars
    local struct_clan_mark = self:getClanMarkStruct()
    local icon = struct_clan_mark:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)
end

-------------------------------------
-- function refresh_auth
-------------------------------------
function UI_ClanSetting:refresh_auth()
    local vars = self.vars

    local member_type = g_clanData:getMyMemberType()
    local is_member = (member_type == 'member')

    -- 클랜 해체/탈퇴 버튼
    vars['disbandBtn']:setVisible(member_type == 'master')
    vars['leaveBtn']:setVisible(member_type ~= 'master')

    -- 지원 레벨 버튼
    vars['sliderBar']:setVisible(member_type ~= 'member')
    vars['quantityBtn1']:setVisible(member_type ~= 'member')
    vars['quantityBtn2']:setVisible(member_type ~= 'member')
    vars['quantityBtn3']:setVisible(member_type ~= 'member')
    vars['quantityBtn4']:setVisible(member_type ~= 'member')

    -- 클랜 변경
    if (is_member) then
        local block_msg = Str('클랜원은 변경할 수 없습니다.')
        vars['introduceChangeBtn']:setBlockMsg(block_msg)
        vars['okBtn']:setBlockMsg(block_msg)
        vars['markBtn']:setBlockMsg(block_msg)
        vars['markBtn']:setBlockMsg(block_msg)
        vars['contentBtn1']:setBlockMsg(block_msg)
        vars['contentBtn2']:setBlockMsg(block_msg)
        vars['contentBtn3']:setBlockMsg(block_msg)
        vars['contentBtn4']:setBlockMsg(block_msg)
        vars['joinTypeBtn1']:setEnabled(false)
        vars['joinTypeBtn2']:setEnabled(false)
    end
end

-------------------------------------
-- function click_introduceChangeBtn
-- @brief 클랜 소개 변경
-------------------------------------
function UI_ClanSetting:click_introduceChangeBtn()
    self.vars['introduceEditBox']:openKeyboard()
end

-------------------------------------
-- function click_minusBtn
-------------------------------------
function UI_ClanSetting:click_minusBtn()
    self:setCurrCount(self.m_joinLv - 1)
end

-------------------------------------
-- function click_plusBtn
-------------------------------------
function UI_ClanSetting:click_plusBtn()
    self:setCurrCount(self.m_joinLv + 1)
end

-------------------------------------
-- function click_maxBtn
-------------------------------------
function UI_ClanSetting:click_maxBtn()
    self:setCurrCount(JOIN_MAX_LV)
end

-------------------------------------
-- function click_disbandBtn
-- @brief 클랜 해체
-------------------------------------
function UI_ClanSetting:click_disbandBtn()
    local ask_func
    local request_func
    local popup_func
    local finish_cb

    ask_func = function()
        local msg = Str('정말 클랜을 해체하시겠습니까?')
        local msg_sub = Str('(현재 클랜이 랭킹에서 사라지며 시즌 보상을 획득할 수 없습니다.\n24시간 동안 재가입이 불가능합니다)')
        MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, msg_sub, request_func)
    end

    request_func = function()
        g_clanData:request_clanDestroy(popup_func)
    end

    popup_func = function()
        local msg = Str('클랜이 해체되었습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg, finish_cb)

        g_lobbyChangeMgr:changeTypeAndGotoLobby(LOBBY_TYPE.NORMAL)
    end

    finish_cb = function(ret)
        if g_clanData:isNeedClanInfoRefresh() then
            UINavigator:closeClanUI()
            UINavigator:goTo('clan')
        end
    end

    ask_func()
end

-------------------------------------
-- function click_leaveBtn
-- @brief 클랜 탈퇴
-------------------------------------
function UI_ClanSetting:click_leaveBtn()

    local ask_func
    local request_func
    local popup_func
    local finish_cb

    ask_func = function()
        local msg = Str('정말 클랜을 탈퇴하시겠습니까?')
        local msg_sub = Str('(24시간 동안 재가입이 불가능합니다)')
        MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, msg_sub, request_func)
    end

    request_func = function()
        g_clanData:request_clanExit(popup_func)
    end

    popup_func = function()
        local msg = Str('클랜에서 탈퇴하였습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg, finish_cb)

        g_lobbyChangeMgr:changeTypeAndGotoLobby(LOBBY_TYPE.NORMAL)
    end

    finish_cb = function(ret)
        if g_clanData:isNeedClanInfoRefresh() then
            UINavigator:closeClanUI()
            UINavigator:goTo('clan')
        end
    end

    ask_func()
end

-------------------------------------
-- function click_contentBtn
-- @brief 필수 참여 카테고리
-------------------------------------
function UI_ClanSetting:click_contentBtn(idx)
    local vars = self.vars
    local sprite = vars['contentSprite'..idx]
    if (sprite) then
        local visible = sprite:isVisible()
        sprite:setVisible(not visible)
        self.m_bChangedClanSet = true
    end
end

-------------------------------------
-- function click_markBtn
-- @brief 클랜 마크
-------------------------------------
function UI_ClanSetting:click_markBtn()
    local ui = UI_ClanMark(self:getClanMarkStruct())

    local function close_cb()
        if ui.m_bChanged then
            self.m_bChangedClanSet = true
            self.m_structClanMark = ui.m_structClanMark
            self:refresh_mark()
        end
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_okBtn
-- @brief 적용 버튼
-------------------------------------
function UI_ClanSetting:click_okBtn()
    -- 가입 방식은 종료 직전에 변화 여부를 검사한다.
    self:checkJoinTypeChanged()

    local finish_cb = function()
        self.m_bRet = true
        local msg = Str('변경사항이 적용되었습니다.')
        local ok_cb = function()
            self:close()
        end
        MakeSimplePopup(POPUP_TYPE.OK, msg, ok_cb)
    end

    if (not self.m_bChangedClanSet) then
        --ccdisplay('변경 사항이 없습니다.')
        self:close()
        return
    end

    local fail_cb = nil

    local intro = self.m_clanIntroText
    local notice = nil -- 로비로 빠짐
    local join = self.m_clanAutoJoin
    local mark = self.m_structClanMark and self.m_structClanMark:tostring() or nil
    local joinlv = self.m_joinLv

    local l_category 
    for idx = 1, 4 do
        local sprite = self.vars['contentSprite'..idx]
        if (sprite:isVisible()) then
            local name = g_clanData:getNeedCategryNameWithIdx(idx)
            if (name) then
                if (l_category) then
                    l_category = l_category .. ',' .. name
                else
                    l_category = name
                end
            end
        end
    end

    g_clanData:request_clanSetting(finish_cb, fail_cb, intro, notice, join, mark, joinlv, l_category)
end

-------------------------------------
-- function checkJoinTypeChanged
-- @brief
-------------------------------------
function UI_ClanSetting:checkJoinTypeChanged()
    if (self.m_bChangedClanSet == false) and (self.m_clanAutoJoin ~= nil) then 
        if (self.m_clanAutoJoin ~= g_clanData:getClanStruct():isAutoJoin()) then
            self.m_bChangedClanSet = true
        end
    end
end

-------------------------------------
-- function getClanMarkStruct
-- @brief
-------------------------------------
function UI_ClanSetting:getClanMarkStruct()
    if self.m_structClanMark then
        return self.m_structClanMark
    end

    local struct_clan = g_clanData:getClanStruct()
    return struct_clan.m_structClanMark
end

--@CHECK
UI:checkCompileError(UI_ClanSetting)
