TARDIS:AddControl({
    id = "teleport_double",
    ext_func=function(self,ply,part)

        if not IsValid(part) then
            return TARDIS:Control("teleport", ply, nil)
        end

        local on = part:GetOn()

        if GetConVar("hugoextension_tardis2_UsePartTimers"):GetBool() then  -- only add timer logic if enabled
            if part.Delayed == true then  -- this addition is necessary for parts using a timer, because the instant they're used they return on as true, but due to the timer they actually run this function *after* that
                on = not on
            end
        end

        local tp = self:GetData("teleport")
        local vx = self:GetData("vortex")
print (on)
        if (tp and on) or (vx and on) or (not on and not tp and not vx) then  -- basically it will only return teleport when the part is off or if in vortex/teleport and it *is* on
            TARDIS:Control("teleport", ply, part)
        end
    end,
    serveronly=true,
    power_independent = false,
    screen_button = false,
    tip_text = "Controls.Teleport.Tip",
})
