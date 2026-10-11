DRP = DRP or {}
DRP.Utils = DRP.Utils or {}

function DRP.Utils.Trim(value)
    if type(value) ~= 'string' then return value end
    return value:match('^%s*(.-)%s*$')
end

function DRP.Utils.IsNonEmptyString(value, maxLength)
    value = DRP.Utils.Trim(value)
    return type(value) == 'string' and #value > 0 and (not maxLength or #value <= maxLength)
end

function DRP.Utils.ClampNumber(value, minimum, maximum)
    value = tonumber(value) or minimum
    return math.max(minimum, math.min(maximum, value))
end
