# Changelog

All notable changes to the spec-interview plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2026-01-15

### Added
- **Smart Skipping** - Automatically skips clearly defined sections, focuses interview on gaps
- **Pre-Interview Analysis** - Classifies each stage as CLEAR/UNCLEAR/MISSING before asking questions
- **Context Awareness** - Scans project for tech stack, similar specs, and patterns to avoid redundant questions
- **Complexity Analysis** - Calculates complexity score and warns if scope too large (score > 30)
- **Split Recommendations** - Suggests phasing options (by priority or component) for high-complexity features
- **Enhanced Validation Phase** - 14-category best practices checklist after interview completion
- **Output Options** - User chooses save location with intelligent recommendations
- New reference files:
  - `references/validation-checklist.md` (219 lines, 14 categories with severity levels)
  - `references/analysis-patterns.md` (306 lines, classification criteria and complexity scoring)

### Changed
- Execution flow now includes 10 steps (was 7)
- Spec template expanded to 14 sections (added Assumptions & Constraints)
- Interview stages can be skipped if file analysis shows CLEAR status
- Synthesis phase now leads to Validation phase before writing

### Removed
- `allowed-tools` field from skill frontmatter (was deprecated in v2.0.0)

## [2.0.0] - 2026-01-14

### Added
- **8-Stage Methodology** - Expanded from 5 stages to 8 for more comprehensive coverage
  - Stage 6: Non-Functional Requirements (performance, security, accessibility)
  - Stage 8: Prioritization & Phasing (MoSCoW, MVP definition)
- **Phase 0: Calibration** - Mandatory first step that assesses technical level and confirms understanding
- **Synthesis Phase** - Summarizes decisions in a table, flags conflicts/gaps, gets user confirmation
- **12+ Language Support** - Auto-detection for Turkish, German, Spanish, French, Italian, Portuguese, Dutch, Russian, Japanese, Chinese, Korean, Arabic
- **Adaptive Technical Depth** - Questions and explanations adapt based on user's technical proficiency
- **5 Whys Technique** - Built-in guidance for deeper requirement discovery
- **File Mode Error Handling** - Graceful handling of missing, empty, or unexpected files
- **Comprehensive Spec Template** - 13-section output format with detailed structure

### Changed
- Language detection is now automatic (no explicit argument needed)
- Progress tracking simplified from ASCII art to plain text format
- AskUserQuestion examples now include `multiSelect` field consistently
- All headers now comply with 12-character limit
- Template placeholders standardized to `{{placeholder}}` format

### Fixed
- "Concurrent Edit" header exceeded 12-character limit (now "Concurrency")
- Missing `multiSelect` field in 8 of 10 AskUserQuestion examples
- False claim about "Other" option being auto-added by AskUserQuestion
- "Store" vs "Remember" state guidance (model cannot persist state)
- Unverified "37% more requirements" statistic removed
- Documentation inconsistencies between README, command, and skill files

### Removed
- `allowed-tools` field from skill frontmatter (deprecated)
- Explicit language argument `[ENG|TUR]` (now auto-detected)
- ASCII art boxes and visual sketches (replaced with blockquotes)

## [1.0.0] - 2025-12-01

### Added
- Initial release
- 5-stage interview methodology
- FILE and IDEA input modes
- English and Turkish language support
- Basic spec document generation
