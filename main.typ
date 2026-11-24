#import "resistor/0.1.0/src/lib.typ": resistor, sumber, with-source

#show: resistor.with(
  title: [OptiCardio: Arsitektur Rekonstruksi PPG-ke-cMRI 4-_Chamber_ _Long-axis_ untuk Deteksi Aritmia],
  short-title: [OptiCardio: Arsitektur Rekonstruksi PPG-ke-cMRI...],
  authors: (
    (
      name: "Faiz Muhammad Kautsar",
      department: [Fakultas Teknologi Elektro dan Informatika Cerdas],
      organization: [Institut Teknologi Sepuluh Nopember],
      location: [Surabaya, 60111 Indonesia],
      email: "5054231013@student.its.ac.id",
      corresponding: true,
    ),
    (
      name: "Muhammad Farhan Arya Wicaksono",
      department: [Fakultas Teknologi Elektro dan Informatika Cerdas],
      organization: [Institut Teknologi Sepuluh Nopember],
      location: [Surabaya, 60111 Indonesia],
      email: "5054231011@student.its.ac.id",
    ),
    (
      name: "Imam Muhammad Diponegoro",
      department: [Fakultas Teknologi Elektro dan Informatika Cerdas],
      organization: [Institut Teknologi Sepuluh Nopember],
      location: [Surabaya, 60111 Indonesia],
      email: "5054231018@student.its.ac.id",
    ),
    (
      name: "Muhammad Rasyad Lubis",
      department: [Fakultas Teknologi Elektro dan Informatika Cerdas],
      organization: [Institut Teknologi Sepuluh Nopember],
      location: [Surabaya, 60111 Indonesia],
      email: "5054231010@student.its.ac.id",
    ),
    (
      name: "Shalahuddin Ahmad Cahyoga",
      department: [Fakultas Teknologi Elektro dan Informatika Cerdas],
      organization: [Institut Teknologi Sepuluh Nopember],
      location: [Surabaya, 60111 Indonesia],
      email: "5054231014@student.its.ac.id",
    ),
    (
      name: "Dini Adni Navastara",
      department: [Fakultas Teknologi Elektro dan Informatika Cerdas],
      organization: [Institut Teknologi Sepuluh Nopember],
      location: [Surabaya, 60111 Indonesia],
      email: "dini_navastara@its.ac.id",
    ),
  ),
  short-authors: "Faiz Muhammad Kautsar, dkk",
  received: "Date Month Year",
  accepted: "Date Month Year",
  published: "Date Month Year",
  abstract-id: [
    Akuisisi _cardiac_ MRI (cMRI) melalui metode konvensional memerlukan prosedur yang dapat menimbulkan ketidaknyamanan signifikan bagi pasien. Penelitian ini mengusulkan OptiCardio, sebuah arsitektur _deep learning end-to-end_ yang merekonstruksi _cine_ cMRI dari sinyal fotopletismografi (PPG), yakni rekam aliran darah melalui pantulan cahaya, yang ditangkap menggunakan ponsel pintar. Arsitektur ini mengintegrasikan tiga model: CardioGAN untuk konversi PPG-ke-ECG 1-_lead_, _Multi-Channel Masked Autoencoder_ (MCMA) untuk rekonstruksi ECG 1-_lead_ ke 12-_lead_, dan _cross-modal autoencoder_ (CMAE) untuk translasi ECG-ke-cMRI, dihubungkan melalui _alignment layer_ berbasis ResNet 1D. Arsitektur ini di-_finetune_ secara _end-to-end_ pada dataset BIDMC dan Chapman-Shaoxing melalui skema _cycle-consistent finetuning_ dengan sembilan fungsi _loss_, mencakup supervisi langsung, distilasi, konsistensi siklus kecil dan besar, serta konsistensi fisiologi berbasis Hukum Einthoven, guna memperketat penyelarasan laten lintas-modal tanpa data berpasangan _end-to-end_. Meskipun hasil kualitatif pada sinyal 1-_lead_ mengalami degradasi sangat minor, rekonstruksi 12-_lead_ mengalami peningkatan signifikan pada konsistensi fisiologis, dan pengujian laten menunjukkan bahwa ruang laten justru tetap kaya serta lebih selaras, dengan presisi pencarian _top-k_ (k=1) _macro average_ sebesar 61,9% untuk fenotipe aritmia, melampaui seluruh _baseline_ yang diuji, dan _loss_ konsistensi siklus ECG-ke-cMRI sebesar 0,0241 _Mean Absolute Error_ (MAE) pada ruang laten _backbone_ CMAE setelah _tuning_. Peningkatan pada metodologi akuisisi PPG, khususnya pada deteksi titik fidusial, juga mencapai tingkat kelulusan kualitas denyut PPG sebesar 98,5%, melampaui _baseline_ sebesar 92,0%.
  ],
  keywords-id: ("cMRI", "Fotopletismografi", "PPG-ke-ECG", "ECG-ke-MRI"),
  abstract-en: [
    Conventional cardiac MRI (cMRI) acquisition requires procedures causing significant patient discomfort. This study proposes OptiCardio, an end-to-end deep learning architecture reconstructing cine cMRI from smartphone photoplethysmography (PPG)—optical blood-flow reflection—signals. The pipeline integrates CardioGAN (PPG-to-1-lead ECG), Multi-Channel Masked Autoencoder (MCMA, 1-lead to 12-lead ECG), and a cross-modal autoencoder (CMAE, ECG-to-cMRI), bridged by 1D ResNet alignment layers. OptiCardio is fine-tuned end-to-end on BIDMC and Chapman-Shaoxing via cycle-consistent fine-tuning with nine losses—direct supervision, distillation, small and big cycle consistency, and Einthoven's Law physiological consistency—tightening cross-modal latent alignment without end-to-end paired data. While 1-lead quality shows minor degradation, 12-lead physiological consistency improves substantially, and latent probing confirms a rich, well-aligned latent space, achieving 61.9% macro-average top-k (k=1) arrhythmia retrieval precision (surpassing all baselines) and 0.0241 Mean Absolute Error (MAE) ECG-to-cMRI cycle consistency loss on CMAE. Modified PPG acquisition and fiducial detection also reach a 98.5% beat quality pass rate, exceeding the 92.0% baseline.
  ],
  keywords-en: ("cMRI", "ECG-to-MRI", "Photoplethysmography", "PPG-to-ECG"),
  footer-issue: "Vol. x Nomor x, September 2026",
)

#set par(leading: 0.40em, spacing: 0.40em)
#show math.equation: set block(spacing: 0.50em)
#show figure: set block(spacing: 6pt)

= Pendahuluan

_Magnetic Resonance Imaging_ (MRI) telah menjadi metode yang digunakan secara luas dalam prognosis dan diagnosis gejala pasien dalam praktik medis. Dalam bidang kardiologi, _cardiac_ MRI (cMRI) sering kali membutuhkan penggunaan _cine_ MRI: MRI yang diambil selama periode waktu tertentu, sehingga memungkinkan analisis perilaku atau kelainan jantung yang bermanifestasi pada dimensi temporal. Namun, kendala utama pada akuisisi _cine_ MRI adalah prosedurnya sering kali membutuhkan metode yang menimbulkan tingkat ketidaknyamanan yang relatif tinggi bagi pasien. @tomography12060077 @MADL2022423

Karena sifat sistem kardiovaskular dalam tubuh yang dinamis secara spasial, _cine_ cMRI memerlukan penggunaan berbagai metode untuk memitigasi ketidakakuratan yang terakumulasi di dalam k-space yang diakuisisi. Metode-metode seperti _cardiac gating_ dan menahan napas memungkinkan akuisisi dan interpretasi data _cine_ cMRI yang lebih akurat. @Holtackers2024-ni Namun, metode-metode mitigasi ini memiliki satu kelemahan umum: Untuk memungkinkan fidelitas yang lebih tinggi dalam pengambilan k-space, periode akuisisi harus berlangsung dalam jangka waktu yang relatif lebih lama, suatu perpanjangan yang mungkin tidak dapat ditoleransi oleh pasien dengan patologi fisik ataupun ketidaknyamanan dengan prosedur akuisisi. @motionmitcardiac2026

Untuk memitigasi periode yang lebih lama dalam mengambil data _cine_ cMRI, berbagai metode telah dikembangkan baik untuk mengurangi jumlah waktu dalam menangkap data cMRI, maupun untuk memperolehnya melalui metode yang kurang sensitif terhadap gerakan. Akhir-akhir ini, untuk mendekati permasalahan tersebut, terdapat penelitian untuk mengakuisisi data cMRI melalui translasi lintas-modal langsung dari data _electrocardiogram_ (ECG) 12-_lead_. @Radhakrishnan2023cmae Selain itu, metode-metode seperti _Generative Adversarial Networks_ @Amirrajab2022 @jiang2024gan, _Probabilistic Diffusion Models_ @xiang2024diffcmr, atau _Deep Image Priors_ @Hamilton2025dip juga telah dieksplorasi untuk memitigasi periode akuisisi _undersampled_.

Namun, meskipun menggunakan metode yang kurang sensitif terhadap gerakan seperti ECG sebagai sumber akuisisi, penggunaan peralatan seperti mesin ECG 12-_lead_ tetap diperlukan, yang mungkin tidak tersedia dengan mudah dalam beberapa konteks. @KHURSHID202369 Fotopletismografi (PPG) adalah sebuah teknik yang digunakan untuk mengukur detak jantung dengan mengamati _subsurface scattering_ dari kulit pasien, di mana selama periode konsentrasi darah yang lebih tinggi, hemoglobin di dalam darah akan menyerap dan menghasilkan atenuasi yang dapat diukur pada reflektansi cahaya. Sinyal ini secara fisiologis terhubung dengan sinyal listrik di dalam jantung karena kompleks QRS secara langsung mengendalikan gerakan kontraksi yang memengaruhi konsentrasi darah yang teramati di dalam tubuh. @slapnicar2024fundamental

Meskipun terdapat berbagai studi mengenai translasi antarmodalitas komponen diagnostik kardiologi (PPG-ke-ECG, ECG-ke-MRI), penelitian mengidentifikasi belum adanya studi konvensional yang mengintegrasikan seluruh _pipeline_ dari sinyal PPG hingga rekonstruksi cMRI. Oleh karena itu, penelitian mengusulkan OptiCardio, yakni arsitektur _end-to-end_ yang bertujuan untuk menguji pemanfaatan translasi lintas-modal dari sinyal PPG-ke-ECG untuk memungkinkan akuisisi sinyal ECG yang jauh lebih mudah tersedia, yang kemudian dapat berfungsi sebagai jembatan menuju rekonstruksi cMRI yang dapat diakses melalui fitur-fitur holistik. Pendekatan ini memiliki potensi besar pada kasus-kasus di mana diagnosis melalui pendekatan yang lebih invasif mungkin tidak mungkin dilakukan. Selain itu, aksesibilitasnya memungkinkan _platform_ diagnostik pertolongan pertama yang lebih cepat bagi pasien, selaras dengan _Sustainable Development Goal_ (SDG) 3, yakni target 3.d sebagai deteksi dini risiko kesehatan nasional.

= Literatur Terkait

Penelitian sebelumnya dalam translasi representasi jantung lintas-modal sering kali hanya terfokus pada translasi bentuk sinyal yang "berdekatan", di mana modalitas tersebut memiliki hubungan holistik yang relatif mudah dibuktikan satu sama lain. Penelitian berfokus pada translasi _end-to-end_ dari fotopletismografi dengan fidelitas lebih rendah ke _cine_ cMRI untuk menginvestigasi lebih lanjut holisme representasi yang dipelajari dalam pendekatan _deep learning_ saat ini di ruang lingkup ini.

== Akuisisi PPG

Fotopletismografi (PPG) adalah teknik yang digunakan untuk mengukur detak jantung dengan mengamati variasi intensitas pantulan cahaya dari kulit yang berkorelasi dengan _scattering_ di bawah permukaan yang disebabkan oleh volume darah dalam kapiler seorang pasien. Biasanya, PPG diperoleh melalui penggunaan sensor pada perangkat khusus, seperti jam tangan pintar atau oksimeter denyut nadi mandiri. Seiring dengan kemajuan teknologi, ketersediaan akuisisi PPG yang andal menjadi semakin mudah diakses. Kelayakan penggunaan kamera ponsel pintar sebagai platform akuisisi untuk skema autentikasi berbasis biometrik baru-baru ini didemonstrasikan, di mana, meskipun memerlukan penggunaan prapemrosesan ekstensif untuk mendapatkan profil fenotipe yang akurat dalam pembacaan PPG, metode tersebut berhasil memperoleh profil kualitas yang memadai untuk identifikasi pengguna yang akurat. @Lovisotto_2020_CVPR_Workshops_seeingred

== Pemahaman ECG

_Electrocardiogram_ (ECG) adalah grafik rekam aktivitas listrik jantung yang digunakan untuk mengevaluasi kondisi fisiologis dan mendiagnosis patologi kardiovaskular secara noninvasif. Dalam praktik klinis tradisional, interpretasi ECG mengandalkan analisis visual oleh dokter secara spasio-temporal pada grafik gelombang yang membentuk morfologi kompleks PQRST, seperti frekuensi detak, keteraturan irama, durasi interval, dan morfologi gelombang. Misalnya, jarak antarkompleks QRS yang tidak teratur mengindikasikan gangguan irama, sedangkan pergeseran vertikal pada segmen ST menjadi penanda utama serangan jantung akut.

Meskipun ECG 12-_lead_ telah menjadi standar diagnostik, interpretasi tradisional yang bertumpu pada analisis manual dokter berpotensi menghadapi kendala variabilitas antardokter serta keterbatasan mata manusia dalam mengenali pola yang kompleks. Perkembangan pemrosesan sinyal digital dan _deep learning_ mengubah paradigma ini dengan memanfaatkan arsitektur _neural network_ untuk mengekstraksi fitur laten sinyal ECG secara otomatis.

Salah satu pendekatan awal yang menerapkan metode berbasis _deep learning_ adalah penelitian untuk deteksi disfungsi kontraksi, yang menerapkan arsitektur 1D berbasis _convolutional neural network_ (CNN), yang memberikan hasil sangat memuaskan pada populasi sampel 44.959 dari Mayo Clinic. @Attia2019Screening Kemudian, eksplorasi lanjutan dari ECG-Cor-Net menerapkan sebuah cabang 2D CNN tambahan di atas cabang 1D CNN untuk deteksi Kardiomiopati Hipertrofi dan Kardiomiopati Dilatasi yang berfungsi untuk meningkatkan ketahanan model terhadap _baseline wander_ dan artefak frekuensi tinggi. @AIoa2300297 Penelitian lain juga menerapkan CNN untuk deteksi aritmia multilabel, dengan hasil yang memuaskan. @Zhu2020

Akan tetapi, kekurangan dari pendekatan-pendekatan sebelumnya adalah ukuran dataset yang digunakan relatif kecil, sehingga model terbatas pada domain yang terspesifik. ECGFounder adalah model encoder ECG yang dilatih pada 10 juta sampel pelatihan yang dikurasikan dari berbagai sumber beragam untuk mengatasi masalah tersebut, sebuah _foundation model_ berbasis ResNet 1D untuk ekstraksi fitur pada ECG, di mana evaluasi _downstream_ menemukan bahwa ECGFounder menghasilkan performa _state-of-the-art_ pada berbagai kasus diagnostik ECG setelah _finetuning_. @Ecgfounder2025Li-aw

== PPG-ke-ECG

Hubungan fisik antara sinyal ECG dan PPG bertumpu pada fenomena di mana kompleks QRS menandai depolarisasi ventrikel yang memicu kontraksi otot jantung, menghasilkan gelombang denyut nadi yang merambat ke seluruh tubuh. Masalah invers dalam merekonstruksi ECG 12-_lead_ dari sinyal PPG ini telah lama dianggap sebagai masalah _ill-posed_ karena kurangnya spasialitas berdimensi lebih tinggi yang dapat diturunkan dari data masukan berdimensi tunggal. Namun, untuk sembarang ECG 1-_lead_, masalah ini mungkin lebih mudah diselesaikan karena sinkronisasi dapat dicapai dengan menyelaraskan kurva QRS dengan puncak PPG. Penelitian non-_deep learning_ sebelumnya telah menunjukkan kemungkinan ini melalui pemetaan ketukan PPG ke ECG melalui transformasi linear pada koefisien DCT dari kedua modalitas tersebut. @zhu2021ppg2ecg Namun, masalah dengan pendekatan ini adalah kurangnya fleksibilitas dengan kasus yang tidak bergantung pada subjek tertentu di mana pemetaan universal perlu dilatih dari variasi sinyal ECG yang lebih luas. Untuk memitigasi hal ini, @tian2020XDJDL memanfaatkan _cross-domain joint dictionary learning_ yang memungkinkan pemetaan dua arah dari data sinyal, memungkinkan pemetaan holistik yang lebih universal.

CardioGAN @Sarkar2020CardioGANAG merupakan salah satu eksplorasi pertama menuju penerjemah _deep learning_, yang memanfaatkan GAN dengan skema diskriminator ganda dan generator berbasis _attention_. Hasil empiris dalam penelitian tersebut menunjukkan bahwa _deep learning_ memiliki potensi besar untuk rekonstruksi ECG berfidelitas tinggi yang fleksibel dari data PPG. Beberapa penelitian selanjutnya mengusulkan beberapa desain alternatif, seperti solusi berbasis BiLSTM @tang2022ecgppg, dan arsitektur berbasis WNet, yang keduanya memperoleh kualitas rekonstruksi tinggi. @tang2023PPG2ECGps.

== ECG 1-ke-12 Lead

Meskipun rekonstruksi ECG tampak relatif masuk akal berdasarkan hasil-hasil terbaru, masalah utama di mana rekonstruksi _lead_ lainnya dari sinyal 1-_lead_ tetap menjadi masalah yang belum terpecahkan. Sebagian besar penelitian sebelumnya mengeksplorasi rekonstruksi dari skenario sampel beberapa _lead_ @NELWAN200411, 3-_lead_ @MAHESHWARI2014341, atau menggunakan sinyal VCG. @EDENBRANDT1988361 Eksplorasi terbaru mengenai masalah ini melatih Conditional GAN pada data _lead_ I, yang memberikan hasil yang menjanjikan. @SEO2022106858ecg @ZHAN2024106377ecg Namun, masalah pada pendekatan ini muncul dari kurangnya keragaman dalam data yang diamati dan kurangnya fleksibilitas dalam akuisisi data. MCMA meneliti masalah ini dengan melakukan _masked autoencoder_ dengan _zero padding_ untuk rekonstruksi 12-_lead_ dari sinyal 1-_lead_. Pendekatan MCMA menunjukkan hasil yang menjanjikan dengan kualitas rekonstruksi yang tinggi dan metrik yang baik melalui _latent probing_ untuk tugas-tugas _downstream_. @Chen2024mcma

== ECG-ke-cMRI

Sama seperti PPG ke ECG 12-_lead_, translasi ECG ke cMRI sering kali dianggap _ill-posed_, karena bentuk fisiologis nyata jantung pada setiap individu bervariasi dan sinyal yang diamati karenanya memiliki implikasi yang berbeda pada individu yang berbeda. Namun, karena ECG berkorelasi secara langsung dengan pewaktuan kontraksi otot di dalam jantung, @Sattar2025-py terdapat kemungkinan bahwa rekonstruksi yang masuk akal dapat dilakukan untuk visualisasi volumetrik relatif dari cMRI.

Penelitian terbaru mengeksplorasi penggunaan _cross-modal autoencoder_ (CMAE) yang dilatih di bawah skema _contrastive loss_ untuk memastikan representasi holistik dalam ruang laten yang menunjukkan hasil menjanjikan, mendemonstrasikan rekonstruksi yang masuk akal dan laten yang menunjukkan korespondensi holistik fenotipikal di bawah pengujian laten @Radhakrishnan2023cmae. Membangun di atas hal ini, MMCL @TURGUT2025mmcl menerapkan skema _contrastive learning_ derivasi CLIP untuk pemahaman mendalam pada antarmodalitas ECG-cMRI, menghasilkan _encoder_ yang dapat menghasilkan performa diagnostik kompetitif pada kasus _downstream_. Kemudian, dari hasil MMCL, PTACL mengusulkan penggunaan _masked autoencoder_ bersama dengan skema _contrastive loss_ lokal dan global untuk menyelaraskan kedua ruang laten tersebut secara bersamaan. Hasil mereka mendemonstrasikan hasil yang menjanjikan dalam pengujian _downstream_, namun jalur dekoder ditiadakan untuk penelitian mereka karena laten diselaraskan dalam ruang _encoding_. @selivanov2025ptacl Mengembangkan dari CMAE, ECGFlowCMR menerapkan sebuah 3D-VAE yang diarahkan dalam ruang laten menggunakan model _rectified flow_ yang mendapatkan prior sinyal fase denyut dari sebuah encoder ECG berbasis ResNet 1D, menghasilkan model yang memiliki fidelitas yang jauh lebih tinggi sebagai _state-of-the-art_ dalam generasi cMRI dari ECG. @fang2026ecgflowcmr

= Metodologi <sec:methods>

Terlihat pada @fig:pipeline_final, arsitektur _end-to-end_ OptiCardio terdiri dari tiga tahap utama: (1) konversi PPG ke ECG 1-_lead_ menggunakan CardioGAN, (2) rekonstruksi ECG 12-_lead_ menggunakan model MCMA, dan (3) dihasilkannya cMRI dari ECG 12-_lead_ menggunakan CMAE. Setiap tahap dihubungkan oleh _alignment layer_ yang menangani proses _resampling_ dan normalisasi antarlaten.

#figure(
  image("I.png", width: 84%),
  caption: [Diagram alir OptiCardio.],
) <fig:pipeline_final>

== Akuisisi Data

Diakuisisi empat jenis data untuk pelatihan dan evaluasi: video PPG, sinyal PPG, sinyal ECG, dan data cMRI. Video PPG, yang digunakan untuk memperoleh sinyal PPG, didapatkan dari _dataset_ publikasi @Lovisotto_2020_CVPR_Workshops_seeingred yang terdiri dari 14 partisipan, menghasilkan ukuran sampel sebanyak 128 video. _Ground truth_ untuk sinyal PPG diperoleh dari _dataset_ Beth Israel Deaconess Medical Center (BIDMC) @bidmc pada PhysioNet @PhysioNet yang diturunkan dari _dataset_ MIMIC II @Saeed2002mimic, berjumlah 53 pasien, dengan masing-masing menyediakan rekaman 8 menit pada 125 Hz. Data cMRI diakuisisi dari _dataset_ Sunnybrook Cardiac MR Left Ventricle Segmentation Challenge, @Radau2009Evaluation dengan total 45 _cine_ cMRI. Sinyal ECG 12-_lead_ pada 500 Hz juga diperoleh dari Chapman-Shaoxing 12-_lead_ ECG Database @Zheng2020chapman.

== Akuisisi Sinyal PPG

Sinyal PPG mentah dari video ponsel pintar diekstraksi menggunakan metodologi turunan @Lovisotto_2020_CVPR_Workshops_seeingred yang terdiri atas tahapan-tahapan berikut:

=== Ekstraksi Komponen Luma

_Frame_ video pertama-tama dikonversi dari ruang warna BGR menjadi YCrCb. Sinyal PPG mentah diturunkan dengan menghitung rata-rata spasial dari komponen Luma pada setiap _frame_. Sinyal tersebut kemudian diinversi agar berkorelasi positif dengan denyut volume darah.

=== Prapemrosesan Sinyal

Untuk memitigasi artefak pergerakan dan _baseline wander_, _detrending_ temporal diterapkan menggunakan filter _rolling average_ dengan ukuran _window_ sekitar 1,01 detik. Sinyal yang telah di-_detrending_ kemudian dilewatkan melalui filter _low-pass_ Butterworth $2^("nd")$-_order_ dengan frekuensi _cutoff_ sebesar 4 Hz untuk menghilangkan _noise_ frekuensi tinggi.

=== Pemisahan Denyut

Denyut jantung individu disegmentasi dengan mengidentifikasi awal dari setiap siklus. Sinyal yang telah melalui tahap prapemrosesan dihaluskan menggunakan _moving average_, dan batas-batas denyut dideteksi menggunakan penentuan minima relatif. Untuk mencegah _false positive_ dari _noise_, batas minimum interval antardenyut diterapkan yang setara dengan detak jantung maksimal sebesar 101 bpm.

=== Deteksi Titik Fidusial

Untuk setiap denyut yang disegmentasi $B_i$, fitur-fitur morfologis yang berbeda diekstraksi. Denyut tersebut pertama-tama dinormalisasi secara min-max ke rentang $[0, 1]$. _Systolic Peak_ atau puncak sistolik diidentifikasi sebagai nilai maksimum global, sedangkan _Dicrotic Notch_ dideteksi sebagai nilai minimum lokal pertama yang terjadi setelah puncak sistolik.

== PPG ke ECG 1-Lead

Model _pretrained_ CardioGAN @Sarkar2020CardioGANAG digunakan pada arsitektur untuk mengonversi segmen PPG (512 sampel) pada 128 Hz menjadi ECG 1-_lead_ (_lead_ II) _peak-aligned_. Generator menggunakan _encoder-decoder_ dengan 6 lapisan _downsampling_ dan 6 lapisan _upsampling_. Setiap lapisan _downsampling_ memiliki jumlah filter yang meningkat (64, 128, 256, 512, 512, 512) dengan ukuran _kernel_ $1 times 16$ yang tetap dan _stride_ 2. LayerNorm dan LeakyReLU diterapkan setelah setiap lapisan konvolusional kecuali yang pertama. Arsitektur serupa digunakan pada _upsampling_, dengan konvolusi dan aktivasi diganti dengan lapisan dekonvolusional dan aktivasi ReLU. _Output_ akhir kemudian diperoleh dari lapisan dekonvolusional yang diikuti oleh aktivasi tanh.

== Prapemrosesan 1-Lead ke 12-Lead

Sebelum meneruskan sinyal 1-_lead_ yang dihasilkan oleh _backbone_ CardioGAN @Sarkar2020CardioGANAG ke MCMA @Chen2024mcma, perlu diterapkan penyesuaian pada sampel tersebut dikarenakan adanya ketidaksesuaian antar _dataset_ yang digunakan untuk melatih kedua _backbone_.

Pertama, dilakukan _resampling_ melalui interpolasi linear terhadap hasil 512 sampel pada 128 Hz menjadi 2048 sampel pada 512 Hz agar sesuai dengan dimensi masukan MCMA.

Kemudian, dilatih sebuah _alignment layer_ yang dirancang sebagai jaringan ResNet 1D untuk menjembatani hasil CardioGAN dengan MCMA, yang tersusun atas empat lapisan konvolusi 1D sekuensial dengan ukuran _kernel_ 15 dan _padding_ 7 untuk mempertahankan dimensi temporal. Jaringan menerapkan ekspansi dan kompresi fitur dengan perubahan jumlah _channel_ sebesar 1 $arrow$ 32 $arrow$ 64 $arrow$ 32 $arrow$ 1, di mana tiga lapisan pertama diikuti oleh fungsi aktivasi GELU. Hasil dari operasi konvolusi ini kemudian dijumlahkan kembali dengan sinyal masukan aslinya melalui koneksi residual ($y = x + F(x)$).

_Alignment layer_ difungsikan dalam OptiCardio untuk melakukan _warping_ secara non-linear pada sinyal ECG 1-_lead_ sintesis sehingga ketika sinyal tersebut melewati MCMA, morfologi asli dari hasil CardioGAN tetap dipertahankan hasil _lead_ II dalam rekonstruksi. Lalu, untuk menjamin stabilitas di awal pelatihan, lapisan konvolusi terakhir dari jaringan diinisialisasi dengan bobot dan bias bernilai nol, sehingga modul bermula sebagai _identity mapping_.

_Pretraining_ kemudian dilakukan pada _dataset_ BIDMC @bidmc dengan mengoptimalkan fungsi objektif

$
  cal(L)_"align" = || hat(y)_"native12"^"II" - hat(y)_"1lecg" ||_2^2 + (1 - rho(hat(y)_"native12"^"II", hat(y)_"1lecg"))
$

di mana $hat(y)_"1lecg"$ adalah keluaran 1-_lead_ asli dari CardioGAN, $hat(y)_"native12"^"II"$ adalah _Lead_ II dari hasil rekonstruksi MCMA, dan $rho$ fungsi korelasi pearson. Pelatihan dilakukan selama 5 _epoch_ menggunakan _optimizer_ Adam pada _weight decay_ $1 times 10^(-5)$ dan _scheduler_ OneCycleLR pada maksimum _learning rate_ (LR) $2.5 times 10^(-2)$, dengan keseluruhan komponen OptiCardio beku dan sebelum dilakukan _finetuning_ _end-to-end_.

== ECG 1-Lead ke 12-Lead

Untuk merekonstruksi ECG 12-_lead_, arsitektur memanfaatkan model MCMA @Chen2024mcma sebagai _pretrained backbone_ yang mengikuti skema _masked autoencoder_, di mana _encoder_-nya terdiri dari 6 blok _encoder_ dan 6 blok _decoder_. Setiap blok terdiri atas blok multikonvolusi, yaitu blok konvolusional yang memiliki struktur konvolusional residual, di mana, jika diberikan $x$ dan $sigma(dot)$ yang melambangkan aktivasi GELU, $x$ diproses sebagai

$
  hat(y) = "InstanceNorm"(underbrace(sigma(W_s * x), "Residual") + space.nobreak underbrace(sigma(W_2 * sigma("LayerNorm"(W_1 * x))), "Downsampling"))
$

dengan $*$ melambangkan konvolusi. Blok _decoder_ menggunakan struktur yang sama, dengan perbedaan terletak pada konvolusi yang digantikan oleh konvolusi transpos (_transposed convolutions_),

$
  hat(y) = "InstanceNorm"(underbrace(sigma(W_s star x), "Residual") + space.nobreak underbrace(sigma(W_2 * sigma("LayerNorm"(W_1 star x))), "Upsampling"))
$

dengan $star$ melambangkan konvolusi transpos. Seluruh konvolusi dikonfigurasikan pada k=13, dengan window_size=2.

== Prapemrosesan 12-Lead

Karena _backbone_ MCMA @Chen2024mcma dan CMAE @Radhakrishnan2023cmae juga dilatih menggunakan data yang berbeda, perlu dilakukan pelatihan pada _alignment layer_ antara kedua _backbone_ tersebut untuk memastikan fidelitas morfologi terjaga pada lingkup laten keduanya, dinamakan _beat alignment layer_ berdasarkan denyut median yang digunakan dalam _pretraining_ CMAE.

_Beat alignment layer_, seperti _alignment layer_ sebelumnya, diinisialisasi sebagai _identity mapping_ pada lapisan konvolusi terakhirnya, dengan tiga lapisan konvolusi 1D sekuensial dengan ukuran _kernel_ 15 dan _padding_ 7. Konvolusi ini mengaplikasikan arsitektur ekspansi-kompresi fitur secara bersamaan pada ke-12 _channel_ (12 $arrow$ 48 $arrow$ 48 $arrow$ 12) dengan aktivasi GELU, yang hasil akhirnya ditambahkan kembali ke sinyal masukan melalui koneksi residual ($y = x + F(x)$).

Berbeda dengan _alignment layer_ sebelumnya, dikarenakan _pretraining_ CMAE yang mengasumsikan _median beat_, _beat alignment layer_ dilatih pada segmen-segmen denyut jantung individual berukuran 600 sampel yang diekstraksi melalui _R-peak detection_ yang didapatkan dari dataset BIDMC. @bidmc

_Pretraining_ kemudian difokuskan untuk meminimalkan fungsi _loss_ gabungan yang mencakup rekonstruksi pada domain waktu serta konsistensi fitur laten lintas-modal:

$
  cal(L)_"beat_align" &= (1 - rho(hat(y)_"12lecg", hat(y)_"recon_cmae")) + 0.5 times || hat(y)_"12lecg" - hat(y)_"recon_cmae" ||_1 \
  &+ 2.0 times (1 - "sim"(z_"ecg", z_"mri")) + 0.01 times 1/N sum z_"ecg"^2
$

di mana $hat(y)_"12lecg"$ adalah sinyal keluaran dari _beat alignment layer_ (setelah menerima input dari MCMA), $z_"ecg"$ dan $z_"mri"$ masing-masing adalah representasi laten dari _encoder_ ECG (hasil _encoding_ dari ECG encoder CMAE) dan MRI ($z_"ecg"$ yang di-_decode_ oleh decoder MRI CMAE yang di-_encode_ kembali oleh _encoder_ MRI CMAE), $hat(y)_"recon_cmae"$ adalah hasil rekonstruksi akhir dari _decoder_ ECG pada CMAE ($z_"ecg"$), serta $"sim"(dot)$ merupakan fungsi similaritas kosinus.

Optimisasi kemudian dilakukan dengan menggunakan _optimizer_ Adam dengan _weight decay_ $1 times 10^(-5)$ dan _scheduler_ OneCycleLR dengan maksimum LR $2.5 times 10^(-2)$ selama 5 _epoch_, dengan keseluruhan komponen OptiCardio beku dan sebelum dilakukan _finetuning_ _end-to-end_.

== ECG 12-Lead ke cMRI

Sinyal ECG 12-_lead_ yang telah dilalui _beat alignment layer_ kemudian dilewatkan ke model _pretrained_ CMAE @Radhakrishnan2023cmae dengan terlebih dahulu memasukkannya ke dalam _encoder_ ECG untuk mendapatkan representasi laten lintas-modal, kemudian mengembalikan laten cMRI tersebut melalui _decoder_ MRI. Bagian _encoder_ dalam model terdiri dari blok konvolusional _densely connected_, sedangkan bagian _decoder_ memanfaatkan varian dekonvolusional timbal baliknya. Konvolusi 1D digunakan untuk modalitas ECG, sedangkan konvolusi 2D digunakan untuk cMRI. Keluaran dari tahapan ini adalah rekonstruksi 50-_frame_ _cine_ cMRI _long-axis_ _4-chamber_ dari masukan sinyal ECG.

== ECG 1-Lead ke PPG

Agar siklus terpenuhi, perlu ditambahkan model untuk mengembalikan dari sinyal ECG _lead_ II ke PPG. Model ECG-ke-PPG ini diimplementasikan menggunakan _backbone_ Reverso-Small @fu2026reverso _pretrained_ sebagai pengekstraksi fitur. Untuk mengembalikan representasi fitur berdimensi tinggi dari _backbone_ menjadi sinyal PPG 1D, sebuah _projection head_ ditambahkan pada bagian akhir arsitektur yang diimplementasikan sebagai jaringan konvolusional 1D sekuensial yang terdiri atas empat lapisan dengan penurunan jumlah _channel_ secara bertahap 128 $arrow$ 64 $arrow$ 32 $arrow$ 1 dan ukuran _kernel_ 7, di mana setiap lapisannya (kecuali lapisan akhir) diikuti oleh fungsi aktivasi GELU. Model ini dilatih untuk merekonstruksi sinyal PPG asli melalui siklus penuh dari _generator_ ECG yang dibekukan, di mana

$ hat(y)_"ppg" = G_"inv" (hat(y)_"12lecg"^"II") $

dengan $G_"inv"$ adalah model ECG-ke-PPG, dengan asumsi seluruh komponen OptiCardio beku dan sebelum dilakukannya _finetuning_ secara _end-to-end_.

_Pretraining_ ECG-ke-PPG dilakukan pada _dataset_ BIDMC @bidmc dengan mengoptimalkan fungsi _loss_ gabungan

$
  cal(L)_"proj" = || hat(y)_"ppg" - x_"ppg" ||_1 + (1 - rho(hat(y)_"ppg", x_"ppg")) + lambda_"tv" sum_t | hat(y)_"ppg" (t+1) - hat(y)_"ppg" (t) |
$

di mana $x_"ppg"$ adalah sinyal PPG asli, $rho(dot)$ merupakan metrik korelasi pearson untuk menjaga keselarasan bentuk gelombang, dan komponen _Total Variation_ (TV) dibobotkan secara ringan dengan $lambda_"tv" = 0.1$ untuk mengurangi _noise_ frekuensi tinggi pada sinyal hasil rekonstruksi.

== LoRA Finetuning

Karena OptiCardio merupakan arsitektur yang sangat dalam dan mengintegrasikan berbagai _backbone_, arsitektur sangat rentan terhadap fenomena _catastrophic forgetting_, yakni fenomena di mana model akan melupakan ataupun mendegradasi performa tugas awal setelah dilakukan pelatihan pada tugas baru. @colonna2024catastrophic

Oleh karena itu, untuk mengantisipasi fenomena _catastrophic forgetting_ serta meminimalisir ukuran gradien yang harus disimpan dan di-_tracking_ dalam VRAM selama pelatihan, digunakan _finetuning_ berbasis _Low-Rank Adaptation_ (LoRA) pada _rank_ 8 dan $alpha$ 16. @hu2022lora

Prosedur LoRA yang diterapkan menggunakan inisialisasi berbasis PiSSA. @pisaniurips2024 Penggunaan inisialisasi ini berfungsi untuk memastikan bahwa konvergensi yang dicapai oleh _adapter_ semirip mungkin dengan _full-finetuning_.

== Finetuning Cycle-Consistent <ftexp>

Untuk meningkatkan korespondensi holistik dari representasi laten menengah di antara submodel-submodel tersebut, dilakukan _finetuning_ pada model secara _end-to-end_ melalui skema yang ditunjukkan pada @fig:training. Penelitian tidak memiliki akses terhadap data berpasangan secara _end-to-end_, di mana _finetuning_ _end-to-end_ yang disupervisi untuk setiap modalitas tidak mungkin dilakukan secara praktis, sehingga diterapkan skema konsistensi siklus atau _cycle consistency_ pada penelitian.

Untuk simplifikasi formulasi, asumsikan notasi

$
  hat(y)_"1lecg" &= G_"fwd" (x_"ppg"), &
  quad hat(y)_"native12" &= M_"mcma" (A_"ecg" (hat(y)_"1lecg")), \
  hat(y)_"12lecg" &= A_"beat" (hat(y)_"native12"), &
  quad z &= "Enc"_"ecg" (hat(y)_"12lecg"), \
  hat(y)_"recon" &= "Dec"_"ecg" ("Enc"_"mri" ("Dec"_"mri" (z))), &
  quad hat(y)_"chapman" &= M_"mcma" (y_"chapman"^"II")
$

di mana $G_"fwd"$ _backbone_ CardioGAN, $A_"ecg"$ _alignment layer_ MCMA, $M_"mcma"$ _backbone_ MCMA, $A_"beat"$ _beat alignment layer_ CMAE, $"Enc"_"ecg"$ dan $"Enc"_"mri"$ encoder CMAE, serta $"Dec"_"ecg"$ dan $"Dec"_"mri"$ sebagai decoder CMAE.

#figure(
  image("assets/Copy of Copy of opticardio.drawio.png", width: 48%),
  caption: [Diagram alir dari proses _finetuning_ OptiCardio, dengan _node_ lingkaran ungu menandakan _losses_, biru menandakan _weight_ dibekukan, dan merah _weight_ dilatih.],
) <fig:training>

Setelah itu, keseluruhan model di-_finetune_ secara _end-to-end_ menggunakan sembilan macam _loss_, pada data BIDMC @bidmc dan Chapman-Shaoxing @Zheng2020chapman dengan 80-20 train-test split.

Dengan _dataset_ BIDMC @bidmc yang memiliki pasangan PPG-ECG, dikalkulasikan empat buah _loss_, yakni supervisi pada ECG yang dinotasikan dengan $cal(L)_"sup"$, distilasi CardioGAN yang dinotasikan $cal(L)_"distill"$, _small cycle loss_ yang dinotasikan $cal(L)_"cyc"_"small"$, dan _big cycle loss_ yang dinotasikan $cal(L)_"cyc"_"big"$.

Supervisi $cal(L)_"sup"$ didefinisikan sebagai fungsi _shifted pearson correlation_, di mana

$ cal(L)_"sup" = 1 - max_(tau) (rho (hat(y)_"1lecg" (t), y_"ecg" (t - tau))) $

dengan $tau$ menotasikan jangka pergeseran pada dimensi waktu, dengan $rho$ merupakan fungsi korelasi pearson. Fungsi dari pergeseran waktu adalah agar korelasi morfologi pada rekonstruksi $hat(y)_"1lecg"$ dapat dikalkulasikan tanpa memperhatikan _Pulse Transit Time_ (PTT) pada ECG nyata $y_"ecg"$ yang merupakan _out-of-distribution_ pada _backbone_ CardioGAN karena prosedur _pretraining_-nya yang melakukan sinkronisasi puncak pada pasangan PPG-ECG.

Kemudian, $cal(L)_"distill"$ didefinisikan sebagai

$ cal(L)_"distill" = 1 - rho (hat(y)_"1lecg", y_"teacher") $

di mana $y_"teacher"$ adalah hasil CardioGAN _frozen_, dan $hat(y)_"1lecg"$ hasil model _backbone_ CardioGAN yang dilatih. Fungsi dari _loss_ ini adalah untuk memastikan morfologi CardioGAN tidak terdegradasi selama pelatihan.

_Loss_ ketiga yang dikalkulasikan menggunakan BIDMC merupakan _small cycle loss_, di mana hasil dari rekonstruksi MCMA diekstraksi _lead_ II-nya, kemudian direkonstruksi kembali ke PPG melalui _decoder_ PPG yang dinotasikan sebagai $G_"inv"$, dan dibandingkan dengan PPG nyata pada MAE.

$ cal(L)_("cyc"_"small") = || G_"inv" (hat(y)_"12lecg"^"II") - x_"ppg" ||_1 $

Terakhir, _big cycle loss_ dikalkulasikan pada BIDMC dengan mengembalikan hasil $hat(y)_"recon"^"II"$ ke PPG dan dibandingkan terhadap PPG nyata dengan MAE.

$ cal(L)_"cyc"_"big" = || G_"inv" (hat(y)_"recon"^"II") - x_"ppg" ||_1 $

Menggunakan rekonstruksi _lead_ II dari _backbone_ MCMA, dikalkulasikan $cal(L)_"align"$ yang mengukur keterselarasan antara rekonstruksi _backbone_ CardioGAN dengan MCMA berdasarkan MSE dan korelasi pearson, di mana

$
  cal(L)_"align" = || hat(y)_"native12"^"II" - hat(y)_"1lecg" ||_2^2 + (1 - rho(hat(y)_"native12"^"II", hat(y)_"1lecg"))
$

Kemudian $cal(L)_"cyc"_"mri"$ digunakan untuk memastikan bahwa input decoder MRI CMAE yang dimasukkan kembali ke encoder MRI lalu di-_decode_ dengan decoder ECG sesuai dengan hasil input encoder ECG.

$ cal(L)_"cyc"_"mri" = || hat(y)_"recon" - hat(y)_"12lecg" ||_1 $

$cal(L)_"z_reg"$ diterapkan pada laten CMAE sebagai regularisasi L2 agar laten tidak terlalu jauh satu sama lain.

$ cal(L)_"z_reg" = 1/N sum z^2 $

Untuk memastikan bahwa fisika dari ECG terjaga dan derivasi MCMA mengikuti relasi ECG nyata, diterapkan _loss_ konsistensi fisiologi pada ECG pada empat lokasi, yakni pada hasil $hat(y)_"native12"$, $hat(y)_"12lecg"$, $hat(y)_"recon"$, dan $hat(y)_"chapman"$.
Fungsi ini diderivasikan dari Hukum Einthoven, _Goldberger's Central Terminal_ (GCT), dan _Wilson's Central Terminal_ (WCT). Untuk Hukum Einthoven, digunakan referensi validitas berupa $y^"I" - y^"II" + y^"III" = 0$, kemudian untuk GCT diasumsikan $y^"aVR" + y^"aVL" + y^"aVF" = 0$, menghasilkan $cal(L)_"phys"$ yang terlihat pada @physloss.

$
  cal(L)_"phys" (y) &= || y^"I" - y^"II" + y^"III" ||_1 + || y^"aVR" + (y^"I" + y^"II")/2 ||_1 + || y^"aVL" - (y^"I" - y^"III")/2 ||_1 \
  &+ || y^"aVF" - (y^"II" + y^"III")/2 ||_1 + || y^"aVR" + y^"aVL" + y^"aVF" ||_1
$ <physloss>

Kemudian, dari @physloss diambil total agregasi dari seluruh posisi, sehingga

$
  cal(L)_"phys_total" = cal(L)_"phys"(hat(y)_"native12") + cal(L)_"phys"(hat(y)_"12lecg") + cal(L)_"phys"(hat(y)_"recon") + cal(L)_"phys"(hat(y)_"chapman")
$

Lalu, menggunakan dataset Chapman-Shaoxing @Zheng2020chapman, dikalkulasikan supervisi pada 12-_lead_ nyata menggunakan korelasi pearson, MAE, dan $L_"phys"$, di mana

$
  cal(L)_"chapman" & = (1 - rho(hat(y)_"chapman", y_"chapman")) \
                   & + 0.1 times || hat(y)_"chapman" - y_"chapman" ||_1 + 0.1 times cal(L)_"phys" (hat(y)_"chapman")
$

Akhirnya, total dari keseluruhan _loss_ menghasilkan persamaan @totalloss.

$
  cal(L)_"total" &= lambda_"sup" cal(L)_"sup" + lambda_"distill" cal(L)_"distill" + lambda_"align" cal(L)_"align" + lambda_"phys_total" cal(L)_"phys_total" \
  &+ lambda_("cyc"_"small") cal(L)_("cyc"_"small") + lambda_("cyc"_"mri") cal(L)_"cyc"_"mri" + lambda_("cyc"_"big") cal(L)_"cyc"_"big" + lambda_"z_reg" cal(L)_"z_reg" + lambda_"chapman" cal(L)_"chapman"
$ <totalloss>

Setiap _loss_ dibobotkan oleh masing-masing nilai $lambda$-nya, yang diatur pada $lambda_"sup" = 10.0$, $lambda_"distill" = 15.0$, $lambda_"align" = 5.0$, $lambda_"phys_total" = 5.0$, $lambda_("cyc"_"small") = 5.0$, $lambda_("cyc"_"mri") = 2.0$, $lambda_("cyc"_"big") = 5.0$, $lambda_"z_reg" = 0.01$, dan $lambda_"chapman" = 5.0$.

Pengaturan ini dimaksudkan untuk memastikan stabilitas meskipun data berpasangan tidak tersedia untuk keseluruhan _pipeline_. Pelatihan dilakukan selama 12 _epoch_ menggunakan _optimizer_ Adam dengan _weight decay_ $1 times 10^(-5)$, dengan _scheduler_ OneCycleLR pada LR maksimum $1.5 times 10^(-3)$. Untuk menjaga stabilitas pelatihan, digunakan pula _gradient clipping_ pada _max norm_ 0.5.

== Evaluasi

Untuk mengevaluasi performa model, evaluasi dilakukan pada dua tugas _latent probing_ _downstream_, yaitu pencarian fenotipikal untuk kelainan ECG melalui test set @Zheng2020chapman guna menentukan akurasi klinis dan konsistensi pemetaan ruang laten pada _head_ rekonstruksi cMRI _downstream_ di @Radau2009Evaluation guna mengevaluasi korespondensi holistik dari ruang laten yang dihasilkan.

Karena terdapat dua ruang laten 12-lead yang dapat digunakan, agar perbandingan yang dilakukan komprehensif pada keseluruhan arsitektur, OptiCardio dievaluasi pada submodel MCMA dan CMAE-nya setelah prosedur _finetuning end-to-end_.

=== Akuisisi dan Penilaian Kualitas Sinyal PPG

_Pipeline_ akuisisi sinyal PPG dievaluasi pada _dataset_ Seeing Red @Lovisotto_2020_CVPR_Workshops_seeingred yang terdiri atas 128 video ponsel pintar dari 14 partisipan. Evaluasi denyut yang terekstraksi mengikuti metodologi @Lovisotto_2020_CVPR_Workshops_seeingred, di mana semua denyut yang menunjukkan angka >120 bpm, atau memiliki lebih dari tiga nilai maksimum yang berbeda, atau yang terlalu berbeda dari rujukan gelombang denyut yang diharapkan ditandai sebagai denyut tidak valid.

=== Presisi Pencarian Fenotipikal

Evaluasi ini dilakukan dengan terlebih dahulu memperoleh sampel pada test set berdasarkan label kode patologis aritmia dari setiap pasien di @Zheng2020chapman (dengan memilih _worst-case_ pada kasus label-ganda menurut urutan: PVC (_Premature Ventricular Contraction_) > AFL (_Atrial Flutter_) > AFIB (_Atrial Fibrillation_) > SB (_Sinus Bradycardia_) > ST (_Sinus Tachycardia_) > SR (_Sinus Rhythm_)) pada maksimum 200 sampel per label, lalu melakukan _embedding_ pada seluruh sampel, dan terakhir menghitung matriks kesamaan melalui _dot-product_.

Presisi kemudian dihitung dengan mencari tetangga _top-k_ untuk setiap sampel, mendapatkan rasio jumlah tetangga yang memiliki label yang sama, lalu menghitung rata-rata global di seluruh _dataset_ berdasarkan rasio tersebut. Dengan kata lain,

$
  bb(1)(i, j) = cases(
    1 "jika" (Y_i inter cal(M)) inter (Y_j inter cal(M)) eq.not emptyset,
    0 "lainnya"
  )
$

dengan $Y_i$ melambangkan himpunan label penyakit untuk pasien $i$, dan $cal(M)$ adalah himpunan label yang ada, sehingga presisi untuk kelas $c$ didefinisikan sebagai

$ "Precision"_c @k = frac(1, |cal(D)_c|) sum_(i in cal(D)_c) frac(1, k) sum_(j in cal(N)_k(i)) bb(1)(i, j) $

dengan $cal(D)_c$ adalah himpunan sampel yang tergolong dalam kelas $c$. _Average_ presisi dikalkulasikan sebagai _macro average_ di seluruh kelas $cal(C)$ agar perbandingan antarkelas adil, di mana

$ "Average-Precision@k" = frac(1, |cal(C)|) sum_(c in cal(C)) "Precision"_c @k $

Setelah itu, model dibandingkan pada metrik di atas terhadap berbagai _baseline_ dari @Radhakrishnan2023cmae, @Chen2024mcma, @Ecgfounder2025Li-aw, @TURGUT2025mmcl, dan @fang2026ecgflowcmr. Untuk stabilitas, diambil 95% _Confidence Interval_ (CI) bootstrap dengan 30 kali percobaan.

=== Konsistensi Siklus Laten <lccexpl>

Evaluasi ini dilakukan untuk menentukan penyelarasan laten antara bentuk gelombang ECG dengan cMRI padanannya. Untuk ini, terlebih dahulu dilakukan _pretraining_ terhadap sebuah _head_ rekonstruksi pada @Radau2009Evaluation yang terdiri dari struktur _encoder_ dan _decoder_ konvolusional empat lapisan dengan dimensi laten sebesar 256. Bagian _encoder_ secara progresif melakukan _downsampling_ terhadap masukan $96 times 96$ menjadi peta fitur $6 times 6$ menggunakan konvolusi $4 times 4$ dengan _stride_ 2, aktivasi LeakyReLU, dan _Batch Normalization_, yang diikuti dengan proyeksi _dense_ ke ruang laten teraktivasi tanh. Bagian _decoder_ mencerminkan arsitektur ini, menggunakan konvolusi transpos untuk melakukan _upsampling_ terhadap fitur-fitur agar kembali ke resolusi aslinya dengan keluaran Sigmoid. Setelah itu, sebuah _probe_ dibentuk sebagai pemetaan dari ECG 12-_lead_ $z_"ECG"$ (pada dimensi masing-masing _encoder_) ke laten _decoder_ $z_"MRI"$ untuk MRI (pada 256 dimensi) menggunakan MLP yang terdiri atas tiga lapisan linear dengan aktivasi LeakyReLU dan _Batch Normalization_.

Untuk mengukur penyelarasan topologis antarmodalitas tersebut, dimanfaatkan alur konsistensi siklus melalui _probe_ laten. Secara bersamaan dilatih sebuah _forward mapper_ dan _reverse mapper_, yang keduanya dikonstruksi menggunakan _probe_ yang sama seperti yang telah disebutkan. Kualitas penyelarasan kemudian dikuantifikasi oleh konsistensi siklus yang didefinisikan sebagai nilai MAE antara vektor laten aslinya dengan hasil rekonstruksi dua-arahnya.

= Hasil

== Kualitas Akuisisi Sinyal PPG

Seperti yang terlihat pada @tab:ppg_comparison, implementasi mencapai tingkat kelulusan kualitas denyut sebesar 98,5% berbanding 92,0% yang dilaporkan pada studi asli, atau 93,8% pada uji coba reproduksi penelitian (peningkatan minor disebabkan oleh pengecualian data 1 pasien pada dataset publik, dari 15 pasien pada studi aslinya). Dari total 3.718 denyut yang terdeteksi, 3.661 diklasifikasikan sebagai valid, mewakili peningkatan sebesar 6,5 poin persentase. Rasio sinyal terhadap _noise_ (SNR) rata-rata adalah 23,1 dB dengan denyut jantung rata-rata sebesar 67,2 bpm.

== Hasil Presisi Pencarian Fenotipikal

Terlihat pada @tab:ecg_all_precision, OptiCardio pada _backbone_ MCMA secara konsisten mengungguli seluruh _baseline_ pembanding dalam presisi rata-rata pada seluruh nilai $k$ yang diuji. Untuk metrik yang paling ketat, Precision\@1 (P\@1), ruang laten ini mencapai rerata 61,9%, melampaui posisi kedua yaitu _baseline_ MCMA sebesar 3,0% dan _baseline_ CMAE sebesar 10,4%. Pada $k=10$, OptiCardio pada _backbone_ MCMA tetap mempertahankan presisi rerata sebesar 56,8%, unggul 6,3% atas _baseline_ MCMA di posisi kedua.

#figure(
  caption: [Evaluasi Kualitas Sinyal PPG],
  table(
    columns: (1.4fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center),
    inset: (x: 8pt, y: 2.5pt),

    table.header[*Metrik*][*OptiCardio*][*Reproduksi* @Lovisotto_2020_CVPR_Workshops_seeingred][*Dilaporkan* @Lovisotto_2020_CVPR_Workshops_seeingred],
    [Video Diproses], [128], [128], [N/A],
    [Total Denyut], [3.718], [3.718], [3.836],
    [Denyut Valid], [3.661], [3.486], [3.529],
    table.hline(stroke: 0.5pt + black),
    [*Kelulusan (%)*], [*98,5*], [*93,8*], [*92,0*],
    table.hline(stroke: 0.5pt + black),
    [Rata-rata bpm], [67,2], [67,4], [--],
    [SNR (dB)], [23,1], [23,1], [--],
  ),
) <tab:ppg_comparison>

Berdasarkan kelas, OptiCardio menunjukkan peningkatan performa yang paling menonjol pada dua label patologis, yaitu ST, di mana ruang laten _backbone_ MCMA memperoleh 91,6% pada P\@1 di atas _baseline_ MCMA yang sebesar 88,3% dan _baseline_ MMCL yang sebesar 62,4%, serta SR, di mana ruang laten pada _backbone_ MCMA memperoleh 72,4% pada P\@1, melampaui posisi kedua terdekat yaitu _baseline_ MCMA dengan selisih 10,8%. Selain itu, ruang laten OptiCardio pada _backbone_ CMAE unggul pada label AFL dan AFIB, masing-masing mencapai 21,4% dan 63,3% pada P\@1, di atas _baseline_ CMAE di posisi kedua yang sebesar 14,2% dan 62,2%.

Meskipun OptiCardio unggul dalam metrik keseluruhan maupun sebagian besar kelas morfologis, perlu dicatat bahwa _baseline_ MCMA tetap sangat kompetitif pada beberapa label, misalnya SB, yang mencapai P\@1 tertinggi sebesar 82,8%, sedikit di atas OptiCardio pada _backbone_ MCMA yang sebesar 80,0%.

== Hasil Konsistensi Siklus Laten

Terlihat pada @tab:latent_loss, OptiCardio pada _backbone_ CMAE (merah) mencapai _loss_ konsistensi sebesar 0,0241, unggul atas _baseline_ MMCL @TURGUT2025mmcl (ungu), ECGFlowCMR @fang2026ecgflowcmr (kuning), dan MCMA @Chen2024mcma (biru muda) masing-masing sebesar 13%, 60%, dan 72%. Walaupun nilai tersebut merupakan degradasi pada _baseline_ CMAE (hijau) (0,0206), degradasi sangat minor pada skala $1 times 10^(-3)$, dan hanya terlampaui secara signifikan oleh ECGFounder (coklat) pada 0,0170. Sementara itu, OptiCardio pada _backbone_ MCMA (biru tua) mencapai _loss_ sebesar 0,0566, yang merupakan peningkatan dari _baseline_ MCMA (0,0856) dan melampaui ECGFlowCMR (0,0599), menunjukkan bahwa ruang laten menjadi lebih konsisten pada _backbone_ setelah integrasi dengan OptiCardio.

#figure(
  caption: [Metrik Loss Konsistensi Siklus Laten],
  table(
    columns: (auto, auto),
    align: (left, center),
    inset: (x: 10pt, y: 2.5pt),

    table.header[*Metode*][*Loss Akhir (MAE)*],
    [ECGFounder @Ecgfounder2025Li-aw], [0,0170],
    [CMAE @Radhakrishnan2023cmae], [0,0206],
    [OptiCardio (CMAE)], [0,0241],
    [MMCL @TURGUT2025mmcl], [0,0277],
    [OptiCardio (MCMA)], [0,0566],
    [ECGFlowCMR @fang2026ecgflowcmr], [0,0599],
    [MCMA @Chen2024mcma], [0,0856],
  ),
) <tab:latent_loss>

Pada kurva pelatihan dalam @lscurve, ECGFounder menunjukkan penurunan _loss_ paling awal dan tercepat, mencapai kestabilan pada _plateau_ terendah dengan fluktuasi paling minim. CMAE dan OptiCardio pada _backbone_ CMAE mengikuti pola serupa dengan penurunan yang tidak jauh tertinggal, stabil pada plateau yang sedikit lebih tinggi namun masih relatif halus. MMCL mencapai kestabilan pada rentang waktu yang sama, tetapi kurvanya menunjukkan _plateau_ yang lebih tinggi, sama seperti ECGFlowCMR yang jauh lebih tinggi. Sementara itu, OptiCardio pada _backbone_ MCMA mengalami _descent_ yang lebih stabil dan linear berbanding dengan _baseline_, menunjukkan bahwa integrasi membantu dalam stabilitas ruang laten.

== Hasil Kualitatif <qualitative>

Terlihat dalam @fig:samples merupakan beberapa sampel terselaraskan pada 6 posisi berjarak sama dalam rentang R-R _lead_ II yang diperoleh dari OptiCardio. _Ground truth_ PPG di sini didapatkan dari dataset BIDMC pada sampel pasien bidmc10. Puncak ECG _lead_ II diselaraskan paling dekat dengan puncak PPG untuk tujuan visualisasi. ECG 12-_lead_ diurutkan dengan urutan _lead_ I, II, III, V1, V2, V3, V4, V5, V6, aVF, aVL, dan aVR, dari atas ke bawah. Divisualisasikan pula hasil dari model sebelum dilakukannya _finetuning_ pada @fig:samplesbefore.

#figure(
  image("latent_cycle_consistency.png", width: 48%),
  caption: [Grafik _loss_ pelatihan dari _probe_ untuk konsistensi ruang laten.],
) <lscurve>

Sebagaimana terlihat pada @heartanno, hasil pelatihan OptiCardio menghasilkan 4-_chamber_ _long-axis_ _cardiac_ MRI yang memiliki anatomi layaknya sampel asli @deBourguignon2015SlicePlanes, dengan kedua ventrikel dan atrium terlihat pada rekonstruksi, serta adanya aorta desendens dan vena pulmonalis. Selain itu, kualitas rekonstruksi pada model juga cenderung lebih baik. Hal ini terlihat pada rekonstruksi yang, walaupun lebih redup, area gelap persisten pada gambar ventrikel kiri yang teranotasi dengan lingkaran biru dalam @fig:samplesbefore tereduksi secara signifikan pada @fig:samples.

#figure(
  box(
    width: 48%,
    grid(
      columns: (1fr, 1fr),
      gutter: 6pt,
      image("heaert-annotated.png"), image("real-annotate.png"),
    ),
  ),
  caption: [Frame ke-3 dari @fig:samples, dianotasikan anatomi jantungnya, dengan sampel dari @deBourguignon2015SlicePlanes.],
) <heartanno>

Pada morfologi kompleks PQRST yang diukur dengan _arbitrary units_ (a.u.), terlihat bahwa hasil tuning pada @fig:samples terdapat sedikit degradasi pada amplitudo kompleks yang menyebabkan emfasis pada puncak P dan lembah Q tidak setajam @fig:samplesbefore. Akan tetapi, pada 12-_lead_, dengan pelatihan _end-to-end_ serta _loss_ yang mempertimbangkan fisiologi ECG, terlihat bahwa kompleks secara 12-_lead_ lebih terpreservasi dengan baik, di mana _lead_ I (paling atas) sebelum pelatihan mengalami inversi, sebagaimana terlihat pada bagian yang dianotasi dengan kotak biru pada 12-lead, yang terkoreksi setelah dilakukannya pelatihan.

#let m(val, ci, bold: false, ul: false) = {
  let main = if bold [*#val*] else if ul [#underline[#val]] else [#val]
  [#main#h(1.5pt)#text(size: 0.72em, fill: rgb("#666666"))[±#ci]]
}

#figure(
  caption: [Evaluasi Fidelitas Visual cMRI Menggunakan KID (lebih rendah lebih baik)],
  {
    set text(size: 8pt)
    table(
      columns: (2.7fr, 1.1fr, 1.1fr, 1.1fr),
      align: (left, center, center, center),
      inset: (x: 5pt, y: 2pt),

      table.header[*Metode*][*UKBB-10 (500 fr)*][*UKBB-13 (650 fr)*][*Key-5 (UKBB-13)*],
      table.hline(stroke: 0.5pt + black),

      [_Referensi UKBB:_], [], [], [],
      [Real UKBB 5v5 (Batas Bawah)], m("0,0618", "0,0136"), [--], [--],
      [ECGFlowCMR Resmi (ECG UKBB) @fang2026ecgflowcmr],
      m("0,1246", "0,0078"),
      m("0,1106", "0,0078"),
      m("0,0987", "0,0038"),
      table.hline(stroke: 0.5pt + black),

      [_PPG-ke-cMRI (53 subjek BIDMC):_], [], [], [],
      [OptiCardio + CMAE (Pre-E2E)\*], m("0,5268", "0,0096"), m("0,5209", "0,0096"), m("0,5238", "0,0084"),
      [OptiCardio + CMAE (Post-E2E)\*], m("0,5056", "0,0088"), m("0,5041", "0,0090"), m("0,5114", "0,0074"),
      [OptiCardio + ECGFlow (Pre, CFG=2,5)],
      m("0,1821", "0,0056", bold: true),
      m("0,1719", "0,0062", bold: true),
      m("0,1623", "0,0060", bold: true),
      [OptiCardio + ECGFlow (Post, CFG=2,5)],
      m("0,1825", "0,0056", ul: true),
      m("0,1726", "0,0059", ul: true),
      m("0,1628", "0,0062", ul: true),
      [OptiCardio + ECGFlow (Post, CFG=10,0)], m("0,2110", "0,0069"), m("0,1980", "0,0081"), m("0,1851", "0,0079"),
    )
    v(2pt)
    align(left, text(
      size: 7.5pt,
    )[\*Untuk varian PPG-ke-cMRI, terbaik pertama di-*_bold_*, kedua di-#underline[_underline_]. CMAE dievaluasi pada ROI aktif `[0:74]` di-_resize_ ke $96 times 96$; ECGFlow _zero-shot_ menggunakan $alpha = 0,8$ dan 25 langkah ODE.])
  },
) <tab:kid_eval>


= Diskusi

Hasil menunjukkan bahwa OptiCardio berhasil membangun koherensi holistik lintas-modal _end-to-end_ di seluruh jalur PPG-ECG-cMRI. Peningkatan tingkat kelulusan dari jalur akuisisi sinyal PPG menunjukkan bahwa perubahan pada prosedur yang diimplementasikan, terutama pada mekanisme deteksi titik fidusial, secara substansial meningkatkan performa ekstraksi PPG di dalam arsitektur. Hal ini terutama penting karena dalam kasus di mana PTT berdampak, jika titik tidak ditentukan dengan akurat, maka surogat _Pulse Arrival Time_ (PAT) untuk sinkronisasi dengan kasus _downstream_ seperti ECG akan mengalami degradasi pula.

Kemudian, _finetuning_ _end-to-end_ yang dijelaskan pada @ftexp memungkinkan model untuk mendapatkan laten yang jauh lebih erat antarmodalitas, sebagaimana ditunjukkan oleh peningkatan metrik pada seluruh evaluasi, baik pada @tab:ecg_all_precision maupun @tab:latent_loss. Dapat dilihat secara spesifik bahwa dengan dilakukannya pelatihan _end-to-end_, terjadi stabilitas ruang laten yang memungkinkan _descent_ pada _backbone_ MCMA lebih stabil dan linear, tanpa mendegradasi performa laten _backbone_ CMAE secara signifikan.

Perlu diperhatikan bahwa walaupun pengujian @tab:ecg_all_precision pada OptiCardio dilakukan pada dua ruang laten, arsitektur harus dievaluasi secara menyeluruh, di mana kedua _backbone_ yang terlibat merupakan bagian dari model yang sama yang dilatih secara _end-to-end_. Dengan @tab:ecg_all_precision menghasilkan peningkatan dari _baseline_ pada kedua _backbone_ menunjukkan bahwa dengan dilakukannya prosedur tuning pada model, keterselarasan antarmodalitas menjadi lebih erat, dengan degradasi yang sangat minor relatif terhadap peningkatan yang terlihat pada hasil kualitatif.

Penambahan beberapa komponen juga terbukti membantu dalam meningkatkan koherensi dan konsistensi representasi. Sebagaimana dalam @fig:samples, _finetuning_ dengan _loss_ berbasis fisiologi ECG sangat membantu. Pada sampel BIDMC10, _finetuning_ menghilangkan inkonsistensi pada inversi _lead_ I. Walaupun mungkin terjadi secara variabilitas anatomis, abnormalitas ini signifikan karena inversi _lead_ I kemungkinan besar mengindikasikan _lead misplacement_ dalam mayoritas kasus (jika bukan, akan mengindikasikan deviasi aksis kanan yang ekstrim). Konsistensi anatomi juga terbantu oleh pelatihan, di mana artefak gelap sebelum pelatihan yang sering terlihat pada ventrikel kiri, sebagaimana @fig:samplesbefore, tereduksi secara signifikan, menghasilkan rekonstruksi cMRI yang lebih jelas secara anatomi.


#figure(
  // placement: top,
  caption: [Metrik Evaluasi Presisi Pencarian #linebreak() (Rerata dengan #sym.plus.minus pada 95% CI dari 30 kali percobaan)],
  {
    set text(size: 8pt)
    table(
      columns: (2.6fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      align: (left, center, center, center, center, center, center, center),
      inset: (x: 4pt, y: 1.8pt),

      // Header
      table.header[*Metode*][*Avg.*][*PVC*][*AFL*][*AFIB*][*SB*][*ST*][*SR*],
      table.hline(stroke: 0.5pt + black),

      // --- P@1 ---
      [_Precision\@1 (%):_], [], [], [], [], [], [], [],
      [OptiCardio (MCMA)],
      m("61,9", "0,4", bold: true),
      m("59,9", "1,0", bold: true),
      m("10,7", "0,3"),
      m("57,1", "0,9"),
      m("80,0", "1,2", ul: true),
      m("91,6", "0,2", bold: true),
      m("72,4", "0,8", bold: true),
      [OptiCardio (CMAE)],
      m("58,1", "0,4"),
      m("57,1", "0,9"),
      m("21,4", "0,4", bold: true),
      m("63,3", "1,1", bold: true),
      m("65,2", "1,3"),
      m("85,0", "0,4"),
      m("56,5", "0,8"),
      [CMAE @Radhakrishnan2023cmae],
      m("51,5", "0,4"),
      m("44,5", "1,4"),
      m("14,2", "0,4", ul: true),
      m("62,2", "0,8", ul: true),
      m("58,5", "1,1"),
      m("79,2", "0,5"),
      m("50,5", "1,2"),
      [MCMA @Chen2024mcma],
      m("58,9", "0,3", ul: true),
      m("58,6", "1,2", ul: true),
      m("13,9", "0,3"),
      m("48,1", "0,9"),
      m("82,8", "1,0", bold: true),
      m("88,3", "0,4", ul: true),
      m("61,6", "0,9", ul: true),
      [MMCL @TURGUT2025mmcl],
      m("46,5", "0,4"),
      m("47,6", "1,2"),
      m("11,7", "0,5"),
      m("54,7", "1,1"),
      m("59,5", "1,4"),
      m("62,4", "0,6"),
      m("43,1", "0,9"),
      [ECGFlowCMR @fang2026ecgflowcmr],
      m("45,5", "0,5"),
      m("43,5", "1,3"),
      m("12,8", "0,4"),
      m("43,6", "0,8"),
      m("67,1", "1,3"),
      m("59,1", "0,6"),
      m("46,7", "0,9"),
      [ECGFounder @Ecgfounder2025Li-aw],
      m("38,0", "0,5"),
      m("33,3", "1,1"),
      m("12,9", "1,1"),
      m("50,2", "0,9"),
      m("49,8", "1,3"),
      m("42,0", "0,6"),
      m("39,6", "1,1"),
      table.hline(stroke: 0.5pt + black),

      // --- P@5 ---
      [_Precision\@5 (%):_], [], [], [], [], [], [], [],
      [OptiCardio (MCMA)],
      m("58,0", "0,2", bold: true),
      m("55,0", "0,5", ul: true),
      m("8,7", "0,2"),
      m("49,1", "0,4"),
      m("78,0", "0,8", ul: true),
      m("87,1", "0,2", bold: true),
      m("70,0", "0,7", bold: true),
      [OptiCardio (CMAE)],
      m("53,9", "0,2", ul: true),
      m("55,6", "0,6", bold: true),
      m("12,8", "0,2", bold: true),
      m("56,3", "0,5", bold: true),
      m("64,0", "0,9"),
      m("82,3", "0,3"),
      m("52,5", "0,5"),
      [CMAE @Radhakrishnan2023cmae],
      m("46,2", "0,2"),
      m("43,4", "0,5"),
      m("7,9", "0,1"),
      m("53,7", "0,4", ul: true),
      m("55,8", "0,8"),
      m("73,0", "0,2"),
      m("43,6", "0,5"),
      [MCMA @Chen2024mcma],
      m("53,2", "0,2"),
      m("48,5", "0,5"),
      m("8,7", "0,2"),
      m("41,5", "0,5"),
      m("79,2", "0,6", bold: true),
      m("84,5", "0,2", ul: true),
      m("56,9", "0,7", ul: true),
      [MMCL @TURGUT2025mmcl],
      m("42,4", "0,2"),
      m("41,7", "0,6"),
      m("11,0", "0,1", ul: true),
      m("45,3", "0,6"),
      m("56,5", "0,9"),
      m("60,1", "0,3"),
      m("40,0", "0,5"),
      [ECGFlowCMR @fang2026ecgflowcmr],
      m("39,0", "0,2"),
      m("35,2", "0,5"),
      m("9,2", "0,2"),
      m("36,6", "0,5"),
      m("62,5", "0,8"),
      m("55,9", "0,3"),
      m("34,9", "0,4"),
      [ECGFounder @Ecgfounder2025Li-aw],
      m("35,0", "0,2"),
      m("34,8", "0,6"),
      m("9,4", "0,2"),
      m("43,3", "0,6"),
      m("48,8", "0,9"),
      m("38,7", "0,3"),
      m("35,3", "0,6"),
      table.hline(stroke: 0.5pt + black),

      // --- P@10 ---
      [_Precision\@10 (%):_], [], [], [], [], [], [], [],
      [OptiCardio (MCMA)],
      m("56,8", "0,1", bold: true),
      m("54,7", "0,3", bold: true),
      m("10,0", "0,1", ul: true),
      m("45,9", "0,4"),
      m("76,2", "0,7", ul: true),
      m("86,1", "0,1", bold: true),
      m("68,0", "0,6", bold: true),
      [OptiCardio (CMAE)],
      m("51,0", "0,2", ul: true),
      m("50,0", "0,4", ul: true),
      m("10,8", "0,1", bold: true),
      m("53,1", "0,5", bold: true),
      m("61,9", "0,8"),
      m("79,4", "0,2"),
      m("50,5", "0,5"),
      [CMAE @Radhakrishnan2023cmae],
      m("43,9", "0,2"),
      m("41,1", "0,4"),
      m("7,0", "0,1"),
      m("51,0", "0,4", ul: true),
      m("54,7", "0,7"),
      m("68,8", "0,2"),
      m("40,6", "0,4"),
      [MCMA @Chen2024mcma],
      m("50,5", "0,1"),
      m("44,3", "0,3"),
      m("8,3", "0,1"),
      m("38,8", "0,4"),
      m("77,1", "0,6", bold: true),
      m("80,8", "0,2", ul: true),
      m("53,9", "0,6", ul: true),
      [MMCL @TURGUT2025mmcl],
      m("40,3", "0,2"),
      m("39,1", "0,4"),
      m("8,5", "0,1"),
      m("42,8", "0,5"),
      m("54,6", "0,7"),
      m("58,6", "0,3"),
      m("38,4", "0,5"),
      [ECGFlowCMR @fang2026ecgflowcmr],
      m("36,8", "0,2"),
      m("34,3", "0,3"),
      m("9,5", "0,1"),
      m("33,8", "0,4"),
      m("59,9", "0,7"),
      m("50,9", "0,4"),
      m("32,1", "0,3"),
      [ECGFounder @Ecgfounder2025Li-aw],
      m("34,2", "0,2"),
      m("34,8", "0,4"),
      m("8,6", "0,1"),
      m("41,3", "0,4"),
      m("47,7", "0,7"),
      m("36,8", "0,2"),
      m("36,0", "0,4"),
    )
    v(2pt)
    align(left, text(size: 8pt)[\*Terbaik pertama di-*_bold_*, kedua terbaik di-#underline[_underline_].])
  },
) <tab:ecg_all_precision>

Kemudian, observasi bahwa ECGFounder menghasilkan performa yang buruk pada evaluasi @tab:ecg_all_precision menunjukkan bahwa ECGFounder, sebagai _foundation model_ _state-of-the-art_ tetap memerlukan pelatihan _head_ tambahan untuk tugas _downstream_ yang memiliki distribusi berbeda untuk mengekstrak fenotipe pada lingkup laten dimensi tinggi, sebagaimana terlihat pada konsistensi laten yang tinggi pada @tab:latent_loss namun performa rendah pada _retrieval_, di mana hal ini akan berdampak pada fleksibilitas aplikasi _downstream_. Sebaliknya, OptiCardio dapat mempreservasi fitur fenotipikal pada ruang laten dengan fidelitas tinggi yang memungkinkan _retrieval_ dengan akurasi tinggi serta mempreservasi rekonstruksi dengan baik pada ruang laten, sehingga dapat dengan lebih fleksibel diintegrasikan dengan kasus _downstream_.

Dari pemeriksaan kualitatif tiap langkah pada @fig:samples dan @fig:samplesbefore, terdapat degradasi minor pada kompleks P dan Q dalam _lead_ II 1-_lead_ yang memengaruhi amplitudonya. Akan tetapi, sebagaimana terlihat pada hasil 12-_lead_ dan penjelasan @qualitative, rekonstruksi sisa 12 _lead_ lebih konsisten secara fisika, sehingga dapat disimpulkan bahwa _optimizer_ menemukan rute yang lebih mudah dengan mengoptimalkan _loss_ dengan "menyembunyikan" informasi rekonstruksi secara _adversarial_ yang mendegradasi 1-_lead_ secara minor untuk membantu rekonstruksi 12-_lead_, sebuah fenomena yang dikenal pada pelatihan berbasis siklus. @chue2017cycleganstego

= Kesimpulan

Penelitian ini menguji kelayakan translasi holistik _end-to-end_ dari PPG ke cMRI melalui implementasi berbasis _deep learning_. Arsitektur penelitian, OptiCardio, mengintegrasikan tiga model yang berbeda, CardioGAN @Sarkar2020CardioGANAG, MCMA @Chen2024mcma, dan CMAE @Radhakrishnan2023cmae, menjadi sebuah model yang secara holistik dapat menerjemahkan tiga modalitas dari PPG, ECG, dan cMRI. Mekanisme akuisisi PPG penelitian yang telah dimodifikasi, memperoleh tingkat kelulusan sebesar 98,5%, jauh di atas _baseline_ @Lovisotto_2020_CVPR_Workshops_seeingred, menunjukkan bahwa mekanisme yang dimodifikasi dapat memberikan akuisisi PPG yang lebih akurat.

Kemudian, _tuning_ konsistensi siklus yang diterapkan juga memperketat ruang laten dari model-model yang diintegrasi, memungkinkan ruang laten pada arsitektur OptiCardio secara keseluruhan meraih performa yang jauh lebih tinggi dalam pengujian laten untuk tugas lanjutan, di mana model secara konsisten menunjukkan peringkat tinggi dalam presisi pencarian patologi, dengan presisi _macro average_ P\@1 61,9%, P\@5 58,0%, dan P\@10 56,8%, serta posisi pertama atau kedua pada seluruh patologi yang diuji. Hal ini terlihat pula pada _loss_ yang lebih stabil pada _backbone_ MCMA dibandingkan _baseline_ saat melakukan pemetaan inversi laten dari ECG ke cMRI.

#block(
  // top,
  // float: true,
  // clearance: 7pt,
  {
    show figure.caption: set text(size: 8.5pt)
    grid(
      columns: (1fr, 1fr),
      gutter: 4mm,
      [
        #figure(
          grid(
            columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
            grid.cell(
              colspan: 6,
              image("after-tuning/signal_all_steps_annotated.png"),
            ),
            image("after-tuning/mri_step_1.png"),
            image("after-tuning/mri_step_2.png"),
            image("after-tuning/mri_step_3.png"),
            image("after-tuning/mri_step_4.png"),
            image("after-tuning/mri_step_5.png"),
            image("after-tuning/mri_step_6.png"),
            // break
            image("after-tuning/mri_flow_step_1.png"),
            image("after-tuning/mri_flow_step_2.png"),
            image("after-tuning/mri_flow_step_3.png"),
            image("after-tuning/mri_flow_step_4.png"),
            image("after-tuning/mri_flow_step_5.png"),
            image("after-tuning/mri_flow_step_6.png"),
          ),
          caption: [Kiri-ke-kanan, atas-ke-bawah: sampel 6 frame terjemahan PPG-ECG-cMRI pada posisi yang telah disinkronisasi dari _pipeline_ OptiCardio setelah tuning _end-to-end_, serta anotasi kompleks PQRST-nya. GIF gambar ini dapat diakses pada https://its.id/m/plot-opticardio.],
        ) <fig:samples>
      ],
      [
        #figure(
          grid(
            columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
            grid.cell(
              colspan: 6,
              image("before-tuning/signal_all_steps_annotated.png"),
            ),
            image("before-tuning/mri_step_1.png"),
            image("before-tuning/mri_step_2.png"),
            image("before-tuning/mri_step_3.png"),
            image("before-tuning/mri_step_4.png"),
            image("before-tuning/mri_step_5.png"),
            image("before-tuning/mri_step_6.png"),
            // break
            image("before-tuning/mri_flow_step_1.png"),
            image("before-tuning/mri_flow_step_2.png"),
            image("before-tuning/mri_flow_step_3.png"),
            image("before-tuning/mri_flow_step_4.png"),
            image("before-tuning/mri_flow_step_5.png"),
            image("before-tuning/mri_flow_step_6.png"),
          ),
          caption: [Kiri-ke-kanan, atas-ke-bawah: sampel 6 frame terjemahan PPG-ECG-cMRI pada posisi yang telah disinkronisasi dari _pipeline_ OptiCardio sebelum tuning _end-to-end_ serta anotasi kompleks PQRST-nya. GIF gambar ini dapat diakses pada https://its.id/m/plot-opticardio.],
        ) <fig:samplesbefore>
      ],
    )
  },
)

Pada hasil kualitatif, terlihat pula bahwa setelah tuning, OptiCardio menghasilkan rekonstruksi yang lebih bersih dari artefak, memiliki konsistensi anatomis pada _cardiac_ MRI, serta memiliki konsistensi yang lebih baik dengan fisiologi ECG nyata pada 12-_lead_. Dengan lebih konsistennya rekonstruksi, beserta dengan ruang laten yang lebih selaras, model akan dapat digunakan pada kasus _downstream_ dengan lebih fleksibel tanpa harus melakukan spesialisasi berlebih.

Akan tetapi, walaupun penelitian berhasil dalam meningkatkan kualitas keterselarasan ruang laten antarmodel serta konsistensi rekonstruksi, perlu dicatat bahwa _tuning_ juga telah berdampak pada kualitas rekonstruksi, sebagaimana terlihat pada degradasi minor pada _lead_ II. Beberapa perbaikan yang dapat diuji pada penelitian lanjutan untuk memitigasi hal tersebut meliputi penggunaan dataset berpasangan _end-to-end_ untuk prosedur _finetuning_, integrasi _discriminator_ dan regularisasi untuk memperketat ruang lingkup eksplorasi dari _optimizer_, ataupun diterapkannya _backbone_ yang lebih kapabel pada rekonstruksi untuk meningkatkan fidelitas cMRI.

#show bibliography: set text(size: 8pt)
#show bibliography: set par(justify: true, first-line-indent: 0pt, leading: 0.30em, spacing: 0.18em)
#bibliography("refs.bib")
