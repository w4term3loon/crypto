local depth = arg[2]

-- Calculates the gratest
-- common divisor.
-- input: number
-- input: another number xd
local function gcd(a, b)
  if b == 0 then
    return a
  else return gcd(b, a % b)
  end
end

-- Iterative function to calculate
-- (a^n) % p in O(logn)
-- input: base
-- input: exponent
-- input: modulus
-- return: remainder
local function modexp(b, e, m)
  if m == 1 then
    return 0
  end
  local res = 1
  while 0 < e do
    if e % 2 then -- odd
      res = (res * b) % m
      e = e - 1
    else -- even
      b = (b^2) % m
      e = e // 2
    end
  end
  return res % m
end

-- Carries out the fermat test
-- on a given number.
-- input: number
-- output: if the number is prime
local function fermat(number)
  print("iteration " .. arg[2] - depth + 1)
  if depth == 0 then
    return true
  else depth = depth - 1
  end

  local witness = math.random(2, number - 2)
  print("witness: " ..  witness)
  print("------o------")

  if gcd(number, witness) ~= 1 then
    return false
  end

  if modexp(witness, number - 1, number) == 1 then
    return fermat(number)
  else return false
  end
end

print(fermat(arg[1]))
