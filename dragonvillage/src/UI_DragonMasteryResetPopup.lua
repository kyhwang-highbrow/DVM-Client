local PARENT = UI

-------------------------------------
-- class UI_DragonMasteryResetPopup
-------------------------------------
UI_DragonMasteryResetPopup = class(PARENT,{
        m_dragonObject = 'StructDragonObject',
        m_bChanged = 'boolean', -- 초기화 실행 여부
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonMasteryResetPopup:init(dragon_obj)
    self.m_dragonObject = dragon_obj
    self.m_bChanged = false

    local vars = self:load('dragon_mastery_skill_reset_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonMasteryResetPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonMasteryResetPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonMasteryResetPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)

    -- 특성 안내 (네이버 sdk 링크)
    NaverCafeManager:setPluginInfoBtn(vars['plugInfoBtn'], 'mastery_help')
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonMasteryResetPopup:refresh()
    local vars = self.vars

    -- 망각의 서 아이콘
    vars['priceNode']:removeAllChildren()
    local item_icon = IconHelper:getItemIcon(ITEM_ID_OBLIVION)
    vars['priceNode']:addChild(item_icon)

    -- 망각의 서 수량
    local dragon_obj = self.m_dragonObject
    local req_count = MasteryHelper:getMasteryResetPrice(dragon_obj)
    local own_count = g_userData:get('oblivion') or 0
    local str = Str('{1} / {2}', comma_value(own_count), req_count)
    if (req_count <= own_count) then
        str = '{@possible}' .. str
        vars['resetLabel']:setString(Str('초기화'))
    else
        str = '{@impossible}' .. str
        vars['resetLabel']:setString(Str('구매'))
    end
    vars['priceLabel']:setString(str)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_DragonMasteryResetPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_DragonMasteryResetPopup:click_enhanceBtn()

    -- 망각의 서 수량 체크
    local dragon_obj = self.m_dragonObject
    local req_count = MasteryHelper:getMasteryResetPrice(dragon_obj)
    local own_count = g_userData:get('oblivion') or 0
    if (own_count < req_count) then
        --UIManager:toastNotificationRed(Str('망각의 서가 부족합니다.'))
        --local vars = self.vars
        --cca.uiImpossibleAction(vars['enhanceBtn'])

        -- 구매 팝업 띄우기
        -- 망각의 서 product_struct
        local product_struct = g_shopData:getProduct('st', 210020)
        product_struct:buy(function(ret)
            ItemObtainResult_Shop(ret) 
            self:refresh()
        end)

        return
    end

    local function cb_func(ret)
        self.m_bChanged = true
        self:close()
    end
    
    local function fail_cb()
    end

    local doid = self.m_dragonObject['id']

    self:request_mastery_reset(doid, cb_func, fail_cb)
end


-------------------------------------
-- function request_mastery_reset
-- @brief
-------------------------------------
function UI_DragonMasteryResetPopup:request_mastery_reset(doid, cb_func, fail_cb)
    local uid = g_userData:get('uid')

    --[[
    -- 에러코드 처리
    local function response_status_cb(ret)
    end

    -- 통신실패 처리
    local function response_fail_cb(ret)
    end
    --]]

    local function success_cb(ret)
		-- 드래곤 갱신
		g_dragonsData:applyDragonData(ret['modified_dragon'])

		-- 골드 갱신
		g_serverData:networkCommonRespone(ret)

		if (cb_func) then
			cb_func()
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/dragons/mastery_reset')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
	--ui_network:hideLoading()
    ui_network:setRevocable(true)
    --ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    --ui_network:setFailCB(response_fail_cb)
    ui_network:request()
end

-------------------------------------
-- function isChanged
-- @brief 초기화 실행 여부
-------------------------------------
function UI_DragonMasteryResetPopup:isChanged()
    return self.m_bChanged
end

--@CHECK
UI:checkCompileError(UI_DragonMasteryResetPopup)
