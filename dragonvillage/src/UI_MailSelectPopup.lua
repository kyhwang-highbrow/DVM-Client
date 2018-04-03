local PARENT = UI
local RENEW_INTERVAL = 10

-------------------------------------
-- class UI_MailSelectPopup
-------------------------------------
UI_MailSelectPopup = class(PARENT, {
        m_selectType = 'number',
        m_selectMap = '',
		m_tableView = '',
        m_dirty = 'boolean',
    })

MAIL_SELECT_TYPE = {
    NONE = 0,
    EXP_BOOSTER = 1,
    GOLD_BOOSTER = 2,
    STAMINA = 3,
}

-------------------------------------
-- function init
-------------------------------------
function UI_MailSelectPopup:init(select_type)
    self.m_selectType = select_type
	
	local vars = self:load('mail_select.ui')
	UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_MailSelectPopup'
    self.m_dirty = false

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_MailSelectPopup')

	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

	self:initUI()
	self:initButton() 
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_MailSelectPopup:initUI()
    local vars = self.vars
    self.m_selectMap = {}

    local type = self.m_selectType
    if (type == MAIL_SELECT_TYPE.EXP_BOOSTER or type == MAIL_SELECT_TYPE.GOLD_BOOSTER) then
        self:setBoosterItem()

    elseif (type == MAIL_SELECT_TYPE.STAMINA) then
        self:setStaminaItem()
    end

    self:makeMailTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_MailSelectPopup:initButton()
	local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MailSelectPopup:refresh()
end

-------------------------------------
-- function setBoosterItem
-------------------------------------
function UI_MailSelectPopup:setBoosterItem()
    local vars = self.vars 
    local title = Str('보유한 부스터 아이템')
    vars['titleLabel']:setString(title)
    local type = self.m_selectType

    local item_mail_map = g_mailData.m_mMailMap['item']
    if (item_mail_map) then
        for _, struct_mail in pairs(item_mail_map) do
            if (type == MAIL_SELECT_TYPE.EXP_BOOSTER and struct_mail:isExpBooster()) then
                local id = struct_mail:getMid()
                self.m_selectMap[id] = struct_mail
            end

            if (type == MAIL_SELECT_TYPE.GOLD_BOOSTER and struct_mail:isGoldBooster()) then
                local id = struct_mail:getMid()
                self.m_selectMap[id] = struct_mail
            end
        end
    end

    self.m_dirty = true
end

-------------------------------------
-- function setStaminaItem
-------------------------------------
function UI_MailSelectPopup:setStaminaItem()
    local vars = self.vars 
    local title = Str('보유한 날개')
    vars['titleLabel']:setString(title)

    local item_mail_map = g_mailData.m_mMailMap['st']
    if (item_mail_map) then
        for _, struct_mail in pairs(item_mail_map) do
            local id = struct_mail:getMid()
            self.m_selectMap[id] = struct_mail
        end
    end
end

-------------------------------------
-- function makeMailTableView
-------------------------------------
function UI_MailSelectPopup:makeMailTableView()
    local vars = self.vars

	-- item ui에 보상 수령 함수 등록하는 콜백 함수
	local create_cb_func = function(ui, data)
        -- 보상 버튼 등록
        local function click_rewardBtn()
            local struct_mail = data
            self:click_rewardBtn(struct_mail)
        end
        ui.vars['rewardBtn']:registerScriptTapHandler(click_rewardBtn)
	end
   
    -- 테이블 뷰 인스턴스 생성
    local l_item_list = self.m_selectMap
    local node = vars['listNode']
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1160, 115)
    table_view:setCellUIClass(UI_MailListItem, create_cb_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    table_view:makeDefaultEmptyMandragora(Str('보유한 아이템이 없다고라.'))

    self.m_tableView = table_view

    -- 정렬
    g_mailData:sortMailList(table_view.m_itemList)
end

-------------------------------------
-- function click_rewardBtn
-- @brief 단일 보상 수령
-------------------------------------
function UI_MailSelectPopup:click_rewardBtn(struct_mail)
    local function success_cb()
        -- 메일 삭제
    	self.m_tableView:delItem(struct_mail:getMid())
        -- 더티 처리
        self.m_dirty = true
    end

    -- 코드 중복을 막기 위해 UI_MailPopup 클래스의 기능을 활용
    UI_MailPopup.check_readType(self, struct_mail, success_cb)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_MailSelectPopup:click_closeBtn()
    -- close cb는 dirty일때만 실행하도록 한다.
    if (not self.m_dirty) then
        self.m_closeCB = nil
    end

    self:closeWithAction()
end

--@CHECK
UI:checkCompileError(UI_MailSelectPopup)