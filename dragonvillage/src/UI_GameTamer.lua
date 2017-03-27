-- 우선은 UI_Game에 붙여서 기능 구현 한 후에 구조화 검토..

-------------------------------------
-- function initTamerUI
-------------------------------------
function UI_Game:initTamerUI(tamer)
	local vars = self.vars

	for i = 1, 3 do
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
			vars['tamerSkillGauge' .. i]:setPercentage(0)
		end
	end

end

-------------------------------------
-- function click_tamerSkillBtn
-------------------------------------
function UI_Game:click_tamerSkillBtn(idx)
	local world = self.m_gameScene.m_gameWorld;
	local tamer = world.m_tamer
	if (idx == 1) then
		tamer:changeState('active')
	else
		tamer:changeState('passive')
	end
end

-------------------------------------
-- function updateTamerSkillGuage
-------------------------------------
function UI_Game:updateTamerSkillGuage(idx)

end