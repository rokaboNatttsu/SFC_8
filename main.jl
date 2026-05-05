# JuliaでのSFCモデル実装

using Plots

# カテゴリごとにグループ化されたパラメータ
τ1, τ2, τ3, τ4 = 0.2, 0.01, 0.1, 0.3  # 税率
β = 0.02  # 政府支出成長率
α1, α2, α3, α4 = 0.8, 0.05, 0.05, 0.02  # 消費パラメータ
δ, γ1, γ2, γ3 = 0.1, 1.0, 0.1, 0.05  # 投資パラメータ
ω = 0.65  # 賃金シェア
θ1, θ2 = 0.5, 0.1  # 利益分配パラメータ
θ3, θ4 = 0.1, 0.01  # 銀行配当パラメータ
ι1, ι2 = 0.5, 0.1  # 労働者借入パラメータ
μ1, μ2, μ3 = 20.0, 0.1, 0.1  # 企業借入パラメータ
ν = 0.1  # 現金比率
λ01, λ11, λ12, λ22, λ14 = 0.1, 0.5, 0.3, 0.2, 0.1  # ポートフォリオパラメータ
r_B, r_L, r_E, π, u_T = 0.03, 0.05, 0.06, 0.02, 0.8  # 金利とインフレ

# シミュレーションパラメータ
T = 100  # 期間数

# カテゴリごとにグループ化された配列の初期化
T_iw, T_ii, T_i, T_a, T_v, T_c = zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T)
G = zeros(T)
C_w, C_i, C = zeros(T), zeros(T), zeros(T)
I = zeros(T)
u = zeros(T)
K = zeros(T)
W = zeros(T)
P, P_i, P_b, P_f = zeros(T), zeros(T), zeros(T), zeros(T)
S = zeros(T)
NL_w, NL_i, NL_f, NL_b, NL_g = zeros(T), zeros(T), zeros(T), zeros(T), zeros(T)
p_B = zeros(T)
L_w, ΔL_w, ΔM_w, M_w = zeros(T), zeros(T), zeros(T), zeros(T)
M_i, ΔM_i = zeros(T), zeros(T)
ΔL_f, L_f, ΔM_f, M_f = zeros(T), zeros(T), zeros(T), zeros(T)
M = zeros(T)
H, ΔH = zeros(T), zeros(T)
Δb, b, B = zeros(T), zeros(T), zeros(T)
B_i_e, B_b_e, B_i, B_b, b_i, b_b, Δb_i, Δb_b = zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T)
E_i_T, E_b_T, p_E, Δe_i, Δe_b, e_i, e_b, E_i, E_b = zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T)
r_LL_w, r_LL_f, r_LL = zeros(T), zeros(T), zeros(T)
r_BB_i, r_BB_b, r_BB = zeros(T), zeros(T), zeros(T)

# 初期値（期間1）
K[1] = 100.0
G[1] = 20.0
C_w[1], C_i[1] = 15.0, 10.0; C[1] = C_w[1] + C_i[1]
I[1] = 10.0
u[1] = (C[1] + G[1] + I[1]) / (γ1 * K[1])
W[1] = 25.0
L_w[1], L_f[1] = 5.0, 5.0
M_w[1], M_i[1], M_f[1] = 10.0, 5.0, 5.0; M[1] = M_w[1] + M_i[1] + M_f[1]
E_i[1], E_b[1] = 20.0, 10.0; e_i[1], e_b[1] = 20.0, 10.0
B_i[1], B_b[1] = 30.0, 20.0; b_i[1], b_b[1] = 30.0, 20.0; b[1] = b_i[1] + b_b[1]; B[1] = B_i[1] + B_b[1]
H[1] = ν * M[1]; ΔH[1] = 0.0
p_B[1] = (1 - r_B) / (1 - r_B^2)
r_LL_w[1], r_LL_f[1] = r_L * L_w[1], r_L * L_f[1]; r_LL[1] = r_LL_w[1] + r_LL_f[1]
r_BB_i[1], r_BB_b[1] = r_B * B_i[1], r_B * B_b[1]; r_BB[1] = r_BB_i[1] + r_BB_b[1]
T_iw[1], T_ii[1] = τ1 * W[1], 0.0; T_i[1] = T_iw[1] + T_ii[1]
T_a[1] = τ2 * (M_i[1] + E_i[1] + B_i[1])
T_v[1] = τ3 * (C[1] + G[1] + I[1])
T_c[1] = τ4 * (C[1] + G[1] + I[1] - W[1] - T_v[1] - r_LL_f[1] - δ * K[1])
P[1] = C[1] + G[1] + I[1] - W[1] - T_v[1] - T_c[1] - r_LL_f[1]
P_i[1], P_b[1] = 0.0, 0.0; P_f[1] = P[1]
S[1] = 0.0
NL_w[1] = -C_w[1] + W[1] - T_iw[1] - r_LL_w[1]
NL_i[1] = -C_i[1] - T_ii[1] - T_a[1] + r_BB_i[1] + P_i[1] + S[1]
NL_f[1] = -I[1] + P_f[1]
NL_b[1] = r_LL[1] + r_BB_b[1] + P_b[1] - S[1]
NL_g[1] = -G[1] + T_i[1] + T_a[1] + T_v[1] + T_c[1] - r_BB[1]

# main.mdのモデル式順序に従ったシミュレーションロープ
function simulate(st, en)
    tm2 = 1
    for t in 2:T
        tm2 = t-2
        if tm2==0
            tm2 = 1
        end
        # 税: T_iw, T_ii, T_i, T_a, T_v, T_c
        T_iw[t] = τ1 * W[t-1]
        T_ii[t] = τ1 * (r_B*B_i[tm2] + P_i[t-1] + S[t-1])
        T_i[t] = T_iw[t] + T_ii[t]
        T_a[t] = τ2 * (M_i[t-1] + E_i[t-1] + B_i[t-1])
        T_v[t] = τ3 * (C[t-1] + G[t-1] + I[t-1])
        T_c[t] = τ4 * (C[t-1] + G[t-1] + I[t-1] - W[t-1] - T_v[t-1] - r_LL_f[tm2] - δ * K[t-1])

        # 政府支出: G
        G[t] = (1 + β) * G[t-1]

        # 消費: C_w, C_i, C
        C_w[t] = α1 * (W[t-1] - T_iw[t-1] - r_LL_w[t-1]) + α2 * (M_w[t-1] - L_w[t-1])
        C_i[t] = min(α3 * C[t-1], α4 * (M_i[t-1] + E_i[t-1] + B_i[t-1]))
        C[t] = C_w[t] + C_i[t]

        # 投資: I
        I[t] = δ * K[t-1] + (u[t-1] - u_T) * γ2 * K[t-1] + γ3 * (M_f[t-1] - L_f[t-1])

        # 設備稼働率: u
        u[t] = (C[t] + G[t] + I[t]) / (γ1 * K[t-1])

        # 資本ストック: K
        K[t] = (1 - δ) * K[t-1] + I[t]

        # 賃金: W
        W[t] = ω * (C[t-1] + G[t-1] + I[t-1])

        # 利益: P, P_i, P_b, P_f
        P[t] = C[t] + G[t] + I[t] - W[t] - T_v[t] - T_c[t] - r_LL_f[t-1]
        P_i[t] = (E_i[t-1] / (E_i[t-1] + E_b[t-1])) * max(0, θ1 * (P[t] - I[t]) + θ2 * (M_f[t-1] - L_f[t-1]))
        P_b[t] = (E_b[t-1] / (E_i[t-1] + E_b[t-1])) * max(0, θ1 * (P[t] - I[t]) + θ2 * (M_f[t-1] - L_f[t-1]))
        P_f[t] = P[t] - P_i[t] - P_b[t]

        # 銀行配当: S
        S[t] = θ3 * (r_LL[t-1] + r_BB_b[t-1] + P_b[t-1]) + θ4 * (L_f[t-1] + E_b[t-1] + B_b[t-1])

        # 純貸出: NL_w, NL_i, NL_f, NL_b, NL_g
        NL_w[t] = -C_w[t] + W[t] - T_iw[t] - r_LL_w[t-1]
        NL_i[t] = -C_i[t] - T_ii[t] - T_a[t] + r_BB_i[t-1] + P_i[t] + S[t]
        NL_f[t] = -I[t] + P_f[t]
        NL_b[t] = r_LL[t-1] + r_BB_b[t-1] + P_b[t-1] - S[t]
        NL_g[t] = -G[t] + T_i[t] + T_a[t] + T_v[t] + T_c[t] - r_BB[t-1]

        println(NL_w[t],", ",NL_i[t],", ",NL_f[t],", ",NL_b[t],", ",NL_g[t])
        println(NL_w[t]+NL_i[t]+NL_f[t]+NL_b[t]+NL_g[t])

        # 債券価格: p_B
        p_B[t] = (1 - r_B) / (1 - r_B^2)

        # 労働者の借入と預金: L_w, ΔL_w, ΔM_w, M_w
        L_w[t] = min(0, (ι1 - ι2 * r_L) * W[t])
        ΔL_w[t] = L_w[t] - L_w[t-1]
        ΔM_w[t] = NL_w[t] + ΔL_w[t]
        M_w[t] = M_w[t-1] + ΔM_w[t]

        # 資本家の預金: M_i, ΔM_i
        M_i[t] = (1 / μ1) * C_i[t]
        ΔM_i[t] = M_i[t] - M_i[t-1]

        # 企業の借入と預金: ΔL_f, L_f, ΔM_f, M_f
        ΔL_f[t] = max(-L_f[t-1], μ2 * (W[t] + T_v[t] + T_c[t] + r_LL_f[t-1] - μ3 * M_f[t-1]))
        L_f[t] = L_f[t-1] + ΔL_f[t]
        ΔM_f[t] = NL_f[t] + ΔL_f[t]
        M_f[t] = M_f[t-1] + ΔM_f[t]

        # 総貨幣: M
        M[t] = M_w[t] + M_i[t] + M_f[t]

        # 現金: H, ΔH
        H[t] = ν * M[t]
        ΔH[t] = H[t] - H[t-1]

        # 政府債券: Δb, b, B
        Δb[t] = (-NL_g[t] - ΔH[t]) / p_B[t]
        b[t] = b[t-1] + Δb[t]
        B[t] = p_B[t] * b[t]

        # 債券配分: B_i_e, B_b_e, B_i, B_b, b_i, b_b, Δb_i, Δb_b
        B_i_e[t] = ((1 - λ01 - λ12 * r_E + λ22 * r_B - λ14 * π) / (λ01 + λ11 * r_E + λ12 * r_B + λ14 * π)) * E_i[t-1]
        B_b_e[t] = ((1 - λ01 - λ12 * r_E + λ22 * r_B - λ14 * π) / (λ01 + λ11 * r_E + λ12 * r_B + λ14 * π)) * E_b[t-1]
        B_i[t] = (B_i_e[t] / (B_i_e[t] + B_b_e[t])) * B[t]
        B_b[t] = (B_b_e[t] / (B_i_e[t] + B_b_e[t])) * B[t]
        b_i[t] = B_i[t] / p_B[t]
        b_b[t] = B_b[t] / p_B[t]
        Δb_i[t] = b_i[t] - b_i[t-1]
        Δb_b[t] = b_b[t] - b_b[t-1]

        # 株式需要と配分: E_i_T, E_b_T, p_E, Δe_i, Δe_b, e_i, e_b, E_i, E_b
        E_i_T[t] = ((λ01 + λ11 * r_E + λ12 * r_B + λ14 * π) / (1 - λ01 - λ12 * r_E + λ22 * r_B - λ14 * π)) * B_i[t]
        E_b_T[t] = ((λ01 + λ11 * r_E + λ12 * r_B + λ14 * π) / (1 - λ01 - λ12 * r_E + λ22 * r_B - λ14 * π)) * B_b[t]
        p_E[t] = (E_i_T[t] + E_b_T[t]) / (e_i[t-1] + e_b[t-1])
        Δe_i[t] = (NL_i[t] - ΔM_i[t] - p_B[t] * Δb_i[t]) / p_E[t]
        Δe_b[t] = -Δe_i[t]
        e_i[t] = e_i[t-1] + Δe_i[t]
        e_b[t] = e_b[t-1] + Δe_b[t]
        E_i[t] = p_E[t] * e_i[t]
        E_b[t] = p_E[t] * e_b[t]

        # 次期間の利息支払いの更新: r_LL_w, r_LL_f, r_LL, r_BB_i, r_BB_b, r_BB
        r_LL_w[t] = r_L * L_w[t]
        r_LL_f[t] = r_L * L_f[t]
        r_LL[t] = r_LL_w[t] + r_LL_f[t]
        r_BB_i[t] = r_B * B_i[t]
        r_BB_b[t] = r_B * B_b[t]
        r_BB[t] = r_BB_i[t] + r_BB_b[t]
    end
end

simulate(1, T)

# 会計的整合性を確認するプロット
## フローの整合性を確認するプロット
plot(1:T, NL_w.+NL_i.+NL_f.+NL_b.+NL_g, label="flow consistency", xlabel="Time", ylabel="Value", legend=:topright)
savefig("figs/flow_consistency.png")


# 主要変数のプロット
plot(1:T, C, label="Consumption", xlabel="Time", ylabel="Value", legend=:topright)
plot!(1:T, G, label="Government Spending")
plot!(1:T, I, label="Investment")
plot!(1:T, K, label="Capital Stock")
savefig("figs/sfc_model_plot.png")
