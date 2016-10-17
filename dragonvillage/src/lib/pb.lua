-- Copyright (c) 2010-2011 by Robert G. Jakabosky <bobby@neoawareness.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

local _G = _G
local rawset = rawset
local assert = assert
local sformat = string.format
local print = print
local FileUtil = cc.FileUtils:getInstance()

local mod_name = ...

local parser = require(mod_name .. "/proto/parser")
local backend = require(mod_name .. '/standard')
backend.cache = {}

local function proto_file_to_name(file)
    local name = file:gsub("%.proto$", '')
    return name:gsub('/', '.')
end

module('protobuf')

local loading = "loading...."
function load_proto(text, name, require)
    -- Use sentinel mark in cache. (to detect import loops).
    if name then
        backend.cache[name] = loading
    end

    -- parse .proto into AST tree
    local ast = parser.parse(text)

    -- process imports
    local imports = ast.imports
    if imports then
        require = require or _M.require
        for i=1,#imports do
            local import = imports[i]
            local name = proto_file_to_name(import.file)
            import.name = name
            -- recurively load imports.
            import.proto = require(name, backend)
        end
    end

    -- compile AST tree into Message definitions
    local proto = backend.compile(ast)

    -- cache compiled .proto
    if name then
        backend.cache[name] = proto
    end

    return proto
end

function require(name)
    -- check cache for compiled .proto
    local proto = backend.cache[name]
    assert(proto ~= loading, "Import loop!")
    -- return compiled .proto, if cached
    if proto then return proto end

    -- load .proto file.
    -- text = FileUtil.load('packet/' .. name)
    text = FileUtil:getStringFromFile('packet/' .. name)

    -- compile AST tree into Message definitions
    return load_proto(text, name, require)
end

-- Raw Message for Raw decoding.
local raw

function decode_raw(...)
    if not raw then
        -- need to load Raw message definition.
        local proto = load_proto("message Raw {}")
        raw = proto.Raw
    end
    -- Raw message decoding
    local msg = raw()
    return msg:Parse(...)
end

function _M.print(msg)
    io.write(msg:SerializePartial('text'))
end

