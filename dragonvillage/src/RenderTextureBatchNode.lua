-------------------------------------
-- class RenderTextureBatchNode
-- @brief Animator(spine or vrp)를 texture로 만들어서 배치노드를 생성
-------------------------------------
RenderTextureBatchNode = class({
        m_batchNode = 'cc.SpriteBatchNode',
    })

-------------------------------------
-- function init
-------------------------------------
function RenderTextureBatchNode:init()
end

-------------------------------------
-- function init_fromRes
-------------------------------------
function RenderTextureBatchNode:init_fromRes(res, scale)
    local animator

    if (AnimatorHelper:isIntegratedSpineResName(res)) then
        animator = MakeAnimatorSpineToIntegrated(res)
    else
        animator = MakeAnimator(res)
    end

    if scale then
        animator:setScale(scale)
    end
    local batch_node = self:makeBatchNode(animator.m_node)
    self:setBatchNode(batch_node)
end

-------------------------------------
-- function makeBatchNode
-------------------------------------
function RenderTextureBatchNode:makeBatchNode(node)
    local content_size = node:getContentSize()

    local width = content_size['width']
    local height = content_size['height']

    if (width == 0) then
        width = 512
    else
        width = width * node:getScaleX()
    end

    if (height == 0) then
        height = 512
    else
        height = height * node:getScaleY()
    end

    local render = cc.RenderTexture:create(width, height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    render:begin()
    node:setPosition(width/2, height/2)
    node:visit()
    render:endToLua()

    local texture = render:getSprite():getTexture()

    local batch = cc.SpriteBatchNode:createWithTexture(texture)
    batch:setDockPoint(cc.p(0.5, 0.5))
    batch:setAnchorPoint(cc.p(0.5, 0.5))

    return batch
end

-------------------------------------
-- function setBatchNode
-------------------------------------
function RenderTextureBatchNode:setBatchNode(batch_node)
    if self.m_batchNode then
        self.m_batchNode:removeFromParent(true)
        self.m_batchNode = nil
    end

    self.m_batchNode = batch_node
end

-------------------------------------
-- function getSprite
-------------------------------------
function RenderTextureBatchNode:getSprite()
    local texture = self.m_batchNode:getTexture()
    local sprite = cc.Sprite:createWithTexture(texture)
    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    sprite:setFlippedY(true)
    self.m_batchNode:addChild(sprite)

    return sprite
end