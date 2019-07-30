local PARENT = UI

-------------------------------------
-- class UI_UserDeckInfoPopup
-------------------------------------
UI_UserDeckInfoPopup = class(PARENT, {
        m_structUserInfoColosseum  = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_UserDeckInfoPopup:init(struct_user_info)
    self.m_uiName = 'UI_UserDeckInfoPopup'
    self.m_structUserInfoColosseum = struct_user_info

    local vars = self:load('user_deck_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_UserDeckInfoPopup')

    -- @UI_ACTION
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserDeckInfoPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserDeckInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserDeckInfoPopup:refresh()
    local vars = self.vars
    local struct_user_info = self.m_structUserInfoColosseum

    -- 레벨, 닉네임
    local str_lv = struct_user_info:getUserText()
    vars['nameLabel']:setString(str_lv)

    -- 길드
    -- vars['guildLabel']:setString('')

    -- 드래곤
    self:refresh_dragons()
end

-------------------------------------
-- function refresh_dragons
-------------------------------------
function UI_UserDeckInfoPopup:refresh_dragons()
    local l_dragons = self.m_structUserInfoColosseum:getDefDeck_dragonList()

	-- 초기화를 하기 위함
    for idx=1, 5 do
        self:refresh_dragon(idx, nil)
    end

    for idx, dragon in pairs(l_dragons) do
        self:refresh_dragon(idx, dragon)
    end
end

-------------------------------------
-- function refresh_dragon
-------------------------------------
function UI_UserDeckInfoPopup:refresh_dragon(idx, t_dragon_data)
    local vars = self.vars

    if (not t_dragon_data) then
        vars['dragonNameLabel' .. idx]:setString('')
        vars['dragonLvLabel' .. idx]:setString('')
        vars['hp_label' .. idx]:setString('')
        vars['def_label' .. idx]:setString('')
        vars['atk_label' .. idx]:setString('')
        return
    end

    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[t_dragon_data['did']]

    do -- 드래곤 리소르
        local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'], t_dragon['attr'])
        animator.m_node:setDockPoint(cc.p(0.5, 0.5))
        animator.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['dragonNode' .. idx]:addChild(animator.m_node)
    end

    do -- 드래곤 이름
        vars['dragonNameLabel' .. idx]:setString(Str(t_dragon['t_name']))
    end

    do -- 드래곤 등급
        vars['starNode' .. idx]:removeAllChildren()
        local sprite = IconHelper:getDragonGradeIcon(t_dragon_data, 1)
        if sprite then
            vars['starNode' .. idx]:addChild(sprite)
        end
    end

    do -- 드래곤 레벨 + 강화
		local lv_str = t_dragon_data:getLvText(true) -- use_rich
        vars['dragonLvLabel' .. idx]:setString(lv_str)
    end

    do -- 드래곤 속성
        local attr = t_dragon['attr']
        local icon = IconHelper:getAttributeIconButton(attr)
        vars['attrNode' .. idx]:addChild(icon)
    end

    do -- 드래곤 역할
        local role_type = t_dragon['role']
        local icon = IconHelper:getRoleIconButton(role_type)
        vars['roleNode' .. idx]:addChild(icon)
    end

    do -- 드래곤 희귀도
        local rarity = t_dragon['rarity']
        local icon = IconHelper:getRarityIconButton(rarity)
        vars['rarityNode' .. idx]:addChild(icon)
        
    end

    do -- 드래곤 간략 능력치
        local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data)

        vars['atk_label' .. idx]:setString(status_calc:getFinalStatDisplay('atk'))
        vars['def_label' .. idx]:setString(status_calc:getFinalStatDisplay('def'))
        vars['hp_label' .. idx]:setString(status_calc:getFinalStatDisplay('hp'))
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_UserDeckInfoPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function RequestUserDeckInfoPopup
-------------------------------------
function RequestUserDeckInfoPopup(peer_uid, deck_name)
    local uid = g_userData:get('uid')
    deck_name = (deck_name or 'def')

    local function success_cb(ret)
        local struct_user_info = StructUserInfoColosseum:create(ret['pvpuser_info'], deck_name)
        UI_UserDeckInfoPopup(struct_user_info)
    end

    local function fail_cb(ret)
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/game/pvp/user_info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('peer', peer_uid)
    ui_network:setParam('name', deck_name)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
end