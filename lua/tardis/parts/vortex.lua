-- Vortex

local PART = {}
PART.ID = "vortex"
PART.Name = "Vortex"
PART.Model = "models/doctorwho1200/toyota/2013timevortex.mdl"
PART.AutoSetup = true
PART.AutoPosition = false
PART.ClientThinkOverride = true
PART.ClientDrawOverride = true
PART.ShouldDrawOverride = true
PART.Collision = false
PART.NoStrictUse = true
PART.CustomAlpha = true
PART.NoShadow = true
PART.NoShadowCopy = true
PART.NoCloak = true
if SERVER then

    function PART:Initialize()
        self:SetSolid(SOLID_NONE)
        self:SetPos(self.exterior:LocalToWorld(self.pos))
        self:SetAngles(self.exterior:LocalToWorldAngles(self.ang))
        self:SetParent(self.exterior)
    end

else

-- is it bad to initialize this many variables?? should i use less variables or only define them the moment they're first needed?
local vectorx
local vectory
local vectorz
local flightpos
local center
local traveldistance
local reset
local active
local toofar

-- todo: instead of automatically moving the tardis back upon releasing a key, make it stay in the spot and instead WASD just increments the vector, so you can stay wherever you want
-- basically more natural and more like actual 3d flight -- done 

-- also make it align with the tardis' orientation instead of fixing it to an angle of 0,0,0

-- also also add an option to exit the vortex with some velocity, basically sliding out of a mat

-- oh yeah ALSO ALSO add a random vector generator to have the tardis fly around in the vortex on its own -- done

    function PART:PreDraw()

        if self:GetData("vortexalpha",0) > 0 then
--             self:SetRenderOrigin(self.exterior:LocalToWorld(self.pos))
            self:SetRenderAngles(self:GetData("lockedang"))

            local enabled = self.exterior:GetData("vortexmovement", true)
            local damaged = self.exterior:IsLowHealth()
            local drift = self.exterior:GetVortexDrift()


            -- handle inputs but only register them when physlock is off and spin is on
            if enabled ~= false then
                if not damaged then                             -- if low health, ignore inputs as tardis is meant to be uncontrollable
                if self:GetData("vortexup", false) then         -- all of these control inputs are done via tardis data because apparently TARDIS:IsBindDown doesn't work in this file?
                    flightpos = (flightpos + Vector(0,0,-1))
                end
                if self:GetData("vortexright", false) then
                    flightpos = (flightpos + Vector(0,1,0))
                end
                if self:GetData("vortexleft", false) then
                    flightpos = (flightpos + Vector(0,-1,0))
                end
                if self:GetData("vortexdown", false) then
                    flightpos = (flightpos + Vector(0,0,1))
                end
                if self:GetData("vortexforward", false) then
                    flightpos = (flightpos + Vector(-2,0,0))
                end
                if self:GetData("vortexback", false) then
                    flightpos = (flightpos + Vector(2,0,0))
                end
            end


            -- automatic flight movement
            if drift or damaged then -- enabled if vortex drift compensators are disabled or tardis is damaged (uncontrollable)

                -- vectorx = 1000 * math.sin(2 * math.pi * 0.1 * CurTime())  -- maybe dont actually move on the x axis because that breaks the vortex illusion a bit
                vectorx = 0
                vectory = 400 * math.sin(2 * math.pi * 0.3 * CurTime())
                vectorz = 200 * math.sin(2 * math.pi * 0.25 * CurTime())

                if damaged then
                    -- vectorx = 1000 * math.sin(2 * math.pi * 0.05 * CurTime())  -- maybe dont actually move on the x axis because that breaks the vortex illusion a bit
                    vectorx = 0
                    vectory = 400 * math.sin(2 * math.pi * 0.8 * CurTime())
                    vectorz = 200 * math.sin(2 * math.pi * 0.5 * CurTime())
                end

                flightpos = self.exterior:GetPos() + Vector(vectorx, vectory, vectorz)
            end
        end

                    -- making sure you cant fly past the vortex model
                    if not drift then  -- only bother with this if manual vortex flight is enabled (drift compensators are active)

                        center = self.exterior:GetPos()
                        traveldistance = self:GetPos() - center

                        if math.abs(traveldistance.y) >= 400 then
                            flightpos = flightpos - Vector(0,traveldistance.y * 0.1,0)
                        end
                        if math.abs(traveldistance.z) >= 400 then
                            flightpos = flightpos - Vector(0,0,traveldistance.z * 0.1)
                        end
                        if math.abs(traveldistance.x) >= 1000 then
                            flightpos = flightpos - Vector(traveldistance.x * 0.1,0,0)
                        end
                    end


                        -- failsafe, if the vortex ever strays too far for some reason it'll snap back around the tardis
                        active = self.exterior:GetData("vortex", false) or self.exterior:GetData("teleport", false)
                        toofar = self:GetPos():Distance(self.exterior:GetPos()) > 2000

                        reset = self:GetData("demat", false) or flightpos == nil or (active and toofar)

                            if reset then
                                flightpos = self.exterior:GetPos()
                            end


                                -- calculate flight position but only when physlock is off and spin is on
                                if enabled ~= false and not self.exterior:GetData("mat", false) then
                                finalflightpos = LerpVector(FrameTime() * 2, self:GetData("vortexcurpos", self.exterior:GetPos()), flightpos)
                                end

                                    if reset then
                                        finalflightpos = self.exterior:GetPos()
                                    end


            -- finally, apply movement

                self:SetPos(finalflightpos)

                self:SetData("vortexcurpos", finalflightpos, true)

        end
    end
end

TARDIS:AddPart(PART)