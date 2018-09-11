
"""
This function adds the ramping limits of generators when there are no CommitmentVariables
"""
function rampconstraints(m::JuMP.Model, devices::Array{T,1}, device_formulation::Type{D}, system_formulation::Type{S}, time_periods::Int64; initial = 9999) where {T <: PowerSystems.ThermalGen, D <: AbstractThermalDispatchForm, S <: AbstractDCPowerModel}

    devices = [d for d in devices if !isa(d.tech.ramplimits,Nothing)]

    if !isempty(devices)

        pth = m[:pth]
        time_index = m[:pth].axes[2]
        name_index = [d.name for d in devices]

        (length(time_index) != time_periods) ? error("Length of time dimension inconsistent") : true

        rampdown_thermal = JuMP.JuMPArray(Array{ConstraintRef}(undef, length(name_index), time_periods), name_index, time_index)
        rampup_thermal = JuMP.JuMPArray(Array{ConstraintRef}(undef, length(name_index), time_periods), name_index, time_index)

        for (ix,name) in enumerate(name_index)
            t1 = time_index[1]
            rampdown_thermal[name,t1] = @constraint(m,  devices[ix].tech.activepower - pth[name,t1] <= devices[ix].tech.ramplimits.down)
            rampup_thermal[name,t1] = @constraint(m,  pth[name,t1] - devices[ix].tech.activepower <= devices[ix].tech.ramplimits.up)
        end

        for t in time_index[2:end], (ix,name) in enumerate(name_index)
            rampdown_thermal[name,t] = @constraint(m,  pth[name,t-1] - pth[name,t] <= devices[ix].tech.ramplimits.down)
            rampup_thermal[name,t] = @constraint(m,  pth[name,t] - pth[name,t-1] <= devices[ix].tech.ramplimits.up)
        end

        JuMP.registercon(m, :rampdown_thermal, rampdown_thermal)
        JuMP.registercon(m, :rampup_thermal, rampup_thermal)


    else
        @warn("Data doesn't contain generators with ramping limits")

    end

    return m

end


"""
This function adds the ramping limits of generators when there are CommitmentVariables
"""
function rampconstraints(m::JuMP.Model, devices::Array{T,1}, device_formulation::Type{D}, system_formulation::Type{S}, time_periods::Int64; initial = 9999) where {T <: PowerSystems.ThermalGen, D <: AbstractThermalCommitmentForm, S <: AbstractDCPowerModel}

    devices = [d for d in devices if !isa(d.tech.ramplimits,Nothing)]

    if !isempty(devices)

        pth = m[:pth]
        onth = m[:onth]

        time_index = m[:pth].axes[2]
        name_index = [d.name for d in devices]

        (length(time_index) != time_periods) ? error("Length of time dimension inconsistent") : true

        rampdown_thermal = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index), time_periods), name_index, time_index)
        rampup_thermal = JuMP.JuMPArray(Array{ConstraintRef}(undef, length(name_index), time_periods), name_index, time_index)

        for (ix,name) in enumerate(name_index)
            t1 = time_index[1]
            rampdown_thermal[name,t1] = @constraint(m, devices[ix].tech.activepower - pth[name,t1] <= devices[ix].tech.ramplimits.down * onth[name,t1])
            rampup_thermal[name,t1] = @constraint(m, pth[name,t1] - devices[ix].tech.activepower <= devices[ix].tech.ramplimits.up  * onth[name,t1])
        end

        for t in time_index[2:end], (ix,name) in enumerate(name_index)
            rampdown_thermal[name,t] = @constraint(m, pth[name,t-1] - pth[name,t] <= devices[ix].tech.ramplimits.down * onth[name,t])
            rampup_thermal[name,t] = @constraint(m, pth[name,t] - pth[name,t-1] <= devices[ix].tech.ramplimits.up * onth[name,t] )
        end

        JuMP.registercon(m, :rampdown_thermal, rampdown_thermal)
        JuMP.registercon(m, :rampup_thermal, rampup_thermal)

    else
        @warn("There are no generators with Ramping Limits Data in the System")    
        
    end
        
    
    return m

end