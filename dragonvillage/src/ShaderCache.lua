ShaderCache = {}

CUSTOM_SHADER__CHARACTER_DAMAGED = 'character_damaged'

function ShaderCache:init()
    -- 커스텀 쉐이더 등록
    self:addShader(CUSTOM_SHADER__CHARACTER_DAMAGED, 'shader/characterDamaged.vsh', 'shader/characterDamaged.fsh')
end

function ShaderCache:addShader(key, vsh, fsh)
    local shader = cc.GLProgram:createWithFilenames(vsh, fsh)
    shader:link()

    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
    
    shader:updateUniforms()

    cc.ShaderCache:getInstance():addGLProgram(shader, SHADER_CHARACTER_DAMAGED);
end

function ShaderCache:getShader(key)
    local shader = cc.ShaderCache:getInstance():getGLProgram(key)
    shader:updateUniforms()

    return shader
end

