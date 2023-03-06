local PARENT = UI

-------------------------------------
-- class UI_LeagueRaidSeasonRewardPopup
-------------------------------------
UI_LeagueRaidSeasonRewardPopup = class(PARENT,{
    m_rewardData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LeagueRaidSeasonRewardPopup:init()
    local vars = self:load('league_raid_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    self.m_uiName = 'UI_LeagueRaidSeasonRewardPopup'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_LeagueRaidSeasonRewardPopup')

    self.m_rewardData = g_leagueRaidData:getRewardInfo()

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(t_info, is_clan)
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LeagueRaidSeasonRewardPopup:initUI()
    local vars = self.vars

    local member_count = g_leagueRaidData:getMemberCount()
    local my_info = g_leagueRaidData:getMyInfo()
    local member_list = g_leagueRaidData:getMemberList()
    local nick_name = g_userData:get('nick')
    local my_data = g_leagueRaidData:getMyData()
    local reward = g_leagueRaidData:getRewardInfo()
    local last_score = g_leagueRaidData.m_lastScore

    if (reward == nil) then reward = {} end

    if(vars['userLabel']) then vars['userLabel']:setString(nick_name) end
    if(vars['scoreLabel']) then vars['scoreLabel']:setString(Str('{1}점', comma_value(last_score))) end
    if(vars['rankNode']) then 
        local leagueImgName = 'res/ui/icons/rank/league_raid_rank_' .. string.lower(my_info['last_league'] .. '.png')
        local sprite = cc.Sprite:create(leagueImgName)

        if (sprite) then 
            sprite:setPosition(ZERO_POINT)
            sprite:setAnchorPoint(cc.p(0.5, 0.5))
            sprite:setDockPoint(cc.p(0.5, 0.5))
            vars['rankNode']:addChild(sprite)
        end
    end
    
    if(vars['userNode']) then 
        local leader_info = my_data['leader'] == nil and {} or my_data['leader']

        do -- 리더 드래곤 아이콘
            local dragon_id = leader_info['did']
            local transform = leader_info['transform']
            local evolution = transform and transform or leader_info['evolution']
            local dragon_skin = leader_info['dragon_skin']
            local icon = IconHelper:getDragonIconFromDidWithSkin(dragon_id, evolution, 0, 0, dragon_skin)
            -- local icon = IconHelper:getDragonIconFromDid(dragon_id, evolution, 0, 0)
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            icon:setFlippedX(true)
            vars['userNode']:addChild(icon)
        end
    end
    
    --reward = {}
    --table.insert(reward, {item_id=700001, count=65535})
    --table.insert(reward, {item_id=700001, count=65535})
    --table.insert(reward, {item_id=700001, count=65535})

    local reward_item_id_list = {}
    local reward_map = {}

    for i, v in ipairs(reward) do
        if (v and v['item_id']) then 
            table.insert(reward_item_id_list, v['item_id'])
            reward_map[v['item_id']] = v['count']
        end
    end

    if (table.count(reward_map) > 0 and vars['rewardNode']) then
        local reward_cnt = #reward

        local function create_func(ui, data)
            ui.root:setScale(0.6)
            ui.vars['numberLabel']:setString(comma_value(reward_map[data]))
        end

        local table_view = UIC_TableViewTD(vars['rewardNode'])
        table_view:setAlignCenter(true)
        table_view:setHorizotalCenter(true)
        table_view.m_cellSize = cc.size(95, 95)
        table_view.m_nItemPerCell = 3
        table_view:setCellUIClass(UI_ItemCard, create_func)
        table_view:setItemList(reward_item_id_list)
        table_view.m_scrollView:setTouchEnabled(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_LeagueRaidSeasonRewardPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end


--@CHECK
--UI:checkCompileError(UI_LeagueRaidSeasonRewardPopup)
