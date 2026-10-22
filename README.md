# Book NL project structure

- `main.tex` — full book entry point; includes the draft/debug chapter and the combined appendix collection.
- `appendices/appendix-volume.tex` — combined appendix entry point; it collects the independent physiology and pharmacology appendix volumes.
- `appendices/appendix 1: Physiology/physiology-volume.tex` — standalone physiology volume with chapters A.1 and A.2.
- `appendices/appendix 2: Pharmacology/pharmacology-volume.tex` — standalone pharmacology volume with chapters B.1 and B.2.
- `chapters/` — independently compilable main-book chapters, including the active draft/debug chapter `chapter0.tex`.
- `appendices/` — independently compilable appendix chapters and pharmacology topic files.
- `template/part1a-table-rows.tex` — table-row fragment used by the debug chapter; it is not a standalone document.
- `main.bib` — bibliography database shared by the full book and standalone content files.
- `assets/` — images and other book assets.
- `template/` — kaobook class/style support files and custom cover-page definitions.

Appendix and chapter files detect the master preamble when compiled from the Prism workspace root, the `Book NL` folder, or their own source folder. You can compile the open chapter directly; no editor compiler-path setting is required for standalone previews.

Run commands from this folder. Compile the complete book with XeLaTeX/latexmk:

`latexmk -xelatex main.tex`

Compile all appendices together, or each appendix as its own volume:

- `latexmk -xelatex -outdir=build/appendices appendices/appendix-volume.tex`
- `latexmk -xelatex -outdir=build/physiology "appendices/appendix 1: Physiology/physiology-volume.tex"`
- `latexmk -xelatex -outdir=build/pharmacology "appendices/appendix 2: Pharmacology/pharmacology-volume.tex"`

For rapid previews, compile individual chapters directly:

- `latexmk -xelatex -outdir=build chapters/chapter0.tex`
- `latexmk -xelatex -outdir=build "appendices/appendix 1: Physiology/01-physiology-foundations.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 1: Physiology/02-membrane-transport-and-excitability.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 2: Pharmacology/overview-of-pharmacology.tex"`
- `latexmk -xelatex -outdir=build "appendices/appendix 2: Pharmacology/02-safe-prescribing.tex"`

Appendix chapters use hierarchical labels A.1, A.2, B.1, and B.2, and each chapter starts on a new page with its own margin table of contents. Pharmacokinetics and pharmacodynamics are separate topic files assembled into pharmacology chapter B.1; each topic file can also be compiled alone with its wrapper chapter. Thai text can be entered directly; the configured Unicode script switching selects the Thai font automatically.