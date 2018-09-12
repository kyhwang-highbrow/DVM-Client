ShaderCache = {}

SHADER_CHARACTER_DAMAGED = 'character_damaged'
SHADER_BLUR = 'shader_blur'
SHADER_GRAY = 'shader_gray'

SHADER_RED = 'shader_red'
SHADER_GREEN = 'shader_green'
SHADER_BLUE = 'shader_blue'

SHADER_DARK = 'shader_dark'

SHADER_GRAY_PNG  = 'shader_gray_png'

-- sprite의 default shader는 GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP
SHADER_DEFAULT_SPRITE = "ShaderPositionTextureColor_noMVP"

POSITION_TEXTURE_COLOR_P_VERTEX = 'shader/position_texture_color_P_vertex.vsh'
POSITION_TEXTURE_COLOR_NO_MVP_VERTEX = 'shader/position_texture_color_noMvp_vertex.vsh'

-------------------------------------
-- function init
-------------------------------------
function ShaderCache:init()
    -- 커스텀 쉐이더 등록
	self:addShader(SHADER_BLUR, POSITION_TEXTURE_COLOR_NO_MVP_VERTEX, 'shader/shaderBlur.fsh')
    self:addShader(SHADER_CHARACTER_DAMAGED, POSITION_TEXTURE_COLOR_NO_MVP_VERTEX, 'shader/characterDamaged.fsh')
	self:addShader(SHADER_GRAY, POSITION_TEXTURE_COLOR_NO_MVP_VERTEX, 'shader/gray.fsh')

    self:addShader(SHADER_RED, POSITION_TEXTURE_COLOR_NO_MVP_VERTEX, 'shader/red.fsh')
    self:addShader(SHADER_GREEN, POSITION_TEXTURE_COLOR_NO_MVP_VERTEX, 'shader/green.fsh')
    self:addShader(SHADER_BLUE, POSITION_TEXTURE_COLOR_NO_MVP_VERTEX, 'shader/blue.fsh')

    self:addShader(SHADER_DARK, POSITION_TEXTURE_COLOR_NO_MVP_VERTEX, 'shader/dark.fsh')

    -- png 인 경우 projection matrix 사용하여야 포지션이 틀어지지 않음 
    self:addShader(SHADER_GRAY_PNG, POSITION_TEXTURE_COLOR_P_VERTEX, 'shader/gray.fsh')
end

-------------------------------------
-- function addShader
-------------------------------------
function ShaderCache:addShader(key, vsh, fsh)
    local shader = cc.ShaderCache:getInstance():getGLProgram(key)
    if shader then return end
	
    shader = cc.GLProgram:createWithFilenames(vsh, fsh)
    cc.ShaderCache:getInstance():addGLProgram(shader, key);
end

-------------------------------------
-- function getShader
-------------------------------------
function ShaderCache:getShader(key)
    local shader = cc.ShaderCache:getInstance():getGLProgram(key)
	if (not shader) then return end

    shader:updateUniforms()

    return shader
end