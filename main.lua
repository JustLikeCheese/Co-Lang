require "import"

CoSyntax = {}
CoSyntax.codeSplit = function(code)
  -- 语法分析
  local startIndex = 0
  local stringMode, stringMode2 = false, false
  local result, numberMode = {}, false
  local word
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

CoSyntax.codeTypes = function(codes)
  local result = {}
  for i = 1, #codes do
    local code = codes[i]
    local type = CoSyntax.codeType(code)
    table.insert(result, type)
  end
  return result
end

CoSyntax.codeVariables = function(codes)
  local result = {}
  for i = 1, #codes do
    local code = codes[i]
    local type = CoSyntax.codeType(code)
    table.insert(result, type == 0) -- 判断是否为变量
  end
  return result
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
-- 添加变量
CoState.put = function(name, value, type)
  local index = table.findValue(CoNames, name)
  if index == 0 then
    table.insert(CoNames, name)
    table.insert(CoValues, value)
    table.insert(CoTypes, type)
  else
    CoValues[index] = value
    CoTypes[index] = type
  end
end

-- 获取变量值
CoState._getValue = function(name)
  for i = 1, #CoNames do
    if CoNames[i] == name then
      return CoValues[i]
    end
  end
  return "null"
end

-- 获取表达式的值
CoState.getValue = function(name)
  local codeType = CoSyntax.codeType(name)
  if codeType == 0 then
    -- 如果为变量
    local value = CoState._getValue(name)
    local type = CoState.getType(name)
    if type == "number" or type == "string" then
      return value
    elseif type == "function" then
      return "function: 0x"
    else
      return "null"
    end
  elseif codeType == 1 then
    -- 如果为数字字面量
    return name
  elseif codeType == 2 then
    -- 如果为字符串字面量
    return name:sub(2, #name - 1)
  end
end

CoState.getValues = function(names)
  local result = {}
  for i = 1, #names do
    table.insert(result, CoState.getValue(names[i]))
  end
  return result
end

-- 获取变量类型
CoState._getType = function(name)
  for i = 1, #CoNames do
    if CoNames[i] == name then
      return CoTypes[i]
    end
  end
  return "null"
end

-- 获取表达式类型
CoState.getType = function(name)
  local codeType = CoSyntax.codeType(name)
  if codeType == 0 then
    -- 如果为变量
    return CoState._getType(name)
  elseif codeType == 1 then
    -- 如果为数字字面量
    return "number"
  elseif codeType == 2 then
    -- 如果为字符串字面量
    return "string"
  end
  return "null"
end

CoState.getTypes = function(names)
  local result = {}
  for i = 1, #names do
    table.insert(result, CoState.getType(names[i]))
  end
  return result
end

CoLineCounter = 0       -- 行计数器
StandardError = ""      -- 标准错误输出
ParameterValues = {}    -- 参数值
ParameterTypes = {}     -- 参数类型
ParameterVariables = {} -- 参数是否为变量
ReturnValues = {}       -- 返回值
ReturnTypes = {}        -- 返回类型
CoState.load = function(lines)
  CoLineCounter = 0
  CoSyntax.codeFormat(lines)
  while true do
    -- 行计数器加一
    CoLineCounter = CoLineCounter + 1
    -- 获取当前行
    local Line = lines[CoLineCounter]
    local Parameters = CoSyntax.codeSplit(Line)
    local Function = Parameters[1]
    if Function == "!" then
      -- 错误
      error(Parameters[2])
      return
    end
    table.remove(Parameters, 1)
    -- 标准错误输出
    StandardError = ""
    -- 获取参数值和类型
    ParameterValues = CoState.getValues(Parameters)         -- 获取表达式值
    ParameterTypes = CoState.getTypes(Parameters)           -- 获取表达式类型
    ParameterVariables = CoSyntax.codeVariables(Parameters) -- 获取参数是否为变量，如果为变量则为true
    ReturnValues = {}
    ReturnTypes = {}
    if Function == "const" then
      if ParameterVariables[1] then
        local value = ParameterValues[2]
        local type = ParameterTypes[2]
        table.insert(ReturnValues, value)
        table.insert(ReturnTypes, type)
      else
        StandardError = "SyntaxError: 赋值语句的左边不能为常量。"
      end
    elseif Function == "echo" then
      local result = ""
      for i = 1, #ParameterValues do
        result = result .. ParameterValues[i] .. " "
      end
      print(result)
    else
      StandardError = "RuntimeError: 名为 `" .. Function .. "` 的函数不存在。"
    end
    -- 检查标准错误输出是否不为空
    if StandardError ~= "" then
      error(StandardError, 2)
      return
    end
    -- 检查返回值
    if #ReturnValues > 0 then
      for i = 1, #ReturnValues do
        if ParameterVariables[i] then
          -- 如果为变量则返回变量
          CoState.put(Parameters[i], ReturnValues[i], ReturnTypes[i])
        end
      end
    end
    if CoLineCounter == #lines then
      break
    end
  end
end

-- print(dump(CoSyntax.codeSplit("Hello World!")))
CoState.load({
  "const a \"Hello World!\"",
  "echo a 111"
})
