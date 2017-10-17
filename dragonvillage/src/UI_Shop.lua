local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Shop
-------------------------------------
UI_Shop = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Shop:init()
    local vars = self:load('shop.ui')
    UIManager:open(self, UIManager.SCENE)
    
	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Shop')
	
	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

    self:initUI()
	self:initTab()
	self:initButton()
	self:refresh()

    -- 런칭 패키지 풀팝업
    g_fullPopupManager:show(FULL_POPUP_TYPE.LAUNCH_PACK)
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_Shop:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Shop'
    self.m_titleStr = Str('상점')
    self.m_bUseExitBtn = true

    -- 상점에서 우정포인트 추가
    if (g_topUserInfo) then
        g_topUserInfo:makeGoodsUI('fp', 5) 
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Shop:initUI()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_Shop:initTab()
    local vars = self.vars

    local l_shop = {'st', 'gold', 'cash', 'amethyst', 'topaz', 'mileage', 'honor', 'package'}
    for _, tab in pairs(l_shop) do
        self:addTabWithTabUIAuto(tab, vars, UI_ShopTab(self, tab))
    end

    self:setTab('cash')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Shop:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Shop:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Shop:click_exitBtn()
    self:close()
end

-------------------------------------
-- function addTabWithTabUIAuto
-------------------------------------
function UI_Shop:addTabWithTabUIAuto(tab, vars, ui, ...)
    ui:setBuyCB(function(ret) self:buyResult(ret) end)
    return PARENT.addTabWithTabUIAuto(self, tab, vars, ui, ...)
end

-------------------------------------
-- function buyResult
-------------------------------------
function UI_Shop:buyResult(ret)
    if (not g_shopDataNew.m_bDirty) then
        return
    end

    -- 상점의 모든 테이블 뷰 삭제
    self.vars['tableViewNode']:removeAllChildren()

    -- 테이블 뷰 초기화
    for i,v in pairs(self.m_mTabData) do
        local ui = v['ui']
        if ui then
            ui:clearProductList()
        end
    end

    -- 서버에서 데이터 받고 다시 생성
    local function cb_func(ret)
        self:setTab(self.m_currTab, true)
    end

    g_shopDataNew:request_shopInfo(cb_func)
end

-------------------------------------
-- function onDestroyUI
-------------------------------------
function UI_Shop:onDestroyUI()
    if (g_topUserInfo) then
        g_topUserInfo:deleteGoodsUI('fp') 
    end
end