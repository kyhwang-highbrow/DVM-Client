-------------------------------------
-- table TutorialHelper
-------------------------------------
TutorialHelper = {}

-------------------------------------
-- function playTutorial
-- @brief wrapping
-------------------------------------
function TutorialHelper:playTutorial(scenario_name, tar_ui)
    g_scenarioViewingHistory:playTutorial(scenario_name, tar_ui)
end

-------------------------------------
-- function convertToWorldSpace
-- @brief 
--[[
    tutorial에서 사용하기 좋도록 대상 node를 원래의 부모에서 떼어내어
    new_parent에 붙이는 것으로 가정한 화면상의 위치 계산
]]
-- @return cc.p : node의 dock과 anchor를 고려한 좌표 
-------------------------------------
function TutorialHelper:convertToWorldSpace(new_parent, node)
    -- node의 화면에서 보이는 사이즈를 구해온다.
    -- 이때 좌표는 dock_point (0,0) anchor_point (0, 0) 기준
	local transform = node:getNodeToWorldTransform() 
	local world_x = transform[12 + 1]
	local world_y = transform[13 + 1]

    -- dock과 anchor를 고려하여 가감해준다
    local dock_point = node:getDockPoint()
    local anchor_point = node:getAnchorPoint()
    local node_size = node:getContentSize()
    local content_size = new_parent:getContentSize()

    world_x = world_x - (dock_point['x'] * content_size['width']) + (anchor_point['x'] * node_size['width'])
    world_y = world_y - (dock_point['y'] * content_size['height']) + (anchor_point['y'] * node_size['height'])

    return {x = world_x, y = world_y}
end

-------------------------------------
-- function getStencilRectangle
-- @brief 받아온 node를 0,0 을 기준으로 스텐실을 생성할 좌표를 계산한다
-------------------------------------
function TutorialHelper:getStencilRectangle(node)
    -- 화면상에서 보이는 0,0 기준 좌표
	local transform = node:getNodeToWorldTransform() 
	local world_x = transform[12 + 1]
	local world_y = transform[13 + 1]

    -- node의 크기 계산
    local node_size = node:getContentSize()
    local width = node_size['width']
    local height = node_size['height']
   
    -- 사각형 좌표
    local retangle = {
        cc.p(world_x, world_y),
        cc.p(world_x + width, world_y),
        cc.p(world_x + width, world_y + height),
        cc.p(world_x, world_y + height),
    }

    return retangle
end