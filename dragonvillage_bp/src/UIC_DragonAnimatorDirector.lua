local PARENT = UIC_DragonAnimator

-------------------------------------
-- class UIC_DragonAnimatorDirector
-------------------------------------
UIC_DragonAnimatorDirector = class(PARENT, {
        m_topEffect = 'Animator',
        m_bottomEffect = 'Animator',

        m_skipBtnCnt = 'number', -- 두 번 터치를 해야 스킵이 되도록
        m_dragonAppearCB = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_DragonAnimatorDirector:init()
    self:setTalkEnable(false)
	
	-- UI class 구조 단순 차용
	self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UIC_DragonAnimatorDirector:initUI()
	-- 사용할 리소스 생성
	local res_name = 'res/ui/a2d/dragon_upgrade_fx/dragon_upgrade_fx.vrp'
    self.m_topEffect = MakeAnimator(res_name)
    self.m_bottomEffect = MakeAnimator(res_name)

    self.vars['topEffectNode']:addChild(self.m_topEffect.m_node)
    self.vars['bottomEffectNode']:addChild(self.m_bottomEffect.m_node)
end

-------------------------------------
-- function initButton
-------------------------------------
function UIC_DragonAnimatorDirector:initButton()
    self.vars['skipBtn']:registerScriptTapHandler(function() self:click_skipBtn() end)
end

-------------------------------------
-- function setDragonAnimator
-- @ brief 연출 종료후 나타날 드래곤 리소스 생성
-------------------------------------
function UIC_DragonAnimatorDirector:setDragonAnimator(did, evolution, flv)
    PARENT.setDragonAnimator(self, did, evolution, flv)
    self.m_animator:setVisible(false)
end

-------------------------------------
-- function setDragonAppearCB
-- @ brief 드래곤 리소스 보여준 후 실행할 콜백함수 등록
-------------------------------------
function UIC_DragonAnimatorDirector:setDragonAppearCB(cb)
    self.m_dragonAppearCB = cb
end

-------------------------------------
-- function startDirecting
-- @brief 연출 시작
-------------------------------------
function UIC_DragonAnimatorDirector:startDirecting(direct)
    local vars = self.vars
    
	-- 연출을 위한 세팅
	self.m_bottomEffect:setVisible(false)
    self.vars['skipBtn']:setVisible(true)
    self.m_skipBtnCnt = 0

	-- 연출 시작
    -- 소용돌이 애니메이션 없이 바로 결과 보여줌
    if (direct) then
        self:appearDragonAnimator()
    else
        self.m_topEffect:changeAni('top_appear')
        self.m_topEffect:addAniHandler(function() self:appearDragonAnimator() end)
    end
end

-------------------------------------
-- function appearDragonAnimator
-- @brief 연출 마무리 하며 드래곤 등장
-------------------------------------
function UIC_DragonAnimatorDirector:appearDragonAnimator()
    local vars = self.vars
    self.m_topEffect:changeAni('top_disappear', false)
    
	-- 드래곤 바닥에 깔 이펙트 보여줌
    self.m_bottomEffect:setVisible(true)
    self.m_bottomEffect:changeAni('bottom_idle', true)

	-- 드래곤 등장
    self.m_animator:setVisible(true)
	-- 스킵 버튼 블럭
    vars['skipBtn']:setVisible(false)

	-- 드래곤 등장 콜백
    if self.m_dragonAppearCB then
        self.m_dragonAppearCB()
    end
end

-------------------------------------
-- function click_skipBtn
-------------------------------------
function UIC_DragonAnimatorDirector:click_skipBtn()
    self.m_skipBtnCnt = (self.m_skipBtnCnt + 1)
	-- 2회 클릭시 드래곤 바로 보여줌
    if (self.m_skipBtnCnt >= 2) then
        self:appearDragonAnimator()
    end
end