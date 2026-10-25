# Book NL project structure

- `main.tex` — full book entry point; includes the planning and LaTeX-cookbook chapter and the combined appendix collection.
- `appendices/appendix-volume.tex` — combined appendix entry point; it collects the independent physiology, pharmacology, and medical microbiology and immunology volumes.
- `appendices/appendix 1: Physiology/physiology-volume.tex` — standalone physiology volume with chapters A1 and A2.
- `appendices/appendix 2: Pharmacology/pharmacology-volume.tex` — standalone pharmacology volume with chapters B1 and B2.
- `appendices/appendix 3: Medical Microbiology and Immunology/medical-microbiology-volume.tex` — standalone volume with chapters C1–C5 on bacteriology, virology, medical mycology, medical parasitology, and immune responses to bacterial infection.
- `chapters/` — independently compilable main-book chapters, including the active planning and LaTeX-cookbook chapter `chapter0.tex`.
- `appendices/` — independently compilable appendix chapters and pharmacology topic files.
- `chapters/images/` — chapter figures; current B1 examples are `b1-expression-distribution-histogram.png` and `b1-gene-transcription-translation-diagram.png`.
- `appendices/appendix 1: Physiology/images/` and `appendices/appendix 2: Pharmacology/images/` — figures for their respective appendix chapters; the A1 membrane-transport figure is chapter-prefixed and descriptive.
- `template/part1a-table-rows.tex` — table-row fragment used by the cookbook chapter; it is not a standalone document.
- `main.bib` — bibliography database shared by the full book and standalone content files.
- `assets/` — active book-cover image and other book assets.
- `archive/unused-covers/` — unused cover designs, named with the `unused-` prefix; duplicates are identified as such.
- `template/` — kaobook class/style support files and custom cover-page definitions.

## Local setup

Extract the complete ZIP archive and keep its directory structure intact. Compile from the `Book NL` folder; the project relies on the adjacent `template/`, `chapters/`, `appendices/`, `assets/`, image folders, and bibliography files. The `archive/` folder holds unused cover designs and is not required for compilation.

The full book requires XeLaTeX, `latexmk`, Biber, MakeIndex, the LaTeX packages used by the kaobook template, and these fonts:

- `Noto Sans Condensed` and `Noto Sans Thai UI` are operating-system fonts. Install both families before compiling; installing only the Latin font causes a missing-font error when Thai text is processed.
- Latin Modern Mono and Latin Modern Math are TeX-distribution fonts. The project loads them by filename, so they do not need to be installed through the operating-system font manager.

Use a complete TeX distribution where possible: MacTeX on macOS or the full TeX Live scheme on Windows/Linux. Minimal installations may be missing `latexmk`, Biber, MakeIndex, Latin Modern, or LaTeX packages required by the template. MiKTeX can install missing packages when prompted, but ensure its package-on-demand option is enabled.

### macOS

- With Homebrew, install the fonts with `brew install --cask font-noto-sans font-noto-sans-thai-ui`.
- Alternatively, download the Noto Sans and Noto Sans Thai UI font families from Google Fonts, open the downloaded `.ttf` files in Font Book, and install them.
- Install MacTeX for XeLaTeX, `latexmk`, Biber, MakeIndex, and the template's LaTeX packages. If you use BasicTeX or another minimal TeX Live installation, install missing packages with `tlmgr`; at minimum, install the Latin Modern font packages with `sudo tlmgr install lm lm-math`.

### Windows

- Download the Noto Sans and Noto Sans Thai UI font families from Google Fonts and extract their archives.
- Select the `.ttf` files for both families, right-click, and choose **Install** (or **Install for all users**). Install the available font styles, including italic and bold variants.
- Install the full TeX Live distribution, or MiKTeX with XeLaTeX, `latexmk`, Biber, MakeIndex, and package-on-demand enabled. If Latin Modern fonts are missing, install TeX Live packages `lm` and `lm-math` with `tlmgr install lm lm-math`, or install those packages through MiKTeX Console. If MiKTeX prompts to install missing packages during compilation, allow it.

### Linux

Install a full TeX Live distribution, including XeLaTeX, `latexmk`, Biber, MakeIndex, and the template's LaTeX packages. Install both Noto font families for your user or system, then refresh the font cache if your distribution requires it.

After installing the Noto fonts, restart your editor or terminal so XeLaTeX can detect them, and confirm both family names appear in the system font manager. Check that the required TeX executables are on your `PATH`:

```sh
command -v xelatex latexmk biber makeindex kpsewhich
```

In Windows PowerShell, use `Get-Command xelatex, latexmk, biber, makeindex, kpsewhich`. Latin Modern fonts are provided by the TeX distribution, not the OS font manager. Check their availability with `kpsewhich lmmono10-regular.otf` and `kpsewhich latinmodern-math.otf`; each command should print a file path. If either returns no path, install the `lm` and `lm-math` packages using the TeX package manager for your distribution. On a standard MacTeX installation, prefix the `tlmgr` command with `sudo`.

Appendix and chapter files detect the master preamble when compiled from the Prism workspace root, the `Book NL` folder, or their own source folder. You can compile the open chapter directly; no editor compiler-path setting is required for standalone previews.

### Compile

Run commands from this folder (`Book NL`). Use XeLaTeX rather than pdfLaTeX, since the preamble uses system fonts and Unicode text.

On macOS or Linux, open Terminal and run:

```sh
cd "/path/to/Book NL"
latexmk -xelatex main.tex
```

On Windows, open PowerShell and run:

```powershell
Set-Location "C:\path\to\Book NL"
latexmk -xelatex main.tex
```

The `latexmk` command above compiles the complete book, rerunning XeLaTeX as needed and invoking Biber and MakeIndex for the bibliography and index. To compile only the appendix collection or a single chapter, use the commands below from the same folder.

The build writes `main.pdf` and temporary LaTeX files beside `main.tex`. The cover is unnumbered; the notice and Creative Commons page includes the build date and is page `i`, followed by the dedication page as `ii`. Front matter continues with lowercase Roman numerals, and the main text restarts at Arabic page `1`.

Compile all appendices together, or each appendix as its own volume:

- `latexmk -xelatex -outdir=build/appendices appendices/appendix-volume.tex`
- `latexmk -xelatex -outdir=build/physiology "appendices/appendix 1: Physiology/physiology-volume.tex"`
- `latexmk -xelatex -outdir=build/pharmacology "appendices/appendix 2: Pharmacology/pharmacology-volume.tex"`
- `latexmk -xelatex -outdir=build/medical-microbiology "appendices/appendix 3: Medical Microbiology and Immunology/medical-microbiology-volume.tex"`

For rapid previews, compile individual chapters directly:

- `latexmk -xelatex -outdir=build chapters/chapter0.tex`
- `latexmk -xelatex -outdir=build "appendices/appendix 1: Physiology/01-physiology-foundations.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 1: Physiology/02-membrane-transport-and-excitability.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 2: Pharmacology/overview-of-pharmacology.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 2: Pharmacology/01-pharmacokinetics.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 2: Pharmacology/02-pharmacodynamics.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 2: Pharmacology/02-safe-prescribing.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 3: Medical Microbiology and Immunology/01-bacteriology.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 3: Medical Microbiology and Immunology/02-virology.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 3: Medical Microbiology and Immunology/03-medical-mycology.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 3: Medical Microbiology and Immunology/04-medical-parasitology.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 3: Medical Microbiology and Immunology/05-immunology-bacterial-infection.tex"`

The cookbook chapter uses self-contained TikZ examples, so it can be compiled to the build folder like other standalone chapters.

Appendix chapters use hierarchical labels A1–A2, B1–B2, and C1–C5, and each chapter starts on a new page with its own margin table of contents. Pharmacokinetics and pharmacodynamics are separate topic files assembled into pharmacology chapter B1; each topic file can also be compiled alone with its wrapper chapter. Thai text can be entered directly; the configured Unicode script switching selects the Thai font automatically.

## Part 1A content-planning table

Chapter 0 presents Part 1A of Medical Council Notification 12/2555 in a multi-page landscape table with repeated column headings. Topic rows live in `template/part1a-table-rows.tex` and follow the source numbering hierarchy and order (for example, B1, B1.1, then B1.1.1). The table uses the landscape page width and omits the source PDF page-number column. Its planning columns are competency/topic, weight, items, and author; weights, item counts, and author assignments are editorial fields rather than values stated in the notification. Row colors retain the source learning-priority distinctions.

## Clinical-correlation boxes

Use `clinicalcorrelation` for an in-text box. With no options, it uses the default “Clinical correlation” title and green colors. Override the title with `frametitle`, and set the body and title-bar colors with `backgroundcolor` and `frametitlebackgroundcolor`:

```latex
\begin{clinicalcorrelation}[
  frametitle={Clinical takeaway},
  backgroundcolor=RoyalBlue!12!White,
  frametitlebackgroundcolor=RoyalBlue!25!White
]
Connect the mechanism to a clinical finding.
\end{clinicalcorrelation}
```

Color values use `xcolor` syntax, so you can choose a named color or mix it with white to make a lighter fill. Set both background keys to keep the body and title bar coordinated.

For a margin box, `\marginclinicalcorrelation` takes the vertical offset first, then the same optional box-style keys, followed by the content in braces:

```latex
\marginclinicalcorrelation[.5cm][
  frametitle={Clinical takeaway},
  backgroundcolor=RoyalBlue!12!White,
  frametitlebackgroundcolor=RoyalBlue!25!White
]{Connect the mechanism to a clinical finding.}
```

Both optional arguments can be omitted; existing calls with only a vertical offset continue to work. See the box examples in `chapters/chapter0.tex` for default, title-only, color-only, and combined styling.
## Chapter templates

Start a new main-book chapter by copying `chapters/chapter-template.tex` to a numbered file in `chapters/`. It contains the shared `subfiles` wrapper, standalone setup, chapter heading, chapter label, and margin table of contents. Update the standalone chapter counter passed to `\standalonechaptersetup{...}` so compiling the chapter by itself gives the correct number; the current template uses `12`, so its standalone chapter is numbered 13. Add the new `\subfile{...}` to `main.tex` when it should appear in the complete book.

For appendices, copy the relevant `chapter-template.tex` within the Physiology, Pharmacology, or Medical Microbiology and Immunology directory. Their appendix groups are `A`, `B`, and `C`, respectively. Change the final numeric argument of `\standaloneappendixchaptersetup{A}{3}`, `{B}{3}`, or `{C}{6}` to the chapter number you want. If the chapter should appear in its appendix volume, add its filename to that volume's `\subfile` list. The templates are intentionally not included in any volume. Keep the source structure and filenames intact so the standalone wrappers can locate `main.tex` and shared assets.

`chapters/chapter0.tex` is the project's copyable LaTeX cookbook and an active planning chapter in the full book. It demonstrates the custom commands and visual conventions below; use the empty template for actual chapter content rather than editing the cookbook into a content chapter.

## Authoring cookbook and custom commands

### Chapter structure and headings

- Begin with `\chapter{...}`, then `\labch{key}` and `\margintoc`. The latter prints a local margin table of contents.
- Use `\section[Short contents title]{Full printed title}` when a long section needs a compact table-of-contents title. `\subsection` supports the same short-title pattern. Add `\labsec{key}` or `\labsubsec{key}` directly after the heading.
- `\addpart{...}` creates a part divider. For standalone source files, use the wrapper pattern in the chapter templates and preserve the `\ifSubfilesClassLoaded` conditional setup.

### Labels and cross-references

Custom label commands prepend a type-specific namespace to the key. Do not include that namespace in the argument:

| Element | Label command | Common reference commands |
| --- | --- | --- |
| Page | `\labpage{key}` | `\refpage{key}`, `\vrefpage{key}` |
| Part | `\labpart{key}` | `\arefpart{key}`, `\avrefpart{key}`, `\refpart{key}`, `\vrefpart{key}`, `\nrefpart{key}`, `\frefpart{key}` |
| Chapter | `\labch{key}` | `\refch{key}`, `\refchshort{key}`, `\vrefch{key}`, `\nrefch{key}`, `\frefch{key}` |
| Section | `\labsec{key}` | `\refsec{key}`, `\refsecshort{key}`, `\vrefsec{key}`, `\nrefsec{key}`, `\frefsec{key}` |
| Subsection | `\labsubsec{key}` | `\refsubsec{key}`, `\refsubsecshort{key}`, `\vrefsubsec{key}`, `\nrefsubsec{key}`, `\frefsubsec{key}` |
| Figure / table | `\labfig{key}`, `\labtab{key}` | `\reffig{key}`, `\reffigshort{key}`, `\vreffig{key}`, `\reftab{key}`, `\vreftab{key}` |
| Equation | `\labeq{key}` | `\refeq{key}`, `\refeqshort{key}`, `\vrefeq{key}` |
| Theorem-like item | `\labdef`, `\labassum`, `\labthm`, `\labprop`, `\lablemma`, `\labremark`, `\labexample`, `\labexercise` | Corresponding `\ref...` and `\vref...` commands, such as `\refdef{key}` and `\refthm{key}` |

For figures and tables, put the label immediately after `\caption` or `\captionof`; for equations and theorem-like blocks, put it inside the numbered environment. Compile enough times for references to resolve. Full helper definitions live in `template/kaorefs.sty`.

### Lists, tables, and figures

- Use ordinary `itemize`, `enumerate`, and `description` environments. The project styles nested bullets and removes excess list spacing by default.
- Use `booktabs` rules (`\toprule`, `\midrule`, `\bottomrule`) in tables. Prefer explicit `p{...}` column widths when cells contain prose. Use `\captionof{table}{...}` for a non-floating table and `\labtab{...}` after its caption.
- Store external graphics in the `images/` folder belonging to their content collection: `chapters/images/` for main-book chapters or the relevant appendix's `images/` folder. Prefix filenames with the chapter identifier (`chapter-0-`, `a1-`, `b1-`, etc.), followed by a concise lowercase, hyphen-separated description of the image. The active cover is `assets/book-cover-minimal-blue-medical-design.png`; unused cover designs are kept in `archive/unused-covers/` with filenames beginning `unused-`.
- Use `\includegraphics[width=\linewidth]{...}` for an external graphic and give it a descriptive `\caption{...}` followed by `\labfig{...}`. Write paths relative to the project root using `\booknlroot`, for example `\includegraphics[width=\linewidth]{\booknlroot chapters/images/chapter-0-example-diagram.png}`. TikZ is already loaded for native vector diagrams and custom shapes.
- `marginfigure` and `margintable` place compact content in the page margin. Keep their contents small enough to fit the margin width. `marginlisting` is provided for a short margin code listing.

### Page layouts and margin elements

- `\pagelayout{margin}` restores the normal text-plus-margin layout; `\pagelayout{wide}` removes the side margin area; `\pagelayout{fullwidth}` selects the full-width layout. Restore the desired layout after a local change.
- Wrap a rotated page in `landscape`. `widepar` extends a paragraph into the outside margin, `fullwidthpar` spans the page width, and `wideequation` wraps a numbered equation at the wider width. Avoid nesting width-changing layouts.
- `\marginnote[<vertical offset>]{...}` places an unnumbered margin note. `\sidenote{...}` creates a numbered sidenote. `\margintoc[<vertical offset>]` creates the chapter's local contents in the margin.

### Boxes and theorem environments

- `kaobox` is a general note box. `clinicalcorrelation` and `testcorrelation` provide the standard clinical and exam callouts. Each accepts the mdframed options such as `frametitle`, `backgroundcolor`, and `frametitlebackgroundcolor`.
- `\marginclinicalcorrelation[<vertical offset>][<box options>]{<body>}` creates a styled clinical box in the margin. `\margintestcorrelation[<vertical offset>]{<body>}` creates the standard test-correlation box in the margin.
- `kaocounter` is a numbered comment box; its counter resets by section.
- Available theorem environments are `theorem`, `proposition`, `lemma`, `corollary`, `definition`, `remark`, `example`, and `exercise`. Their styles and optional framed mode are defined in `template/kaotheorems.sty`.

### Citations and bibliography helpers

The project uses `biblatex` with Biber and the shared `main.bib`. Standard commands include `\cite`, `\parencite`, `\textcite`, and `\supercite`; optional postnotes use biblatex syntax, for example `\parencite[chap.~1]{Costanzo2014BRS}`. Custom margin citation commands are `\sidecite`, `\sidesupercite`, `\sidetextcite`, and `\sideparencite`. Each takes a bibliography key as its required final argument; optional leading arguments control the margin-note offset and citation prenote/postnote. Start with the simple form `\sidecite{Costanzo2014BRS}`. Citation command definitions and exact optional-argument handling are in `template/kaobiblio.sty`.

### Small typography helpers

The preamble defines `\invitro`, `\invivo`, `\cis`, `\trans`, `\etal`, `\denovo`, `\adhoc`, `\etcetera`, `\etc`, `\ie`, `\eg`, `\vs`, and `\cfr` for consistent italicized scientific phrases and abbreviations. `\hairsp` inserts a very small space. `\Command{...}`, `\Class{...}`, `\Package{...}`, `\Option{...}`, `\Environment{...}`, and `\Path{...}` typeset technical identifiers. `\blankpage` inserts a blank page, and `\na` provides an em dash for table cells; `\hangp{...}` and `\hangstar` are compact table-alignment helpers; `\monthyear` prints the current month and year. These definitions are in `template/kao.sty`.

For concrete, compilable examples of lists, TikZ shapes, tables, figures, margin content, boxes, equations, theorem environments, listings, citations, and cross-references, see `chapters/chapter0.tex`.

To compile the empty templates directly from `Book NL`, use the same standalone XeLaTeX workflow as other chapter files:

```sh
latexmk -xelatex -outdir=build chapters/chapter-template.tex
latexmk -xelatex -outdir=build "appendices/appendix 1: Physiology/chapter-template.tex"
latexmk -xelatex -outdir=build "appendices/appendix 2: Pharmacology/chapter-template.tex"
```

The generated files go under `build/`; do not add template source files to the volume `\subfile` lists unless they are first copied and given real chapter content.