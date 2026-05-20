#!/usr/bin/env python3
"""Generate PDF from docs/SECURITY_REPORT.md."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MD = ROOT / "docs" / "SECURITY_REPORT.md"
PDF = ROOT / "docs" / "SECURITY_REPORT.pdf"


def generate_with_fpdf(text: str) -> None:
    from fpdf import FPDF

    pdf = FPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()
    w = pdf.w - pdf.l_margin - pdf.r_margin

    in_mermaid = False
    for line in text.splitlines():
        if line.strip().startswith("```mermaid"):
            in_mermaid = True
            continue
        if in_mermaid:
            if line.strip() == "```":
                in_mermaid = False
            continue
        if line.strip().startswith("```"):
            continue

        safe = line.encode("latin-1", errors="replace").decode("latin-1")
        if line.startswith("# "):
            pdf.set_font("Helvetica", style="B", size=14)
            pdf.multi_cell(w, 8, safe[2:])
            pdf.set_font("Helvetica", size=10)
        elif line.startswith("## "):
            pdf.set_font("Helvetica", style="B", size=12)
            pdf.multi_cell(w, 7, safe[3:])
            pdf.set_font("Helvetica", size=10)
        elif line.startswith("|"):
            pdf.set_font("Courier", size=8)
            pdf.multi_cell(w, 4, safe)
            pdf.set_font("Helvetica", size=10)
        elif line.strip():
            pdf.multi_cell(w, 5, safe)
        else:
            pdf.ln(2)

    pdf.output(str(PDF))
    print(f"Wrote {PDF}")


def main() -> None:
    if not MD.exists():
        raise SystemExit(f"Missing {MD}")
    generate_with_fpdf(MD.read_text(encoding="utf-8"))


if __name__ == "__main__":
    main()
