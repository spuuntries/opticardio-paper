#import "gemastik.typ": gemastik
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@preview/orchid:0.1.0"
#import fletcher.shapes: house, hexagon, parallelogram, rect, pill

#let blob(pos, label, tint: white, ..args) = node(
	pos, align(center, label),
	width: 28mm,
	fill: tint.lighten(60%),
	stroke: 1pt + tint.darken(20%),
	corner-radius: 5pt,
	..args,
)


#show "¹": super("1")
#show "²": super("2")
#show "³": super("3")
#show "⁴": super("4")

#show: gemastik.with(
  title: [OptiCardio: Deep Reconstruction Architecture #linebreak()for Non-intrusive PPG-to-cMRI Acquisition],
  abstract: [
    Cardiac MRI (cMRI) acquisition through conventional methods requires procedures which may induce significant amount of patient discomfort. This work presents OptiCardio, an end-to-end deep learning architecture that reconstructs cine cardiac MRI from smartphone-captured photoplethysmography (PPG) signals. The architecture integrates three models: CardioGAN for PPG-to-ECG conversion, MCMA for 1-lead to 12-lead ECG reconstruction, and a cross-modal autoencoder (CMAE) for ECG-to-cMRI translation. The architecture was tuned on the BIDMC dataset via a cycle-consistent finetuning scheme with five loss functions to tighten cross-modal latent alignment. Although the qualitative results degraded in quality, latent probing showed that the latent space remained rich and more aligned, with 67.44% top-k (k=1) retrieval precision for arrhythmia phenotyping, and 0.0136 MAE ECG-to-cMRI latent cycle consistency loss. Improvements to PPG acquisition methodology also achieved a 98.5% PPG beat quality pass rate  (exceeding the baseline of 92.0%).
  ], 
  authors: 
  (
    (
      name: "Faiz Kautsar",
      department: [Department of Informatics],
      organization: [Sepuluh Nopember Institute of Technology],
      location: [Surabaya, Indonesia],
      email: "5054231013@student.its.ac.id"
    ),
    (
      name: "Muhammad Farhan Arya Wicaksono",
      department: [Department of Informatics],
      organization: [Sepuluh Nopember Institute of Technology],
      location: [Surabaya, Indonesia],
      email: "5054231011@student.its.ac.id"
    ),
    (
      name: "Imam Muhammad Diponegoro",
      department: [Department of Informatics],
      organization: [Sepuluh Nopember Institute of Technology],
      location: [Surabaya, Indonesia],
      email: "5054231018@student.its.ac.id"
    ),
    (
      name: "Dini Adni Navastara",
      department: [Department of Informatics],
      organization: [Sepuluh Nopember Institute of Technology],
      location: [Surabaya, Indonesia],
      email: "dini_navastara@its.ac.id"
    ),
  ),
  index-terms: ("cMRI", "Photoplethysmography", "PPG-to-ECG", "ECG-to-MRI"),
  bibliography: bibliography("refs.bib"),
  figure-supplement: [Fig.],
)

= Introduction

Magnetic Resonance Imaging (MRI) has served as a widely used method in the prognosis and diagnosis of patient symptoms in medical practice. For cardiology, cardiac MRI (cMRI) has often required the use of cine MRIs: MRIs captured over a period of time, allowing for the analysis of cardiac behaviour or abnormalities which manifest over a temporal dimension. Yet, a major issue with cine MRI acquisition is that its procedure often required methods which incur relatively high levels of inconvenience to the patients.

In particular, due to the spatially-dynamic nature of the cardiovascular system within the body, cine cMRI necessitates the use of various methods in order to mitigate the inaccuracies accumulated within the acquired k-space. Methods like cardiac gating and breath-holding allow for a more accurate acquisition and interpretation of cine cMRI data. However, these mitigation methods have a common downside: they will cause sparsity in the acquired k-space data as acquisition can only occur during a given predetermined regular interval. To allow for higher fidelity in the k-space capture, the acquisition period must occur for a longer period of time, prolongation which may be intolerable for patients with compromised physical or mental conditions.

Mitigating the inconvenience of longer periods in capturing cine cMRI data, methods have been developed to either reduce the amount of time to capture cMRI data, or obtain it through less motion-sensitive methods. Specifically, there have recently been attempts at acquiring cMRI data via direct cross-modal translation of 12-lead electrocardiogram (ECG) data. @Radhakrishnan2023cmae Methods like Generative Adversarial Networks @Amirrajab2022 @jiang2024gan, Probabilistic Diffusion Models @xiang2024diffcmr, or Deep Image Priors @Hamilton2025dip have also been explored to mitigate an undersampled acquisition period.

However, even using a less motion-sensitive method like ECG as the acquisition source requires the use of equipments such as a 12-lead ECG machine which may not be as readily-available in certain contexts. Photoplethysmography (PPG) is a technique used for measuring the heartbeats by observing subsurface scattering from the skin of a patient, where during a period of higher blood concentration, the hemoglobin within blood will absorb and result in a measurable attenuation in the reflected light. This signal is physiologically coupled with the electrical signals within the heart as the QRS complex directly controls the timing of the contraction motion which affects the blood concentration observed within the body. Thus, a logical progression is the utilization of cross-modal translation of PPG to ECG signals to allow for a much more readily-available acquisition of ECG signal, serving as a bridge to accessible cMRI reconstruction via holistic features. Such a holistic approach may prove beneficial in cases where diagnosis through the more invasive approaches may not prove feasible, not to mention the easy accessibility allowing for a more immediate first-aid diagnostic platform for patients.

// Our work seeks to test the feasibility of creating such an end-to-end cross-modal architecture by integrating the pre-existing works which exist within this domain. We will also see if end-to-end adaptation of that architecture via unpaired data is feasible and whether there are benefits to doing such an approach.

// Our method augments this proposed method with DIP in order to mitigate the sparsity within the reconstructed image's k-space.

= Related Works

Prior works in cross-modal translation of cardiac representations have often only focused on the translation of "adjacent" signal forms, i.e., where the modalities could have relatively trivially-provable holism on one another. Our work intentionally focuses on the end-to-end translation from the lower-fidelity form of photoplethysmography to cine cMRI in order to additionally investigate the holism of learned representations within current deep learning approaches within this space. 

== PPG Acquisition

Photoplethysmography (PPG) is a technique used for measuring heartbeats by observing variations in the intensity of red light reflections from the skin which correlates with the subsurface scattering caused by blood volume in the capillaries of a patient. Usually, PPG is obtained through the use of photo sensors on specialized devices, such as smartwatches or standalone pulse oximeters. As technology advances forward, the availability of reliable PPG acquisition becomes more and more readily-available.  Viability of smartphone camera use as an acquisition platform for a biometrics-based authentication scheme was recently demonstrated, where, although requiring the use of extensive preprocessing in order to obtain accurate phenotype profiles within the PPG readings, it managed to obtain sufficient quality profiling for accurate identification of users. @Lovisotto_2020_CVPR_Workshops_seeingred 

== PPG-to-ECG

The physical link between ECG and PPG signals is rooted in the fact that the QRS complex marks the ventricular depolarization that triggers heart muscle contraction, generating a pulse wave that propagates through the body. The inverse problem of reconstructing all 12 leads of an ECG reading from this PPG signal have long been considered to be an ill-posed problem due to the lack of higher dimensional spatiality in which could be derived from the single dimensional input data. However, for arbitrary single lead ECGs this problem may be more tractable as synchronization can be achieved by aligning the QRS curve with PPG peaks. Prior non-deep learning works have shown this possibility through the mapping of PPG to ECG beats through linear transformation on DCT coefficients of both modalities. @zhu2021ppg2ecg However, a problem with this approach is the lack of flexibility with respect to subject-independent cases where where a universal mapping needs to be trained from a wider variety of ECG signals. Mitigating this, @tian2020XDJDL utilized cross-domain joint dictionary learning which allowed for bidirectional mapping of the signal data, allowing for a more universal holistic mappings.

CardioGAN @Sarkar2020CardioGANAG was one of the first explorations toward a deeply-learned translator, utilizing a GAN with a dual discriminator scheme and an attention-based generator. Empirical results within the study demonstrated that deep learning has the potential for flexible high-fidelity ECG reconstruction from PPG data. A BiLSTM-based architecture was later proposed @tang2022ecgppg, then a WNet-based one, both of which obtained high quality reconstructions. @tang2023PPG2ECGps. 

== 1-to-12 Lead ECG

Although reconstruction of ECG seems to be relatively plausible based on recent results, the core problem of only being able to perform single-lead reconstruction from another single-lead signal has remained an unsolved problem, most prior works explored the reconstruction from reduced scenarios, @NELWAN200411, 3-lead, @MAHESHWARI2014341 or using VCG signals. @EDENBRANDT1988361 Recent explorations on this problem approached it by training a Conditional GAN on lead I data, which showed promising results. @SEO2022106858ecg @ZHAN2024106377ecg However, problems with such an approach arise in the lack of diversity within the observed data and the lack of flexibility in data acquisition. MCMA worked on this problem by doing a masked autoencoder with zero padding for 12-lead reconstruction from arbitrary single-lead signals. Their approach showed promising results with high reconstruction quality and performant metrics under latent probing for downstream tasks. @Chen2024mcma 

== ECG-to-cMRI

Like PPG to 12-lead ECG, the translation of ECG to cMRI has often been deemed ill-posed, as the real physiological form of the heart in each individuals vary and the signals observed therefore have different implications on different individuals. However, as ECG directly corresponds to the timings of  muscular contractions within the heart, @Sattar2025-py there is reason to believe that plausible reconstruction could be done for relative volumetric visualization of the cMRI.

Recent research explored the use of a cross-modal autoencoder (CMAE) trained under a contrastive loss scheme to ensure holistic representation within latent space which showed promising results, demonstrating plausible reconstruction and latents which showed phenotypical holistic correspondence under latent probing. @Radhakrishnan2023cmae Building upon this, PTACL proposed the use of masked autoencoders along with a local and global contrastive loss scheme to align the two latent spaces together. Their results demonstrated promising results with respect to downstream probing, however the decoder pathway was scrapped for their research as latents were aligned within the encoding space. @selivanov2025ptacl 

Even though there have been many studies on the individual components (PPG-to-ECG, ECG-to-MRI), to the best of our knowledge, there have not been any studies that integrate the entire pipeline from PPG signal to cardiac MRI reconstruction. Such an end-to-end pipeline offers the potential for cost-effective cross-modal holistic biometric phenotyping using readily-available photo sensors on devices like smartphones for a more immediate diagnostic platform. A rich end-to-end holistic latent space may also prove to be very beneficial in ensuring that the physiologically-linked phenotypes are represented for downstream tasks, possibly allowing for a more accurate and precise diagnostic platform.

= Methods <sec:methods>

Seen in @fig:pipeline_final, our end-to-end architecture consists of three main stages: (1) PPG to 1-lead ECG conversion using CardioGAN, (2) 12-lead ECG reconstruction using the MCMA model, and (3) cMRI generation from 12-lead ECG using the CMAE. Each stage is connected by bridge functions that handle resampling and normalization.

#figure(
  image("I.png", width: 105%),
  caption: [Flowchart of OptiCardio.]
) <fig:pipeline_final>

== Data Acquisition

We acquired four types of data for training and evaluation: PPG videos, PPG signals, ECG signals, and cMRI data. PPG videos, which are used to acquire PPG signals, were obtained from @Lovisotto_2020_CVPR_Workshops_seeingred's publicly-released dataset consisting of 14 participants, resulting in a sample size of 128 videos. Ground truth for PPG signals were obtained from the Beth Israel Deaconess Medical Center (BIDMC) dataset @bidmc on PhysioNet @PhysioNet which was derived from the Mimic II dataset @Saeed2002mimic, totalling 53 patients, each providing 8-minute 125 Hz recordings. cMRI data was acquired from the Sunnybrook Cardiac MR Left Ventricle Segmentation Challenge dataset, @Radau2009Evaluation with a total of 45 cine-MRI images. 12-lead ECG signal was also obtained from the Chapman-Shaoxing 12-lead ECG Database @Zheng2020chapman for downstream evaluation and comparison.


== PPG Signal Acquisition

Raw PPG signals from smartphone videos were extracted using a modified methodology based on @Lovisotto_2020_CVPR_Workshops_seeingred's and processed through the following stages:

// #pagebreak()

=== Luma Component Extraction

Video frames are first converted from the BGR color space to YCrCb. The raw PPG signal is derived by calculating the spatial mean of the Luma component for each frame. The signal is then inverted to positively correlate with blood volume pulses.

=== Signal Preprocessing

To mitigate motion artifacts and baseline wander, a temporal detrending step is applied using a rolling average filter with a window size ($w$) of approximately 1.01 seconds. The detrended signal is then passed through a $2^("nd")$-order Butterworth low-pass filter with a cutoff frequency of 4 Hz to remove high-frequency noise.

=== Beat Separation

Individual heartbeats are segmented by identifying the onset of each cycle. The preprocessed signal is smoothed using a moving average, and beat boundaries are detected using relative minima determination. To prevent false positives from noise, a minimum inter-beat interval constraint corresponding to a maximum heart rate of 101 bpm is applied.
// #colbreak()

=== Fiducial Point Detection

For each segmented beat $B_i$, distinct morphological features are extracted. The beat is first min-max normalized to the range $[0, 1]$. The Systolic Peak ($t_"sp"$) is identified as the global maximum, while the Dicrotic Notch ($t_"dn"$) is detected as the first local minimum occurring after the systolic peak.


== PPG to 1-Lead ECG

The CardioGAN model @Sarkar2020CardioGANAG is used in the architecture to convert PPG segments (512 samples) into 1-lead ECG (lead II). The generator uses an encoder-decoder with 6 downsampling layers and 6 upsampling layers. Each downsampling layer has increasing number of filters (64, 128, 256, 512, 512, 512) with a fixed $1 times 16$ kernel size and stride 2. LayerNorm and LeakyReLU is applied after each convolutional layer except the first. Similar architecture was used in the upsampling, with the convolutions and activations replaced with deconvolutional layers and ReLU activations. The final output is then obtained from a deconvolutional layer followed by a tanh.

== 1-Lead to 12-Lead Preprocessing

Prior to passing the generated 1-lead signal from the CardioGAN generator to the 12-lead MCMA, we had to implement adjustments to the sample due to mismatches between the datasets used to train the models. First, we resampled the output of the generator of 512 samples at 128 Hz into 1024 samples to match the input dimensionality of MCMA. Then, the signal was placed on the lead II channel with 12 channel zero-padding scaffold, which was smoothed using a Savitzky-Golay filter at window size 15 and polynomial order 3 to reduce high-frequency noise. The denoised signal was then resampled to 600 time steps using linear interpolation and normalized using robust scaling (based on the interquartile range) to handle amplitude outliers. To ensure differentiability during finetuning later, this step was changed out during training for smoothing via a 15-point moving average followed by linear interpolation resampling to a fixed resolution of 600 time steps, along with instance normalization instead of robust scaling. 

== 1-Lead to 12-Lead ECG

To reconstruct a 12-lead ECG, our architecture utilizes the MCMA model @Chen2024mcma which follows a Masked Auto-Encoder (MAE) scheme, where the encoder consists of 6 encoder blocks and 6 decoder blocks. Each block consists of multi-convolution blocks, which are convolutional blocks with a residual convolutional structure, where, given $x$ and $sigma(dot)$ denoting the GELU activation, $x$ is processed as $ hat(y) = "InstanceNorm"(underbrace(sigma(W_s*x), "Residual") \ + space.nobreak underbrace(sigma(W_2*sigma("LayerNorm"(W_1*x))), "Downsampling") $
with $*$ denoting convolution. The decoder blocks utilize the same structure, with the difference being the convolutions are replaced with transposed convolutions, 
$ hat(y) = "InstanceNorm"(underbrace(sigma(W_s star x), "Residual") \ + space.nobreak underbrace(sigma(W_2*sigma("LayerNorm"(W_1 star x))), "Upsampling") $
where $star$ denoting transposed convolution. All convolutions are configured at k=13, with window_size=2.

== 12-Lead ECG-to-cMRI

The 12-lead ECG signal is then passed into the CMAE model @Radhakrishnan2023cmae by first inserting into the ECG encoder to obtain the cross-modal latent, then decoding the cMRI latent via the MRI decoder. The encoders in the model consisted of parallel convolutional blocks which are densely connected, with the decoders utilizing the reciprocal deconvolutional variants. 1D convolution was used for the ECG modality, whilst 2D was used for cMRI. The output of this is a 50-frame cine cMRI 4-chamber long-axis reconstruction of the ECG signal input.

== Cycle-Consistent Finetuning <ftexp>

In order to increase the holistic correspondence of the intermediate latents between the submodels, we finetuned the models end-to-end through the scheme shown in @fig:training. Our experiments had no paired data end-to-end, thus finetuning end-to-end for each modality supervised is practically unfeasible, leading us to use a cycle consistency scheme. All the parts of the architecture already satisfy for a cycle except the ECG-to-PPG step, requiring us to pretrain a PPG decoder head which takes in input from lead II of the MCMA signal to transform back into PPG. 

The PPG decoder model was structured as a 1D residual convolutional network consisting of six blocks of dilated convolutions following @lea2016tcn, where, assuming $x$ as input and $sigma(dot)$ denoting LeakyReLU, $ hat(y) = sigma(x) + \
"BatchNorm"(sigma("BatchNorm"(x)*_d W_1)*_d W_2) $ where $*_d$ denoting a dilated conv, set up with $d$ increasing exponentially. This model was then trained by doing a GAN training with a discriminator network consisting of four downsampling blocks with channel depths of 16, 32, 64, and 128, utilizing kernel size 4 and stride 2 convolutions followed by LeakyReLU (0.2) and Batch Normalization. A final convolution produces a feature map that is globally averaged to yield the single validity probability. This model was then trained for 50 epochs on the BIDMC dataset @bidmc with a cycle consistency loss and GAN discriminator loss.

Afterwards, the entire model is tuned end-to-end on the BIDMC dataset @bidmc using paired PPG and lead II data for five losses:

$ cal(L)_sup = || hat(y)_"1lecg" - y_"ecg" ||_1 $ 

$ cal(L)_("cyc"_"small") = || G_"inv" (G_"fwd" (x_"ppg")) - x_"ppg" ||_1 $ 

$ cal(L)_"cyc"_"big" = || G_"inv" (hat(y)_"recon") - x_"ppg" ||_1 $ 

$ cal(L)_"cyc"_"mri" = || "Dec"_"ecg" ("Enc"_"mri" ("Dec"_"mri" ( "Enc"_"ecg" (hat(y)_"12lecg")))) - \ hat(y)_"12lecg" ||_1 $

$ cal(L)_"reg" = frac(1, N) sum z^2 $

Each loss is weighted by its respective $lambda$, set at $lambda_"sup" = 10.0$, $lambda_("cyc"_"small") = 5.0$, $lambda_("cyc"_"big") = 5.0$, $lambda_("cyc"_"mri") = 2.0$, and $lambda_"reg" = 0.01$.

This setup is meant to ensure stability even though paired data isn't available for the entire pipeline. We trained for 10 epochs using the AdamW optimizer at default parameters, with learning rates set at $5 times 10^(-4)$ for the GAN generator and inverter components, and a lower rate of $3 times 10^(-5)$ for the cross-modal encoders, decoders, and reconstruction blocks.

== Evaluation

To evaluate the model's performance, we evaluated on two downstream latent probing tasks, phenotypical retrieval for ECG abnormalities via @Zheng2020chapman to determine the clinical accuracy and latent space mapping consistency on a downstream cMRI reconstruction head on @Radau2009Evaluation to evaluate holistic correspondence of the resulting latent space.

#figure(
  image("assets/training.png"),
  caption: [The flowchart of the OptiCardio finetuning process, the above pretrained ECG-to-PPG head is temporarily added on to stabilize the cycle, red circle nodes denote losses.]
) <fig:training>

=== PPG Signal Acquisition and Quality Assessment

The PPG signal acquisition pipeline was evaluated on the Seeing Red dataset @Lovisotto_2020_CVPR_Workshops_seeingred comprising 128 smartphone videos from 14 participants. We evaluated the extracted beats following @Lovisotto_2020_CVPR_Workshops_seeingred's methodology, where all beats which correspond to >120 bpm, or having more than three distinct maximums, or that are too different from a reference expected beat wave (calculated via dynamic time warping) are flagged as an invalid beat.

=== Phenotypical Retrieval Precision

This evaluation was done by first obtaining a stratified sample by arrythmia pathological code label of every patient in @Zheng2020chapman (picking the most severe in cases of multi-labels by order of: PVC (Premature Ventricular Contraction) > AFL (Atrial Flutter) > AFIB (Atrial Fibrillation) > SB (Sinus Bradycardia) > ST (Sinus Tachycardia) > SR (Sinus Rhythm)) at 400 samples per label, then embedding all of the samples, then finally calculating a similarity matrix via dot-product. 

Precision is then calculated through retrieving the top-k neighbors for each sample, obtaining the ratio of neighbors which has the same labels, then calculating the global mean across the entire dataset based on that. In other words,

$ bb(1)(i, j) = cases(
 1 "if" (Y_i inter cal(M)) inter (Y_j inter cal(M)) eq.not emptyset,
 0 "otherwise") $
 where $Y_i$ denoting the set of disease labels for patient $i$, and $cal(M)$ the set of labels, thus
$ "Precision@k" = frac(1, N) sum_(i=1)^(N) frac(1, k) sum_(j in cal(N)_k(i)) bb(1)(i, j)) $

Afterwards, we compared the above metrics on our model against baselines from @Radhakrishnan2023cmae, @selivanov2025ptacl, and @TURGUT2025mmcl.

=== Latent Cycle Consistency <lccexpl>

This evaluation was done to determine the latent alignment between the ECG waveforms and the corresponding cMRIs. For this, we first pretrained a reconstruction head on @Radau2009Evaluation consisting of a four-layer convolutional encoder and decoder structure with a latent dimension of 256. The encoder progressively downsamples the $96 times 96$ input to $6 times 6$ feature maps using $4 times 4$ convolutions with stride 2, LeakyReLU activations, and Batch Normalization, followed by a dense projection to a tanh-activated latent space. The decoder mirrors this architecture, utilizing transposed convolutions to upsample features back to the original resolution with a Sigmoid output. Afterwards, a probe is constructed as a mapping from the 12-lead $z_"ECG"$ into the decoder latent $z_"MRI"$ for MRI (at 256 dims) with an MLP consisting of three linear layers with LeakyReLU activations and Batch Normalization. To measure the topological alignment between the modalities, we employ a cycle-consistent framework via the latent prober. We simultaneously train a forward mapper and a reverse mapper, both constructed with the same aforementioned probe. The alignment quality is then quantified by the Cycle Consistency Loss ($cal(L)_"cyc"$), defined as the MAE between the original latent vector and its round-trip reconstruction.

= Results

== PPG Signal Acquisition and Quality Assessment

As seen in @tab:ppg_comparison, our implementation achieved 98.5% beat quality pass rate versus 92.0% reported in the original study, or 93.8% in our reproduction run (a slight increase due to exclusion of 1 patient data in the publicly-released dataset of the 15 in the original study). From 3,718 total detected beats, 3,661 were classified as valid, representing a 6.5 percentage point improvement. Signal-to-noise ratio averaged 23.1 dB with mean heart rate of 67.2 bpm. 

#figure(
  caption: [PPG Signal Quality Evaluation],
  table(
    columns: (12em, 5em, 7em, 6em),
    align: (left, center, center, center),
    inset: (x: 8pt, y: 4pt),
    // stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },

    table.header[*Metric*][*Ours*][*Reproduction* @Lovisotto_2020_CVPR_Workshops_seeingred][*Reported* @Lovisotto_2020_CVPR_Workshops_seeingred],
    [Videos Processed], [128], [128], [N/A],
    [Total Beats], [3,718], [3,718], [3,836],
    [Valid Beats], [3,661], [3,486], [3,529],
    table.hline(),
    [*Pass Rate (%)*], [*98.5*], [*93.8*], [*92.0*],
    table.hline(),
    [Mean HR (bpm)], [67.2], [67.4], [--],
    [SNR (dB)], [23.1], [23.1], [--],
  )
) <tab:ppg_comparison>

== Phenotypical Retrieval Precision

As explained in @lccexpl, evaluation of the latent ECG features involved utilizing the space for pathology retrieval on phenotypically-similar ECG waveforms. Our model consistently outperforms comparative baselines in overall precision across all $k$ values. For the strictest metric, Precision\@1 (P\@1), our method achieves 67.44%, surpassing the second place baseline CMAE by 2.65% and the MMCL baseline by 8.25%. Even at $k=15$, OptiCardio maintains a precision of 57.19%, a 2.46% lead over the baseline CMAE. Class-wise, our model demonstrates performance gains which are most pronounced in two pathological labels, ST, obtaining a 82.37% at P\@1 over PTACL's 63% and MMCL's 57.75%, and AFIB, obtaining 64.8% at P\@1 which passes the nearest second place MMCL's by 6%. While OptiCardio leads in overall and morphological metrics, we do have to note that the baseline of PTACL remains highly competitive in certain labels, e.g. SB, where it achieves the highest P\@1 of 77.25%. 

// performance gains are most pronounced in pathological categories characterized by distinct morphological features:

// Sinus Tachycardia (ST): OptiCardio achieves a dominant 82.37% P@1, significantly outperforming ViTMAE-ECG (63.00%) and MMCL (57.75%). This suggests our cross-modal alignment strategy effectively captures the high-frequency periodicity associated with tachycardia.

// Atrial Fibrillation (AFIB): We observe a strong lead in AFIB detection (64.80% P@1), outperforming the closest competitor (MMCL) by over +6%.

// Competitive Baselines While OptiCardio leads in overall and morphological metrics, we note that ViTMAE-ECG remains highly competitive in rhythm-based classes, specifically Sinus Bradycardia (SB), where it achieves the highest P@1 of 77.25%. This indicates that masked autoencoding objectives may be particularly adept at capturing the temporal spacing features (R-R intervals) defining bradycardia, whereas our method prioritizes the morphological integrity required for MRI reconstruction.

#figure(
  image("latentgraph.png"),
  caption: [Training loss graph of the probes for latent space consistency.]
)

== Latent Cycle Consistency

Seen in @tab:latent_loss, OptiCardio achieved a lower consistency loss of 0.0136, representing a 10%, 39%, 78% increase in performance against each baseline respectively. Notably, MMCL's losses exhibits sudden instability with upward fluctuations at the end of training. Both MMCL and PTACL demonstrates an earlier plateau, with CMAE closer to ours at a marginally higher loss curve.

#figure(
  caption: [Retrieval Precision Evaluation Metrics],
  placement: top,
  // 1. Mengatur ukuran font untuk menghemat ruang
  table(
    // 2. Mengurangi lebar kolom (Menggunakan auto dan lebar minimum yang lebih kecil)
    // 6 kolom: Method | Overall | SR | AFIB | SB | ST
    columns: (auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center),
    // inset: (x: 5pt, y: 3pt), // Mengurangi padding
    // stroke: none,
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
    
    // Header
    table.header[*Method*][*Overall*][*SR*][*AFIB*][*SB*][*ST*],
    table.hline(), // Garis horizontal setelah header

    // --- P@1 ---
    [_Precision\@1 (%):_], [], [], [], [], [],
    [OptiCardio (Ours)], [*67.44*], [55.42], [*64.80*], [67.17], [*82.37*],
    // Cross-modal AE
    [CMAE @Radhakrishnan2023cmae], [64.79], [52.64], [58.16], [67.67], [80.60],
    // ViTMAE-ECG
    [PTACL @selivanov2025ptacl], [63.88], [*58.00*], [57.25], [*77.25*], [63.00],
    // MMCL
    [MMCL @TURGUT2025mmcl], [59.19], [51.50], [58.25], [69.25], [57.75],
    table.hline(), // Garis pemisah antar Metrik K

    // --- P@3 ---
    [_Precision\@3 (%):_], [], [], [], [], [],
    [OptiCardio (Ours)], [*63.13*], [52.14], [*58.84*], [63.66], [*77.83*],
    // Cross-modal AE
    [CMAE @Radhakrishnan2023cmae], [61.75], [50.29], [56.04], [64.91], [75.65],
    // ViTMAE-ECG
    [PTACL @selivanov2025ptacl], [57.79], [*54.42*], [49.00], [*66.42*], [61.33],
    // MMCL
    [MMCL @TURGUT2025mmcl], [56.10], [50.75], [54.75], [64.58], [54.33],
    table.hline(),

    // --- P@5 ---
    [_Precision\@5 (%):_], [], [], [], [], [],
    [OptiCardio (Ours)], [*61.70*], [48.92], [*58.67*], [64.06], [*75.11*],
    // Cross-modal AE
    [CMAE @Radhakrishnan2023cmae], [60.00], [*49.72*], [53.93], [63.06], [73.20],
    // ViTMAE-ECG
    [PTACL @selivanov2025ptacl], [54.95], [48.20], [45.10], [*68.95*], [57.55],
    // MMCL
    [MMCL @TURGUT2025mmcl], [54.61], [48.40], [53.35], [63.50], [53.20],
    table.hline(),

    // --- P@10 ---
    [_Precision\@10 (%):_], [], [], [], [], [],
    [OptiCardio (Ours)], [*58.79*], [46.17], [*54.39*], [62.46], [*72.07*],
    // Cross-modal AE
    [CMAE @Radhakrishnan2023cmae], [57.06], [47.63], [50.15], [61.45], [68.89],
    // ViTMAE-ECG
    [PTACL @selivanov2025ptacl], [55.26], [*47.70*], [43.75], [*70.00*], [59.60],
    // MMCL
    [MMCL @TURGUT2025mmcl], [51.58], [45.50], [50.72], [60.85], [49.25],
    table.hline(),

    // --- P@15 ---
    [_Precision\@15 (%):_], [], [], [], [], [],
    [OptiCardio (Ours)], [*57.19*], [45.29], [*52.01*], [60.87], [*70.50*],
    // Cross-modal AE
    [CMAE @Radhakrishnan2023cmae], [54.73], [46.11], [47.81], [59.65], [65.22],
    // ViTMAE-ECG
    [PTACL @selivanov2025ptacl], [54.38], [*48.25*], [45.90], [*66.82*], [56.57],
    // MMCL
    [MMCL @TURGUT2025mmcl], [50.18], [44.87], [49.27], [59.55], [47.02],
    table.hline(),
  )
) <tab:ecg_all_precision>

#figure(
  caption: [Latent Cycle Consistency Loss Metrics],
  placement: top,
  table(
    columns: (10em, 10em, 8em),
    align: (left, center, center),
    inset: (x: 8pt, y: 4pt),
    // stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },

    table.header[*Method*][*Final Loss (MAE)*][*Comparison*],
    [OptiCardio (Ours)], [*0.0136*], [*1.0×*],
    [CMAE @Radhakrishnan2023cmae], [0.0150], [1.10x],
    [PTACL @selivanov2025ptacl], [0.0189], [1.39x],
    [MMCL @TURGUT2025mmcl], [0.0242], [1.78x],
  )
) <tab:latent_loss>

== Qualitative Results

Seen in @fig:samples are some qualitative aligned samples obtained from our model with respect to ground truth. Ground truth PPG here is obtained from the BIDMC dataset. We aligned the closest lagging lead II ECG peak with the PPG for visualization purposes. We also visualized the results from our model prior to the cycle-consistent finetuning in @fig:samplesbefore.

= Discussion

Our results demonstrate that OptiCardio successfully establishes end-to-end cross-modal holistic coherence across the PPG-ECG-cMRI pipeline. The increase in the pass rate from the PPG signal acquisition pipeline shows that our changes, mainly in the fiducial point detection mechanism, substantially improved the performance of PPG extraction within our architecture. The end-to-end cycle-consistent finetuning explained in @ftexp allowed for the model to obtain a much tighter latent coupling between the modalities, as shown by the increase in metrics in both @tab:ecg_all_precision and @tab:latent_loss. We specifically highlight the increase in performance compared to the CMAE @Radhakrishnan2023cmae baseline due to its integration into our model, which indicates that our model's tuning increased its performance downstream without significantly impacting its ability to reconstruct the cMRI sequence. 

However, a qualitative examination of the intermediary states of the model, seen in @fig:samples and @fig:samplesbefore, we see that there has been a degradation in the quality of the ECG's reconstruction, where there are observable noise in the reconstruction, mainly in the CardioGAN's output, which cascaded into MCMA's. We posit that this is likely due to the lack of strengthening in the harness for the ECG reconstruction. Even though we've already placed the $lambda$ at a high value for the supervised reconstruction of the lead II ECG, we believe that the optimizer found an easier route optimizing for the other losses, thus opting for "hiding" the crucial reconstruction information within the data, instead of learning meaningful features, a relatively well-known problem in cyclic training. @chue2017cycleganstego An improvement could be made by introducing a discriminator and regularization at this stage to ensure that high fidelity reconstruction is achieved.

Although the tuning did depreciate the qualitative performance, we maintain that our approach holds merit, however. The model, even prior to tuning, demonstrates high-level of physiological coherence. Analyzing the anatomy of the reconstructions, the QRS complex can clearly be observed within the reconstruction of the CardioGAN, which is also visible within the respective leads of the MCMA reconstruction. 

// Our results demonstrate that OptiCardio successfully establishes cross-modal physiological coherence across the PPG-ECG-cMRI pipeline, with the 98.5% PPG beat quality pass rate representing a 6.5 percentage point improvement over the original Seeing Red implementation. The cycle-consistent finetuning strategy proved critical, achieving 0.0130 latent consistency loss compared to 0.0206 for the standalone CMAE baseline, indicating tighter coupling between ECG and MRI latent spaces that reduces cumulative error propagation across the three-stage architecture. Phenotypical retrieval performance (67.44% overall P`@1`, with particularly strong 82.37% precision for Sinus Tachycardia detection) suggests the learned representations preserve clinically-relevant cardiac features despite the complexity of the transformation chain. However, several factors constrain immediate clinical translation. The limited training scale (14-53 subjects per stage) restricts generalization across demographic diversity and pathological conditions, particularly for spatially-localized abnormalities that may not manifest clearly in single-lead-derived signals. The 96×96 spatial resolution and 50-frame temporal resolution, while sufficient for proof-of-concept, fall short of diagnostic standards required for valve assessment or detection of small structural defects below 5mm. Compared to direct ECG-to-cMRI approaches like the original CMAE (64.79% P`@1`), our end-to-end pipeline maintains competitive retrieval precision (67.44% P`@1`) despite the additional PPG-to-ECG translation step, suggesting that the cycle consistency constraints effectively mitigate error accumulation. The physiological alignment observed in qualitative results, where QRS complex timing corresponds with ventricular systole onset in the generated cine-MRI, validates the model's capacity to capture fundamental electromechanical coupling. Nonetheless, the absence of extensive clinical validation, environmental sensitivity requirements (controlled lighting, temperature, positioning), and the single-lead origin limiting detection of spatially-distributed pathologies position OptiCardio as a research tool and preliminary screening platform rather than a replacement for gold-standard imaging modalities.

#figure(grid(
    columns: 3,
image("assets/before/step_000.png"),
image("assets/before/step_001.png"),
image("assets/before/step_002.png"),
image("assets/before/step_003.png"),
image("assets/before/step_004.png"),
image("assets/before/step_005.png")),
caption: [Left-to-right, top-to-bottom: a 6 frame sample of a PPG translation from our model prior to cycle-consistent tuning, note that the 12-lead shows the aligned reconstruction for the entire 512 window of the PPG.]
) <fig:samplesbefore>

#figure(grid(
    columns: 3,
image("assets/after/step_000.png"),
image("assets/after/step_001.png"),
image("assets/after/step_002.png"),
image("assets/after/step_003.png"),
image("assets/after/step_004.png"),
image("assets/after/step_005.png")),
caption: [Left-to-right, top-to-bottom: a 6 frame sample of a PPG translation from our model after cycle-consistent tuning.]
) <fig:samples>


= Conclusions

In this work, we demonstrate the feasibility of performing end-to-end holistic translation of PPG into cMRI through the use of deeply-learned features. Our model, OptiCardio, integrated three different models, CardioGAN @Sarkar2020CardioGANAG, MCMA @Chen2024mcma, and CMAE @Radhakrishnan2023cmae, into a model which can holistically translate the three modalities of PPG, ECG, and cMRI. Our improved PPG acquisition mechanism which obtained a 98.5% pass rate, well above the @Lovisotto_2020_CVPR_Workshops_seeingred baseline, means that the use of our mechanism could allow for a more accurately-centered PPG acquisition which allows for a more accurate translation into ECG. The cycle-consistent tuning which we applied also tightened the latent space of the models, allowing the latent space of the overall OptiCardio architecture a much higher performance in downstream latent probing, where our model consistently showed high ranking in pathology retrieval precision, 67.44% at P\@1, and a conclusively lower loss compared to baselines when doing latent inversion mapping from ECG to cMRI at 0.0136 MAE.

Although our tuning did degrade the quality of the reconstructions for some of the modalities, the high performance during latent probing shows that the latent space proves to be rich in holistic relationships and has high potential in use for downstream applications. Improvement on this could be done in future works by obtaining an end-to-end paired dataset for the cycle-consistent tuning procedure in order to mitigate the number of "guessing" the model has to do during translation, or introducing a much stronger harness for reconstruction to tighten the scope of exploration from the optimizer function, such as implementing a discriminator or utilizing some form of regularization to prevent jitter in the reconstruction.
