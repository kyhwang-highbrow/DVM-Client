local PARENT = UI

-------------------------------------
-- class UI_EventWelcomeNewbie
-------------------------------------
UI_EventWelcomeNewbie = class(PARENT, {


    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventWelcomeNewbie:init()
    local vars = self:load('event_welcome_newbie.ui')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventWelcomeNewbie:initUI()
    local vars = self.vars

    local can_reward_take = g_eventData:isPossibleToGetWelcomeNewbieReward()
    vars['rewardBtn']:setVisible(can_reward_take)
    vars['completeNode']:setVisible(not can_reward_take)

    local reward_str = g_eventData:getWelcomeNewbieRewardString()
    if (not reward_str) then
        return
    end

    -- �ű� ���� ���� �̺�Ʈ ������ ���ñ��̶�� ����
    -- @brief 20191216 �ű� ���� ���� �̺�Ʈ ������ ���� ��õ �巡�� ���ñ� 2���̶� ù ��° ���� ���
    local l_reward = pl.stringx.split(reward_str, ',')
    local first_reward = l_reward[1]
    if (not first_reward) then
        return
    end

    local l_data = pl.stringx.split(reward_str, ';')
    local item_id = tonumber(l_data[1])
    local item_cnt = tonumber(l_data[2])
    if (not item_id) then
        return
    end

    -- �巡�� ī�� ���� �ݹ�
    local function create_func(data)
        local did = data['did']
        local t_data = {['evolution'] = 3, ['grade'] = 6, ['lv'] = 60}
        local ui = MakeSimpleDragonCard(did, t_data)
        -- Ŭ��
		ui.vars['clickBtn']:registerScriptTapHandler(function()
			UI_BookDetailPopup.openWithFrame(did, 6, 3, 0.8, true)    -- param : did, grade, evolution, scale, ispopup
		end)
		
        return ui
    end

    -- �巡�� ���ñ� ��� �巡����� �巡�� ī��� ���
    local l_dragon = TablePickDragon:getDragonList(item_id, g_dragonsData.m_mReleasedDragonsByDid)
    for i, t_dragon in ipairs(l_dragon) do
        local ui = create_func(t_dragon)
        vars['dragonNode' .. i]:addChild(ui.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventWelcomeNewbie:initButton()
    local vars = self.vars

    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventWelcomeNewbie:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_EventWelcomeNewbie:click_rewardBtn()
    local vars = self.vars
    local finish_cb = function(ret)
        local can_reward_take = g_eventData:isPossibleToGetWelcomeNewbieReward()
        vars['rewardBtn']:setVisible(can_reward_take)
        vars['rewardBtn']:setEnabled(can_reward_take)
        vars['completeNode']:setVisible(not can_reward_take)
    end
    g_eventData:request_eventWelcomeNewbieReward(finish_cb)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventWelcomeNewbie:onEnterTab()
end

