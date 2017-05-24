local PARENT = UIC_DragonAnimatorDirector

-------------------------------------
-- class UIC_DragonAnimatorDirector_Summon
-------------------------------------
UIC_DragonAnimatorDirector_Summon = class(PARENT, {
        m_topEffect = 'Animator',
        m_bottomEffect = 'Animator',

        m_skipBtnCnt = 'number', -- 두 번 터치를 해야 스킵이 되도록
        m_dragonAppearCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:init()
end

-------------------------------------
-- function initUI
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:initUI()
	local res_name = 'res/ui/a2d/summon/summon.vrp'
    self.m_topEffect = MakeAnimator(res_name)
    self.m_bottomEffect = MakeAnimator(res_name)

    self.vars['topEffectNode']:addChild(self.m_topEffect.m_node)
    self.vars['bottomEffectNode']:addChild(self.m_bottomEffect.m_node)
end

-------------------------------------
-- function startDirecting
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:startDirecting()
    local vars = self.vars

	-- init
    self.m_bottomEffect:setVisible(false)
    self.vars['skipBtn']:setVisible(true)
    self.m_skipBtnCnt = 0
    
	-- start
    self.m_topEffect:changeAni('appear')
    self.m_topEffect:addAniHandler(function() self.m_topEffect:changeAni('idle', true) end)
end

-------------------------------------
-- function continueDirecting
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:continueDirecting()
	local l_ani = {'crack_01', 'crack_02', 'crack_03', 'crack_04', 'top_appear'}
	local is_loop = false
	local function cb_func()
		self:appearDragonAnimator()
	end
	self.m_topEffect:changeAni_Repeat(l_ani, is_loop, cb_func)

	local cut_node = self.m_topEffect.m_node:getSocketNode('cut')
	
	local t_tamer = TableTamer():get(110002)
	local illustration_res = t_tamer['res']
    local illustration_animator = MakeAnimator(illustration_res)
	illustration_animator:changeAni('idle', true)
    cut_node:addChild(illustration_animator.m_node)
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:click_skipBtn()
    self.m_skipBtnCnt = (self.m_skipBtnCnt + 1)
	if (self.m_skipBtnCnt == 1) then
		self:continueDirecting()
    elseif (self.m_skipBtnCnt >= 2) then
        self:appearDragonAnimator()
    end
end