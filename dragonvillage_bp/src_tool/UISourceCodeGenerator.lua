require 'LuaStandAlone'

-------------------------------------
-- class UISourceCodeGenerator
-------------------------------------
UISourceCodeGenerator = class({
    m_uiFilePath = 'string',
    m_uiFileName = 'string',
    m_luaFileName = 'string',
    m_luaClassName = 'string',

    m_uiFileNumOfLine = 'number',
                     
    })


-------------------------------------
-- function init
-------------------------------------
function UISourceCodeGenerator:init()
    local path = self:getUserInput()
    self.m_uiFilePath = path
    self.m_uiFileNumOfLine = 0

    -- 전체 경로에서 이름만 얻어냄.
    local split_name = pl.stringx.split(path, '\\')
    self.m_uiFileName = split_name[#split_name]

    -- ui파일의 이름을 통해 PascalCase의 LUA 클래스 이름을 얻어냄.
    self.m_luaClassName = self:snakeToPascal(self.m_uiFileName)

    -- extension 추가
    self.m_luaFileName = self.m_luaClassName .. '.lua'

end


-------------------------------------
-- function snakeToPascal
-- @brief   snake case인 ui파일이름을 Pascal case인 lua파일 이름으로 바꾼다.
-- @param   file_name   : string,   snake_case ui파일 이름
-- @return  str         : string,   PascalCase lua파일 이름
-------------------------------------
function UISourceCodeGenerator:snakeToPascal(file_name)

    -- 이름을 '_'제거하고 확장자 떼서 파일 이름만 남도록 가공
    local offset = string.find(file_name, '.ui')
    local name = file_name:sub(1, offset - 1)
    name = pl.stringx.split(name, '_')

    -- 새로운 이름 생성
    local str = 'UI_'
    for k, v in ipairs (name) do

        str = str .. v:sub(1, 1):upper() .. v:sub(2)
    end
    return str
end

-------------------------------------
-- function makeFile
-- @brief ui파일을 만드는 전체적인 프로세스를 실행하는 함수.
-------------------------------------
function UISourceCodeGenerator:makeFile()
    local initButton_str = self.m_luaClassName .. ':initButton'
    local init_str       = self.m_luaClassName .. ':initUI'
    local contents       = self:readFile('..\\src\\UI_ClassForm.lua')
    for k, v in pairs(contents) do
        contents[k] = contents[k]:gsub('uiName%.ui', self.m_uiFileName)
        contents[k] = contents[k]:gsub('UI_ClassForm', self.m_luaClassName)
    end
    --------------------------------------------------------------------------
    -- 1. 이벤트 binding과 function 코드 제작
    local initButton_line = self:findStr(contents, initButton_str, true)[1]
    local new_function_line = self:findStr(contents, '--@CHECK')[1]
    local init_line = self:findStr(contents, init_str, true)[1]
    
    --------------------------------------------------------------------------
    -- 2. line을 기준으로 정확한 위치에 올 수 있게 offset을 더해줌.
    initButton_line = initButton_line + 1
    new_function_line = new_function_line - 1
    init_line = init_line + 1

    --------------------------------------------------------------------------
    -- 3. 소스코드를 만들어서 기존의 string에 붙여줌.
    local function_code, event_code, comment_code = 
        self:makeCode(contents, initButton_line, new_function_line, init_line)

    contents[initButton_line], contents[new_function_line], contents[init_line]
         = function_code, event_code, comment_code
    
    --------------------------------------------------------------------------
    -- 4. 새로운 파일 내용을 새로운 파일에 쓴다.
    local new_contents = ''
    for _, v in ipairs(contents) do
        new_contents = new_contents .. v .. '\n'
    end
    pl.file.write('generatedUI\\'.. self.m_luaFileName, new_contents)
    print(self.m_luaFileName)
    pl.file.write('..\\src\\' .. self.m_luaFileName, new_contents)

    --------------------------------------------------------------------------
    -- 5. 기타 환경설정 파일에 쓴 파일 정보를 추가함.
    self:addToRequire()     -- require.lua
    self:addToVSFilter()    -- vcxproj.filters
    self:addToVSProj()      -- vcxproj


end

-------------------------------------
-- function readFile
-- @brief   classForm lua파일을 읽어서, line 단위로 split
-- @return  contents_line   : number,     line 단위로 분리한 UI_ClassForm.lua 파일의 내용
-------------------------------------
function UISourceCodeGenerator:readFile(file_name)
    local contents = pl.file.read(file_name)
    local contents_line = pl.stringx.splitlines(contents)
    return contents_line
end

-------------------------------------
-- function findStr
-- @brief   contents에서 str을 찾아서 그 line number를 반환
-- @param   contents        : string,               파일 내용
--          str             : string,               찾을 string
--          is_function     : boolean, optional,    함수인지 아닌지. 함수이면 str 뒤에 '()'를 추가
-- @return  i               : number,               찾았을 경우 그 line의 number 반환
--          nil             : nil,                  못찾았을 경우 nil 반환 
-------------------------------------
function UISourceCodeGenerator:findStr(contents, str, is_function)
    is_function = is_function or false
    local l_line_num = {}
    if (is_function) then
        str = str .. '()'
    end

    for i, v in ipairs(contents) do
        if (v:find(str)) then
            table.insert(l_line_num, i)
        end
    end    
    if(#l_line_num > 0) then
        return l_line_num
    end
    return nil
end



-------------------------------------
-- function makeCode
-- @brief   Component들에 해당되는 소스코드를 주어진 string 뒤에 append한다.
-- @param   t               : table,    UI_ClassForm.lua 파일 컨텐츠를 담고 있는 테이블
--          initButton      : number,   event handler를 append할 line number
--          newFunction     : number,   event function을 append할 line number
--          comment         : number,   버튼이 아닌 컴포넌트들의 주석 코드가 append 될 line number
-- @return  btn_event_str   : string,   event handler가 append 된 string
--          btn_func_str    : string,   event function이 append된 string
--          comment_str     : string,   버튼이 아닌 컴포넌트들의 주석 코드가 append 된 string
-------------------------------------
function UISourceCodeGenerator:makeCode(t, initButton, newFunction, comment)
    btn_event_str, btn_func_str, comment_str = t[initButton], t[newFunction], t[comment]
    local ui_contents = pl.file.read(self.m_uiFilePath)
    local vars = loadstring('return ' .. ui_contents)()
    
    -- button 외의 것들을 코드에 삽입.
    local components = {}
    self:findComponents(vars, components, 'lua_name')
    for k, v in pairs(components) do

        -- button들 코드에 삽입.
        if(k == 'Button') then
            for k2, v2 in pairs(v) do   
                    --button init 함수 내용 작성
                btn_event_str = self:appendEvent(btn_event_str, v2)

                --button click 이벤트 함수 내용 작성
                btn_func_str = self:appendEventFunc(btn_func_str, v2)
            end
        --button 외의 components 코드에 삽입.
        else 
            for k2, v2 in pairs(v) do
                comment_str = self:appendComment(comment_str, k, v2)
            end
        end

    end

    return btn_event_str, btn_func_str, comment_str
end

-------------------------------------
-- function appendEvent
-- @brief event handler 소스코드를 btn_event_str 뒤에 append한다.
-- @param btn_event_str     : string,   event handler를 append할 string
--        component_name    : string,   event handler string에 포함될 컴포넌트의 이름
-- @return                  : string
-------------------------------------
function UISourceCodeGenerator:appendEvent(btn_event_str, component_name)
    return btn_event_str .. 
            '\n' ..
            '    self.vars[\'' .. component_name .. '\']:registerScriptTapHandler(function() ' ..
                'self:click_' .. component_name .. '() ' ..
                'end)'
end

-------------------------------------
-- function appendEventFunc
-- @brief event function 소스코드를 btn_func_str 뒤에 append한다.
-- @param btn_func_str      : string,   event function을 append할 string
--        component_name    : string,   event function string에 포함될 컴포넌트의 이름 
-- @return                  : string
-------------------------------------
function UISourceCodeGenerator:appendEventFunc(btn_func_str, component_name) 
    local comment_form =    '-------------------------------------\n' ..
                            '-- function FUNCTIONNAME\n'..
                            '-------------------------------------\n'

    local function_form =    'function CLASSNAME:FUNCTIONNAME()\n' ..
                            '    cclog(\'TODO FUNCTIONNAME event occurred!\')\n' ..
                            'end\n'

    local form = btn_func_str .. '\n' .. comment_form .. function_form
    form = form:gsub('CLASSNAME', self.m_luaClassName)

    return form:gsub('FUNCTIONNAME', 'click_' .. component_name)

end

-------------------------------------
-- function appendComment
-- @brief 주석으로써 컴포넌트의 존재를 알려주는 소스코드를 comment_str 뒤에 append한다.
-- @param comment_str       : string,   주석 코드를 append할 string
--        component_type    : string,   component type
--        component_name    : string,   component name
-- @return                  : string
-------------------------------------
function UISourceCodeGenerator:appendComment(comment_str, component_type, component_name)
    return comment_str .. '\n' ..
            '\t--vars[\'' .. component_name .. '\'] -- ' .. component_type
end


-------------------------------------
-- function findComponents
-- @brief 주어진 테이블을 재귀적으로 탐색하고, t 테이블의 component type을 key로 하고, t 테이블의 value를 components의 value로 넣는다.
-- @param t             : table,    key : attributes, value : value
--        components    : table,    key : type of components, value : value
--        key           : string,   찾을 key
-------------------------------------
function UISourceCodeGenerator:findComponents(t, components, key)
    local component_type = t['type']
    for k, v in pairs(t) do
        if(type(v) == 'table') then
            self:findComponents(v, components, key)
        else
            if ( k == key) then
                if (v ~= '') then
                    if(not components[component_type]) then
                        components[component_type] = {}
                    end 
                    table.insert(components[component_type], v)
                end
            end
        end
    end
end

-------------------------------------
-- function addToRequire
-- @brief   require.lua 파일의 -UI : Generated 주석 아래에 생성한 파일의 클래스명을 추가한다.
-------------------------------------
function UISourceCodeGenerator:addToRequire()
    local file = pl.file.read('..\\src\\require.lua')
    local offset = self.m_luaFileName:find('.lua')
    local name_without_ext = self.m_luaFileName:sub(1, offset - 1)

    if(file:find('\t\'' .. name_without_ext .. '\',')) then
        return
    end

    file = file:gsub('UI : Generated', 'UI : Generated\n' .. '\t\'' .. name_without_ext .. '\',')
    pl.file.write('..\\src\\require.lua', file)
end

-------------------------------------
-- function addToVSFileter
-- @brief   vcxprog.filter 파일의 xml에 생성한 파일을 추가한다.
-------------------------------------
function UISourceCodeGenerator:addToVSFilter()
    local xml_str = '\n' ..
                    '\t\t<None Include=\"..\\src\\' .. self.m_luaFileName .. '\">\n' ..
                        '\t\t\t<Filter>lua\\UI</Filter>\n' ..
                    '\t\t</None>'
    local file = pl.file.read('..\\proj.win32\\DragonVillage.vcxproj.filters')
    if(file:find(xml_str)) then
        return
    end
    local contents = pl.stringx.splitlines(file)
    local line_number = nil
    
    for i = 1, #contents do
        if (contents[i]:find('<Filter>lua')) then
            line_number = i
            break
        end
    end
    contents[line_number - 2] = contents[line_number - 2] .. xml_str

    file = ''
    for i = 1, #contents do
        file = file .. contents[i] .. '\n'
    end

    pl.file.write('..\\proj.win32\\DragonVillage.vcxproj.filters', file)
end

-------------------------------------
-- function addToVSProj
-- @brief   vcxprog 파일의 xml에 생성한 파일의 경로를 추가한다.
-------------------------------------
function UISourceCodeGenerator:addToVSProj()
    local xml_str = '<None Include=\"..\\src\\' .. self.m_luaFileName .. '\" />'
    local file = pl.file.read('..\\proj.win32\\DragonVillage.vcxproj')
    local contents = pl.stringx.splitlines(file)

    if(file:find(xml_str)) then
        return
    end

    for i = 1, #contents do
        local strip_string = pl.stringx.lstrip(contents[i])
        if (strip_string:find('<None Include=')) then
            
            if (strip_string:lower() > xml_str:lower()) then
                contents[i - 1] = contents[i - 1] .. '\n\t  ' .. xml_str
                break
            end
        end
    end
    
    file = ''
    for i = 1, #contents do
        file = file .. contents[i] .. '\n'
    end
    pl.file.write('..\\proj.win32\\DragonVillage.vcxproj', file)
    
end


-------------------------------------
-- function getUserInput
-- @brief   user input을 받는다.
-- @return  string,     user input
-------------------------------------
function UISourceCodeGenerator:getUserInput()
    print('Input ui file (full-path) (ex : \"aaa\\bbb\\xxx.ui\") :')
    return io.read()
end


-- lua class 파일 자체에서 실행되도록 함
if (arg[1] == 'run') then
    UISourceCodeGenerator():makeFile()
end