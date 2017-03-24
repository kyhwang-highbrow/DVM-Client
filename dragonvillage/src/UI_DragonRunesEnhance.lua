local PARENT = UI

-------------------------------------
-- class UI_DragonRunesEnhance
-------------------------------------
UI_DragonRunesEnhance = class(PARENT,{
        m_runeObject = 'StructRuneObject',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesEnhance:init(rune_obj)
    self.m_runeObject = rune_obj

    local vars = self:load('dragon_rune_enhance_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonRunesEnhance')

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
function UI_DragonRunesEnhance:initUI()
    local vars = self.vars

    local rune_obj = self.m_runeObject
    vars['runeNameLabel']:setString(rune_obj['name'])

    -- 강화 시 메인 옵션 추가 능력치
    vars['mainOptionStatusUpLabel']:setVisible(false)
    vars['mainOptionStatusUpSprite']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesEnhance:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['enhanceBtn']:registerScriptTapHandler(function() self:click_enhanceBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesEnhance:refresh()
    local vars = self.vars

    local rune_obj = self.m_runeObject

    -- 룬 아이콘
    vars['runeNode']:removeAllChildren()
    local ui = UI_RuneCard(rune_obj)
    cca.uiReactionSlow(ui.root)
    vars['runeNode']:addChild(ui.root)

    -- 능력치 출력
    vars['optionLabel']:setString(rune_obj:makeRuneDescRichText())

    -- 보유 골드
    self:refreshGold()

    -- 소모 골드
    local req_gold = rune_obj:getRuneEnhanceReqGold()
    vars['enhancePriceLabel']:setString(comma_value(req_gold))
    cca.uiReactionSlow(vars['enhancePriceLabel'])

    local is_max_lv = rune_obj:isMaxRuneLv()
    vars['enhanceBtn']:setVisible(not is_max_lv)
end

-------------------------------------
-- function refreshGoldLabel
-------------------------------------
function UI_DragonRunesEnhance:refreshGold()
    -- 보유 골드
    local gold = g_userData:get('gold')
    self.vars['goldLabel']:setString(comma_value(gold))
    cca.uiReactionSlow(self.vars['goldLabel'])
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_DragonRunesEnhance:click_enhanceBtn()
    local rune_obj = self.m_runeObject
    local roid = rune_obj['roid']

    local function finish_cb(ret)
        if ret['lvup_success'] then
            self.m_runeObject = g_runesData:getRuneObject(roid)
            self:refresh()
            UIManager:toastNotificationGreen(Str('{1}강화를 성공하였습니다.', self.m_runeObject['lv']))
        else
            UIManager:toastNotificationRed(Str('{1}강화를 실패하였습니다.', rune_obj['lv'] + 1))
            self:refreshGold()
        end
    end

    g_runesData:request_runeLevelup(roid, finish_cb)
end