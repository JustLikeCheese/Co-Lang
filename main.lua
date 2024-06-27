require "import"

CoSyntax = {}
CoSyntax.codeSplit = function(code)
  -- 语法分析
  local startIndex = 0
  local stringMode, stringMode2 = false, false
  local result, numberMode = {}, false
  local word = nil
  for index = 1, #code do
    -- 获取每个字符
    local char = string.sub(code, index, index)
    if startIndex == 0 then -- 如果开始
      if char ~= ' ' then   -- 如果不为空格
        startIndex = index
        stringMode = char == '\"'
        numberMode = table.contains({ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '-' }, char)
      end
    elseif stringMode2 then                        -- 如果为反义模式
      stringMode2 = false                          -- 取消反义模式
    elseif stringMode then                         -- 字符串模式
      if char == '\\' then                         -- 如果为反斜杠
        stringMode2 = true                         -- 开启反义模式
      elseif char == '\"' then                     --如果为双引号,结束字符串
        word = string.sub(code, startIndex, index) -- 截取字符串
        stringMode = false                         -- 更新字符串模式
        startIndex = 0
      end
    elseif char == ' ' then -- 如果为空格(普通模式)
      word = string.sub(code, startIndex, index - 1) -- 截取字符串
      startIndex = 0
    elseif char == '\"' then -- 如果为双引号(普通模式)
      word = string.sub(code, startIndex, index - 1) -- 截取字符串
      stringMode = true -- 更新字符串模式
      startIndex = index -- 更新开始位置
    elseif numberMode and table.contains({ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' }, char) == false then -- 如果为非法字符
      return { "!", "SyntaxError: 非法的字面量。" } -- 返回错误
    end
    if word ~= nil then -- 如果为回收状态
      table.insert(result, word)
      word = nil
    end
  end
  if stringMode then         -- 如果双引号未结束
    return { "!", "SyntaxError: 未闭合的双引号。" }
  elseif startIndex > 0 then -- 如果还有未回收的字符串
    word = string.sub(code, startIndex, #code)
    table.insert(result, word)
  end
  return result
end

CoSyntax.codeType = function(code)
  local char = string.sub(code, 1, 1)
  if char == '\"' then
    return 2 -- string
  elseif table.contains({ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '-' }, char) then
    return 1 -- number
  else
    return 0 -- variable
  end
end

CoSyntax.codeFormat = function(lines)
  for i = 1, #lines do
    local line = lines[i]
        :gsub("\n", "") -- 删除换行符
        :gsub("\t", "") -- 删除制表符
        :gsub(" ", "")  -- 删除空格
    if line == "" or line:sub(1, 2) == "//" then
      table.remove(lines, i)
      i = i - 1
    end
  end
  return lines
end

-- CoState
CoState = {}
CoNames = {}
CoValues = {}
CoTypes = {}
CoState.put = function(name, value, type)
  table.insert(CoNames, name)
  table.insert(CoValues, value)
  table.insert(CoTypes, type)
end

CoState.get = function(name)
  for i = 1, #CoNames do
    if CoNames[i] == name then
      return CoValues[i]
    end
  end
  return "null"
end

CoState.get2 = function(name)
  local value = CoState.get(name)
  local type = CoState.type(name)
  if type == "number" or type == "string" then
    return value
  elseif type == "function" then
    return "function: 0x"
  end
end

CoState.type = function(name)
  for i = 1, #CoNames do
    if CoNames[i] == name then
      return CoTypes[i]
    end
  end
  return "null"
end

CoState.load = function(lines)
end

-- print(dump(CoSyntax.codeSplit("Hello World!")))
CoState.load({ "echo \"HelloWorld!" })
