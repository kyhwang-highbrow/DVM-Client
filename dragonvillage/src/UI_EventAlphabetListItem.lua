local PARENT = UI

-------------------------------------
-- class UI_EventAlphabetListItem
-------------------------------------
UI_EventAlphabetListItem = class(PARENT,{
        m_tWordData = 'table',
        m_refreshCB = 'function',
        m_lAlphabetIcon = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventAlphabetListItem:init(ui_name, t_word_data)
    local ui_name = (ui_name or 'empty.ui')
    local vars = self:load(ui_name)
    self.m_tWordData = t_word_data
    self.m_lAlphabetIcon = {}

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventAlphabetListItem:initUI()
    local t_word_data = self.m_tWordData
    local vars = self.vars

    for i,item_id in ipairs(t_word_data['alphabet_list']) do
        local item_card = UI_ItemCard(item_id)
        item_card.root:setSwallowTouch(false)
        --self.root:addChild(item_card.root)
        vars['alphabetNode' .. i]:removeAllChildren()
        vars['alphabetNode' .. i]:addChild(item_card.root)

        self.m_lAlphabetIcon[i] = {item_id=item_id, ui=item_card}
    end

    vars['swallowTouchMenu']:setSwallowTouch(false)

    -- 보상
    local item_id, count = ServerData_Item:parsePackageItemStrIndivisual(t_word_data['reward'])
    local ui = UI_ItemCard(item_id, count)
    ui.root:setSwallowTouch(false)
    vars['rewardIonNode']:addChild(ui.root)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventAlphabetListItem:initButton()
    local vars = self.vars

    vars['receiveBtn']:registerScriptTapHandler(function() self:click_receiveBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventAlphabetListItem:refresh()
    
    local vars = self.vars

    -- clone된 알파벳 수량
    local alphabet_data = g_userData:get('alphabet')
    if (not alphabet_data['700237']) then
        alphabet_data['700237'] = 0
    end


    for i,data in pairs(self.m_lAlphabetIcon) do
        local item_id = data['item_id']
        local item_id_str = tostring(item_id)
        local item_card = data['ui']
        
        if (not alphabet_data[item_id_str]) then
            alphabet_data[item_id_str] = 0
        end

        local count = g_userData:get('alphabet', tostring(item_id)) or 0
        local count_str
        if (count == 0) then
            count_str = ''
        else
            count_str = tostring(count)
        end

        local vars = item_card.vars
        vars['commonSprite']:setVisible(false)
        vars['bgSprite']:setVisible(false)
        vars['highlightSprite']:setVisible(false)
        vars['numberLabel']:setString(count_str)

        if (alphabet_data[item_id_str] <= 0) then
            if (alphabet_data['700237'] <= 0) then
                local shader = ShaderCache:getShader(SHADER_GRAY_PNG)
                vars['icon']:setGLProgram(shader)    
            else
                alphabet_data['700237'] = math_max(alphabet_data['700237'] - 1)
                local shader = ShaderCache:getShader(SHADER_DEFAULT_SPRITE)
                vars['icon']:setGLProgram(shader)
                -- 와일트 카드 사용된 상태
                vars['highlightSprite']:setVisible(true)
            end
        else
            local shader = ShaderCache:getShader(SHADER_DEFAULT_SPRITE)
            vars['icon']:setGLProgram(shader)
        end

        -- 사용된 수량 감소
        alphabet_data[item_id_str] = math_max(alphabet_data[item_id_str] - 1)

        -- 등장 연출
        cca.fruitReact(item_card.root, i)
    end

    local word_id = self.m_tWordData['id']
    local t_word_data = g_eventAlphabetData:getAlphabetEvent_WordData(word_id)

    do
        local status = t_word_data['status']

        vars['readyBtn']:setVisible(false)
        vars['receiveBtn']:setVisible(false)
        vars['completeBtn']:setVisible(false)

        -- 모두 교환한 상태
        if (status == 'max') then
            vars['completeBtn']:setVisible(true)

        -- 교환 불가 상태
        elseif (status == 'not_exchangeable') then
            vars['readyBtn']:setVisible(true)

        -- 교환 가능 상태
        elseif (status == 'exchangeable') or (status == 'exchangeable_wild') then
            vars['receiveBtn']:setVisible(true)
        end
    end

    do
        local exchange_cnt = t_word_data['exchange_cnt']
        local exchange_max = t_word_data['exchange_max']
        local str = Str('교환 가능 {1}/{2}', exchange_cnt, exchange_max)
        vars['rewardNumberLabel']:setString(str)
    end
end

-------------------------------------
-- function click_receiveBtn
-------------------------------------
function UI_EventAlphabetListItem:click_receiveBtn()
    local function finish_cb(ret)
        if self.m_refreshCB then
            self.m_refreshCB()
        end

        -- 보상 획득 알림
        g_serverData:confirm_reward(ret)
    end

    local reward_id = self.m_tWordData['id']
    g_eventAlphabetData:request_alphabetEventReward(finish_cb, reward_id)
end

-------------------------------------
-- function setRefreshCB
-------------------------------------
function UI_EventAlphabetListItem:setRefreshCB(cb)
    self.m_refreshCB = cb
end