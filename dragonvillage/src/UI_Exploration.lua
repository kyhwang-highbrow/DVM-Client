local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Exploration
-------------------------------------
UI_Exploration = class(PARENT,{
        m_lLocationButtons = 'list',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_Exploration:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Exploration'
    self.m_bVisible = true or false
    self.m_titleStr = Str('탐험') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_Exploration:init()
    local vars = self:load('exploration_map.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Exploration')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Exploration:initUI()
    local vars = self.vars

    local table_exploration_list = TableExplorationList()

    self.m_lLocationButtons = {}
    for i,v in pairs(table_exploration_list.m_orgTable) do
        local order = v['order']
        local epr_id = v['epr_id']
        local ui = UI_ExplorationLocationButton(self, epr_id)

        self.m_lLocationButtons[i] = ui
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Exploration:initButton()
    self.vars['adBtn']:registerScriptTapHandler(function() self:click_adBtn() end)
    self.vars['adBtn']:runAction(cca.buttonShakeAction(2, 2))
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Exploration:refresh()
    for i,v in pairs(self.m_lLocationButtons) do
        v:refresh()
    end

    -- 광고 보기 버튼 체크
    self.vars['adBtn']:setVisible(g_advertisingData:isAllowToShow(AD_TYPE['EXPLORE']))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Exploration:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_adBtn
-------------------------------------
function UI_Exploration:click_adBtn()
	-- -- 광고 비활성화 시
	-- if (AdSDKSelector:isAdInactive()) then
	-- 	AdSDKSelector:makePopupAdInactive()
	-- 	return
	-- end

    -- 현재 진행중인 탐험이 없다면
    if (not g_explorationData:isExploring()) then
        local msg = Str('진행중인 탐험 지역이 없습니다.')
        UIManager:toastNotificationRed(msg)
        return
    end
    
    -- -- 광고 프리로드 요청
    -- AdSDKSelector:adPreload(AD_TYPE['EXPLORE'])

    -- -- 탐험 광고 안내 팝업
    -- local function ok_cb()
    --     AdSDKSelector:showDailyAd(AD_TYPE['EXPLORE'], function()
    --         UIManager:toastNotificationGreen(Str('광고 보상을 받았습니다.'))
    --         g_explorationData:setDirty()
    --         g_explorationData:request_explorationInfo(function() self:refresh() end)
    --     end)
    -- end
    -- local msg = Str("동영상 광고를 보시면 탐험 시간이 단축됩니다.") .. '\n' .. Str("광고를 보시겠습니까?")
    -- local submsg = Str("모든 탐험 중인 지역의 탐험 시간을 50% 단축합니다.") .. '\n' .. Str("탐험 시간 단축은 1일 1회 가능합니다.")
    -- MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_cb)

    local function finish_callback()
        UIManager:toastNotificationGreen(Str('광고 보상을 받았습니다.'))
        g_explorationData:setDirty()
        g_explorationData:request_explorationInfo(function() self:refresh() end)
    end

    local function ok_btn_callback()
        g_advertisingData:request_dailyAdShow(AD_TYPE.EXPLORE, finish_callback)
    end

    local msg = Str("모든 탐험 중인 지역의 탐험 시간을 50% 단축합니다.")
    local submsg = Str("탐험 시간 단축은 1일 1회 가능합니다.")
    MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_callback)
end

--@CHECK
UI:checkCompileError(UI_Exploration)
