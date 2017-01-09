local PARENT = UI

-------------------------------------
-- class UI_UserDeckInfoPopup
-------------------------------------
UI_UserDeckInfoPopup = class(PARENT, {
        m_tData = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_UserDeckInfoPopup:init(t_data)
    self.m_tData = t_data

    local vars = self:load('user_deck_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_UserDeckInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh(t_data)
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
function UI_UserDeckInfoPopup:refresh(t_data)
    local vars = self.vars

    local lv = (t_data['lv'] or 1)
    local nick = (t_data['nick'] or '')

    -- 레벨, 닉네임
    local str_lv = Str('레벨 {1}', lv)
    local str = str_lv .. ' ' .. nick
    vars['nameLabel']:setString(str)

    -- 길드
    vars['guildLabel']:setString(t_data['guild_name'])

    -- 드래곤
    self:refresh_dragons(t_data['dragons'])
end

-------------------------------------
-- function refresh_dragons
-------------------------------------
function UI_UserDeckInfoPopup:refresh_dragons(dragons)
    local l_dragons = {}
    local idx = 1

    for i=1, 9 do
        if dragons[i] then
            l_dragons[idx] = dragons[i]
            idx = idx + 1
        end
    end

    for i=1, 5 do
        self:refresh_dragon(i, l_dragons[i])
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

    do -- 드래곤 레벨
        vars['dragonLvLabel' .. idx]:setString(Str('레벨 {1}', t_dragon_data['lv']))
    end

    do -- 드래곤 속성
        local attr = t_dragon['attr']
        local icon = IconHelper:getAttributeIcon(attr)
        vars['attrNode' .. idx]:addChild(icon)
    end

    do -- 드래곤 역할
        local role_type = t_dragon['role']
        local icon = IconHelper:getRoleIcon(role_type)
        vars['roleNode' .. idx]:addChild(icon)
    end

    do -- 드래곤 희귀도
        local rarity = t_dragon['rarity']
        local icon = IconHelper:getRarityIcon(rarity)
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
function RequestUserDeckInfoPopup(uid, deck_name)
    deck_name = (deck_name or '1')

    local function success_cb(ret)
        UI_UserDeckInfoPopup(ret)
        --UI_UserDeckInfoPopup(ret['lv'], ret['nick'], ret['guild_name'], ret['dragons'])
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/users/get_user_deck')
    ui_network:setParam('uid', uid)
    ui_network:setParam('deck_name', deck_name)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()    
end