#import "@local/resistor:0.1.0": resistor, sumber, with-source

#show: resistor.with(
  title: [Judul Artikel, Huruf Awal Kapital, Kecuali Kata Sambung],
  short-title: [Judul Artikel],
  authors: (
    (
      name: "Nama Penulis Pertama",
      department: "Program Studi",
      faculty: "Fakultas",
      organization: "Nama Institusi",
      address: "Kota, Negara",
      email: "penulis1@domain.ekstensi",
      wa: "081234567890",
      corresponding: true,
    ),
    (
      name: "Penulis Kedua",
      department: "Program Studi",
      faculty: "Fakultas",
      organization: "Nama Institusi Lain",
      address: "Kota, Negara",
      email: "penulis2@domain.ekstensi",
      wa: "081234567891",
    ),
    (
      name: "Penulis Ketiga",
      department: "Program Studi",
      faculty: "Fakultas",
      organization: "Nama Institusi",
      address: "Kota, Negara",
      email: "penulis3@domain.ekstensi",
    ),
  ),
  short-authors: "Penulis Pertama, dkk",
  received: "Date Month Year",
  accepted: "Date Month Year",
  published: "Date Month Year",
  abstract-id: [
    Abstrak ditulis dalam Bahasa Indonesia dan Bahasa Inggris. Abstrak terdiri dari 150--200 kata yang diikuti setidaknya 3--5 kata kunci. Abstrak memuat secara jelas ringkasan permasalahan penelitian, tujuan penelitian, metode, hasil, dan simpulan. Bagian akhir abstrak memuat kesimpulan secara menyeluruh atau tentang pentingnya hasil penelitian.
  ],
  keywords-id: ("kata kunci pertama", "kata kunci kedua", "kata kunci ketiga"),
  abstract-en: [
    Abstracts are written in Indonesian and English. Each abstract consists of 150--200 words followed by at least 3--5 keywords. The abstract contains a clear summary of the research problem, research objectives, methods, results, and conclusions. The final part of the abstract contains overall conclusions or about the importance of the research results.
  ],
  keywords-en: ("first keyword", "second keyword", "third keyword"),
  bibliography: bibliography("refs.bib"),
)

= Pendahuluan <sec-pendahuluan>

Pendahuluan berisi latar belakang penelitian, teori dasar, masalah penelitian, solusi penelitian, dan tujuan penelitian. Pendahuluan tidak memuat gambar, tabel, atau poin-poin dan penomoran.

Penulis disarankan untuk menggunakan struktur makalah berikut ini: *1. Pendahuluan, 2. Metode Penelitian, 3. Hasil dan Pembahasan, 4. Kesimpulan, 5. Ucapan Terima Kasih (jika ada), 6. Daftar Pustaka*. Pendahuluan menjawab *1) latar belakang penelitian, 2) karya-karya terkait @brown2021, 3) solusi yang ditawarkan, dan 4) state of the art/analisis kesenjangan/kebaruan*. Hindari menjelaskan definisi dan teori secara umum.

= Metode Penelitian <sec-metode>

Bagian ini berisi uraian secara lengkap dan rinci mengenai langkah-langkah penelitian. Dalam menguraikan langkah-langkah penelitian dapat ditunjukkan dalam bentuk *diagram alir penelitian atau kerangka kerja penelitian secara lengkap dan rinci termasuk algoritma, aturan, pemodelan, desain, dan aspek perancangan sistem lainnya*. Pada bagian ini juga dijelaskan teknik pengumpulan data dan analisis data dari penelitian yang dilakukan @pratama2024.

Angka Arab digunakan untuk memberi label pada setiap tabel. Judul tabel diposisikan di atas tabel. Untuk membedakan judul kolom dari badan tabel, digunakan garis horizontal di bagian atas, bawah kepala kolom, dan bawah tabel, seperti terlihat pada @tbl-atribut.

#figure(
  table(
    columns: (22mm, 46mm, 22mm),
    [Atribut], [Definisi], [Skala Nilai],
    [Atribut 1], [Ini adalah alternatif nomor 1], [2],
    [Atribut 2], [Ini adalah alternatif nomor 2], [4],
    [Atribut 3], [Ini adalah alternatif nomor 3], [6],
  ),
  caption: [Contoh tabel atribut.],
) <tbl-atribut>

Setiap gambar harus jelas dan tidak buram dalam format JPEG atau PNG. Contoh gambar beserta keterangan sumber disediakan pada @fig-penelitian di bawah ini:

#figure(
  rect(
    width: 102mm,
    height: 46mm,
    stroke: 0.6pt + black,
    align(center + horizon)[
      #text(size: 10pt, fill: luma(90))[Ilustrasi / Gambar Penelitian]
    ],
  ),
  caption: with-source([Penelitian Mahasiswa], [Penulis, 2025]),
) <fig-penelitian>

Semua persamaan dibuat dalam format persamaan, bukan gambar tangkapan layar, dan diberi penomoran di sisi kanan persamaan, seperti @eq-area berikut ini:

$ A = pi r^2 $ <eq-area>

= Hasil dan Pembahasan <sec-hasil>

Hasil dan Pembahasan merupakan bagian yang memuat semua temuan ilmiah yang diperoleh sebagai data penelitian. Bagian ini diharapkan dapat memberikan penjelasan ilmiah yang secara logis dapat menjelaskan alasan diperolehnya hasil tersebut yang diuraikan secara jelas, lengkap, rinci, terpadu, sistematis, dan berkesinambungan.

Pembahasan hasil penelitian yang diperoleh dapat disajikan dalam bentuk uraian teoritis, baik secara kualitatif maupun kuantitatif. Dalam praktiknya, bagian ini dapat digunakan untuk membandingkan hasil penelitian yang diperoleh dalam penelitian saat ini dengan hasil penelitian yang dilaporkan oleh peneliti terdahulu @smith2023. Secara ilmiah, hasil penelitian yang diperoleh dapat berupa *temuan baru/kebaruan atau perbaikan*, penegasan, atau penolakan terhadap suatu fenomena ilmiah dari peneliti sebelumnya, sebagaimana mengacu pada @sec-pendahuluan.

== Evaluasi Kinerja <sec-evaluasi>

Contoh subbab tingkat kedua menggunakan penomoran Arab bertingkat.

=== Uji Statistik <sec-statistik>

Contoh subbab tingkat ketiga untuk analisis tambahan bila diperlukan.

= Kesimpulan <sec-kesimpulan>

Kesimpulan ditulis dalam bentuk paragraf, dan berisi pernyataan yang menjawab masalah berdasarkan temuan penelitian. Kesimpulan tidak boleh berisi referensi apa pun, tanpa bullet dan numbering. Jika perlu, berikan *saran penelitian lebih lanjut*.

= Ucapan Terima Kasih <sec-ucapan>

Bagian Ucapan Terima Kasih bersifat opsional, yang disajikan untuk mengungkapkan rasa terima kasih penulis kepada individu atau institusi atau pihak-pihak yang telah memberikan dukungan, bimbingan, atau sumber daya selama penelitian. Penulis mengakui kontribusi yang berharga ini, mulai dari bimbingan akademik, dukungan finansial, hingga bantuan teknis. Ucapan terima kasih juga disampaikan kepada para kolaborator, pembimbing, dan pihak-pihak lain yang telah membantu menyukseskan penelitian ini.
