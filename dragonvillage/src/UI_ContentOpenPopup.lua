local PARENT = UI

-------------------------------------
-- class UI_ContentOpenPopup
-------------------------------------
UI_ContentOpenPopup = class(PARENT,{
        m_content_type = 'string',
})

-------------------------------------
-- function init
-------------------------------------
function UI_ContentOpenPopup:init(content_type)
    self.m_content_type = content_type

    local vars = self:load('popup_contents_open.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ContentOpenPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ContentOpenPopup:initUI()
    local vars = self.vars
    local content_type = self.m_content_type
    self.vars['descLabel']:setString(Str('신규 콘텐츠가 오픈되었습니다'))

    -- 시험의 탑 층 개방용 팝업
    if (content_type == 'attr_tower_expend') then
        self.vars['linkBtn']:setVisible(true)
        local expend_floor = g_attrTowerData:getAttrMaxStageId()%1000
        self.vars['descLabel']:setString(Str('전 속성 {1}층 개방', expend_floor))

        -- 나머지는 시험의 탑과 동일하게 사용
        content_type = 'attr_tower'
        self.m_content_type = 'attr_tower'
    else
        self.vars['linkBtn']:setVisible(true)
    end
    
    self:changeAni(content_type)
    vars['contentsLabel']:setString(getContentName(content_type))


    local table_contents = TABLE:get('table_content_help')
    local t_contents = table_contents[content_type] or {}
    local open_desc = t_contents['open_desc'] or ''
    vars['infoLabel']:setString(Str(open_desc))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ContentOpenPopup:initButton()
    local vars = self.vars
    self.vars['okBtn']:registerScriptTapHandler(function() self:close() end)
    self.vars['linkBtn']:registerScriptTapHandler(function() self:click_lickBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ContentOpenPopup:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ContentOpenPopup:click_lickBtn()
    local content_name = self.m_content_type
	if (content_name == 'daily_shop') then
		UINavigator:goTo('shop_daily', true) -- content_name, is_popup
	else
		-- 바로가기
		UINavigator:goTo(content_name)
	end

    self:close()
end

-------------------------------------
-- function changeAni
-------------------------------------
function UI_ContentOpenPopup:changeAni(content_type)
    local vars = self.vars
    -- content_type과 애니메이션 다를 경우 예외처리
    if (content_type == 'forest') then
        content_type = 'dragon_forest'
    end

    if (content_type == 'exploration') then
        content_type = 'exploation'
    end

    if (content_type == 'challenge_mode') then
        content_type = 'challenge'
    end

    vars['contentsVisual']:changeAni('open_'..content_type, true)
end

--@CHECK
UI:checkCompileError(UI_ContentOpenPopup)
