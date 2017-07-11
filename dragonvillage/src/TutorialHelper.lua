-------------------------------------
-- table Tutorial_Lobby
-------------------------------------
TutorialHelper = {}

-------------------------------------
-- function convertToWorldSpace
-- @brief 
--[[
    tutorial���� ����ϱ� ������ ��� node�� ������ �θ𿡼� �����
    new_parent�� ���̴� ������ ������ ȭ����� ��ġ ���
]]
-- @return cc.p : node�� dock�� anchor�� ����� ��ǥ 
-------------------------------------
function TutorialHelper:convertToWorldSpace(new_parent, node)
    -- node�� ȭ�鿡�� ���̴� ����� ���ؿ´�.
    -- �̶� ��ǥ�� dock_point (0,0) anchor_point (0, 0) ����
	local transform = node:getNodeToWorldTransform() 
	local world_x = transform[12 + 1]
	local world_y = transform[13 + 1]

    -- dock�� anchor�� ����Ͽ� �������ش�
    local dock_point = node:getDockPoint()
    local anchor_point = node:getAnchorPoint()
    local node_size = node:getContentSize()
    local content_size = new_parent:getContentSize()

    world_x = world_x - (dock_point['x'] * content_size['width']) + (anchor_point['x'] * node_size['width'])
    world_y = world_y - (dock_point['y'] * content_size['height']) + (anchor_point['y'] * node_size['height'])

    return {x = world_x, y = world_y}
end