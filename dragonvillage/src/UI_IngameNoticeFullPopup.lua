local PARENT = UI

-------------------------------------
-- class UI_IngameNoticeFullPopup
-------------------------------------
UI_IngameNoticeFullPopup = class(PARENT,{
        m_noticeLabel = 'UIC_ScrollLabel',
        m_titleLabel = 'cc.LabelTTF', 

        m_upArrowObj = '',
        m_downArrowObj = '',

        m_hasReward = 'boolean',

        m_data = 'StructMail',

        m_finishCallback = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameNoticeFullPopup:init(t_notice, finish_cb)
    self.m_uiName = 'UI_IngameNoticeFullPopup'

    local vars = self:load('ingame_notice_popup.ui')
    self.m_data = t_notice
    self.m_finishCallback = finish_cb

    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_IngameNoticeFullPopup')

    self:initUI()
    self:initButton()
    self:refresh()
    -- update 함수를 쓰고 싶을 때
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameNoticeFullPopup:initUI()
    -- UI Object
    local vars = self.vars
    local scrollTextNode = vars['textScrollViewNode']
    self.m_titleLabel = vars['titleLabel']

    self.m_upArrowObj = vars['topVisual']
    self.m_downArrowObj = vars['bottomVisual']

    if self.m_upArrowObj then self.m_upArrowObj:setVisible(false) end
    if self.m_downArrowObj then self.m_downArrowObj:setVisible(false) end

    if not scrollTextNode then return end

    -- data
    local title = Str('공지사항')
    local text = '{@WHITE}follow us on : \n{@#sky_blue;url;https://www.facebook.com/DragonVillageM}[facebook]{@WHITE} \n {@WHITE}or \n{@#pink;url;https://www.instagram.com/dragonvillage_m/}Instagram'
    local t_custom = self.m_data.custom


    -- 데이터를 받자.
    if self.m_data and t_custom then
        --local titleData = self:getStringByLanguage('popup_title')
        local textData = self:getStringByLanguage('popup_msg')

        local haldang = t_custom['nodata']

        --if titleData and titleData ~= '' then
        --    title = titleData
        --end

        if textData and textData ~= '' then
            text = textData
        end
    end

    -- rich_label 생성
	local rich_label = UIC_RichLabel()
	rich_label:setDimension(780, 410)
	rich_label:setFontSize(22)
	rich_label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	rich_label:enableOutline(cc.c4b(0, 0, 0, 127), 1)
    rich_label:setDefualtColor(COLOR['white'])
    rich_label.m_root:setSwallowTouch(false)
    rich_label.m_lineHeight = 1.4
    rich_label.m_wordSpacing = 1.1

    local width, height = rich_label:getNormalSize()

	-- scroll label  생성
	self.m_noticeLabel = UIC_ScrollLabel:create(rich_label)
	self.m_noticeLabel:setDockPoint(CENTER_POINT)
	self.m_noticeLabel:setAnchorPoint(CENTER_POINT)

	scrollTextNode:addChild(self.m_noticeLabel.m_node)

    
    if self.m_titleLabel then
        self.m_titleLabel:setString(title)
    end

    if self.m_noticeLabel then
        self.m_noticeLabel:setString(text)
    end

    local hasReward = self.m_data:isNoticeHasReward()

    -- 보상이 있으면 아예 아래 로직 실행하지 말자
    if not hasReward then return end

    local rewardItemNode = vars['itemNode']

    -- 아이템 데이터가 담겨져 있으면 아이템 노드가 있는지 보고
    if (self.m_data:hasItem() and rewardItemNode) then
        local l_item_list = self.m_data:getItemList()

        -- 아이콘을 그려주는 작업을 하자.
        for i,v in ipairs(l_item_list) do
            local item_id = v['item_id']
            local count = v['count']
        
            local item_card = UI_ItemCard(item_id, count)
            item_card.root:setScale(0.8)

            rewardItemNode:addChild(item_card.root)
        end
    end

end


-------------------------------------
-- function update
-------------------------------------

function UI_IngameNoticeFullPopup:update(dt)
    if not self.m_noticeLabel then return end

    if (self.m_noticeLabel:isShortText()) then return end

    local isTop = self.m_noticeLabel:isTopPosition()
    local isBottom = self.m_noticeLabel:isBottomPosition()

    if self.m_upArrowObj then
        if (self.m_upArrowObj:isVisible() ~= (not isTop)) then
            self.m_upArrowObj:setVisible(not isTop)
        end
    end

    if self.m_downArrowObj then 
        if (self.m_downArrowObj:isVisible() ~= (not isBottom)) then
            self.m_downArrowObj:setVisible(not isBottom) 
        end
    end
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_IngameNoticeFullPopup:initButton()
    local vars = self.vars

    local btnOk = vars['okBtn']
    local labelOk = vars['okLabel']
    local btnReceive = vars['receiveBtn']
    local btnCommunity = vars['communityBtn']
    local hasReward = self.m_data:isNoticeHasReward()


    if btnClose then
        btnClose:registerScriptTapHandler(function() self:click_closeBtn() end)
    end

    btnOk:setVisible(not hasReward)
    btnReceive:setVisible(hasReward)

    local hasItem = self.m_data:hasItem() or false

    if labelOk then
        if hasItem then
            labelOk:setString(Str('닫기'))
        else
            labelOk:setString(Str('확인'))
        end
    end

    btnCommunity:registerScriptTapHandler(function() self:click_communityButton() end)
    btnReceive:registerScriptTapHandler(function() self:click_closeBtn() end)
    btnOk:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_IngameNoticeFullPopup:refresh()
end

-------------------------------------
-- function setBtnBlock
-------------------------------------
function UI_IngameNoticeFullPopup:setBtnBlock()
end

-------------------------------------
-- function click_checkBtn
-------------------------------------
function UI_IngameNoticeFullPopup:click_checkBtn()

end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_IngameNoticeFullPopup:click_closeBtn()
    local t_custom = self.m_data.custom
    
    local t_popupKey = g_settingData:get('lobby_ingame_notice')
    
    if t_custom and t_custom['key'] then 
        local key = t_custom['key']
        
        -- 매번 저장하면 안되니 저장된 데이터가 있는지 확인한다.
        -- 키는 최근 등록한것일 수록 더 큰 값을 가진다.
        -- yyyyMMddHHmmSS
        local savedKey = g_settingData:get('lobby_ingame_notice', key) or -1
        local isNewer = tonumber(key) > tonumber(savedKey)

        -- 더 쌔거면 저장
        if isNewer then
            g_settingData:applySettingData(t_custom['popup_at'], 'lobby_ingame_notice', t_custom['key'])
            self:deleteOldData()
        end 
    end
    
    self.m_data:readNotice(function() if (self.m_finishCallback) then self.m_finishCallback() end end, false)

    self:close()
end


-------------------------------------
-- function applySettingData
-------------------------------------
function UI_IngameNoticeFullPopup:deleteOldData()
    -- 왜서 때로 만들었냐?
    -- 끝도 없이 쌓이기 떄문이다!
    -- 시간 지난거는 예의상 지우는게 맞다.
    local t_popupKey = g_settingData:get('lobby_ingame_notice')

    -- 아예 없으면 암것도 안하기
    if not t_popupKey then return end

    local t_result = {}
    local currentTime = tonumber(socket.gettime() * 1000)

    -- key 등록일 / expired_at 팝업 자동노출 중지 시간
    for key, expired_at in pairs(t_popupKey) do
        if (currentTime <= tonumber(expired_at)) then
            t_result[key] = expired_at
        end
    end

    if not t_result or table.count(t_result) <= 0 then return end

    g_settingData:applySettingData(t_result, 'lobby_ingame_notice')
end

-------------------------------------
-- function click_communityButton
-------------------------------------
function UI_IngameNoticeFullPopup:click_communityButton()
    local lang = Translate:getGameLang() or 'ko'
    
    -- TODO
    -- 링크를 저장할 곳을 찾아서 보금자리를 마련해주자
    if lang == 'ko' then
        SDKManager:goToWeb('https://bit.ly/45kbSlM')
    else
        SDKManager:goToWeb('https://www.facebook.com/DragonVillageM')
    end
end

-------------------------------------
-- function getKeywordByLanguage
-------------------------------------
function UI_IngameNoticeFullPopup:getStringByLanguage(key)
    local result = 'en'
    local t_custom = self.m_data.custom
    local lang = Translate:getGameLang()
    if string.find(lang, 'zh') ~= nil then
        lang = 'zh'
    end
    local searchKeyword = key .. '_' .. lang
    result = t_custom[searchKeyword] or t_custom[key .. '_en']
    return result
end