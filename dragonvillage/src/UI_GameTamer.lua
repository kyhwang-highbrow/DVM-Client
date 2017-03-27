-- 우선은 UI_Game에 붙여서 기능 구현 한 후에 구조화 검토..

-------------------------------------
-- function initTamerUI
-------------------------------------
function UI_Game:initTamerUI(tamer)
	local vars = self.vars

	-- @TODO 3개였다가 1개로 변경.. 추후에 확정되면 정리
	for i = 1, 1 do
		local res = tamer.m_lSkill[i]['res_icon']
		local icon = cc.Sprite:create(res)
		if icon then
			icon:setDockPoint(cc.p(0.5, 0.5))
			icon:setAnchorPoint(cc.p(0.5, 0.5))
			vars['tamerSkillNode' .. i]:addChild(icon)
		end
		
		if (i < 3) then
			vars['tamerSkillBtn' .. i]:registerScriptTapHandler(function() self:click_tamerSkillBtn(i) end)
		else
			vars['tamerSkillBtn' .. i]:setEnabled(false)
			vars['tamerSkillGauge' .. i]:setPercentage(100)
		end
	end

end

-------------------------------------
-- function click_tamerSkillBtn
-------------------------------------
function UI_Game:click_tamerSkillBtn(idx)
	local world = self.m_gameScene.m_gameWorld;
	local tamer = world.m_tamer
	local vars = self.vars

	if (tamer.m_bActiveSKillUsable) then
		tamer:changeState('active')
		tamer.m_bActiveSKillUsable = false
		vars['tamerSkillGauge' .. idx]:setPercentage(100)
	else
		UIManager:toastNotificationRed(Str('더 이상 사용 할 수 없습니다.'))
	end
end