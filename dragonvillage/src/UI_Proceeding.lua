PARENT = UI

-------------------------------------
-- class UI_Proceeding
-------------------------------------
UI_Proceeding = class(PARENT, {
    m_dragonAnimator = 'UIC_DragonAnimator',
})

-------------------------------------
-- function init
-------------------------------------
function UI_Proceeding:init()
    local vars = self:load('proceeding_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- UI 클래스명 지정
    self.m_uiName = 'UI_Proceeding'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Proceeding')

    self:initUI()
    --self:initButton()
    self:refresh()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_Proceeding:initUI()
    local vars = self.vars

    -- vars['dragonNode']

    -- vars['bgNode']
    -- vars['descLabel']

    self:initTamer()
    self:initDragon()
    
    do -- 배경 이미지 생성
        local stage_id = 1110403

        local difficulty, chapter, stage = parseAdventureID(stage_id)

        local bg_node = vars['bgNode']
        local scroll_map = ResHelper:makeUIAdventureChapterBG(bg_node, chapter)

        --scroll_map:setDockPoint(cc.p(0.5, 0.5))
        --scroll_map:setAnchorPoint(cc.p(0.5, 0.5))


        --setTexture('res/ui/event/myth/bg_hatchery_myth_0' .. i .. '.png')
    end
end

function UI_Proceeding:initTamer()
    local vars = self.vars

    local table_tamer = TableTamer()
    local tamer_id = g_tamerData:getCurrTamerID()
    local costume_data = g_tamerCostumeData:getCostumeDataWithTamerID(tamer_id)
    local tamer_res = costume_data:getResSD()
    local animator = MakeAnimator(tamer_res)
	if (animator) then
		animator:setDockPoint(0.5, 0.5)
		animator:setAnchorPoint(0.5, 0.5)
		--animator:setScale(2)
		--animator:setPosition(0, 50)
        animator:changeAni('move', true)
		vars['tamerNode']:addChild(animator.m_node)
	end
end

function UI_Proceeding:initDragon()
    
    if (not self.m_dragonAnimator) then
        self.m_dragonAnimator = UIC_DragonAnimator()
        self.vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
    end

    --local dragon_list = g_dragonsData:getDragonsListRef()
    local leader_dragon = g_dragonsData:getLeaderDragon()
    self.m_dragonAnimator:setDragonAnimatorByTransform(leader_dragon)
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_Proceeding:initButton()
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_Proceeding:refresh()

end