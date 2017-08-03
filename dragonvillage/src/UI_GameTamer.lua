-- 우선은 UI_Game에 붙여서 기능 구현 한 후에 구조화 검토..

-------------------------------------
-- function initTamerUI
-------------------------------------
function UI_Game:initTamerUI(tamer)
	local vars = self.vars

    vars['tamerMenu']:setVisible(true)

    do -- 테이머 아이콘
        local tamer_id = tamer.m_tamerID
        local tamer_type = TableTamer:getTamerType(tamer_id)
        local res = 'res/ui/icons/tamer/colosseum_ready_' .. tamer_type .. '.png'
        local icon = cc.Sprite:create(res)
        if icon then
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            vars['tamerNode']:addChild(icon)
        end
    end

	-- @TODO 3개였다가 1개로 변경.. 추후에 확정되면 정리
	for i = 1, 1 do
        if (vars['tamerSkillNode' .. i]) then
            if (tamer.m_lSkill[i]) then
                local res = tamer.m_lSkill[i]['res_icon']
                local icon = cc.Sprite:create(res)
		        if icon then
			        icon:setDockPoint(cc.p(0.5, 0.5))
			        icon:setAnchorPoint(cc.p(0.5, 0.5))
			        vars['tamerSkillNode' .. i]:addChild(icon)
		        end
            end
            		
		    if (i < 3) then
			    vars['tamerSkillBtn' .. i]:registerScriptTapHandler(function() self:click_tamerSkillBtn(i) end)
		    else
			    vars['tamerSkillBtn' .. i]:setEnabled(false)
		    end
        end
	end

    self.m_bVisible_TamerUI = true
    self.m_posX_TamerUI = vars['tamerMenu']:getPositionX()
    self.m_posY_TamerUI = vars['tamerMenu']:getPositionY()
end

-------------------------------------
-- function click_tamerSkillBtn
-------------------------------------
function UI_Game:click_tamerSkillBtn(idx)
	local world = self.m_gameScene.m_gameWorld;
	local tamer = world.m_tamer
	local vars = self.vars

    -- 조작 가능 상태인지 확인
    if (not world:isPossibleControl()) then return end

	if (tamer.m_bActiveSKillUsable and tamer.m_state ~= 'active') then
        vars['tamerSkillVisual']:setVisible(false)
        vars['tamerSkilllLockSprite']:setVisible(true)
		
        tamer:changeState('active')
	else
		UIManager:toastNotificationRed(Str('더 이상 사용 할 수 없습니다.'))
	end
end