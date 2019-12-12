-------------------------------------
-- class StructPackageState
-- @instance struct_product_state
-- @brief 레벨업, 모험돌파 패키지 활성화, 보상 정보 등등
-------------------------------------
StructPackageState = class({
		active = 'boolean',
        received_list = 'list',

        m_bDirty = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function StructPackageState:init(data)
    self.active = false
    self.received_list = {}
    self.m_bDirty = false

    if (data['active']) then
        self.active = data['active']
    end

    if (data['received_list']) then
        self.received_list = data['received_list']
    end
end

-------------------------------------
-- function isActive
-------------------------------------
function StructPackageState:isActive()
    return self.active
end

-------------------------------------
-- function setDirty
-------------------------------------
function StructPackageState:setDirty(dirty)
    self.m_bDirty = dirty
end

-------------------------------------
-- function getDirty
-------------------------------------
function StructPackageState:getDirty()
    return self.m_bDirty
end

-------------------------------------
-- function isReceived
-------------------------------------
function StructPackageState:isReceived(lv)
    for i,v in pairs(self.received_list) do
        if (v == lv) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function setReceievedList
-------------------------------------
function StructPackageState:setReceievedList(l_received)
    self.received_list = l_received or {}
end