
UISourceCodeGenerator = class({
    m_root = 'string',

    m_uiFilePath = 'string',
    m_uiFileName = 'string',
    m_luaFileName = 'string',
    m_luaClassName = 'string',

    m_uiFileNumOfLine = 'number',
                     
    })



function UISourceCodeGenerator:init(path)
    self.m_root = '..\\res\\'
    self.m_uiFilePath = self.m_root .. path
    self.m_uiFileNumOfLine = 0
    local split_name = pl.stringx.split(path, '\\')
    self.m_uiFileName = split_name[#split_name]
    self.m_luaClassName = self:toCamel(self.m_uiFileName)
    self.m_luaFileName = self.m_luaClassName .. '.lua'

end



function UISourceCodeGenerator:toCamel(file_name)
    local offset = string.find(file_name, '.ui')
    local name_without_ext = file_name:sub(1, offset - 1)
    local name_without_underbar = pl.stringx.split(name_without_ext, '_')
    local str = 'UI_'
    for k, v in ipairs (name_without_underbar) do

        str = str .. v:sub(1, 1):upper() .. v:sub(2)
    end
    return str
end

function UISourceCodeGenerator:makeFile()
    local init_button_function_name = self.m_luaClassName .. ':initButton'
    local file_contents = self:readSourceCode()
    file_contents = self:renameInTable(file_contents, 'uiName.ui', self.m_uiFileName)
    file_contents = self:renameInTable(file_contents, 'UI_ClassForm', self.m_luaClassName)
   
    -- 이벤트 binding과 function 코드 제작
    local init_function_start_line = self:findStr(file_contents, init_button_function_name, true)
    local line_to_write_new_function = self:findStr(file_contents, '--@CHECK')
    line_to_write_new_function = line_to_write_new_function - 1

    local function_code, event_code = 
        self:makeComponentSourceCodeForm(file_contents[init_function_start_line], file_contents[line_to_write_new_function])

    file_contents[init_function_start_line], file_contents[line_to_write_new_function] = function_code, event_code
    
    local new_file_contents = ''
    for _, v in ipairs(file_contents) do
        new_file_contents = new_file_contents .. v .. '\n'
    end
    print(pl.file.write(lfs.currentdir() .. '\\generatedUI\\'.. self.m_luaFileName, new_file_contents))

end

function UISourceCodeGenerator:readSourceCode()
    local contents = pl.file.read('..\\src\\UI_ClassForm.lua')
    local contents_line = pl.stringx.splitlines(contents)
    return contents_line
end

function UISourceCodeGenerator:findStr(contents_line, name, is_function)
    is_function = is_function or false
    if (is_function) then
        name = name .. '()'
    end

    for i, v in ipairs(contents_line) do
        if (v:find(name)) then
            return i
        end
    end    
    return nil
end




function UISourceCodeGenerator:makeComponentSourceCodeForm(contents_string_to_append_event, contents_string_to_write_function)
    local ui_file_contents = pl.file.read(self.m_uiFilePath)
    local vars = loadstring('return ' .. ui_file_contents)()
    local buttons = {}

    self:walkAndFindButtonInUITable(vars, buttons)

    for _, v in ipairs(buttons) do
        
        --button init 함수 내용 작성
        contents_string_to_append_event = self:appendEventCode(contents_string_to_append_event, v)

        --button click 이벤트 함수 내용 작성
        contents_string_to_write_function = self:appendEventFunctionCode(contents_string_to_write_function, v)
    end
    return contents_string_to_append_event, contents_string_to_write_function
end

function UISourceCodeGenerator:appendEventCode(contents_string_to_append, component_name)
    return contents_string_to_append .. 
            '\n' ..
            '    self.vars[\'' .. component_name .. '\']:registerScriptTapHandler(function() \n' ..
            '        self:click_' .. component_name .. '() \n' ..
            '    end)\n'
end

function UISourceCodeGenerator:appendEventFunctionCode(contents_string_to_write_function, component_name) 
    local unicode = require 'unicode'
    local utf8 = unicode.utf8
    local comment_form =    '-------------------------------------\n' ..
                            '-- function FUNCTIONNAME\n'..
                            '-------------------------------------\n'

    local function_form =    'function CLASSNAME:FUNCTIONNAME()\n' ..
                            '    cclog(\'TODO FUNCTIONNAME event occurred!\')\n' ..
                            'end\n'

    local form = contents_string_to_write_function .. '\n' .. comment_form .. function_form
    form = form:gsub('CLASSNAME', self.m_luaClassName)

    return form:gsub('FUNCTIONNAME', 'click_' .. component_name)

end

function UISourceCodeGenerator:walkAndFindButtonInUITable(t, buttons) 
    
    for k, v in pairs(t) do
        if(type(v) == 'table') then
            self:walkAndFindButtonInUITable(v, buttons)
        else
            if (k == 'lua_name' and t['type'] == 'Button') then
                if (v ~= '') then
                    table.insert(buttons, v)
                end
            end
        end
        --다른 UIComponent를 찾고 싶으면 여기다가 조건 추가(위 button 조건처럼 찾으면 될듯)
    end
end


function UISourceCodeGenerator:renameInTable(t, target, name)
    for k, v in pairs(t) do
        t[k] = v:gsub(target, name)
    end
    return t
end