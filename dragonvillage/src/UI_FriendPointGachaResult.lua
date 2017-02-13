local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_FriendPointGachaResult
-------------------------------------
UI_FriendPointGachaResult = class(PARENT, {
        m_lAddedItems = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPointGachaResult:init(l_added_items)
    self.m_lAddedItems = l_added_items
    local vars = self:load('friend_draw_result.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_FriendPointGachaResult')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_FriendPointGachaResult:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_FriendPointGachaResult'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_FriendPointGachaResult:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendPointGachaResult:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendPointGachaResult:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['drawBtn']:registerScriptTapHandler(function() self:click_drawBtn() end)
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_FriendPointGachaResult:refresh()
    local vars = self.vars

    local t_gacha_info = g_gachaData:getGachaInfo('friend_normal')

    -- 보유 우정포인트
    local fp = g_userData:get('fp')
    vars['haveCloverLabel']:setString(comma_value(fp))

    -- 뽑기 가격(우정포인트)
    vars['useCloverLabel']:setString(comma_value(t_gacha_info['price_value']))

    -- 설명은 UI에 있는 내용 그대로 사용
    --vars['drawDscLabel']:setString()

    do -- 아이템 아이콘
        local first_item = self.m_lAddedItems[1]
        local item_id = first_item['item_id']
        local count = first_item['count']
        local ui = UI_ItemCard(item_id, count)
        vars['itemNode']:addChild(ui.root)

        -- 아이템 이름
        local name = TableItem():getValue(item_id, 't_name')
        vars['itmeLabel']:setString(Str(name))
    end
end

-------------------------------------
-- function click_drawBtn
-------------------------------------
function UI_FriendPointGachaResult:click_drawBtn()
    local function finish_cb(ret)
        self:refresh()
        UI_FriendPointGachaResult(ret['added_items']['items_list'])
        self:close()
    end

    g_gachaData:request_friendPointGacha(finish_cb)
end

--@CHECK
UI:checkCompileError(UI_FriendPointGachaResult)
