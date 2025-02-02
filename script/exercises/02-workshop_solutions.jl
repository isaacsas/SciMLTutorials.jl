
using DifferentialEquations
using Sundials
using BenchmarkTools
using Plots


using DifferentialEquations, Plots
function orego(du,u,p,t)
  s,q,w = p
  y1,y2,y3 = u
  du[1] = s*(y2+y1*(1-q*y1-y2))
  du[2] = (y3-(1+y1)*y2)/s
  du[3] = w*(y1-y3)
end
p = [77.27,8.375e-6,0.161]
prob = ODEProblem(orego,[1.0,2.0,3.0],(0.0,360.0),p)
sol = solve(prob)
plot(sol)


plot(sol,vars=(1,2,3))


using BenchmarkTools
prob = ODEProblem(orego,[1.0,2.0,3.0],(0.0,50.0),p)
@btime sol = solve(prob,Tsit5())


@btime sol = solve(prob,Rodas5())


function orego(du,u,p,t)
  s,q,w = p
  y1,y2,y3 = u
  du[1] = s*(y2+y1*(1-q*y1-y2))
  du[2] = (y3-(1+y1)*y2)/s
  du[3] = w*(y1-y3)
end
function g(du,u,p,t)
  du[1] = 0.1u[1]
  du[2] = 0.1u[2]
  du[3] = 0.1u[3]
end
p = [77.27,8.375e-6,0.161]
prob = SDEProblem(orego,g,[1.0,2.0,3.0],(0.0,30.0),p)
sol = solve(prob,SOSRI())
plot(sol)


sol = solve(prob,ImplicitRKMil()); plot(sol)


sol = solve(prob,ImplicitRKMil()); plot(sol)


function orego(du,u,p,t)
  s,q,w = p
  y1,y2,y3 = u
  du[1] = s*(y2+y1*(1-q*y1-y2))
  du[2] = (y3-(1+y1)*y2)/s
  du[3] = w*(y1-y3)
end
p = [60.0,1e-5,0.2]
prob = ODEProblem(orego,[1.0,2.0,3.0],(0.0,30.0),p)
sol = solve(prob,Rodas5(),abstol=1/10^14,reltol=1/10^14)


function onecompartment(du,u,p,t)
  Ka,Ke = p
  du[1] = -Ka*u[1]
  du[2] =  Ka*u[1] - Ke*u[2]
end
p = (Ka=2.268,Ke=0.07398)
prob = ODEProblem(onecompartment,[100.0,0.0],(0.0,90.0),p)

tstops = [24,48,72]
condition(u,t,integrator) = t ∈ tstops
affect!(integrator) = (integrator.u[1] += 100)
cb = DiscreteCallback(condition,affect!)
sol = solve(prob,Tsit5(),callback=cb,tstops=tstops)
plot(sol)


function onecompartment_delay(du,u,h,p,t)
  Ka,Ke,τ = p
  delayed_depot = h(p,t-τ)[1]
  du[1] = -Ka*u[1]
  du[2] =  Ka*delayed_depot - Ke*u[2]
end
p = (Ka=2.268,Ke=0.07398,τ=6.0)
h(p,t) = [0.0,0.0]
prob = DDEProblem(onecompartment_delay,[100.0,0.0],h,(0.0,90.0),p)

tstops = [24,48,72]
condition(u,t,integrator) = t ∈ tstops
affect!(integrator) = (integrator.u[1] += 100)
cb = DiscreteCallback(condition,affect!)
sol = solve(prob,MethodOfSteps(Rosenbrock23()),callback=cb,tstops=tstops)
plot(sol)


p = (Ka = 0.5, Ke = 0.1, τ = 4.0)


function f(du, u, p, t)
    du[1] = -p[1]*u[1] + p[2]*u[2]*u[3]
    du[2] = p[1]*u[1] - p[2]*u[2]*u[3] - p[3]*u[2]*u[2]
    du[3] = u[1] + u[2] + u[3] - 1.
end
M = [1 0 0; 0 1 0; 0 0 0.]
p = [0.04, 10^4, 3e7]
u0 = [1.,0.,0.]
tspan = (0., 1e6)
prob = ODEProblem(ODEFunction(f, mass_matrix = M), u0, tspan, p)
sol = solve(prob, Rodas5())
plot(sol, xscale=:log10, tspan=(1e-6, 1e5), layout=(3,1))


# Robertson Equation DAE Implicit form
function h(out, du, u, p, t)
    out[1] = -p[1]*u[1] + p[2]*u[2]*u[3] - du[1]
    out[2] = p[1]*u[1] - p[2]*u[2]*u[3] - p[3]*u[2]*u[2] - du[2]
    out[3] = u[1] + u[2] + u[3] - 1.
end
p = [0.04, 10^4, 3e7]
du0 = [-0.04, 0.04, 0.0]
u0 = [1.,0.,0.]
tspan = (0., 1e6)
differential_vars = [true, true, false]
prob = DAEProblem(h, du0, u0, tspan, p, differential_vars = differential_vars)
sol = solve(prob, IDA())
plot(sol, xscale=:log10, tspan=(1e-6, 1e5), layout=(3,1))


function f(out, da, a, p, t)
   (L, m, g) = p
   u, v, x, y, T = a
   du, dv, dx, dy, dT = da
   out[1] = x*T/(m*L) - du
   out[2] = y*T/(m*L) - g - dv
   out[3] = u - dx
   out[4] = v - dy
   out[5] = u^2 + v^2 - y*g + T/m
   nothing
end

# Release pendulum from top right
u0 = zeros(5)
u0[3] = 1.0
du0 = zeros(5)
du0[2] = 9.81

p = [1,1,9.8]
tspan = (0.,100.)

differential_vars = [true, true, true, true, false]
prob = DAEProblem(f, du0, u0, tspan, p, differential_vars = differential_vars)
sol = solve(prob, IDA())
plot(sol, vars=(3,4))


function f(out, da, a, p, t)
   L1, m1, L2, m2, g = p

   u1, v1, x1, y1, T1,
   u2, v2, x2, y2, T2 = a

   du1, dv1, dx1, dy1, dT1,
   du2, dv2, dx2, dy2, dT2 = da

   out[1]  = x2*T2/(m2*L2) - du2
   out[2]  = y2*T2/(m2*L2) - g - dv2
   out[3]  = u2 - dx2
   out[4]  = v2 - dy2
   out[5]  = u2^2 + v2^2 -y2*g + T2/m2

   out[6]  = x1*T1/(m1*L1) - x2*T2/(m2*L2) - du1
   out[7]  = y1*T1/(m1*L1) - g - y2*T2/(m2*L2) - dv1
   out[8]  = u1 - dx1
   out[9]  = v1 - dy1
   out[10] = u1^2 + v1^2 + T1/m1 +
                (-x1*x2 - y1*y2)/(m1*L2)*T2 - y1*g
   nothing
end

# Release pendulum from top right
u0 = zeros(10)
u0[3] = 1.0
u0[8] = 1.0
du0 = zeros(10)
du0[2] = 9.8
du0[7] = 9.8

p = [1,1,1,1,9.8]
tspan = (0.,100.)

differential_vars = [true, true, true, true, false,
                     true, true, true, true, false]
prob = DAEProblem(f, du0, u0, tspan, p, differential_vars = differential_vars)
sol = solve(prob, IDA())

plot(sol, vars=(3,4))
plot(sol, vars=(8,9))


using DifferentialEquations, Sundials, Plots

# initial condition
function init_brusselator_2d(xyd)
    N = length(xyd)
    u = zeros(N, N, 2)
    for I in CartesianIndices((N, N))
        x = xyd[I[1]]
        y = xyd[I[2]]
        u[I,1] = 22*(y*(1-y))^(3/2)
        u[I,2] = 27*(x*(1-x))^(3/2)
    end
    u
end

N = 32

xyd_brusselator = range(0,stop=1,length=N)

u0 = vec(init_brusselator_2d(xyd_brusselator))

tspan = (0, 22.)

p = (3.4, 1., 10., xyd_brusselator)

brusselator_f(x, y, t) = ifelse((((x-0.3)^2 + (y-0.6)^2) <= 0.1^2) &&
                                (t >= 1.1), 5., 0.)


using LinearAlgebra, SparseArrays
du = ones(N-1)
D2 = spdiagm(-1 => du, 0=>fill(-2.0, N), 1 => du)
D2[1, N] = D2[N, 1] = 1
D2 = 1/step(xyd_brusselator)^2*D2
tmp = Matrix{Float64}(undef, N, N)
function brusselator_2d_op(du, u, (D2, tmp, p), t)
    A, B, α, xyd = p
    dx = step(xyd)
    N = length(xyd)
    α = α/dx^2
    du = reshape(du, N, N, 2)
    u = reshape(u, N, N, 2)
    @views for i in axes(u, 3)
        ui = u[:, :, i]
        dui = du[:, :, i]
        mul!(tmp, D2, ui)
        mul!(dui, ui, D2')
        dui .+= tmp
    end

    @inbounds begin
        for I in CartesianIndices((N, N))
            x = xyd[I[1]]
            y = xyd[I[2]]
            i = I[1]
            j = I[2]

            du[i,j,1] = α*du[i,j,1] + B + u[i,j,1]^2*u[i,j,2] - (A + 1)*u[i,j,1] + brusselator_f(x, y, t)
            du[i,j,2] = α*du[i,j,2] + A*u[i,j,1] - u[i,j,1]^2*u[i,j,2]
        end
    end
    nothing
end

prob1 = ODEProblem(brusselator_2d_op, u0, tspan, (D2, tmp, p))

sol1 = @time solve(prob1, TRBDF2(autodiff=false));


@gif for t in sol1.t[1]:0.1:sol1.t[end]
    off = N^2
    solt = sol1(t)
    plt1 = surface(reshape(solt[1:off], N, N), zlims=(0, 5), leg=false)
    surface!(plt1, reshape(solt[off+1:end], N, N), zlims=(0, 5), leg=false)
    display(plt1)
end


function brusselator_2d_loop(du, u, p, t)
    A, B, α, xyd = p
    dx = step(xyd)
    N = length(xyd)
    α = α/dx^2
    limit = a -> let N=N
        a == N+1 ? 1 :
        a == 0 ? N :
        a
    end
    II = LinearIndices((N, N, 2))

    @inbounds begin
        for I in CartesianIndices((N, N))
            x = xyd[I[1]]
            y = xyd[I[2]]
            i = I[1]
            j = I[2]
            ip1 = limit(i+1)
            im1 = limit(i-1)
            jp1 = limit(j+1)
            jm1 = limit(j-1)

            ii1 = II[i,j,1]
            ii2 = II[i,j,2]

            du[II[i,j,1]] = α*(u[II[im1,j,1]] + u[II[ip1,j,1]] + u[II[i,jp1,1]] + u[II[i,jm1,1]] - 4u[ii1]) +
            B + u[ii1]^2*u[ii2] - (A + 1)*u[ii1] + brusselator_f(x, y, t)

            du[II[i,j,2]] = α*(u[II[im1,j,2]] + u[II[ip1,j,2]] + u[II[i,jp1,2]] + u[II[i,jm1,2]] - 4u[II[i,j,2]]) +
            A*u[ii1] - u[ii1]^2*u[ii2]
        end
    end
    nothing
end

prob2 = ODEProblem(brusselator_2d_loop, u0, tspan, p)

sol2 = @time solve(prob2, TRBDF2())
sol2_2 = @time solve(prob2, CVODE_BDF())


using SparseDiffTools, SparsityDetection

sparsity_pattern = jacobian_sparsity(brusselator_2d_loop,similar(u0),u0,p,2.0)
jac_sp = sparse(sparsity_pattern)
jac = Float64.(jac_sp)
colors = matrix_colors(jac)
prob3 = ODEProblem(ODEFunction(brusselator_2d_loop, colorvec=colors,jac_prototype=jac_sp), u0, tspan, p)
sol3 = @time solve(prob3, TRBDF2())


using DiffEqOperators
using Sundials
using AlgebraicMultigrid: ruge_stuben, aspreconditioner, smoothed_aggregation
prob6 = ODEProblem(ODEFunction(brusselator_2d_loop, jac_prototype=JacVecOperator{Float64}(brusselator_2d_loop, u0)), u0, tspan, p)
II = Matrix{Float64}(I, N, N)
Op = kron(Matrix{Float64}(I, 2, 2), kron(D2, II) + kron(II, D2))
Wapprox = -I+Op
#ml = ruge_stuben(Wapprox)
ml = smoothed_aggregation(Wapprox)
precond = aspreconditioner(ml)
sol_trbdf2 = @time solve(prob6, TRBDF2(linsolve=LinSolveGMRES())); # no preconditioner
sol_trbdf2 = @time solve(prob6, TRBDF2(linsolve=LinSolveGMRES(Pl=lu(Wapprox)))); # sparse LU
sol_trbdf2 = @time solve(prob6, TRBDF2(linsolve=LinSolveGMRES(Pl=precond))); # AMG
sol_cvodebdf = @time solve(prob2, CVODE_BDF(linear_solver=:GMRES));


function laplacian2d(du, u, p, t)
    A, B, α, xyd = p
    dx = step(xyd)
    N = length(xyd)
    du = reshape(du, N, N, 2)
    u = reshape(u, N, N, 2)
    @inbounds begin
        α = α/dx^2
        limit = a -> let N=N
            a == N+1 ? 1 :
            a == 0 ? N :
            a
        end
        for I in CartesianIndices((N, N))
            x = xyd[I[1]]
            y = xyd[I[2]]
            i = I[1]
            j = I[2]
            ip1 = limit(i+1)
            im1 = limit(i-1)
            jp1 = limit(j+1)
            jm1 = limit(j-1)
            du[i,j,1] = α*(u[im1,j,1] + u[ip1,j,1] + u[i,jp1,1] + u[i,jm1,1] - 4u[i,j,1])
            du[i,j,2] = α*(u[im1,j,2] + u[ip1,j,2] + u[i,jp1,2] + u[i,jm1,2] - 4u[i,j,2])
        end
    end
    nothing
end
function brusselator_reaction(du, u, p, t)
    A, B, α, xyd = p
    dx = step(xyd)
    N = length(xyd)
    du = reshape(du, N, N, 2)
    u = reshape(u, N, N, 2)
    @inbounds begin
        for I in CartesianIndices((N, N))
            x = xyd[I[1]]
            y = xyd[I[2]]
            i = I[1]
            j = I[2]
            du[i,j,1] = B + u[i,j,1]^2*u[i,j,2] - (A + 1)*u[i,j,1] + brusselator_f(x, y, t)
            du[i,j,2] = A*u[i,j,1] - u[i,j,1]^2*u[i,j,2]
        end
    end
    nothing
end
prob7 = SplitODEProblem(laplacian2d, brusselator_reaction, u0, tspan, p)
sol7 = @time solve(prob7, KenCarp4())
M = MatrixFreeOperator((du,u,p)->laplacian2d(du, u, p, 0), (p,), size=(2*N^2, 2*N^2), opnorm=1000)
prob7_2 = SplitODEProblem(M, brusselator_reaction, u0, tspan, p)
sol7_2 = @time solve(prob7_2, ETDRK4(krylov=true), dt=1)
prob7_3 = SplitODEProblem(DiffEqArrayOperator(Op), brusselator_reaction, u0, tspan, p)
sol7_3 = solve(prob7_3, KenCarp4());


using DiffEqDevTools
abstols = 0.1 .^ (5:8)
reltols = 0.1 .^ (1:4)
sol = solve(prob3,CVODE_BDF(linear_solver=:GMRES),abstol=1/10^7,reltol=1/10^10)
test_sol = TestSolution(sol)
probs = [prob2, prob3, prob6]
setups = [Dict(:alg=>CVODE_BDF(),:prob_choice => 1),
          Dict(:alg=>CVODE_BDF(linear_solver=:GMRES), :prob_choice => 1),
          Dict(:alg=>TRBDF2(), :prob_choice => 1),
          Dict(:alg=>TRBDF2(linsolve=LinSolveGMRES(Pl=precond)), :prob_choice => 3),
          Dict(:alg=>TRBDF2(), :prob_choice => 2)
         ]
labels = ["CVODE_BDF (dense)" "CVODE_BDF (GMRES)" "TRBDF2 (dense)" "TRBDF2 (sparse)" "TRBDF2 (GMRES)"]
wp = WorkPrecisionSet(probs,abstols,reltols,setups;appxsol=[test_sol,test_sol,test_sol],save_everystep=false,numruns=3,
  names=labels, print_names=true, seconds=0.5)
plot(wp)


function henon(dz,z,p,t)
  p₁, p₂, q₁, q₂ = z[1], z[2], z[3], z[4]
  dp₁ = -q₁*(1 + 2q₂)
  dp₂ = -q₂-(q₁^2 - q₂^2)
  dq₁ = p₁
  dq₂ = p₂

  dz .= [dp₁, dp₂, dq₁, dq₂]
  return nothing
end

u₀ = [0.1, 0.0, 0.0, 0.5]
prob = ODEProblem(henon, u₀, (0., 1000.))
sol = solve(prob, Vern9(), abstol=1e-14, reltol=1e-14)

plot(sol, vars=[(3,4,1)], tspan=(0,100))


function henon(ddz,dz,z,p,t)
  p₁, p₂ = dz[1], dz[2]
  q₁, q₂ = z[1], z[2]
  ddq₁ = -q₁*(1 + 2q₂)
  ddq₂ = -q₂-(q₁^2 - q₂^2)

  ddz .= [ddq₁, ddq₂]
end

p₀ = u₀[1:2]
q₀ = u₀[3:4]
prob2 = SecondOrderODEProblem(henon, p₀, q₀, (0., 1000.))
sol = solve(prob2, DPRKN6(), abstol=1e-10, reltol=1e-10)

plot(sol, vars=[(3,4)], tspan=(0,100))

H(p, q, params) = 1/2 * (p[1]^2 + p[2]^2) + 1/2 * (q[1]^2 + q[2]^2 + 2q[1]^2 * q[2] - 2/3*q[2]^3)

prob3 = HamiltonianProblem(H, p₀, q₀, (0., 1000.))
sol = solve(prob3, DPRKN6(), abstol=1e-10, reltol=1e-10)

plot(sol, vars=[(3,4)], tspan=(0,100))


function generate_ics(E,n)
  # The hardcoded values bellow can be estimated by looking at the
  # figures in the Henon-Heiles 1964 article
  qrange = range(-0.4, stop = 1.0, length = n)
  prange = range(-0.5, stop = 0.5, length = n)
  z0 = Vector{Vector{typeof(E)}}()
  for q in qrange
    V = H([0,0],[0,q],nothing)
    V ≥ E && continue
    for p in prange
      T = 1/2*p^2
      T + V ≥ E && continue
      z = [√(2(E-V-T)), p, 0, q]
      push!(z0, z)
    end
  end
  return z0
end

z0 = generate_ics(0.125, 10)

function prob_func(prob,i,repeat)
  @. prob.u0 = z0[i]
  prob
end

ensprob = EnsembleProblem(prob, prob_func=prob_func)
sim = solve(ensprob, Vern9(), EnsembleThreads(), trajectories=length(z0))

plot(sim, vars=(3,4), tspan=(0,10))


using DiffEqGPU

function henon_gpu(dz,z,p,t)
  @inbounds begin
    dz[1] = -z[3]*(1 + 2z[4])
    dz[2] = -z[4]-(z[3]^2 - z[4]^2)
    dz[3] = z[1]
    dz[4] = z[2]
  end
  return nothing
end

z0 = generate_ics(0.125f0, 50)
prob_gpu = ODEProblem(henon_gpu, Float32.(u₀), (0.f0, 1000.f0))
ensprob = EnsembleProblem(prob_gpu, prob_func=prob_func)
sim = solve(ensprob, Tsit5(), EnsembleGPUArray(), trajectories=length(z0))


using DiffEqTutorials
DiffEqTutorials.tutorial_footer(WEAVE_ARGS[:folder],WEAVE_ARGS[:file])

