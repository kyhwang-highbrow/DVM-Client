
UISourceCodeGenerator = class({
    m_root = 'string',

    m_uiFilePath = 'string',
    m_uiFileName = 'string',
    m_luaFileName = 'string',
    m_luaClassName = 'string',

    m_uiFileNumOfLine = 'number',
                     
    })


-------------------------------------
-- function init
-------------------------------------
function UISourceCodeGenerator:init(path)
    self.m_root = '..\\res\\'
    self.m_uiFilePath = self.m_root 
    .. path
    self.m_uiFileNumOfLine = 0
    local split_name = pl.stringx.split(path, '\\')
    self.m_uiFileName = split_name[#split_name]
    self.m_luaClassName = self:snakeToPascal(self.m_uiFileName)
    self.m_luaFileName = self.m_luaClassName .. '.lua'

end


-------------------------------------
-- function snakeToPascal
-- @brief   snake case인 ui파일이름을 Pascal case인 lua파일 이름으로 바꾼다.
-- @param   file_name   : string,       snake_case ui파일 이름
-- @return  str         : string,       PascalCase lua파일 이름
-------------------------------------
function UISourceCodeGenerator:snakeToPascal(file_name)
    local offset = string.find(file_name, '.ui')
    local name_without_ext = file_name:sub(1, offset - 1)
    local name_without_underbar = pl.stringx.split(name_without_ext, '_')
    local str = 'UI_'
    for k, v in ipairs (name_without_underbar) do

        str = str .. v:sub(1, 1):upper() .. v:sub(2)
    end
    return str
end

-------------------------------------
-- function makeFile
-- @brief ui파일을 만드는 전체적인 프로세스를 실행하는 함수.
-------------------------------------
function UISourceCodeGenerator:makeFile()
    local init_button_function_name = self.m_luaClassName .. ':initButton'
    local init_function_name        = self.m_luaClassName .. ':initUI'
    local file_contents             = self:readSourceCode()
    file_contents = self:renameInTable(file_contents, 'uiName.ui', self.m_uiFileName)
    file_contents = self:renameInTable(file_contents, 'UI_ClassForm', self.m_luaClassName)
   
    -- 이벤트 binding과 function 코드 제작
    local initButton_function_start_line = self:findStr(file_contents, init_button_function_name, true)
    local line_to_write_new_function = self:findStr(file_contents, '--@CHECK')
    local init_function_start_line = self:findStr(file_contents, init_function_name, true)
    
    initButton_function_start_line = initButton_function_start_line + 1
    line_to_write_new_function = line_to_write_new_function - 1
    init_function_start_line = init_function_start_line + 1

    local function_code, event_code, comment_code = 
        self:makeComponentSourceCodeForm(file_contents, initButton_function_start_line, line_to_write_new_function, init_function_start_line)

    file_contents[initButton_function_start_line], file_contents[line_to_write_new_function], file_contents[init_function_start_line]
         = function_code, event_code, comment_code
    
    local new_file_contents = ''
    for _, v in ipairs(file_contents) do
        new_file_contents = new_file_contents .. v .. '\n'
    end
    print(pl.file.write(lfs.currentdir() .. '\\generatedUI\\'.. self.m_luaFileName, new_file_contents))

end

-------------------------------------
-- function readSourceCode
-- @brief   classForm lua파일을 읽어서, line 단위로 split
-- @return  contents_line : number,     line 단위로 분리한 UI_ClassForm.lua 파일의 내용
-------------------------------------
function UISourceCodeGenerator:readSourceCode()
    local contents = pl.file.read('..\\src\\UI_ClassForm.lua')
    local contents_line = pl.stringx.splitlines(contents)
    return contents_line
end

-------------------------------------
-- function findStr
-- @brief   contents에서 name을 찾아서 그 line number를 반환
-- @param   contents        : string,               파일 내용
--          str             : string,               찾을 string
--          is_function     : boolean, optional,    함수인지 아닌지. 함수이면 str 뒤에 '()'를 추가
-- @return  i               : number,               찾았을 경우 그 line의 number 반환
--          nil             : nil,                  못찾았을 경우 nil 반환 
-------------------------------------
function UISourceCodeGenerator:findStr(contents, str, is_function)
    is_function = is_function or false
    if (is_function) then
        str = str .. '()'
    end

    for i, v in ipairs(contents) do
        if (v:find(str)) then
            return i
        end
    end    
    return nil
end



-------------------------------------
-- function makeComponentSourceCodeForm
-- @brief   Component들에 해당되는 소스코드를 주어진 string 뒤에 append한다.
-- @param   t                                 : table,    UI_ClassForm.lua 파일 컨텐츠를 담고 있는 테이블
--          initButton                        : number,   event handler를 append할 line number
--          newFunction                       : number,   event function을 append할 line number
--          commentComponents                 : number,   버튼이 아닌 컴포넌트들의 주석 코드가 append 될 line number
-- @return  string_to_append_button_event     : string,   event handler가 append 된 string
--          string_to_write_button_function   : string,   event function이 append된 string
--          string_to_append_other_components : string,   버튼이 아닌 컴포넌트들의 주석 코드가 append 된 string
-------------------------------------
function UISourceCodeGenerator:makeComponentSourceCodeForm(t, initButton, newFunction, commentComponents)
    string_to_append_button_event, string_to_write_button_function, string_to_append_other_components = t[initButton], t[newFunction], t[commentComponents]
    local ui_file_contents = pl.file.read(self.m_uiFilePath)
    local vars = loadstring('return ' .. ui_file_contents)()

    -- button 외의 것들을 코드에 삽입.
    local components = {}
    self:walkAndFindComponentInUITable(vars, components)
    for k, v in pairs(components) do

        -- button들 코드에 삽입.
        if(k == 'Button') then
            for k2, v2 in pairs(v) do   
                    --button init 함수 내용 작성
                string_to_append_button_event = self:appendEventCode(string_to_append_button_event, v2)

                --button click 이벤트 함수 내용 작성
                string_to_write_button_function = self:appendEventFunctionCode(string_to_write_button_function, v2)
            end
        --button 외의 components 코드에 삽입.
        else 
            for k2, v2 in pairs(v) do
                string_to_append_other_components = self:appendOtherComponentsCode(string_to_append_other_components, k, v2)
            end
        end

    end

    return string_to_append_button_event, string_to_write_button_function, string_to_append_other_components
end

-------------------------------------
-- function appendEventCode
-- @brief event handler 소스코드를 string_to_append_button_event 뒤에 append한다.
-- @param string_to_append_button_event : string,   event handler를 append할 string
--        component_name            : string,   event handler string에 포함될 컴포넌트의 이름
-- @return                          : string
-------------------------------------
function UISourceCodeGenerator:appendEventCode(string_to_append_button_event, component_name)
    return string_to_append_button_event .. 
            '\n' ..
            '    self.vars[\'' .. component_name .. '\']:registerScriptTapHandler(function() ' ..
                'self:click_' .. component_name .. '() ' ..
                'end)'
end

-------------------------------------
-- function appendEventFunctionCode
-- @brief event function 소스코드를 string_to_write_button_function 뒤에 append한다.
-- @param string_to_write_button_function : string,   event function을 append할 string
--        component_name                    : string,   event function string에 포함될 컴포넌트의 이름 
-- @return                                  : string
-------------------------------------
function UISourceCodeGenerator:appendEventFunctionCode(string_to_write_button_function, component_name) 
    local unicode = require 'unicode'
    local utf8 = unicode.utf8
    local comment_form =    '-------------------------------------\n' ..
                            '-- function FUNCTIONNAME\n'..
                            '-------------------------------------\n'

    local function_form =    'function CLASSNAME:FUNCTIONNAME()\n' ..
                            '    cclog(\'TODO FUNCTIONNAME event occurred!\')\n' ..
                            'end\n'

    local form = string_to_write_button_function .. '\n' .. comment_form .. function_form
    form = form:gsub('CLASSNAME', self.m_luaClassName)

    return form:gsub('FUNCTIONNAME', 'click_' .. component_name)

end

-------------------------------------
-- function appendOtherComponentsCode
-- @brief 주석으로써 컴포넌트의 존재를 알려주는 소스코드를 string_to_append_other_components 뒤에 append한다.
-- @param string_to_append_other_components : string,   주석 코드를 append할 string
--        component_type                    : string,   component type
--        component_name                    : string,   component name
-- @return                                  : string
-------------------------------------
function UISourceCodeGenerator:appendOtherComponentsCode(string_to_append_other_components, component_type, component_name)
    return string_to_append_other_components .. '\n' ..
            '\t--vars[\'' .. component_name .. '\'] -- ' .. component_type
end


-------------------------------------
-- function walkAndFindComponentInUITable
-- @brief 주어진 테이블을 재귀적으로 탐색하고, t 테이블의 component type을 key로 하고, t 테이블의 value를 components의 value로 넣는다.
-- @param t                 : table,                key : attributes, value : value
--        components        : table,                key : type of components, value : value
-------------------------------------
function UISourceCodeGenerator:walkAndFindComponentInUITable(t, components)
    local component_type = t['type']
    for k, v in pairs(t) do
        if(type(v) == 'table') then
            self:walkAndFindComponentInUITable(v, components, component_type)
        else
            if ( k == 'lua_name') then
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
-- function renameInTable
-- @brief 테이블 내에 존재하는 target을 찾아서 전부 str로 replace시킨다.
-- @param   t                 : table,  search 대상
--          target            : string, replace 대상
--          str               : string, str로 replace됨
-- @return  t                 : table,  replace 작업이 끝난 t.
-------------------------------------
function UISourceCodeGenerator:renameInTable(t, target, str)
    for k, v in pairs(t) do
        t[k] = v:gsub(target, str)
    end
    return t
end