local PARENT = UIC_DragonAnimatorDirector

-------------------------------------
-- class UIC_DragonAnimatorDirector_Summon
-------------------------------------
UIC_DragonAnimatorDirector_Summon = class(PARENT, {
		m_lDirectingList = 'list',
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
-- function setDragonAnimator
-- @ brief 연출 종료후 나타날 드래곤 리소스 생성
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:setDragonAnimator(did, evolution, flv)
    PARENT.setDragonAnimator(self, did, evolution, flv)

	-- did를 받아 연출 리스트 생성
    self:makeDirectingList(did)
end

-------------------------------------
-- function startDirecting
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:startDirecting()
    local vars = self.vars

	-- 연출 세팅
    self.m_bottomEffect:setVisible(false)
    self.vars['skipBtn']:setVisible(true)
    self.m_skipBtnCnt = 0
    
	-- 연출 시작
    self.m_topEffect:changeAni('appear')
    self.m_topEffect:addAniHandler(function() self.m_topEffect:changeAni('idle', true) end)
end

-------------------------------------
-- function continueDirecting
-- @brief 연출의 실질적인 시작. 한번 클릭하면 동작한다.
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:continueDirecting()
	-- 연출 리스트를 가져와 리스트대로 애니 실행
	local l_ani = self.m_lDirectingList
	local is_loop = false
	local function cb_func()
		self:appearDragonAnimator()
	end
	self.m_topEffect:changeAni_Repeat(l_ani, is_loop, cb_func)

	-- 전설 등급 드래곤 등작할 시에 나오는 컷씬을 위해 [누리]를 붙임.
	if (#self.m_lDirectingList == 5) then
		local cut_node = self.m_topEffect.m_node:getSocketNode('cut')
		if (cut_node) then
			local t_tamer = TableTamer():get(110002)
			local illustration_res = t_tamer['res']
			local illustration_animator = MakeAnimator(illustration_res)
			illustration_animator:changeAni('idle', true)
			cut_node:addChild(illustration_animator.m_node)
		end
	end
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:click_skipBtn()
    self.m_skipBtnCnt = (self.m_skipBtnCnt + 1)
	
	-- 1회 클릭 시 실질적인 연출 시작
	if (self.m_skipBtnCnt == 1) then
		self:continueDirecting()

	-- 2회 클릭 시 스킵
    elseif (self.m_skipBtnCnt >= 2) then
        self:appearDragonAnimator()

    end
end

-------------------------------------
-- function makeDirectingList
-- @brief 진화 단계에 따른 연출 리스트 생성
-------------------------------------
function UIC_DragonAnimatorDirector_Summon:makeDirectingList(did)
	local rarity = TableDragon:getValue(did, 'rarity')
	local idx = dragonRarityStrToNum(rarity)

	self.m_lDirectingList = {}

	for i = 1, idx do
		table.insert(self.m_lDirectingList, string.format('crack_%02d', i))
	end

	table.insert(self.m_lDirectingList, 'top_appear')
end