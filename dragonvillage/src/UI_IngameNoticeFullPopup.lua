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

    self.m_data = t_notice

    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_IngameNoticeFullPopup')

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
    local text = '{@#GREEN;url;http://www.naver.com}네이버{@#BLUE;url;http://www.google.com}[구글]{@#DEEPSKYBLUE;url;www.daum.net}다움'
    local t_custom = self.m_data.custom


    -- 데이터를 받자.
    if self.m_data and t_custom then
        local titleData = self:getStringByLanguage('popup_title')
        local textData = self:getStringByLanguage('popup_msg')

        local haldang = t_custom['nodata']

        if titleData and titleData ~= '' then
            title = titleData
        end

        if textData and textData ~= '' then
            text = textData
        end
    end

    -- rich_label 생성
	local rich_label = UIC_RichLabel()
	rich_label:setDimension(780, 410)
	rich_label:setFontSize(20)
	rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
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
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_IngameNoticeFullPopup:initButton()
    local vars = self.vars

    local btnClose = vars['okBtn']

    if btnClose then
        btnClose:registerScriptTapHandler(function() self:click_closeBtn() end)
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