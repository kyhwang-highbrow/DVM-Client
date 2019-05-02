local PARENT = UI_ReadySceneNew

-------------------------------------
-- class UI_ReadySceneNew_IllusionDungeon
-------------------------------------
UI_ReadySceneNew_IllusionDungeon = class(PARENT,{

    })

-------------------------------------
-- function init
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:init(stage_id, sub_info)
	-- �巡�� �����ϴ� â��, Ư�� �巡�� �߰�
	self:addSpecialDragon()
end

-------------------------------------
-- function click_manageBtn
-- @breif �巡�� ����
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:click_manageBtn()
    local function next_func()
        local ui = UI_DragonManageInfo()
        local function close_cb()
            local function func()
                self:refresh()
                self.m_readySceneSelect:init_dragonTableView()
				-- �巡�� �����ϴ� â��, Ư�� �巡�� �߰�
				self:addSpecialDragon()
                self.m_readySceneDeck:init_deck()

                do -- ���� �����
					self:apply_dragonSort()
                end
            end
            self:sceneFadeInAction(func)
        end
        ui:setCloseCB(close_cb)
    end
    
    -- �� ���� �� �̵�
    self:checkChangeDeck(next_func)
end

-------------------------------------
-- function addSpecialDragon
-- @breif �巡�� �����ϴ� â��, Ư�� �巡�� �߰�
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:addSpecialDragon()

	if (not self.m_readySceneSelect) then
		return
	end

	local select_table_view = self.m_readySceneSelect.m_tableViewExtMine
	if (not select_table_view) then
		return
	end

	-- ���� ���� �巡��
	local l_dragon_list = g_dragonsData:getDragonsList()

	-- �ӽ÷� �߿��� �巡�� ����
	-- 120301 - 120305
	local table_dragon = TableDragon()
	for i=1,5 do
		local t_dragon = {}
		t_dragon['did'] = 120300+i
		t_dragon['grade'] = 5
		t_dragon['evolution'] = 3
		l_dragon_list['illusionDragon'..i] = t_dragon
	end    

	select_table_view:setItemList(l_dragon_list)
end

