/// Helper to format the `Sumber: ...` line inside a 2026 RESISTOR caption.
#let sumber(src) = [\ *Sumber:* #text(weight: "regular", src)]

/// Helper combining a caption title and `Sumber: ...` line.
#let with-source(title, source) = [#title#sumber(source)]

/// Jurnal RESISTOR (Institut Bisnis dan Teknologi Indonesia) 2026 Typst template.
#let resistor(
  title: [Judul Artikel],
  short-title: none,
  authors: (),
  short-authors: none,
  corresponding-email: none,
  received: "Date Month Year",
  accepted: "Date Month Year",
  published: "Date Month Year",
  abstract-id: none,
  keywords-id: (),
  abstract-en: none,
  keywords-en: (),
  // Optional drop-in fallbacks for gemastik.typ
  abstract: none,
  index-terms: (),
  paper-size: "a4",
  bibliography: none,
  // Masthead & running header/footer metadata (2026 defaults)
  logo: image("../assets/resistor-logo.png", width: 49.5mm),
  open-access-logo: image("../assets/open-access.png", width: 28.8mm),
  journal-name: "JURNAL RESISTOR",
  volume-info: "Vol x, Nomor x, Bulan Tahun, hal. xx-yy",
  p-issn: "2598-7542",
  e-issn: "2598-9650",
  doi: "10.31598/resistor.v1i1",
  publisher: "Penerbit Institut Bisnis dan Teknologi Indonesia",
  journal-homepage: "https://ejournal.instiki.ac.id/index.php/jurnalresistor",
  footer-title: "Jurnal RESISTOR",
  footer-issue: "Vol. x Nomor x, Bulan Tahun",
  copyright-year: "2026",
  license-name: "CC-BY-NC-SA 4.0",
  license-url: "https://creativecommons.org/licenses/by-nc-sa/4.0/",
  body,
) = {
  let main-font = "Garamond"
  let meta-font = "Palatino Linotype"
  let link-blue = rgb("#0563c1")
  let blue-link(dest, label) = link(dest, underline(text(fill: link-blue, label)))

  let abs-id = if abstract-id != none { abstract-id } else { abstract }
  let kw-id = if keywords-id != () { keywords-id } else { index-terms }

  let running-title = if short-title != none { short-title } else { title }
  let running-authors = if short-authors != none {
    short-authors
  } else if authors.len() == 0 {
    ""
  } else if authors.len() == 1 {
    authors.first().name
  } else {
    authors.first().name + ", dkk"
  }

  let corr-idx = if authors.len() == 0 {
    none
  } else {
    let found = authors.position(a => a.at("corresponding", default: false) == true)
    if found != none { found } else { 0 }
  }
  let corr-email = if corresponding-email != none {
    corresponding-email
  } else if corr-idx != none {
    authors.at(corr-idx).at("email", default: none)
  } else {
    none
  }

  // Set document metadata.
  set document(title: title, author: authors.map(a => a.name))

  // Base typography and list formatting.
  set text(font: main-font, size: 11pt, fill: black, lang: "id")
  show raw: set text(font: ("Consolas", "Courier New"), size: 9.5pt, ligatures: false)
  set enum(numbering: "1)", indent: 5mm, body-indent: 6pt)
  set list(indent: 5mm, body-indent: 6pt)

  // Page setup: A4, 25mm top/right/bottom, 30mm left, alternating headers & page-specific footers.
  set page(
    paper: paper-size,
    margin: (top: 25mm, right: 25mm, bottom: 25mm, left: 30mm),
    header-ascent: 18%,
    footer-descent: 25%,
    header: context {
      let p = counter(page).get().first()
      if p == 1 {
        none
      } else if calc.even(p) {
        move(dy: 8pt, grid(
          columns: (auto, 1fr),
          align: (left + horizon, right + horizon),
          if open-access-logo != none { open-access-logo },
          text(font: main-font, size: 9pt)[Journal Homepage: #blue-link(journal-homepage, journal-homepage)],
        ))
      } else {
        move(dy: -15pt, grid(
          columns: (1fr, auto),
          align: (left + bottom, right + bottom),
          text(font: main-font, size: 9pt)[#running-title],
          text(font: main-font, size: 9pt)[#running-authors],
        ))
      }
    },
    footer: context {
      let p = counter(page).get().first()
      if p == 1 {
        if corr-email != none {
          move(dy: -6pt, block(width: 100%, {
            set align(left)
            set text(font: ("Baskerville Old Face", main-font), size: 9pt, weight: "regular")
            set par(leading: 0.42em, spacing: 0pt, first-line-indent: 0pt)
            [Penulis korespondensi]
            linebreak()
            let email-link = if type(corr-email) == str {
              blue-link("mailto:" + corr-email, corr-email)
            } else {
              corr-email
            }
            [\*Alamat email: #email-link]
          }))
        }
      } else {
        set align(left)
        set text(font: main-font, size: 10pt, weight: "regular")
        [#p | #footer-title: #footer-issue]
      }
    },
  )

  // Equations: Cambria Math, right-aligned numbering.
  set math.equation(numbering: "(1)")
  show math.equation: set text(font: "Cambria Math", size: 10pt)
  show math.equation: set block(spacing: 1em)

  // Figures and tables (single-column flow).
  show figure: set block(spacing: 12pt)
  show figure.caption: set text(font: main-font, size: 10pt, weight: "bold")
  show figure.caption: set align(center)
  show figure.caption: set par(leading: 0.45em, first-line-indent: 0pt, justify: false)

  show figure.where(kind: table): set figure(supplement: [Tabel], numbering: "1")
  show figure.where(kind: table): set figure.caption(position: top, separator: [. ])

  show figure.where(kind: image): set figure(supplement: [Gambar], numbering: "1")
  show figure.where(kind: image): set figure.caption(position: bottom, separator: [. ])

  // Arabic heading numbering up to 3 levels; Daftar Pustaka / Referensi unnumbered.
  set heading(numbering: (..nums) => {
    let n = nums.pos()
    if n.len() == 1 { str(n.first()) + "." } else { n.map(str).join(".") }
  })

  let unnumbered-titles = (
    [Daftar Pustaka],
    [DAFTAR PUSTAKA],
    [Referensi],
    [REFERENSI],
    [References],
    [REFERENCES],
  )

  show heading: it => context {
    let levels = counter(heading).get()
    let is-special = it.level == 1 and it.body in unnumbered-titles
    let has-num = it.numbering != none and not is-special

    set text(font: main-font, size: 11pt, weight: "bold", fill: black)
    set align(left)

    if it.level == 1 {
      block(above: 14pt, below: 6pt, sticky: true)[#{
        if has-num {
          numbering(it.numbering, ..levels)
          h(4pt)
        }
        it.body
      }]
    } else if it.level == 2 {
      block(above: 10pt, below: 4pt, sticky: true)[#{
        if has-num {
          numbering(it.numbering, ..levels)
          h(4pt)
        }
        it.body
      }]
    } else {
      set text(style: "italic")
      block(above: 8pt, below: 4pt, sticky: true)[#{
        if has-num {
          numbering(it.numbering, ..levels)
          h(4pt)
        }
        it.body
      }]
    }
  }

  // Reference formatting for equations and headings.
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      link(el.location(), numbering(
        el.numbering,
        ..counter(math.equation).at(el.location()),
      ))
    } else if el != none and el.func() == heading and el.numbering != none and not (el.level == 1 and el.body in unnumbered-titles) {
      let nums = counter(heading).at(el.location())
      let prefix = if el.level == 1 { "Bab" } else { "Subbab" }
      link(el.location(), [#prefix #nums.map(str).join(".")])
    } else {
      it
    }
  }

  // --- Page 1 Front Matter ---
  // Masthead placed cleanly above normal 25mm top margin to align with 2026 spec.
  v(-33pt)
  block(above: 0pt, below: 0pt, width: 100%, {
    set block(spacing: 0pt)
    line(length: 100%, stroke: 1pt + rgb("#7f7f7f"))
    v(7pt)
    grid(
      columns: (1fr, auto),
      align: (left + top, right + horizon),
      {
        set text(font: main-font, size: 9pt)
        set par(leading: 0.42em, spacing: 0pt, first-line-indent: 0pt)
        [*#journal-name*]
        linebreak()
        volume-info
        linebreak()
        [P-ISSN: #p-issn | E-ISSN: #e-issn]
        linebreak()
        let doi-url = if type(doi) == str and doi.starts-with("http") { doi } else { "https://doi.org/" + str(doi) }
        emph[DOI: #blue-link(doi-url, doi)]
        linebreak()
        publisher
      },
      if logo != none { logo },
    )
    v(6pt)
    line(length: 100%, stroke: 2.25pt + rgb("#7f7f7f"))
  })

  // Article title (left-aligned, Garamond 14pt Bold).
  block(above: 5pt, below: 0pt, width: 100%, {
    set align(left)
    set par(leading: 0.45em, first-line-indent: 0pt)
    text(font: main-font, size: 14pt, weight: "bold", title)
  })

  // Authors, deduplicated affiliations, emails, WA, and correspondence note (Palatino Linotype).
  if authors.len() > 0 {
    let multi-author = authors.len() > 1
    let unique-affs = ()
    let author-aff-ids = ()

    for a in authors {
      let parts = ()
      for k in ("department", "faculty", "organization", "institution", "address", "location") {
        let val = a.at(k, default: none)
        if val != none { parts.push(val) }
      }
      let aff = if parts.len() > 0 { parts.join(", ") } else { none }
      let explicit-id = a.at("affiliation-id", default: none)

      if aff == none {
        author-aff-ids.push(explicit-id)
      } else {
        let idx = unique-affs.position(x => x == aff)
        if idx == none {
          unique-affs.push(aff)
          author-aff-ids.push(if explicit-id != none { explicit-id } else { unique-affs.len() })
        } else {
          author-aff-ids.push(if explicit-id != none { explicit-id } else { idx + 1 })
        }
      }
    }

    // Author names line
    v(8pt)
    let author-items = authors.enumerate().map(((i, a)) => {
      let is-corr = i == corr-idx
      let aff-id = author-aff-ids.at(i)
      let sup-parts = ()
      if multi-author and aff-id != none { sup-parts.push(str(aff-id)) }
      if is-corr { sup-parts.push([\*]) }
      if sup-parts.len() > 0 {
        [#a.name#super(sup-parts.join())]
      } else {
        [#a.name]
      }
    })
    align(left, {
      set par(first-line-indent: 0pt, leading: 0.45em)
      text(font: meta-font, size: 11pt, weight: "bold", author-items.join(", "))
    })

    // Affiliations block
    if unique-affs.len() > 0 {
      v(5pt)
      align(left, {
        set text(font: meta-font, size: 9pt, style: "italic")
        set par(first-line-indent: 0pt, leading: 0.45em, spacing: 0.25em)
        for (i, aff) in unique-affs.enumerate() {
          if multi-author {
            [#super(str(i + 1)) #aff]
          } else {
            [#aff]
          }
          if i < unique-affs.len() - 1 { linebreak() }
        }
      })
    }

    // Emails, Kontak WA, and corresponding author footnote legend
    let email-items = ()
    let wa-items = ()
    for (i, a) in authors.enumerate() {
      let is-corr = i == corr-idx
      let email-val = a.at("email", default: none)
      if email-val != none {
        let sup-prefix = if multi-author { [#super(str(i + 1)) ] } else { [] }
        let corr-mark = if is-corr { [\*] } else { [] }
        email-items.push([#sup-prefix#email-val#corr-mark])
      }
      let wa-val = a.at("wa", default: a.at("phone", default: none))
      if wa-val != none {
        if multi-author {
          wa-items.push([#wa-val#super(str(i + 1))])
        } else {
          wa-items.push([#wa-val])
        }
      }
    }

    if email-items.len() > 0 or wa-items.len() > 0 or corr-idx != none {
      v(4pt)
      align(left, {
        set text(font: meta-font, size: 9pt, style: "italic")
        set par(first-line-indent: 0pt, leading: 0.48em, spacing: 0pt)
        if email-items.len() > 0 {
          email-items.join(", ")
          linebreak()
        }
        if wa-items.len() > 0 {
          [Kontak WA: #wa-items.join(", ")]
          linebreak()
        }
        if corr-idx != none {
          [\* penulis korespondensi]
        }
      })
    }
  }

  // Info Artikel + Dual-Abstract Table
  {
    let gray-rule = 1pt + rgb("#808080")
    let blue-rule = 1pt + rgb("#2F5496")

    let info-cell = {
      set text(font: main-font, size: 9pt)
      set par(first-line-indent: 0pt, leading: 0.45em, spacing: 0pt)
      [_Article history:_]
      for (label, val) in (("Received", received), ("Accepted", accepted), ("Published", published)) {
        if val != none {
          linebreak()
          [#label #val]
        }
      }
    }

    let license-block = {
      v(4pt)
      align(right, text(font: main-font, size: 10pt)[
        ©#copyright-year Authors. Licensed Under #blue-link(license-url, license-name)
      ])
    }

    let id-cell(with-license: false) = {
      set text(font: main-font, size: 10pt)
      set par(justify: true, first-line-indent: 0pt, leading: 0.36em, spacing: 0.36em)
      abs-id
      if kw-id != () {
        v(4pt)
        align(left)[Kata Kunci: #kw-id.join(", ")]
      }
      if with-license { license-block }
    }

    let en-cell = {
      set text(font: main-font, size: 10pt, lang: "en")
      set par(justify: true, first-line-indent: 0pt, leading: 0.36em, spacing: 0.36em)
      emph[#abstract-en]
      if keywords-en != () {
        v(4pt)
        align(left, text(size: 9pt, style: "italic")[Keywords: #keywords-en.join(", ")])
      }
      license-block
    }

    // Build right-column rows so rowspan adapts cleanly when either abstract is omitted.
    let extra-rows = ()
    if abs-id != none and abstract-en != none {
      extra-rows.push(("cell", id-cell(with-license: false)))
      extra-rows.push(("hline",))
      extra-rows.push(("cell", text(font: main-font, size: 9pt, weight: "bold")[ABSTRACT]))
      extra-rows.push(("hline",))
      extra-rows.push(("cell", en-cell))
    } else if abs-id != none {
      extra-rows.push(("cell", id-cell(with-license: true)))
    } else if abstract-en != none {
      extra-rows.push(("cell", en-cell))
    } else {
      extra-rows.push(("cell", license-block))
    }

    let right-header = if abs-id == none and abstract-en != none {
      [*ABSTRACT*]
    } else {
      [*ABSTRAK*]
    }

    let span = extra-rows.filter(r => r.at(0) == "cell").len()
    let table-items = ()
    let placed-info = false
    for row in extra-rows {
      if row.at(0) == "hline" {
        table-items.push(table.hline(start: 1, stroke: gray-rule))
      } else {
        if not placed-info {
          table-items.push(table.cell(rowspan: span, info-cell))
          placed-info = true
        }
        table-items.push(row.at(1))
      }
    }

    v(8pt)
    table(
      columns: (35%, 65%),
      stroke: none,
      inset: (x: 4pt, y: 3.5pt),
      align: left + top,
      table.hline(stroke: gray-rule),
      text(font: main-font, size: 10pt, weight: "bold")[I#text(size: 8pt)[NFO] A#text(size: 8pt)[RTIKEL]],
      text(font: main-font, size: 10pt, weight: "bold")[#right-header],
      table.hline(stroke: gray-rule),
      ..table-items,
      table.hline(end: 1, stroke: gray-rule),
      table.hline(start: 1, stroke: blue-rule),
    )
  }

  v(4pt)

  // --- Body & Bibliography (Single-column, 5mm first-line indent) ---
  {
    set par(justify: true, first-line-indent: (amount: 5mm, all: true), leading: 0.48em, spacing: 0.48em)

    // Booktabs horizontal-only rules for body tables (scoped after Info Artikel table).
    set table(
      stroke: (_, y) => (
        top: if y == 0 or y == 1 { 0.5pt + black } else { none },
      ),
      inset: (x: 6pt, y: 3pt),
      align: left,
    )
    show figure.where(kind: table): it => {
      set text(size: 10pt)
      show table: t => block(stroke: (bottom: 0.5pt + black), t)
      it
    }

    show std.bibliography: set text(size: 11pt)
    show std.bibliography: set par(justify: true, first-line-indent: 0pt, leading: 0.48em, spacing: 0.75em)
    set std.bibliography(
      title: [Daftar Pustaka],
      style: "ieee",
    )

    body

    if bibliography != none {
      bibliography
    }
  }
}
