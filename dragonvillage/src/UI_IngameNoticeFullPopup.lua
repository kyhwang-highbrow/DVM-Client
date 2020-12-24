local PARENT = UI

-------------------------------------
-- class UI_IngameNoticeFullPopup
-------------------------------------
UI_IngameNoticeFullPopup = class(PARENT,{
        m_noticeLabel = 'cc.LabelTTF',
        m_titleLabel = 'cc.LabelTTF', 

        m_hasReward = 'boolean',

        m_data = 'StructMail',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_IngameNoticeFullPopup:init(t_notice)
    local vars = self:load('ingame_notice_popup.ui')
    local t_custom = t_notice.custom
    local noticeStartDate = t_custom['start_date']
    --t_custom['items_list'] = '703038;1'

    self.m_data = t_notice

    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    --g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_IngameNoticeFullPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_IngameNoticeFullPopup:initUI()
    -- UI Object
    local vars = self.vars
    local scrollTextNode = vars['textScrollViewNode']
    self.m_titleLabel = vars['titleLabel']

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
	rich_label:setFontSize(20)
	rich_label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	rich_label:enableOutline(cc.c4b(0, 0, 0, 127), 1)
    rich_label:setDefualtColor(COLOR['white'])
    rich_label.m_root:setSwallowTouch(false)
    rich_label.m_lineHeight = 2

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

    if self.m_data then
        btnCommunity:registerScriptTapHandler(function() self:click_communityButton() end)
        btnReceive:registerScriptTapHandler(function() self:click_receiveButton() end)
        btnOk:registerScriptTapHandler(function() self:click_closeBtn() end)
    end
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
    
    if t_custom and t_custom['start_date'] then 
        -- 매번 저장하면 안되니 저장된 데이터가 있는지 확인한다.
        local lastWatchedNoticeDate = g_settingData:get('lobby_ingame_notice') or -1
        local isNewer = t_custom['start_date'] > lastWatchedNoticeDate

        -- 더 쌔거면 저장
        if isNewer then
            g_settingData:applySettingData(t_custom['start_date'], 'lobby_ingame_notice')
        end 
    end
    
    self:close()
end

-------------------------------------
-- function click_receiveButton
-------------------------------------
function UI_IngameNoticeFullPopup:click_receiveButton()
    self.m_data:readNotice(function() self:click_closeBtn() end, false)
end

-------------------------------------
-- function click_communityButton
-------------------------------------
function UI_IngameNoticeFullPopup:click_communityButton()
    local lang = Translate:getGameLang() or 'ko'
    
    -- TODO
    -- 링크를 저장할 곳을 찾아서 보금자리를 마련해주자
    if lang == 'ko' then
        SDKManager:goToWeb(NaverCafeManager:naverCafeStartWithArticle(nil))
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
    local searchKeyword = key .. '_' .. lang

    result = t_custom[searchKeyword]

    return result
end