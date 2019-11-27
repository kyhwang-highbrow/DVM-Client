local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarMatchingSceneListItem
-------------------------------------
UI_ClanWarMatchingSceneListItem = class(PARENT,{
        m_structMatchItem = 'StructClanWarMatch,'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchingSceneListItem:init(data)
    local vars = self:load('clan_war_match_scene_item.ui')
    self.m_structMatchItem = data

	if (data['clan_id'] == 'defeat') then
		return
	end
    self:initUI()
    
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchingSceneListItem:initUI()
    local vars = self.vars
    local struct_match_item = self.m_structMatchItem

    -- 승/패 표시
    vars['resultSprite']:setVisible(true)
    vars['winSprite']:setVisible(false)
    vars['loseSprite']:setVisible(false)
    
    local attack_state = struct_match_item:getAttackState()
    if (attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_SUCCESS']) then
        vars['winSprite']:setVisible(true)
    elseif (attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_FAIL']) then
        vars['loseSprite']:setVisible(true)
    else
        vars['resultSprite']:setVisible(false)
    end
    --[[
    -- 드래곤 초상화
    local struct_clan_info = struct_match_item:getUserInfo()
    local dragon_icon = struct_clan_info:getLeaderDragonCard()
    if (dragon_icon) then
        vars['dragonNode']:addChild(dragon_icon.root)
    end
    --]]
    
    local my_uid = g_userData:get('uid')
    local my_clan_id = g_clanWarData:getMyClanId()
    if (my_uid == struct_match_item['uid']) and (my_clan_id == struct_match_item['clan_id']) then
        vars['meSprite']:setVisible(true)
        vars['arrowSprite']:setPositionY(5)
        vars['lastTimeLabel']:setVisible(true)
	end
	vars['lastTimeLabel']:setString('')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchingSceneListItem:update()
    local vars = self.vars
    local struct_match_item = self.m_structMatchItem
    
    local my_uid = g_userData:get('uid')
    if (my_uid ~= struct_match_item['uid']) then
        return
    end

    local end_time = struct_match_item:getEndDate()
    if (not end_time) then
        vars['lastTimeLabel']:setString('')
        return
    end

    -- 공격 끝날 때 까지 남은 시간 = 공격 시작 시간 + 1시간
    local cur_time = Timer:getServerTime_Milliseconds()
    local remain_time = (end_time - cur_time)/1000
    if (remain_time > 0) then
        local hour = math.floor(remain_time / 3600)
        local min = math.floor(remain_time / 60) % 60
        vars['lastTimeLabel']:setString(Str('{1}:{2}', hour, min))
    else
        vars['lastTimeLabel']:setString('')
    end 
end