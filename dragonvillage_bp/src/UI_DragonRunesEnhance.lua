local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonRunesEnhance
-------------------------------------
UI_DragonRunesEnhance = class(PARENT,{
        m_runeObject = 'StructRuneObject',
        m_changeOptionList = 'list'
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonRunesEnhance:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonRunesEnhance'
    self.m_bVisible = true
    self.m_titleStr = Str('룬 강화')
    self.m_bUseExitBtn = false
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesEnhance:init(rune_obj, attr)
    self.m_runeObject = rune_obj
    self.m_changeOptionList = {}

    local vars = self:load('dragon_rune_enhance.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonRunesEnhance')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(attr)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesEnhance:initUI(attr)
    local vars = self.vars

    -- 배경이 존재하는 경우에만
    if (attr) then
        local animator = ResHelper:getUIDragonBG(attr or 'earth', 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end
    
    local rune_obj = self.m_runeObject
    vars['runeNameLabel']:setString(rune_obj['name'])
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
    local for_enhance = true
    local option_label = vars['optionLabel']
    option_label:setString(rune_obj:makeRuneDescRichText(for_enhance))
    
    -- 변경된 옵션이 있다면 애니메이션 효과
    local change_list = self.m_changeOptionList
    for i, v in ipairs(change_list) do
        local node_list = option_label:findContentNodeWithkey(v)
        if (#node_list > 0) then
            for _i, _v in ipairs(node_list) do
                local find_node = _v
                -- 자연스러운 액션을 위해 앵커포인트 변경
                changeAnchorPointWithOutTransPos(find_node, cc.p(0.5, 0.5))
                cca.stampShakeAction(find_node, 1.5, 0.1, 0, 0)
            end
        end
    end

    -- 강화 성공시 옵션 추가되는 경우 
    local max_lv = RUNE_LV_MAX
    local curr_lv = rune_obj['lv']

    vars['bonusEffectLabel']:setVisible((curr_lv ~= max_lv - 1) and (curr_lv % 3 == 2))
    vars['maxLvEffectLabel']:setVisible((curr_lv == max_lv - 1))

    -- 소모 골드
    local req_gold = rune_obj:getRuneEnhanceReqGold()
    vars['enhancePriceLabel']:setString(comma_value(req_gold))
    cca.uiReactionSlow(vars['enhancePriceLabel'])

    local is_max_lv = rune_obj:isMaxRuneLv()
    vars['enhanceBtn']:setVisible(not is_max_lv)
end

-------------------------------------
-- function show_upgradeEffect
-------------------------------------
function UI_DragonRunesEnhance:show_upgradeEffect(is_success)
    local block_ui = UI_BlockPopup()

    local vars = self.vars
    local top_visual = vars['enhanceTopVisual']
    local bottom_visual = vars['enhanceBottomVisual']

    top_visual:setVisible(true)
    bottom_visual:setVisible(true)

    local ani_name = (is_success) and 'success' or 'fail'
    top_visual:changeAni(ani_name..'_top', false)
    bottom_visual:changeAni(ani_name..'_bottom', false)

    top_visual:addAniHandler(function()
        top_visual:setVisible(false)
        bottom_visual:setVisible(false)

        local rune_obj = self.m_runeObject
        if (is_success) then
            self:refresh()
            UIManager:toastNotificationGreen(Str('{1}강화를 성공하였습니다.', rune_obj['lv']))
        else
            UIManager:toastNotificationRed(Str('{1}강화를 실패하였습니다.', rune_obj['lv'] + 1))
        end

        block_ui:close()
    end)

    if (is_success) then
        SoundMgr:playEffect('UI', 'ui_rune_success')
    else
        SoundMgr:playEffect('UI', 'ui_rune_fail')
    end
end

-------------------------------------
-- function checkChangeSubOption
-------------------------------------
function UI_DragonRunesEnhance:setChangeOptionList(old_data, new_data)
    self.m_changeOptionList = {}
    
    local function compare_func(key)
        if (old_data[key] ~= new_data[key]) then
            table.insert(self.m_changeOptionList, key)
        end
    end

    -- 주 옵션
    compare_func('mopt')
    
    -- 유니크
    compare_func('uopt')

    -- 보조 옵션
    local sopt_cnt = 4
    for i = 1, sopt_cnt do
        local key = 'sopt_'..i
        compare_func(key)
    end
end

-------------------------------------
-- function click_enhanceBtn
-------------------------------------
function UI_DragonRunesEnhance:click_enhanceBtn()
    
    -- 골드가 충분히 있는지 확인
    local req_gold = self.m_runeObject:getRuneEnhanceReqGold()
    if (not ConfirmPrice('gold', req_gold)) then
        return
    end

    local rune_obj = self.m_runeObject
    local owner_doid = rune_obj['owner_doid']
    local roid = rune_obj['roid']

    local function finish_cb(ret)
        local success = ret['lvup_success']
        if (success) then
            self.m_runeObject = g_runesData:getRuneObject(roid)
            self:setChangeOptionList(rune_obj, self.m_runeObject)
        end
        self:show_upgradeEffect(success)
    end

    g_runesData:request_runeLevelup(owner_doid, roid, finish_cb)
end