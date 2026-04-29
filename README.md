まだプロトタイプもできていない

## 取引フロー表

|         | 労働者           | 資本家              | 企業<br>(経常)    | 企業<br>(資本)    | 金融機関             | 統合政府           | 合計      |
| ------- | ------------- | ---------------- | ------------- | ------------- | ---------------- | -------------- | ------- |
| 消費      | $-C_w$        | $-C_i$           | $+C$          |               |                  |                | $0$     |
| 政府支出    |               |                  | $+G$          |               |                  | $-G$           | $0$     |
| 投資      |               |                  | $+I$          | $-I$          |                  |                | $0$     |
| 賃金      | $+W$          |                  | $-W$          |               |                  |                | $0$     |
| 所得税     | $-T_{iw}$     | $-T_{ii}$        |               |               |                  | $+T_i$         | $0$     |
| 資産税     |               | $-T_a$           |               |               |                  | $+T_a$         | $0$     |
| 付加価値税   |               |                  | $-T_v$        |               |                  | $+T_v$         | $0$     |
| 法人税     |               |                  | $-T_c$        |               |                  | $+T_c$         | $0$     |
| 借入金利払い  | $-r_LL_{w-1}$ |                  | $-r_LL_{f-1}$ |               | $+r_LL_{-1}$     |                | $0$     |
| 国債利払い   |               | $+r_BB_{i-1}$    |               |               | $+r_BB_{b-1}$    | $-r_BB_{-1}$   | $0$     |
| 企業利潤    |               | $+P_i$           | $-P$          | $+P_f$        | $+P_b$           |                | $0$     |
| 銀行配当    |               | $+S$             |               |               | $-S$             |                | $0$     |
| \[純貸出\] | \[$NL_w$\]    | \[$NL_i$\]       |               | \[$NL_f$\]    | \[$NL_b$\]       | \[$NL_g$\]     | \[$0$\] |
| 預金の移動   | $-\Delta M_w$ | $-\Delta M_i$    |               | $-\Delta M_f$ | $+\Delta M$      |                | $0$     |
| 貸付金の移動  | $+\Delta L_w$ |                  |               | $+\Delta L_f$ | $-\Delta L$      |                | $0$     |
| 現金の移動   |               |                  |               |               | $-\Delta H$      | $+\Delta H$    | $0$     |
| 国債の移動   |               | $-p_B\Delta b_i$ |               |               | $-p_B\Delta b_b$ | $+p_B\Delta b$ | $0$     |
| 株式の移動   |               | $-p_E\Delta e_i$ |               |               | $-p_E\Delta e_b$ |                | $0$     |
| 合計      | $0$           | $0$              | $0$           | $0$           | $0$              | $0$            |         |


## バランスシート表

|     | 労働者     | 投資家     | 企業      | 金融機関    | 統合政府    | 合計   |
| --- | ------- | ------- | ------- | ------- | ------- | ---- |
| 資本  |         |         | $+K$    |         |         | $+K$ |
| 預金  | $+M_w$  | $+M_i$  | $+M_f$  | $-M$    |         | $0$  |
| 貸付金 | $-L_w$  |         | $-L_f$  | $+L$    |         | $0$  |
| 株式  |         | $+E_i$  | $-E$    | $+E_b$  |         | $0$  |
| 現金  |         |         |         | $+H$    | $-H$    | $0$  |
| 国債  |         | $+B_i$  |         | $+B_b$  | $-B$    | $0$  |
| 純資産 | $-NW_w$ | $-NW_i$ | $-NW_f$ | $-NW_b$ | $-NW_g$ | $-K$ |
| 合計  | $0$     | $0$     | $0$     | $0$     | $0$     | $0$  |


## モデルの式一覧
- $T_{iw}=\tau_1W_{-1}$
- $T_{ii}=\tau_1(r_BB_{i-2}+P_{i-1}+S_{-1})$
- $T_i=T_{iw}+T_{ii}$
- $T_a=\tau_2(M_{i-1}+E_{i-1}+B_{i-1})$
- $T_v=\tau_3(C_{-1}+G_{-1}+I_{-1})$
- $T_c=\tau_4(C_{-1}+G_{-1}+I_{-1}-W_{-1}-T_{v-1}-r_LL_{f-2}-\delta K_{-1})$
- $G=(1+\beta)G_{-1}$
- $C_w=\alpha_1(W_{-1}-T_{iw-1}-r_LL_{w-1})+\alpha_2(M_{w-1}-L_{w-1})$
- $C_i=\min\{\alpha_3C_{-1},\alpha_4(M_i+E_i+B_i)\}$
	- 本当は消費の実物量に上限があるという風に書きたいが、今回のモデルは価格と実質量を分けないため、苦肉の策として消費全体の一定割合で頭打ちになるという方法を採用する。
- $C=C_w+C_i$
- $I=\delta K_{-1}+(u_{-1}-u^T)\gamma_2K_{-1}+\gamma_3(M_{f-1}-L_{f-1})$
- $u=\frac{C+G+I}{\gamma_1K_{-1}}$
- $K=(1-\delta)K_{-1}+I$
- $W=\omega(C_{-1}+G_{-1}+I_{-1})$
- $P=C+G+I-W-T_v-T_c-r_LL_{f-1}$
- $P_i=\frac{E_{i-1}}{E_{-1}}\max\{0, \theta_1(P-I)+\theta_2(M_f-L_f)\}$
- $P_b=\frac{E_{b-1}}{E_{-1}}\max\{0, \theta_1(P-I)+\theta_2(M_f-L_f)\}$
- $P_f=P-P_i-P_b$
- $S=\theta_3(r_LL_{-1}+r_BB_{b-1}+P_{b-1})+\theta_4(L_{-1}+E_{b-1}+B_{b-1})$
- $NL_w=-C_w+W-T_{iw}-r_LL_{w-1}$
- $NL_i=-C_i-T_{ii}-T_a+r_BB_{i-1}+P_i+S$
- $NL_f=-I+P_f$
- $NL_b=r_LL_{-1}+r_BB_{b-1}+P_b-S$
- $NL_g=-G+T_i+T_a+T_v+T_c-r_BB_{-1}$
- $p_B=\frac{1-r_B}{1-(r_B)^2}$
	- 国債の価格
- $L_w=\min\{0,(\iota_1-\iota_2r_L)W\}$
- $\Delta L_w=L_w-L_{w-1}$
- $\Delta M_w=NL_w+\Delta L_w$
- $M_w=M_{w-1}+\Delta M_w$
- $M_i=\frac{1}{\mu_1} C_i$
- $\Delta M_i=M_i-M_{i-1}$
- $\Delta L_f=\max\{-L_f, \mu_2(W+T_v+T_c+r_LL_{f-1}-\mu_3M_{f-1}) \}$
- $L_f=L_{f-1}+\Delta L_f$
- $\Delta M_f=NL_f+\Delta L_f$
- $M_f=M_{-1}+\Delta M_f$
- $M=M_w+M_i+M_f$
- $H=\nu M$
- $\Delta H=H-H_{-1}$
- $\Delta b=\frac{-NL_g-\Delta H}{p_B}$
- $b=b_{-1}+\Delta b$
- $B=p_B\cdot b$
- $B_i^e=\frac{1-\lambda_{01}-\lambda_{12}r_E^e+\lambda_{22}r_B-\lambda_{14}\pi}{\lambda_{01}+\lambda_{11}r_E^e+\lambda_{12}r_B+\lambda_{14}\pi}E_{i-1}$
- $B_b^e=\frac{1-\lambda_{01}-\lambda_{12}r_E^e+\lambda_{22}r_B-\lambda_{14}\pi}{\lambda_{01}+\lambda_{11}r_E^e+\lambda_{12}r_B+\lambda_{14}\pi}E_{b-1}$
- $B_i=\frac{B_i^e}{B_i^e+B_b^e}B$
- $B_b=\frac{B_b^e}{B_i^e+B_b^e}B$
- $b_i=\frac{B_i}{p_B}$
- $b_b=\frac{B_b}{p_B}$
- $\Delta b_i=b_i-b_{i-1}$
- $\Delta b_b=b_b-b_{b-1}$
- $E_i^T=\frac{\lambda_{01}+\lambda_{11}r_E^e+\lambda_{12}r_B+\lambda_{14}\pi}{1-\lambda_{01}-\lambda_{12}r_E^e+\lambda_{22}r_B-\lambda_{14}\pi}B_i$
- $E_b^T=\frac{\lambda_{01}+\lambda_{11}r_E^e+\lambda_{12}r_B+\lambda_{14}\pi}{1-\lambda_{01}-\lambda_{12}r_E^e+\lambda_{22}r_B-\lambda_{14}\pi}B_b$
- $p_E=\frac{E_i^T+E_b^T}{e}$
- $\Delta e_i=\frac{NL_i-\Delta M_i-p_B\Delta b_i}{p_E}$
- $\Delta e_b=-\Delta e_i$
- $e_i=e_{i-1}+\Delta e_i$
- $e_b=e_{b-1}+\Delta e_b$
- $E_i=p_E\cdot e_i$
- $E_b=p_E\cdot e_b$
- $E=E_i+E_b$
- $NW_w=M_w-L_w$
- $NW_i=M_i+E_i+B_i$
- $NW_f=K+M_f-L_f-E$
- $NW_b=-M+L+E_b+H+B_b$
- $NW_g=-H-B$
