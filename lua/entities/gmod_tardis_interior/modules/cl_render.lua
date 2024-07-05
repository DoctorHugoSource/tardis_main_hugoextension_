-- Rendering override

local function predraw_o(self, part)
    if not TARDIS:GetSetting("lightoverride-enabled") then return end
    local lo = self.metadata.Interior.LightOverride
    if not lo then return end

    local power = self:GetPower()
    local lowpower = self:GetData("lowpowermode", true)
    local override = GetConVar("hugoextension_tardis2_NewPowerSystem"):GetBool() == true  -- allow player to force the new power system even if extensions dont support it

    render.SuppressEngineLighting(true)

    local br = power and lo.basebrightness or lo.nopowerbrightness

    local col = power and lo.basebrightnessRGB or lo.nopowerbrightnessRGB

    local lopcol = lo.lowpowerbrightness      -- define low power brightness if the extension has it


    if override and not power then  -- if the player wants to force the new power system when power is off
        br = 0.0025                 -- make no power brightness full darkness instead of the extensions' defined value

            if lo.nopowerbrightness < 0.0025 then  -- if the extension happens to have *darker* nopower brightness than the override, use it instead (example: new hartnell tardis)
            br = lo.nopowerbrightness
            end

        if lowpower and not power then   -- no power but also lowpower
            if lopcol ~= nil then        -- if extension has it defined
            br = lopcol
            else                            -- automatic override to try and make it work on any extension if it does not have lowpower defined     this is not perfect!!!
            br = lo.nopowerbrightness + 0.01  -- take the extension's default nopower brightness and increase it a bit to try and adapt to the extension's intended lighting
            end
        end
    end


    if power and self:GetData("CustomInteriorLightColorEnabled",false) == true then  -- override int color in real time if desired

        local intcol = self:GetData("CustomInteriorLightColor",Color(0.218525, 0.435325, 0.65175))

        local intbr = self:GetData("CustomInteriorLightBrightness",0.002)

        local r = math.Approach( col[1], (intcol.r * intbr), FrameTime() * 0.3 )
        local g = math.Approach( col[2], (intcol.g * intbr), FrameTime() * 0.3 )
        local b = math.Approach( col[3], (intcol.b * intbr), FrameTime() * 0.3 )

        col[1] = r
        col[2] = g
        col[3] = b

        local fadecol = Color(col[1] * 1000, col[2] * 1000, col[3] * 1000)

        self:SetData("CustomInteriorLightColorFade", fadecol, true)  -- doing this because i dont want to add another math.approach over in
                                                                                                                      -- sh_customcolors.lua
    end

--     if self:GetData("CustomInteriorLightBrightnessEnabled",false) == true then  -- override int brightness in real time if desired
--
--     local intbr = self:GetData("CustomInteriorLightBrightness",nil)
--
--     br = power and intbr or lo.nopowerbrightness
--
--
--
--     end

    local parts_table = power and lo.parts or lo.parts_nopower

    if part and parts_table and parts_table[part.ID] then
        local part_br = parts_table[part.ID]
        if istable(part_br) then
            render.ResetModelLighting(part_br[1], part_br[2], part_br[3])
        else
            render.ResetModelLighting(part_br, part_br, part_br)
        end
    elseif col then
        render.ResetModelLighting(col[1], col[2], col[3])
    else
        render.ResetModelLighting(br, br, br)
    end

    --render.SetLightingMode(1)
    local light = self.light_data.main

    if light == nil then return end
    --because for some reason SOMEONE OUT THERE didn't define a light.

    local lights = self.light_data.extra
    local warning = self:GetData("warning", false)

    local tab={}

    local function SelectLightRenderTable(lt)
        if override then
            if lowpower then return end
        else
        if self:CallHook("ShouldDrawLight",nil,lt) == false then
            return {}
        end
    end

        if override then  -- only if newpower is enabled
            if (not power) and (not lowpower) then
                return {}                           -- for blackout, force all lights off even if they have nopower enabled
            end
        end

        if (not power) and warning then
            return lt.off_warn_render_table
        elseif not power and (not lowpower) then
            return lt.off_render_table
        elseif warning then
            return lt.warn_render_table
        end

        if lowpower and (not power) then
            return lt.low_render_table
        end

        if self and power then
            return lt.render_table
        end



    end

    table.insert(tab, SelectLightRenderTable(light))

    if lights then
        for _,l in pairs(lights) do
            if not TARDIS:GetSetting("extra-lights") then
                table.insert(tab, {})
            else
                table.insert(tab, SelectLightRenderTable(l) or {})
            end
        end
    end

    if #tab==0 then
        render.SetLocalModelLights()
    else
        render.SetLocalModelLights(tab)
    end
end

local function postdraw_o(self)
    if not TARDIS:GetSetting("lightoverride-enabled") then return end
    if self.light_data.main == nil then return end
    render.SuppressEngineLighting(false)
end




local funcnum = 0.1
local funcnumcur = 0.1

local function predraw_od (self, part)  -- okay so this is a bunch of junk code to try and fix the disparity between exterior and interior door lighting

    if not GetConVar("hugoextension_tardis2_UniversalDoorlight"):GetBool() == true then return end

    if not (part and part.ID == "door") then return end


-- todo: add metadata and an extension-level opt in to this feature (something like 'metadata.doorlight = enabled')


            if self:GetData("doorstatereal",false) then  -- do this when the door is open/opening
                funcnum = 0.8
                n = math.Approach(funcnumcur, funcnum, FrameTime() * (funcnumcur * funcnumcur) * 130)  -- okay the entire reason for this is very convoluted;
            else                                                                                    -- i need a *sharp* exponential increase here for this effect to work -
                funcnum = 0.01                                                                      -- if the effect applies too early, youll see the back face of the door lit up which breaks it
                n = math.Approach(funcnumcur, funcnum, FrameTime() * (funcnumcur / funcnumcur) * 3) -- if it applies too late, you see the light pop in which also breaks it
            end                                                                                     -- thats why it has to quickly fade in at just right right time, when the edge of the door faces you


        local locallight = render.GetLightColor(self.exterior.parts.door:GetPos() + Vector(0,0,50)) -- use environment lighting to determine brightness and color
                                                                                                    -- hopefully accurate to the actual outside in most maps
        local nvec = locallight * (n * (6 * locallight))  -- make light level influence itself, kinda like an exponent because for some reason environment lighting is not linear


            if self:GetData("vortex", false) then  -- retroactively added; change to vortex lighting during vortex travel

                if self:GetData("CustomVortexEnabled", false) == false then  -- use extension's default tint color from metadata
                    nvec = self.metadata.Interior.WindowTint.ExtTint
                end

                if self:GetData("CustomVortexEnabled", false) == true then  -- enable vortex swap tint
                    nvec = self:GetData("VortexAmbientColor", nil):ToVector()  -- get the color from vortexswitch.lua
                end     -- self:GetData("VortexExtColor", nil) -- alternative lighting

                nvec = nvec

            end

            nvec.x = math.Clamp(nvec.x, 0, 1)  -- clunky but ill improve it if i find a way to clamp a vector directly
            nvec.y = math.Clamp(nvec.y, 0, 1)
            nvec.z = math.Clamp(nvec.z, 0, 1)

    if self:DoorOpen() == true then                       -- apply the calculated lighting via this SetModelLighting function
        render.SetModelLighting(2, nvec.x,nvec.y,nvec.z)  -- this probably gets used like once per year, but this is where the effect comes to life
        render.SetModelLighting(3, nvec.x,nvec.y,nvec.z)  -- it's like ResetModelLighting except you can specify it to project from one specific direction;
    end                                                   -- i use that to project the light color onto the front of both door panels when they're open

        funcnumcur = n  -- close the math.approach loop

end
    -- render.SetModelLighting(2, n,n,n)
    -- render.SetModelLighting(3, n,n,n)

    -- if self:GetData("doorstatereal",false) then
    --     funcnum = 0.8
    --     n = funcnumcur + (funcnum - funcnumcur) * math.abs(0.4) * FrameTime()
    -- else
    -- local nvec = self.exterior.intprojectedlightcolor:ToVector() * n
    -- math.Approach(funcnumcur, funcnum, FrameTime() * 2)

    -- local rate = (1 - math.exp(-0.7 * FrameTime()))
    -- print (render.GetLightColor(self.exterior.parts.door:GetPos() + Vector(0,0,50)))
    -- local n = self.exterior.intprojectedlightcolor:ToVector()


ENT:AddHook("PreDrawPart", "customlighting2", predraw_od)

ENT:AddHook("PostDrawPart", "customlighting2", predraw_od)


ENT:AddHook("PreDraw", "customlighting", predraw_o)

ENT:AddHook("Draw", "customlighting", postdraw_o)

ENT:AddHook("PreDrawPart", "customlighting", predraw_o)

ENT:AddHook("PostDrawPart", "customlighting", postdraw_o)


