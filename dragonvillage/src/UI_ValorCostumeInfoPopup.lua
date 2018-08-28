local PARENT = UI

-------------------------------------
-- class UI_ValorCostumeInfoPopup
-------------------------------------
UI_ValorCostumeInfoPopup = class(PARENT,{
        m_funcBuyBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ValorCostumeInfoPopup:init(buy_btn_func)
    local vars = self:load('shop_valor_costume.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ValorCostumeInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.m_funcBuyBtn = buy_btn_func
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ValorCostumeInfoPopup:initUI()
    local vars = self.vars

    -- table_tamer_costume_info의 cid
    local l_costume = {}
    l_costume[1] = {cid=730603} -- 모코지
    l_costume[2] = {cid=730405} -- 케사스
    l_costume[3] = {cid=730103} -- 고니
    l_costume[4] = {cid=730203} -- 누리
    l_costume[5] = {cid=730304} -- 데데
    l_costume[6] = {cid=730503} -- 두른

    for i,v in pairs(l_costume) do
        local cid = v['cid']
        local flip = v['flip']
        local costume_data = costume_data or g_tamerCostumeData:getCostumeDataWithCostumeID(cid)
        local sd_res = costume_data:getResSD()

	    local sd_animator = MakeAnimator(sd_res)
        vars['valorCostumeNode' .. i]:addChild(sd_animator.m_node)
    end
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ValorCostumeInfoPopup:initButton()
    local vars = self.vars
    vars['closeBTN']:registerScriptTapHandler(function() self:close() end)
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ValorCostumeInfoPopup:refresh()
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_ValorCostumeInfoPopup:click_buyBtn()
    self.m_funcBuyBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ValorCostumeInfoPopup)
