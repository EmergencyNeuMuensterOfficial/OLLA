-- Set Config.banking = "custom" to enable this server-side template.
if Sky.Config.banking ~= "custom" then return end
if not IsDuplicityVersion() then return end

function Sky.FW.GetSharedAccountBalance(name)
    -- Return the current balance for the job/society account named `name`.
    error("Custom banking integration: GetSharedAccountBalance is not implemented")
end

function Sky.FW.AddSharedAccountBalance(name, amount)
    -- Add `amount` and return true when the operation succeeded.
    error("Custom banking integration: AddSharedAccountBalance is not implemented")
end

function Sky.FW.RemoveSharedAccountBalance(name, amount)
    -- Only remove available funds and return whether the operation succeeded.
    error("Custom banking integration: RemoveSharedAccountBalance is not implemented")
end
