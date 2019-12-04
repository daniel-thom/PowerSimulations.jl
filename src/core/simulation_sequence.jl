mutable struct SimulationSequence
    initial_time::Dates.DateTime
    horizons::Dict{String, Int64}
    intervals::Dict{String, <:Dates.TimePeriod}
    order::Dict{Int64, String}
    feed_forward_chronologies::Dict{Pair{String, String}, <:AbstractChronology}
    feed_forward::Dict{Tuple{String, Symbol, Symbol}, <:AbstractAffectFeedForward}
    ini_cond_chronology::Dict{String, <:AbstractChronology}
    cache::Dict{String, Vector{<:AbstractCache}}

    function SimulationSequence(;initial_time::Dates.DateTime = Dates.DateTime(0),
                                 horizons::Dict{String, Int64},
                                 intervals::Dict{String, <:Dates.TimePeriod},
                                 order::Dict{Int64, String},
                                 feed_forward_chronologies::Dict{Pair{String, String}, <:AbstractChronology} = Dict(),
                                 feed_forward::Dict{Tuple{String, Symbol, Symbol}, <:AbstractAffectFeedForward} = Dict(),
                                 ini_cond_chronology::Dict{String, <:AbstractChronology} = Dict(),
                                 cache::Dict{String, <:Vector{<:AbstractCache}} = Dict())
        new(
            initial_time,
            horizons,
            intervals,
            order,
            feed_forward_chronologies,
            feed_forward,
            ini_cond_chronology,
            cache)

    end
end
