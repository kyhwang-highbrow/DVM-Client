local PARENT = UI

-------------------------------------
-- class UI_HallOfFameListItem
-------------------------------------
UI_HallOfFameListItem = class(PARENT,{
		m_tUserInfo = 'table',
        m_idx = 'number',
	})

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFameListItem:init(t_data, idx)
    local vars = self:load('hall_of_fame_scene_item.ui')
    self.m_tUserInfo = t_data
    self.m_idx = idx or 1
    
    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFameListItem:initUI()
    local vars = self.vars
    local data = self.m_tUserInfo

    -- 순위가 없을 경우
    if (not data) then
        vars['noRankMenu']:setVisible(true)
        vars['rankMenu']:setVisible(false)

        -- 검은 테이머 랜덤으로 골라 출력
        local random_num = math_random(1, 3)
        local no_tamer = cc.Sprite:create(string.format('res/ui/icons/tamer/hall_of_fame_no_rank_010%d.png', random_num))
		if (no_tamer) then        
			vars['noRankTamerNode']:addChild(no_tamer)
		    no_tamer:setAnchorPoint(cc.p(0.5, 0.5))
            no_tamer:setDockPoint(cc.p(0.5, 0.5))
        end
		return
    end

	local score = descBlank(data['score'])

	local user_name = data['nick']
	local rank = descBlank(data['rank'])

	vars['scoreLabel']:setString(Str('{1}점', score))
	vars['userNameLabel']:setString(user_name)
	vars['rankingLabel']:setString(rank)

	-- 테이머 애니
	local tamer_id = data['tamer']
    local costume_id = data['costume']

    -- 코스튬 없을 경우 0으로 내려올 수도 있음
    if (costume_id == 0) then
        costume_id = nil
    end

    local sd_res
    if (costume_id) then
        sd_res = TableTamerCostume:getTamerResSD(costume_id)
    else
        sd_res = TableTamer:getTamerResSD(tamer_id)
    end

	local sd_animator = MakeAnimator(sd_res)
	sd_animator:changeAni('idle', true)
	vars['tamerNode']:addChild(sd_animator.m_node)
    local dragon_node = vars['dragonNode']
    
    local rank = tonumber(rank)
    if (self.m_idx%2 == 1) then
        vars['tamerNode']:setScaleX(-0.9)
        dragon_node = vars['dragonNode2']
    end

    -- 대표 드래곤
    local t_leader = data['leader']
    if (t_leader) then
        local did = t_leader['did']
        local table_data = TableDragon():get(did)
        local res_name = table_data['res']
        local attr = table_data['attr']
        local evolution = t_leader['evolution']
        local transform = t_leader['transform']

        -- 성체부터 외형변환 적용
        if (evolution == POSSIBLE_TRANSFORM_CHANGE_EVO) then
            evolution = transform or evolution
        end
        
        local animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
        if (animator) then
            dragon_node:addChild(animator.m_node)
        end
    end

    -- 클랜 정보
    if (data['clan_info']) then
	    -- 클랜 마크
        local t_clan_info = data['clan_info']
        local clan_name = t_clan_info['name']
        vars['clanNameLabel']:setString(clan_name)

        local clan_mark = StructClanMark:create(t_clan_info['mark'])
        local icon = clan_mark:makeClanMarkIcon()
        if (icon) then
            vars['clanMarkNode']:addChild(icon)
        end
    else
        vars['clanNameLabel']:setVisible(false)
    end


    -- 클랜 정보 없을 경우 위치 조정
    if (not self.m_tUserInfo['clan_info']) then
        vars['userNameLabel']:setPositionY(-68)
        vars['rankingLabel']:setPositionY(-62)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFameListItem:initButton()
    local vars = self.vars
    if (not self.m_tUserInfo) then
        return
    end

    if (self.m_tUserInfo['clan_info']) then
	    vars['clanBtn']:registerScriptTapHandler(function()
		    local struct_clan = StructClan(self.m_tUserInfo['clan_info'])
            local clan_object_id = struct_clan:getClanObjectID()
            g_clanData:requestClanInfoDetailPopup(clan_object_id)
        end)
    end
end

