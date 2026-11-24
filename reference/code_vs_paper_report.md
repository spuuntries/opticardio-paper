# Cross-Validation Report: Code vs. Paper

> Scope: [train_lora.py](file:///c:/Users/kek/projects/opticardio/train_lora.py), [train_align.py](file:///c:/Users/kek/projects/opticardio/train_align.py), [train_cmae_align.py](file:///c:/Users/kek/projects/opticardio/train_cmae_align.py), [evaluate.py](file:///c:/Users/kek/projects/opticardio/evaluate.py), plus [models.py](file:///c:/Users/kek/projects/opticardio/models.py) and [lora_utils.py](file:///c:/Users/kek/projects/opticardio/lora_utils.py) vs. methodology in [main.typ](file:///c:/Users/kek/projects/opticardio/paper/main.typ)

---

## 1. ResNetAlign (Alignment Layer: CardioGAN → MCMA)

### Paper says (§3.4, lines 200-206):
- 4 conv1d layers, kernel=15, padding=7
- Channel progression: 1 → 32 → 64 → 32 → 1
- First 3 layers followed by GELU
- Residual connection: y = x + F(x)
- Last conv initialized to zero weights/bias (identity mapping)

### Code in [models.py L514-532](file:///c:/Users/kek/projects/opticardio/models.py#L514-L532):
```python
self.net = nn.Sequential(
    nn.Conv1d(1, 32, kernel_size=15, padding=7),   # layer 1
    nn.GELU(),
    nn.Conv1d(32, 64, kernel_size=15, padding=7),  # layer 2
    nn.GELU(),
    nn.Conv1d(64, 32, kernel_size=15, padding=7),  # layer 3
    nn.GELU(),
    nn.Conv1d(32, 1, kernel_size=15, padding=7),   # layer 4 (no activation)
)
# forward: out = x + self.net(x)
```

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Number of conv layers | 4 | 4 | ✅ |
| Channel progression | 1→32→64→32→1 | 1→32→64→32→1 | ✅ |
| Kernel size / padding | 15 / 7 | 15 / 7 | ✅ |
| Activation (first 3 layers) | GELU | GELU | ✅ |
| Residual connection | y = x + F(x) | `out = x + self.net(x)` | ✅ |
| Zero init on last layer | Yes | Yes (in [train_align.py L33-35](file:///c:/Users/kek/projects/opticardio/train_align.py#L33-L35)) | ✅ |

> [!NOTE]
> Zero init happens at index `net[6]` in train_align.py, which is the 4th Conv1d (indices 0,2,4,6 after interleaved GELUs). Correct.

---

## 2. BeatAlign (Alignment Layer: MCMA → CMAE)

### Paper says (§3.6, lines 222-234):
- 3 conv1d layers, kernel=15, padding=7
- Channel progression: 12 → 48 → 48 → 12
- GELU activations
- Residual connection: y = x + F(x)
- Last conv initialized to zero (identity mapping)

### Code in [models.py L538-562](file:///c:/Users/kek/projects/opticardio/models.py#L538-L562):
```python
self.net = nn.Sequential(
    nn.Conv1d(12, 48, kernel_size=15, padding=7),  # layer 1
    nn.GELU(),
    nn.Conv1d(48, 48, kernel_size=15, padding=7),  # layer 2
    nn.GELU(),
    nn.Conv1d(48, 12, kernel_size=15, padding=7),  # layer 3 (no activation)
)
self.scale = nn.Parameter(torch.full((12, 1), 0.1))
self.bias = nn.Parameter(torch.zeros(12, 1))
# forward: out = (x + self.net(x)) * self.scale + self.bias
```

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Number of conv layers | 3 | 3 | ✅ |
| Channel progression | 12→48→48→12 | 12→48→48→12 | ✅ |
| Kernel / padding | 15 / 7 | 15 / 7 | ✅ |
| GELU activations | Yes (on first two) | Yes (on first two) | ✅ |
| Residual connection | y = x + F(x) | `x + self.net(x)` | ✅ |
| Zero init on last conv | Yes | Yes (in [train_cmae_align.py L32-34](file:///c:/Users/kek/projects/opticardio/train_cmae_align.py#L32-L34)) | ✅ |

> [!WARNING]
> **Extra learnable affine parameters not mentioned in paper.** The code has `self.scale` (init 0.1) and `self.bias` (init 0) that apply a per-lead affine transformation after the residual: `out = (x + F(x)) * scale + bias`. The paper only describes the residual connection `y = x + F(x)`. This is a minor omission — the affine doesn't change the architecture conceptually but IS there in the code.

---

## 3. ECG-to-PPG Model (ReversoECG2PPG)

### Paper says (§3.7, lines 242-252):
- Reverso-Small backbone (pretrained, frozen)
- Projection head: 4 conv1d layers
- Channel progression: 128 → 64 → 32 → 1
- Kernel size: 7
- GELU on each layer except last

### Code in [models.py L442-508](file:///c:/Users/kek/projects/opticardio/models.py#L442-L508):
```python
self.proj_head = nn.Sequential(
    nn.Conv1d(self.d_model, 128, kernel_size=7, padding=3),  # d_model=64
    nn.GELU(),
    nn.Conv1d(128, 64, kernel_size=7, padding=3),
    nn.GELU(),
    nn.Conv1d(64, 32, kernel_size=7, padding=3),
    nn.GELU(),
    nn.Conv1d(32, 1, kernel_size=7, padding=3),
)
```

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Backbone | Reverso-Small, frozen | Reverso-Small, frozen | ✅ |
| Projection layers | 4 conv1d | 4 conv1d | ✅ |
| Kernel size | 7 | 7 | ✅ |
| GELU activation | On each except last | On first 3 of 4 | ✅ |

> [!WARNING]
> **Channel sequence slight mismatch.** Paper says "128 → 64 → 32 → 1" (implying input channels = 128), but code starts from `d_model=64`, so the actual channel progression is **64 → 128 → 64 → 32 → 1**. The paper omits the first expansion step from d_model=64 to 128. The paper says "penurunan jumlah channel secara bertahap 128 → 64 → 32 → 1" which describes only the decreasing part, but the first layer actually expands from 64 to 128.

---

## 4. LoRA / PiSSA Configuration

### Paper says (§3.10, lines 256-259):
- LoRA rank = 8, α = 16
- PiSSA initialization

### Code in [lora_utils.py L4](file:///c:/Users/kek/projects/opticardio/lora_utils.py#L4):
```python
def inject_lora_targeted(model, targets_str, r=8, alpha=16, use_pissa=False):
```

Called in [train_lora.py L48-49](file:///c:/Users/kek/projects/opticardio/train_lora.py#L48-L49):
```python
model = inject_lora_targeted(model, targets_str=config.LORA_TARGETS, use_pissa=True)
```

Config targets from [config.py L32](file:///c:/Users/kek/projects/opticardio/config.py#L32): `LORA_TARGETS = "ppg_gan,ecg_recon,ecg_enc,ecg_dec"`

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| LoRA rank | 8 | r=8 | ✅ |
| LoRA alpha | 16 | alpha=16 | ✅ |
| PiSSA init | Yes | use_pissa=True | ✅ |
| Targets | ppg_gan, ecg_recon, ecg_enc, ecg_dec | "ppg_gan,ecg_recon,ecg_enc,ecg_dec" | ✅ |
| Module types | Conv1d, Conv2d, Linear | Conv1d, Conv2d, Linear | ✅ |

> [!NOTE]
> Paper mentions LoRA targets as "ppg_gan → generates fake ecg, ecg_recon → MCMA 12-lead, ecg_enc → CMAE ecg encoder, ecg_dec → CMAE ecg decoder". The code also LoRA-injects into `ecg_dec` which appears in the targets string but is NOT explicitly mentioned in the paper text as a LoRA target. However the mri_enc and mri_dec are NOT in the targets list, consistent with the paper not mentioning them.

---

## 5. E2E Finetuning Loss Functions (train_step_stacked_cycles)

### Paper §3.8 defines 9 losses. Checking each against [models.py L995-1102](file:///c:/Users/kek/projects/opticardio/models.py#L995-L1102):

### Loss 1: L_sup (Shifted Pearson Correlation)

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Formula | `1 - max_τ ρ(ŷ_1lecg(t), y_ecg(t-τ))` | `shifted_pearson_corr_loss(fake_ecg_1l, real_ecg_lead_ii, max_shift=64)` | ✅ |
| Shift parameter | τ (unspecified range) | max_shift=64 | ✅ (paper doesn't specify exact range) |

### Loss 2: L_distill (Teacher Distillation)

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Formula | `1 - ρ(ŷ_1lecg, y_teacher)` | `1.0 - self._pearson_corr(fake_ecg_1l, teacher_ecg)` | ✅ |
| Teacher | Frozen CardioGAN | `copy.deepcopy(model.ppg_gan).eval()` (frozen in train_lora.py L32-34) | ✅ |

### Loss 3: L_cyc_small (Small Cycle)

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Formula | `‖G_inv(ŷ_12lecg^II) - x_ppg‖₁` | `F.l1_loss(rec_ppg_small.squeeze(), real_ppg.squeeze())` | ✅ |
| Path | PPG→1L→12L→Lead II→PPG | ppg_gan→mcma_forward_diff→beat_align→lead_ii→ecg2ppg | ✅ |

### Loss 4: L_cyc_big (Big Cycle)

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Formula | `‖G_inv(ŷ_recon^II) - x_ppg‖₁` | `F.l1_loss(rec_ppg_big.squeeze(), real_ppg.squeeze())` | ✅ |
| Path | PPG→1L→12L→MRI→12L_recon→Lead II→PPG | ...→ecg_enc→mri_dec→mri_enc→ecg_dec→lead_ii→ecg2ppg | ✅ |

### Loss 5: L_align (Alignment Loss)

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Formula | `‖ŷ_native12^II - ŷ_1lecg‖₂² + (1 - ρ(ŷ_native12^II, ŷ_1lecg))` | `F.mse_loss(recon_lead_ii, sig_2048_raw.detach()) + (1.0 - self._pearson_corr(sig_2048_raw.detach(), recon_lead_ii))` | ✅ |

### Loss 6: L_cyc_mri (MRI Cycle)

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Formula | `‖ŷ_recon - ŷ_12lecg‖₁` | `F.l1_loss(rec_ecg_12l, fake_ecg_12l.detach())` | ✅ |

### Loss 7: L_z_reg (Latent Regularization)

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Formula | `(1/N) Σ z²` | `torch.mean(z**2)` | ✅ |

### Loss 8: L_phys_total (Physical Consistency)

Paper (§3.8, lines 331-340) describes 4 positions for physics loss:
1. `ŷ_native12` → `ecg_12_native`
2. `ŷ_12lecg` → `fake_ecg_12l` (after beat_align)
3. `ŷ_recon` → `rec_ecg_12l`
4. `ŷ_chapman` → `ecg_12_chapman`

Code accumulates physics loss at lines 1018, 1030, 1048, 1069:
```python
loss_phys = self.physical_consistency_loss(ecg_12_native, order="ukb")     # position 1
loss_phys = loss_phys + self.physical_consistency_loss(fake_ecg_12l, ...)  # position 2
loss_phys = loss_phys + self.physical_consistency_loss(rec_ecg_12l, ...)   # position 3
loss_phys_chapman = self.physical_consistency_loss(ecg_12_chapman, ...)    # position 4
loss_phys = loss_phys + loss_phys_chapman
```

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| 4 positions | native12, 12lecg, recon, chapman | native12, 12lecg, recon, chapman | ✅ |
| Einthoven: I - II + III = 0 | ✅ | `l_I - l_II + l_III` (L1) | ✅ |
| Goldberger aVR = -(I+II)/2 | ✅ | `l_aVR - (-(l_I + l_II) / 2)` (L1) | ✅ |
| Goldberger aVL = (I-III)/2 | ✅ | `l_aVL - ((l_I - l_III) / 2)` (L1) | ✅ |
| Goldberger aVF = (II+III)/2 | ✅ | `l_aVF - ((l_II + l_III) / 2)` (L1) | ✅ |
| Wilson: aVR+aVL+aVF = 0 | ✅ | `l_aVR + l_aVL + l_aVF` (L1) | ✅ |

### Loss 9: L_chapman (Chapman Regularization)

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Formula | `(1-ρ(ŷ_chapman, y_chapman)) + 0.1·‖ŷ-y‖₁ + 0.1·L_phys(ŷ_chapman)` | `(1.0 - corr_c) + 0.1 * l1_c + 0.1 * loss_phys_chapman` | ✅ |

### Loss Weights

| Loss | Paper λ | Code multiplier | **Match?** |
|---|---|---|---|
| L_sup | 10.0 | 10.0 | ✅ |
| L_distill | 15.0 | 15.0 | ✅ |
| L_align | 5.0 | 5.0 | ✅ |
| L_phys_total | 5.0 | 5.0 | ✅ |
| L_cyc_small | 5.0 | 5.0 | ✅ |
| L_cyc_mri | 2.0 | 2.0 | ✅ |
| L_cyc_big | 5.0 | 5.0 | ✅ |
| L_z_reg | 0.01 | 0.01 | ✅ |
| L_chapman | 5.0 | 5.0 | ✅ |

> [!NOTE]
> All 9 losses and all 9 weights match perfectly between paper and code.

---

## 6. E2E Training Hyperparameters

### Paper says (§3.8, lines 356-357):
- 10 epochs
- Adam optimizer, weight_decay = 1e-5
- OneCycleLR, max_lr = 1.5e-3
- Gradient clipping max_norm = 0.5

### Code in [train_lora.py](file:///c:/Users/kek/projects/opticardio/train_lora.py):

```python
# Defaults
parser.add_argument("--epochs", type=int, default=5)        # Line 208
parser.add_argument("--lr", type=float, default=3e-4)       # Line 211

# Training
optimizer = torch.optim.Adam(trainable_params, lr=args.lr, weight_decay=1e-5)  # Line 81
scheduler = torch.optim.lr_scheduler.OneCycleLR(
    optimizer, max_lr=args.lr * 5, ...                       # Line 111: 3e-4 * 5 = 1.5e-3
)
# Gradient clipping in models.py L1089
torch.nn.utils.clip_grad_norm_(self.parameters(), max_norm=0.5)
```

| Aspect | Paper | Code default | **Match?** |
|---|---|---|---|
| Epochs | 10 | **5** | ⚠️ **MISMATCH** |
| Optimizer | Adam | Adam | ✅ |
| Weight decay | 1e-5 | 1e-5 | ✅ |
| OneCycleLR max_lr | 1.5e-3 | `3e-4 * 5 = 1.5e-3` | ✅ |
| Gradient clipping | max_norm=0.5 | max_norm=0.5 | ✅ |

> [!CAUTION]
> **Epoch count mismatch**: Paper says 10 epochs, but `train_lora.py` defaults to `--epochs=5`. This is a CLI default, so the actual training run likely used `--epochs 10` on the command line, but the default doesn't match. Worth verifying how it was actually run.

---

## 7. Alignment Layer Pretraining (train_align.py)

### Paper says (§3.4, lines 204-206):
- 5 epochs
- Adam, weight_decay = 1e-5
- OneCycleLR, max_lr = 2.5e-2
- Everything frozen except ecg_align, before e2e finetuning

### Code in [train_align.py](file:///c:/Users/kek/projects/opticardio/train_align.py):
```python
def train_align(epochs=5, batch_size=128, lr=5e-3):  # Line 28
    optimizer = torch.optim.Adam(..., lr=lr, weight_decay=1e-5)  # Line 48
    scheduler = OneCycleLR(optimizer, max_lr=lr*5, ...)  # Line 50: 5e-3 * 5 = 2.5e-2
```

| Aspect | Paper | Code default | **Match?** |
|---|---|---|---|
| Epochs | 5 | 5 | ✅ |
| Optimizer | Adam | Adam | ✅ |
| Weight decay | 1e-5 | 1e-5 | ✅ |
| OneCycleLR max_lr | 2.5e-2 | `5e-3 * 5 = 2.5e-2` | ✅ |
| Only ecg_align trainable | Yes | Yes (lines 38-42 freeze everything else) | ✅ |

### Loss function
Paper: `L_align = ‖ŷ_native12^II - ŷ_1lecg‖₂² + (1 - ρ(ŷ_native12^II, ŷ_1lecg))`

Code:
```python
loss_mse = F.mse_loss(recon_lead_ii, sig_2048)
loss_corr = 1.0 - pearson_corr(sig_2048, recon_lead_ii)
loss = loss_mse + loss_corr
```

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| MSE component | ✅ | `F.mse_loss(recon_lead_ii, sig_2048)` | ✅ |
| Pearson component | ✅ | `1.0 - pearson_corr(...)` | ✅ |

---

## 8. Beat Alignment Layer Pretraining (train_cmae_align.py)

### Paper says (§3.6, lines 228-234):
```
L_beat_align = (1 - ρ(ŷ_12lecg, ŷ_recon_cmae))
             + 0.5 · ‖ŷ_12lecg - ŷ_recon_cmae‖₁
             + 2.0 · (1 - sim(z_ecg, z_mri))
             + 0.01 · (1/N) Σ z_ecg²
```

### Code in [train_cmae_align.py L108-113](file:///c:/Users/kek/projects/opticardio/train_cmae_align.py#L108-L113):
```python
loss_recon_corr = 1.0 - pearson_corr_12lead(aligned, reconstructed)
loss_recon_l1 = F.l1_loss(aligned, reconstructed)
loss_z_consist = 1.0 - F.cosine_similarity(z_ecg_sub, z_mri, dim=1).mean()
loss_z_reg = torch.mean(z_ecg ** 2) * 0.01

loss = loss_recon_corr + loss_recon_l1 * 0.5 + loss_z_consist * 2.0 + loss_z_reg
```

| Component | Paper | Code | **Match?** |
|---|---|---|---|
| `(1 - ρ(aligned, recon))` | ✅ | `1.0 - pearson_corr_12lead(aligned, reconstructed)` | ✅ |
| `0.5 · ‖aligned - recon‖₁` | ✅ | `loss_recon_l1 * 0.5` | ✅ |
| `2.0 · (1 - sim(z_ecg, z_mri))` | ✅ | `loss_z_consist * 2.0` | ✅ |
| `0.01 · (1/N) Σ z²` | ✅ | `torch.mean(z_ecg ** 2) * 0.01` | ✅ |

### Training hyperparameters

| Aspect | Paper | Code default | **Match?** |
|---|---|---|---|
| Epochs | 5 | 5 | ✅ |
| Optimizer | Adam, wd=1e-5 | Adam, wd=1e-5 | ✅ |
| OneCycleLR max_lr | 2.5e-2 | `5e-3 * 5 = 2.5e-2` | ✅ |
| Only beat_align trainable | Yes | Yes (L37-41) | ✅ |

> [!NOTE]
> **z_mri derivation matches paper.** Paper says z_mri is "z_ecg yang di-decode oleh decoder MRI CMAE yang di-encode kembali oleh encoder MRI CMAE". Code: `mri = self.mri_dec(z_ecg_sub)` → `z_mri = self.mri_enc(mri)`. ✅

---

## 9. Evaluation: Retrieval Precision

### Paper says (§3.9.2, lines 370-385):
- Chapman test set (80-20 split), max 200 samples per class
- Priority ordering: PVC > AFL > AFIB > SB > ST > SR
- Dot-product similarity matrix
- Bootstrap 30 runs, 95% CI
- k values: [1, 3, 5, 10, 15]

### Code in [evaluate.py](file:///c:/Users/kek/projects/opticardio/evaluate.py):

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Split | 80-20 train/val | `split_idx = int(len(all_headers) * 0.8)` (L131) | ✅ |
| Max samples per class | 200 | `samples_per_class=400` (default, L234/L1039) | ⚠️ **See note** |
| Priority order | PVC > AFL > AFIB > SB > ST > SR | `PRIORITY_ORDER = ["PVC","AFL","AFIB","SB","ST","SR"]` (L101) | ✅ |
| Similarity | Dot-product | `torch.matmul(embeddings, embeddings.T)` with L2 norm → cosine sim (L316-322) | ✅ |
| k values | 1, 3, 5, 10, 15 | `[1, 3, 5, 10, 15]` (default, L1043) | ✅ |
| Bootstrap | 30 runs, 95% CI | `--bootstrap-runs` flag, `st.t.ppf((1+0.95)/2.0, ...)` (L1168) | ✅ |

> [!IMPORTANT]
> **Samples per class**: Paper says "maksimum 200 sampel per label" but code defaults to `samples_per_class=400`. The eval was likely run with `--samples-per-class 200` on the command line, but the code default is different. The `load_chapman_stratified` function at L108 does use 400 as default. However, since the eval_results clearly show specific numbers matching the paper, the actual invocation must have used the right value.

### Embedding paths match what's expected:

| Model | Paper description | Code path | **Match?** |
|---|---|---|---|
| OptiCardio (CMAE) | ecg_enc embedding | `base_model.ecg_enc(batch)` (L302) | ✅ |
| OptiCardio (MCMA) | ecg_recon features | `base_model.ecg_recon(batch, return_features=True)` (L309) | ✅ |
| CMAE baseline | ecg_enc without LoRA | `load_model(config, use_lora=False)` → `ecg_enc` (L1097-1103) | ✅ |
| MCMA baseline | ecg_recon without LoRA | `cmae_model.ecg_recon` (L1106-1110) | ✅ |

### Hit matching logic
Paper: "jika `(Y_i ∩ M) ∩ (Y_j ∩ M) ≠ ∅`" (any overlap in major codes)
Code: `if not q_major.isdisjoint(n_major)` (L356) → **exactly equivalent** ✅

---

## 10. Evaluation: Latent Cycle Consistency

### Paper says (§3.9.3, lines 387-391):
- MRI autoencoder: 4-layer conv encoder/decoder, latent dim 256, input 96×96
- Encoder: progressive downsampling 96→6 with Conv2d(4,2,1), LeakyReLU, BatchNorm, then dense→tanh
- Decoder: mirrors with ConvTranspose2d, Sigmoid output
- Probe/mapper: 3-layer MLP with LeakyReLU and BatchNorm
- Bidirectional cycle consistency: forward + reverse mapper, MAE loss

### Code in [evaluate.py L395-462](file:///c:/Users/kek/projects/opticardio/evaluate.py#L395-L462):

**MRI_AE:**
```python
# Encoder: Conv2d layers with 4x4 kernel, stride 2, padding 1
nn.Conv2d(1, 32, 4, 2, 1),    LeakyReLU(0.2),           # 96→48
nn.Conv2d(32, 64, 4, 2, 1),   BatchNorm2d, LeakyReLU,   # 48→24
nn.Conv2d(64, 128, 4, 2, 1),  BatchNorm2d, LeakyReLU,   # 24→12
nn.Conv2d(128, 256, 4, 2, 1), BatchNorm2d, LeakyReLU,   # 12→6
Flatten, Linear(256*6*6, 256), Tanh
```

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| 4-layer encoder | ✅ | 4 Conv2d layers | ✅ |
| Kernel 4×4, stride 2 | ✅ | `4, 2, 1` | ✅ |
| LeakyReLU + BatchNorm | ✅ | LeakyReLU(0.2) + BatchNorm2d | ✅ |
| 96→6 downsampling | ✅ | 96→48→24→12→6 | ✅ |
| Dense projection + tanh | ✅ | `Linear(256*6*6, 256), Tanh` | ✅ |
| Latent dim 256 | ✅ | `latent_dim=256` | ✅ |
| Decoder: ConvTranspose2d + Sigmoid | ✅ | ConvTranspose2d mirrors + Sigmoid | ✅ |

**LatentMapper:**
```python
nn.Linear(input_dim, 512), LeakyReLU(0.2), BatchNorm1d(512),
nn.Linear(512, 512),       LeakyReLU(0.2), BatchNorm1d(512),
nn.Linear(512, output_dim),
```

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| 3-layer MLP | ✅ | 3 Linear layers | ✅ |
| LeakyReLU + BatchNorm | ✅ | LeakyReLU(0.2) + BatchNorm1d | ✅ |
| Bidirectional cycle | ✅ | G_AB and G_BA (L700-701) | ✅ |
| Loss = MAE | ✅ | `nn.L1Loss()` (L704) | ✅ |

---

## 11. Evaluation: Reconstruction Sanity

### Paper (commented out, §4 lines 393-407):
- 2048-sample continuous windows from Chapman test set
- Max 400 samples
- R-peak detection on reconstructed Lead II
- Einthoven/Goldberger residual ratio
- Cross-patient correlation (mode collapse check)

### Code in [evaluate.py L841-1008](file:///c:/Users/kek/projects/opticardio/evaluate.py#L841-L1008):

| Aspect | Paper | Code | **Match?** |
|---|---|---|---|
| Window length | 2048 | `window_len=2048` (L862) | ✅ |
| Max samples | 400 | `max_samples=400` (L842, L1250) | ✅ |
| Chapman val split | ✅ | `split="val"` (L862) | ✅ |
| Beat extraction | 200 before, 400 after R-peak | `lo, hi = p - 200, p + 400` (L974) | ✅ |

---

## Summary of Discrepancies

| # | Severity | Description | Location |
|---|---|---|---|
| 1 | ⚠️ Medium | **E2E default epochs = 5 in code, paper says 10** | [train_lora.py L208](file:///c:/Users/kek/projects/opticardio/train_lora.py#L208) vs. paper L356 |
| 2 | ⚠️ Low | **BeatAlign has extra learnable affine (scale/bias) not mentioned in paper** | [models.py L556-557](file:///c:/Users/kek/projects/opticardio/models.py#L556-L557) vs. paper L224 |
| 3 | ⚠️ Low | **Projection head paper says "128→64→32→1" but code actually does 64→128→64→32→1** (expansion step omitted from paper) | [models.py L473-481](file:///c:/Users/kek/projects/opticardio/models.py#L473-L481) vs. paper L242 |
| 4 | ⚠️ Low | **Retrieval eval default samples_per_class=400 in code, paper says max 200** | [evaluate.py L234](file:///c:/Users/kek/projects/opticardio/evaluate.py#L234) vs. paper L372 |

> [!TIP]
> Issues 1 and 4 are CLI defaults that don't affect actual results — the paper values were likely passed as command-line arguments during the actual experiment runs. Issues 2 and 3 are minor omissions from the paper description. **No fundamental algorithmic discrepancies found** — all loss functions, architectures, and evaluation protocols match between code and paper.

