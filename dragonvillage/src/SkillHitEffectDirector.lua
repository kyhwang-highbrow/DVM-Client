SkillHitEffectDirector = {
	m_hitCount = 'num',
	m_inGameUI = 'UI_Game'
}

-------------------------------------
-- function init
-------------------------------------
function SkillHitEffectDirector:init()
	self.m_inGameUI = g_gameScene.m_inGameUI
	self.m_hitCount = 0
end



-------------------------------------
-- function displayHitCombo
-- @brief 스킬 hit count 연출
-------------------------------------
function SkillHitEffectDirector:displayHitCnt()
	ShakeDir2(math_random(335-20, 335+20), math_random(500, 1500))
    SoundMgr:playEffect('EFFECT', 'option_thunderbolt_3')

    for i,v in pairs(self.m_world.m_tEnemyList) do
        if (not v.m_bDead) and (v.enable_body) then
            self:runAtkCallback(v, v.pos.x, v.pos.y)
            v:runDefCallback(self, v.pos.x, v.pos.y)

            self.m_hitNumCount = self.m_hitNumCount + 1
        end
    end

    g_gameScene.m_inGameUI.vars['hitLabel']:setString(self.m_hitNumCount)
    g_gameScene.m_inGameUI.vars['hitNode']:setVisible(true)
    g_gameScene.m_inGameUI.vars['hitNode']:stopAllActions()

    g_gameScene.m_inGameUI.vars['hitNode']:setScale(1.4)
    g_gameScene.m_inGameUI.vars['hitNode']:setOpacity(255)
    g_gameScene.m_inGameUI.vars['hitNode']:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 1), cc.FadeOut:create(0.5), cc.Hide:create()))
end