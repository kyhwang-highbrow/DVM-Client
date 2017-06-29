local PARENT = UI_DragonManage_Base

-------------------------------------
-- class UI_DragonSell
-------------------------------------
UI_DragonSell = class(PARENT,{
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonSell:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonSell'
    self.m_bVisible = true
    self.m_titleStr = Str('드래곤 판매')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSell:init(doid)
    local vars = self:load('dragon_sell.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonSell')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()

    -- 첫 선택 드래곤 지정
    --self:setDefaultSelectDragon(doid)

    -- 정렬 도우미
    --self:init_dragonSortMgr()
	self:init_mtrDragonSortMgr()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSell:initUI()
	local vars = self.vars
    --self:init_dragonTableView()
	self:init_bg()
	vars['priceLabel']:setString(0)
	vars['sortBtn']:setVisible(false)
	vars['sortOrderBtn']:setVisible(false)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_DragonSell:initButton()
    local vars = self.vars
    vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSell:refresh()
    self:refresh_selectedMaterial()
	self:refresh_dragonMaterialTableView()
end

-------------------------------------
-- function init_bg
-- @brief 드래곤 정보
-------------------------------------
function UI_DragonSell:init_bg()
    local vars = self.vars

    -- 배경
    local animator = ResHelper:getUIDragonBG('earth', 'idle')
    vars['bgNode']:addChild(animator.m_node)
end

-------------------------------------
-- function getDragonMaterialList
-- @brief 재료리스트 : 레벨업
-- @override
-------------------------------------
function UI_DragonSell:getDragonMaterialList(doid)
    local dragon_dic = g_dragonsData:getDragonListWithSlime()

    -- 자기 자신 드래곤 제외
    if doid then
        dragon_dic[doid] = nil
    end

    -- 재료로 사용 불가능한 드래곤 제외
    for oid,v in pairs(dragon_dic) do
        if (not g_dragonsData:possibleMaterialDragon(oid)) then
            dragon_dic[oid] = nil
        end
    end

    return dragon_dic
end

-------------------------------------
-- function click_dragonMaterial
-- @override
-------------------------------------
function UI_DragonSell:click_dragonMaterial(t_dragon_data)
    local doid = t_dragon_data['id']

    self:refresh_materialDragonIndivisual(doid)
    self:refresh_selectedMaterial()
end

-------------------------------------
-- function refresh_materialDragonIndivisual
-- @brief 드래곤 재료 리스트에서 선택된 드래곤 표시
-------------------------------------
function UI_DragonSell:refresh_materialDragonIndivisual(doid)
    if (not self.m_mtrlTableViewTD) then
        return
    end

    local item = self.m_mtrlTableViewTD:getItem(doid)
    if (not item) then
        return
    end
    
    local ui = item['ui']
    if (not ui) then
        return
    end

    ui:setCheckSpriteVisible(true)
end

-------------------------------------
-- function refresh_selectedMaterial
-- @brief 선택된 재료의 구성이 변경되었을때
-------------------------------------
function UI_DragonSell:refresh_selectedMaterial()
end

-------------------------------------
-- function createDragonCardCB
-- @brief 드래곤 생성 콜백
-- @override
-------------------------------------
function UI_DragonSell:createDragonCardCB(ui, data)
    local doid = data['id']

    local possible, msg = g_dragonsData:possibleMaterialDragon(doid)
    if (not possible) then
        if ui then
            ui:setShadowSpriteVisible(true)
        end
    end
end

-------------------------------------
-- function checkDragonSelect
-- @brief 선택이 가능한 드래곤인지 여부
-- @override
-------------------------------------
function UI_DragonSell:checkDragonSelect(doid)
	-- 재료용 검증 함수이지만 판매와 동일하기 때문에 사용
    local possible, msg = g_dragonsData:possibleMaterialDragon(doid)

    if possible then
        return true
    else
        UIManager:toastNotificationRed(msg)
        return false
    end
end

-------------------------------------
-- function click_sellBtn
-- @brief
-------------------------------------
function UI_DragonSell:click_sellBtn()

end

--@CHECK
UI:checkCompileError(UI_DragonSell)
