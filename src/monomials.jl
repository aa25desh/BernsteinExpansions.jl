# temp?
univariate(k::Int, l::Int, X::Interval{N}) where {N<:AbstractFloat} = univariate(k, l, X.lo, X.hi)

"""
    univariate(k::Int, l::Int, low::N, high::N) where {N<:AbstractFloat}

Compute the Bernstein coefficients of a univariate monomial.

### Input

- `k`    -- degree of the given monomial
- `l`    -- degree of the Bernstein polynomial
- `low`  -- the lower bound of the interval where the Bernstein coefficients are computed
- `high` -- the upper bound of the interval the Bernstein coefficients are computed

### Output

A vector of `l+1` entries, in floating point, containing the Bernstein coefficients
of this monomial.
"""
function univariate(k::Int, l::Int, low::N, high::N) where {N<:AbstractFloat}
    #low, high = X.lo, X.hi
    m = l - k
    b = zeros(N, l+1)
    @inbounds @fastmath for i in 0:l
        if k < l
            for j in max(0, i-m):min(k, i)
                aux =  binomial(m, i-j) * binomial(k, j) / binomial(k+m, i)
                b[i+1] += aux * low^(k-j) * high^j
            end
        else
            b[i+1] = low^(k-i) * high^i
        end
    end
    return b
end

"""
    univariate(k::Int64, l::Int64, low::Rational, high::Rational)::Vector{Rational}

Compute *exactly* the Bernstein coefficients of a univariate monomial.

### Input

- `k`    -- degree of the given monomial
- `l`    -- degree of the Bernstein polynomial
- `low`  -- the lower bound of the interval where the Bernstein coefficients are computed
- `high` -- the upper bound of the interval the Bernstein coefficients are computed

### Output

A vector with rational entries containing the Bernstein coefficients.
"""
function univariate(k::Int64, l::Int64, low::Rational, high::Rational)::Vector{Rational}
    m = l - k
    b = zeros(Rational, l+1)
    @inbounds for i in 0:l
        if k < l
            for j in max(0, i-m):min(k, i)
                aux =  binomial(m, i-j) * binomial(k, j) // binomial(k+m, i)
                b[i+1] += aux * low^(k-j) * high^j
            end
        else
            b[i+1] = low^(k-i) * high^i
        end
    end
    return b
end

# temp?
function multivariate(k::Vector{Int64}, l::Vector{Int64}, X::IntervalBox{N}) where {N<:Number}
    l = [vi.lo for vi in b.v]
    h = [vi.lo for vi in b.v] # TODO : merge in one loop
    return multivariate(k, l, l, h)
end

"""
    multivariate(k::Vector{Int64}, l::Vector{Int64},
                 low::Vector{N}, high::Vector{N})::ImplicitBernsteinForm{N} where {N<:Number}

Compute the Bernstein coefficients of a multivariate monomial.

### Input

- `k`    -- vector of degrees for each monomial
- `l`    -- vector of degrees of the Bernstein polynomial for each monomial
- `low`  -- the lower bounds of the interval where the Bernstein coefficients are computed
- `high` -- the upper bounds of the interval the Bernstein coefficients are computed

### Output

A Bernstein implicit form holding the Bernstein coefficients.

### Examples

```julia
julia> m = multivariate([3,2],[3,2],[1.0,2],[2,4.0]);
julia> m.array
2-element Array{Array{Float64,1},1}:
 [1.0, 2.0, 4.0, 8.0]
 [4.0, 8.0, 16.0]
```
"""
function multivariate(k::Vector{Int64}, l::Vector{Int64},
                      low::Vector{N}, high::Vector{N})::ImplicitBernsteinForm{N} where {N<:Number}
    n = length(low)
    ncoeffs = 1
    B = Vector{Vector{N}}(undef, n)
    @inbounds for i in 1:n
        @views B[i] = univariate(k[i], l[i], low[i], high[i])
        ncoeffs = ncoeffs * length(B[i])
    end
    return ImplicitBernsteinForm(B, n, ncoeffs)
end
