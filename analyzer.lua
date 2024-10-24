-- ----------------------------------------------------------------------------
-- The analyzer works with hexadecimal binary function definitions and t-th
-- order correlation immunity. Two algorithms exist, the naive approach
-- and a somewhat optimized version. (-n or -o)To use the script try:
-- lua analyzer.lua <binary-function-hex> <correlation-immunity-order> [-n/-o]

-- Relevant inputs:
-- groundT: 0xB4 (Exercise from practical.)
-- 7-bit:   0xDB011464C2F090B41B597D60DD256EE2
-- 8-bit:   0xDB011464C2F090B41B597D60DD256EE224FEEB9B3D0F6F4BE4A6829F22DA911D
-- 9-bit:   0xDB011464C2F090B41B597D60DD256EE224FEEB9B3D0F6F4BE4A6829F22DA911D24FEEB9B3D0F6F4BE4A6829F22DA911DDB011464C2F090B41B597D60DD256EE2
-- ----------------------------------------------------------------------------

-- Transforms a hexadecimal number string
-- to a binary number string.
-- input: hexadecimal number
-- output: padded binary number
local function hexToBinary(hex)
  local ret = ""
  local num = tonumber(hex, 16)
  while num ~= 1 and num ~= 0 do
    ret = tostring(num % 2) .. ret
    num = math.modf(num / 2)
  end
  ret = tostring(num) .. ret
  -- add padding
  while string.len(ret) ~= 4 do
    ret = 0 .. ret
  end
  return ret
end

-- Calculates the length of the input
-- of a binary function based on the output
-- vector length.
-- input: length of the output vector
-- output: arity of the function
local function arity(length)
  local ret = 0
  while length ~= 2 do
    length = length / 2
    ret = ret + 1
  end
  return ret + 1
end

-- Transform the hexadecimal ouput
-- representation to relevant information
-- about the output and input of the function.
-- input: hexadecimal representation of output
-- return: binary function input length
-- return: binary representation of output
local function binarize(hexstr)
  local binary = ""
  local length = 0
  -- delete hex padding
  if hexstr:sub(1, 2) == "0x" then
    hexstr = hexstr:sub(3)
  end
  for hex in hexstr:gmatch'%x' do
    length = length + 4
    local bin = hexToBinary(hex)
    binary = binary .. bin
    -- print(byte.."->"..num.."->"..bin)
  end
  return arity(length), binary
end

-- Calculate the Hamming-weight of an
-- arbitrary binary string.
-- input: binary string
-- return: Hamming-weight
local function hamming(binary)
  local weight = 0
  for bit in binary:gmatch"." do
    if bit == "1" then
      weight = weight + 1
    end
  end
  return weight
end

-- Transform decimal numbers to their binary
-- representation with padding if needed.
-- input: number
-- input: length of desired output
-- return: the binary representation
local function binaryRepresentation(num, length)
  local ret = ""
  local appendix = 0
  for iter = 1, length do
    -- if the 2 power exists
    if num - 2^(length - iter) > 0 then
      num = num - 2^(length - iter)
      appendix = 1
    end
    ret = ret .. appendix
    appendix = 0
  end
  return ret
end

-- Calculates the Walsh-transform for
-- a specific case of vector A.
-- input: vector a
-- input: binary function output vector
-- output: the corresponding Walsh-transform
local function walsh(a, output)
  local sum = 0
  local numOfRows = string.len(output)
  for i = 1, numOfRows do
    local x = binaryRepresentation(i, string.len(a))
    local ax = 0
    for b = 1, string.len(a) do
      if string.sub(a, b, b) == "1" then
        ax = ax ~ tonumber(string.sub(x,b, b))
      end
    end
    local exp = tonumber(string.sub(output, i, i)) ~ ax
    sum = sum + (-1)^exp
  end
  return sum
end

-- Decides if a function is balanced based
-- on the non-zero output distribution.
-- input: binary function output
-- output: Hamming-weight
-- output: if the function is balanced
local function isBalanced(output)
  local ham = hamming(output)
  if ham == string.len(output) / 2 then
    return ham, true
  else return ham, false
  end
end

-- Decides if there is t-th order correlation
-- or if the function is immune to t-th order
-- correlation. Optimized algorithm.
-- input: binary function output vector
-- input: binary function input length
-- output: if the function is correlation immune
local function correlationOptimized(output, inputLength)
  local numOfRows = 2^inputLength
  for a = 1, numOfRows do
    local abin = binaryRepresentation(a, inputLength)
    local ham = hamming(abin)
    if 1 <= ham and ham <= tonumber(arg[2]) then
      local wal = walsh(abin, output)
      if wal ~= 0 then
        return false
      end
    end
  end return true
end

-- Decides if there is t-th order correlation
-- or if the function is immune to t-th order
-- correlation. Naive algorithm.
-- input: binary function output vector
-- input: binary function input length
-- output: if the function is correlation immune
local function correlationNaive(output, inputLength)
  local ret = true
  local numOfRows = 2^inputLength
  for a = 1, numOfRows do
    local abin = binaryRepresentation(a, inputLength)
    local ham = hamming(abin)
    local wal = walsh(abin, output)
    if ham == 1 and wal ~= 0 then
      print("VectorA-Walsh-Hamming")
      print(abin .. " " .. wal .. "\t" .. ham)
    end
    if 1 <= ham and ham <= tonumber(arg[2]) then
      if wal ~= 0 then
        ret = false
      end
    end
  end return ret
end

-- Main function that invokes balancedness checker
-- and correlation immunity checker function and
-- evaluates the output.
local function solve()
  local hexOutput = arg[1]
  local inputLenght, output = binarize(hexOutput)

  local hammingw, balance = isBalanced(output)
  _ = hammingw

  local immunity = nil
  if arg[3] == "-o" then
    immunity = correlationOptimized(output, inputLenght)
    print("Optimized algorithm run")
  elseif arg[3] == "-n" then
    immunity = correlationNaive(output, inputLenght)
    print("Naive algorithm run")
  else print("Please choose an algorithm"); return
  end

  -- output
  print("Function: " .. hexOutput)
  print("Balanced function: " .. tostring(balance))
  print("Immune to "..arg[2].." order correlation: "..tostring(immunity))
  -- print("Input length: " .. inputLenght)
  -- print("Hamming weight: " .. hammingw)
  -- print(output)
end

solve()

