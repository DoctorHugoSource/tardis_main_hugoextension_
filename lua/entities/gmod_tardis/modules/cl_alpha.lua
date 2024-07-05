-- Alpha

function ENT:GetAlpha()

if self:GetData("mat", false) and not self:GetData("teleport") then
    self:SetData("teleport",true)
end

    local alpha = self:GetData("alpha",255) / 255

        if self:GetData("vortexalpha",0)>alpha and TARDIS:GetExteriorEnt() == self then
            return self:GetData("vortexalpha",0),true
        end

            if self:GetData("vortex") then
                return (self:GetData("VortexEVA",false) and 255) or 0

            elseif self:GetData("teleport") then
                return alpha

            elseif self:GetData("teleport-trace") or self:GetData("tracking-trace") then
                return 20/255

            end
    return 1
end

local function shouldapply(self,part)
    local target,override = self:GetAlpha()
    if (target ~= 1 or override) and ((not part) or (part and (not part.CustomAlpha))) then
        return target
    end
end

local function dopredraw(self,part)
    local target = shouldapply(self,part)
    if target~=nil then

        render.OverrideColorWriteEnable( true, false )
        self:DrawModel()
        render.OverrideColorWriteEnable( false, false )

        render.OverrideColorWriteEnable( true, false )
        self.parts.door:DrawModel()
        render.OverrideColorWriteEnable( false, false )

        if (LocalPlayer():GetTardisData("thirdperson") and self:GetData("teleport")) then
        target = 1
        end

        if LocalPlayer():GetTardisData("thirdperson") and self:GetData("vortex") then
        target = 1
        end

    render.SetBlend(target)
        if self:CallHook("ShouldVortexIgnoreZ") then
            cam.IgnoreZ(true)
        end
    end
end

local function dopostdraw(self,part)
    if shouldapply(self,part)~=nil then
--         render.SetBlend(1)
        cam.IgnoreZ(false)
    end
end

ENT:AddHook("PreDraw","teleport",dopredraw)
ENT:AddHook("PreDrawPart","teleport",dopredraw)
ENT:AddHook("Draw","teleport",dopostdraw)
ENT:AddHook("PostDrawPart","teleport",dopostdraw)
ENT:AddHook("PreDrawPortal","vortex",dopredraw)
ENT:AddHook("PostDrawPortal","vortex",dopostdraw)


-- local function dopredraw(self,part)
-- if part then return end
--     local target = shouldapply(self,part)
--     if target~=nil then
--     render.OverrideColorWriteEnable( true, false )
--     self:DrawModel()
--     render.OverrideColorWriteEnable( false, false )
--         render.SetBlend(target)
--         if self:CallHook("ShouldVortexIgnoreZ") then
--             cam.IgnoreZ(true)
--         end
--     end
-- end
--
-- local function dopredrawpart(part)
--     local target = shouldapply(part)
--     if target~=nil then
--     render.OverrideColorWriteEnable( true, false )
--     part:DrawModel()
--     render.OverrideColorWriteEnable( false, false )
--         render.SetBlend(target)
--     end
-- end
--
-- local function dopostdraw(self,part)
-- if part then return end
--     if shouldapply(self,part)~=nil then
--         render.SetBlend(1)
--         cam.IgnoreZ(false)
--     end
-- end
--
-- local function dopostdrawpart(part)
--     if shouldapply(part)~=nil then
--         render.SetBlend(1)
--         cam.IgnoreZ(false)
--     end
-- end
--
-- ENT:AddHook("PreDraw","teleport",dopredraw)
-- -- ENT:AddHook("PreDrawPart","teleport",dopredraw)
-- ENT:AddHook("PreDrawPart","teleportocclude",dopredrawpart)
-- ENT:AddHook("Draw","teleport",dopostdraw)
-- -- ENT:AddHook("PostDrawPart","teleport",dopostdraw)
-- ENT:AddHook("PostDrawPart","teleportocclude",dopostdrawpart)
-- ENT:AddHook("PreDrawPortal","vortex",dopredraw)
-- ENT:AddHook("PostDrawPortal","vortex",dopostdraw)


-- local function dopredraw(self,part)
-- if part then return end
--     local target = shouldapply(self,part)
--     if target~=nil then
--     render.OverrideColorWriteEnable( true, false )
--     self:DrawModel()
--     render.OverrideColorWriteEnable( false, false )
--         render.SetBlend(target)
--         if self:CallHook("ShouldVortexIgnoreZ") then
--             cam.IgnoreZ(true)
--         end
--     end
-- end
--
-- local function dopredrawpart(self,part)
-- if part then
--     local target = shouldapply(self,part)
--     if target~=nil then
--     render.OverrideColorWriteEnable( true, false )
--     self.parts.door:DrawModel()
--     render.OverrideColorWriteEnable( false, false )
--         render.SetBlend(target)
--         if self:CallHook("ShouldVortexIgnoreZ") then
--             cam.IgnoreZ(true)
--         end
--     end
--     end
-- end
--
--
--
-- local function dopostdraw(self,part)
--     if shouldapply(self,part)~=nil then
-- --         render.SetBlend(1)
--         cam.IgnoreZ(false)
--     end
-- end
--
-- ENT:AddHook("PreDraw","teleport",dopredraw)
-- ENT:AddHook("PreDrawPart","teleport",dopredrawpart)
-- ENT:AddHook("Draw","teleport",dopostdraw)
-- ENT:AddHook("PostDrawPart","teleport",dopostdraw)
-- ENT:AddHook("PreDrawPortal","vortex",dopredraw)
-- ENT:AddHook("PostDrawPortal","vortex",dopostdraw)
