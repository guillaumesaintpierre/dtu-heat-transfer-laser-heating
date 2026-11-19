# Contributions and disclosure

## Group authors (DTU 41814, October 2026)

- **Guillaume Saint-Pierre:** contributed to the MATLAB implementation; carried out the baseline 50-second simulation and comparison with the semi-infinite analytical result (assignment part j); helped prepare and review the report.
- **Manuel Belanger:** selected material properties; contributed to derivation of node balances; report preparation.
- **Quentin Paphassarang:** absorbed laser flux, 2D-to-1D reasoning, analytical validation, report preparation.
- **Josephine Savier:** shielding-gas convection model, temperature-field and centreline visualisations, result interpretation.
- **Osric Shaun King Jr.:** hand derivation of energy-balance and explicit stability conditions.

The items above are based on the explicit allocation in Section 12 of the submitted report; no individual claims are made about code lines or tasks beyond those described there. The project is group coursework, not a solo personal project.

## AI-use disclosure from the original report

Section 13 of the group report expressly states that **Claude (Anthropic)** was used for assistance in checking derivations and coefficient tables, writing the MATLAB script in Appendix A, generating figures, locating sources and LaTeX formatting. The report authors retain responsibility for the submitted work. This repository preserves that declaration rather than treating the original implementation as independently authored without assistance.

The standalone `matlab/laser_heating_fvm.m` file is a **cleaned transcription** of the code printed in the team report's Appendix A. The numerical scheme is reproduced but the source has not been compared byte-for-byte against the original `.m` file. An independent NumPy check was added when preparing this GitHub edition and should not be represented as original coursework.

## Privacy and sharing

The PDF in `report/` is derived from the group's original submitted PDF with student administration numbers removed. Contributors' names, methodology, figures, citations and AI declaration remain. The course assignment PDF is not bundled, as it is a staff-authored teaching document. Confirm group members' consent before publishing the whole report and collectively produced script under an open repository.
