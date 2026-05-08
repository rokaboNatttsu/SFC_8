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
λ01, λ11, λ12, λ22, λ14 = 0.5, 0.5, 0.3, 0.2, 0.1  # ポートフォリオパラメータ
rB, rL, rE, π, uT = 0.03, 0.05, 0.06, 0.02, 0.8  # 金利とインフレ

# シミュレーションパラメータ
T = 100  # 期間数

# カテゴリごとにグループ化された配列の初期化
Tiw, Tii, Ti, Ta, Tv, Tc = zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T)
G = zeros(T)
Cw, Ci, C = zeros(T), zeros(T), zeros(T)
I = zeros(T)
u = zeros(T)
K = zeros(T)
W = zeros(T)
P, Pi, Pb, Pf = zeros(T), zeros(T), zeros(T), zeros(T)
S = zeros(T)
NLw, NLi, NLf, NLb, NLg = zeros(T), zeros(T), zeros(T), zeros(T), zeros(T)
pB, pE = zeros(T), zeros(T)
Lw, Lf, L, ΔLw, ΔLf, ΔL = zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T)
Mi, Mw, Mf, M, ΔMi, ΔMw, ΔMf, ΔM = zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T)
H, ΔH = zeros(T), zeros(T)
Δb, b, B = zeros(T), zeros(T), zeros(T)
Bie, Bbe, Bi, Bb, bi, bb, Δbi, Δbb = zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T)
EiT, EbT, Δei, Δeb, ei, eb, Ei, Eb = zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T), zeros(T)
E, e = zeros(T), zeros(T)
NWw, NWi, NWf, NWb, NWg = zeros(T), zeros(T), zeros(T), zeros(T), zeros(T)

# 初期値（期間1）
K[1] = 100.0
G[1] = 20.0
Cw[1], Ci[1] = 15.0, 10.0; C[1] = Cw[1] + Ci[1]
I[1] = 10.0
u[1] = (C[1] + G[1] + I[1]) / (γ1*K[1])
W[1] = 25.0
Lw[1], Lf[1] = 5.0, 5.0
Mw[1], Mi[1], Mf[1] = 10.0, 5.0, 5.0; M[1] = Mw[1] + Mi[1] + Mf[1]
Ei[1], Eb[1], ei[1], eb[1] = 20.0, 10.0, 20.0, 10.0
Bi[1], Bb[1], bi[1], bb[1] = 30.0, 20.0, 30.0, 20.0
b[1], B[1] = bi[1] + bb[1], Bi[1] + Bb[1]
H[1] = ν*M[1]; ΔH[1] = 0.0
pB[1] = (1 - rB) / (1 - rB^2)
Tiw[1], Tii[1] = τ1*W[1], 0.0; Ti[1] = Tiw[1] + Tii[1]
Ta[1] = τ2*(Mi[1] + Ei[1] + Bi[1])
Tv[1] = τ3*(C[1] + G[1] + I[1])
Tc[1] = τ4*(C[1] + G[1] + I[1] - W[1] - Tv[1] - rL*Lf[1] - δ*K[1])
P[1] = C[1] + G[1] + I[1] - W[1] - Tv[1] - Tc[1] - rL*Lf[end]
Pi[1], Pb[1] = 0.0, 0.0; Pf[1] = P[1]
S[1] = 0.0

NLw[1] = -Cw[1] + W[1] - Tiw[1] - rL*Lw[end]
NLi[1] = -Ci[1] - Tii[1] - Ta[1] + rB*Bi[end] + Pi[1] + S[1]
NLf[1] = -I[1] + Pf[1]
NLb[1] = rL*L[end] + rB*Bb[end] + Pb[1] - S[1]
NLg[1] = -G[1] + Ti[1] + Ta[1] + Tv[1] + Tc[1] - rB*B[end]
e[1] = ei[1] + eb[1]
E[1] = Ei[1] + Eb[1]
L[1] = Lw[1] + Lf[1]
NWw[1] = Mw[1] - Lw[1]
NWi[1] = Mi[1] + Ei[1] + Bi[1]
NWf[1] = K[1] + Mf[1] - Lf[1] - E[1]
NWb[1] = -M[1] + L[1] + Eb[1] + H[1] + Bb[1]
NWg[1] = -H[1] - B[1]

# main.mdのモデル式順序に従ったシミュレーションロープ
function simulate(st, en)
    tm2 = 1
    for t in st:en
        tm2 = t-2
        if tm2==0
            tm2 = 1
        end
        # 税: Tiw, Tii, Ti, Ta, Tv, Tc
        Tiw[t] = τ1*W[t-1]
        Tii[t] = τ1*(rB*Bi[tm2] + Pi[t-1] + S[t-1])
        Ti[t] = Tiw[t] + Tii[t]
        Ta[t] = τ2*(Mi[t-1] + Ei[t-1] + Bi[t-1])
        Tv[t] = τ3*(C[t-1] + G[t-1] + I[t-1])
        Tc[t] = τ4*(C[t-1] + G[t-1] + I[t-1] - W[t-1] - Tv[t-1] - rL*Lf[tm2] - δ*K[t-1])

        # 政府支出: G
        G[t] = (1 + β)*G[t-1]

        # 消費: Cw, Ci, C
        Cw[t] = α1*(W[t-1] - Tiw[t-1] - rL*Lw[t-1]) + α2*(Mw[t-1] - Lw[t-1])
        Ci[t] = min(α3*C[t-1], α4*(Mi[t-1] + Ei[t-1] + Bi[t-1]))
        C[t] = Cw[t] + Ci[t]

        # 投資: I
        I[t] = δ*K[t-1] + (u[t-1] - uT)*γ2*K[t-1] + γ3*(Mf[t-1] - Lf[t-1])

        # 設備稼働率: u
        u[t] = (C[t] + G[t] + I[t]) / (γ1*K[t-1])

        # 資本ストック: K
        K[t] = (1 - δ)*K[t-1] + I[t]

        # 賃金: W
        W[t] = ω*(C[t-1] + G[t-1] + I[t-1])

        # 利益: P, Pi, Pb, Pf
        P[t] = C[t] + G[t] + I[t] - W[t] - Tv[t] - Tc[t] - rL*Lf[t-1]
        Pi[t] = (Ei[t-1] / (Ei[t-1] + Eb[t-1]))*max(0, θ1*(P[t] - I[t]) + θ2*(Mf[t-1] - Lf[t-1]))
        Pb[t] = (Eb[t-1] / (Ei[t-1] + Eb[t-1]))*max(0, θ1*(P[t] - I[t]) + θ2*(Mf[t-1] - Lf[t-1]))
        Pf[t] = P[t] - Pi[t] - Pb[t]

        # 銀行配当: S
        S[t] = θ3*(rL*L[t-1] + rB*Bb[t-1] + Pb[t-1]) + θ4*(Lf[t-1] + Eb[t-1] + Bb[t-1])

        # 純貸出: NLw, NLi, NLf, NLb, NLg
        NLw[t] = -Cw[t] + W[t] - Tiw[t] - rL*Lw[t-1]
        NLi[t] = -Ci[t] - Tii[t] - Ta[t] + rB*Bi[t-1] + Pi[t] + S[t]
        NLf[t] = -I[t] + Pf[t]
        NLb[t] = rL*L[t-1] + rB*Bb[t-1] + Pb[t] - S[t]
        NLg[t] = -G[t] + Ti[t] + Ta[t] + Tv[t] + Tc[t] - rB*B[t-1]

        # 債券価格: pB
        pB[t] = (1 - rB) / (1 - rB^2)

        # 労働者の借入と預金: Lw, ΔLw, ΔMw, Mw
        Lw[t] = min(0, (ι1 - ι2*rL)*W[t])
        ΔLw[t] = Lw[t] - Lw[t-1]
        ΔMw[t] = NLw[t] + ΔLw[t]
        Mw[t] = Mw[t-1] + ΔMw[t]

        # 資本家の預金: Mi, ΔMi
        Mi[t] = (1 / μ1)*Ci[t]
        ΔMi[t] = Mi[t] - Mi[t-1]

        # 企業の借入と預金: ΔLf, Lf, ΔMf, Mf
        ΔLf[t] = max(-Lf[t-1], μ2*(W[t] + Tv[t] + Tc[t] + rL*Lf[t-1] - μ3*Mf[t-1]))
        Lf[t] = Lf[t-1] + ΔLf[t]
        ΔMf[t] = NLf[t] + ΔLf[t]
        Mf[t] = Mf[t-1] + ΔMf[t]

        # 預金と貸付金のストックの整合性
        M[t] = Mw[t] + Mi[t] + Mf[t]
        L[t] = Lw[t] + Lf[t]

        # 現金: H, ΔH
        H[t] = ν*M[t]
        ΔH[t] = H[t] - H[t-1]

        # 政府債券: Δb, b, B
        Δb[t] = (-NLg[t] - ΔH[t]) / pB[t]
        b[t] = b[t-1] + Δb[t]
        B[t] = pB[t]*b[t]

        # 債券配分: Bie, Bbe, Bi, Bb, bi, bb, Δbi, Δbb
        Bie[t] = ((1 - λ01 - λ12*rE + λ22*rB - λ14*π) / (λ01 + λ11*rE + λ12*rB + λ14*π))*Ei[t-1]
        Bbe[t] = ((1 - λ01 - λ12*rE + λ22*rB - λ14*π) / (λ01 + λ11*rE + λ12*rB + λ14*π))*Eb[t-1]
        Bi[t] = (Bie[t] / (Bie[t] + Bbe[t]))*B[t]
        Bb[t] = (Bbe[t] / (Bie[t] + Bbe[t]))*B[t]
        bi[t] = Bi[t] / pB[t]
        bb[t] = Bb[t] / pB[t]
        Δbi[t] = bi[t] - bi[t-1]
        Δbb[t] = bb[t] - bb[t-1]

        # 株式需要と配分: EiT, EbT, pE, Δei, Δeb, ei, eb, Ei, Eb, E
        EiT[t] = ((λ01 + λ11*rE + λ12*rB + λ14*π) / (1 - λ01 - λ12*rE + λ22*rB - λ14*π))*Bi[t]
        EbT[t] = ((λ01 + λ11*rE + λ12*rB + λ14*π) / (1 - λ01 - λ12*rE + λ22*rB - λ14*π))*Bb[t]
        pE[t] = (EiT[t] + EbT[t]) / (ei[t-1] + eb[t-1])
        Δei[t] = (NLi[t] - ΔMi[t] - pB[t]*Δbi[t]) / pE[t] # 個々の値がとりうる範囲を制限すべき？
        Δeb[t] = -Δei[t]
        ei[t] = ei[t-1] + Δei[t]
        eb[t] = eb[t-1] + Δeb[t]
        Ei[t] = pE[t]*ei[t]
        Eb[t] = pE[t]*eb[t]
        E[t] = Ei[t] + Eb[t]

        # 純資産
        NWw[t] = Mw[t] - Lw[t]
        NWi[t] = Mi[t] + Ei[t] + Bi[t]
        NWf[t] = K[t] + Mf[t] - Lf[t] - E[t]
        NWb[t] = -M[t] + L[t] + Eb[t] + H[t] + Bb[t]
        NWg[t] = -H[t] - B[t]
    end
end

simulate(2, T)

plot(1:T, NLw.+NLi.+NLf.+NLb.+NLg, label="flow consistency", xlabel="Time", ylabel="Value", legend=:topright)
savefig("figs/flow_consistency.png")

plot(1:T, NWw.+NWi.+NWf.+NWb.+NWg.-K, label="stock consistency", xlabel="Time", ylabel="Value", legend=:topright)
savefig("figs/stock_consistency.png")

# 主要変数のプロット
plot(1:T, C, label="Consumption", xlabel="Time", ylabel="Value", legend=:topright, yscale=:log10)
plot!(1:T, G, label="Government Spending", yscale=:log10)
plot!(1:T, I, label="Investment", yscale=:log10)
plot!(1:T, K, label="Capital Stock", yscale=:log10)
savefig("figs/sfc_model_plot.png")
