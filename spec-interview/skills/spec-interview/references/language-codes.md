# Supported Languages

The spec-interview skill supports multiple languages. Language is auto-detected from user input.

## Detection Triggers

Look for these keywords (case-insensitive) in user input:

| Language | Triggers |
|----------|----------|
| Turkish | `turkish`, `turkce`, `tr`, `TUR` |
| German | `german`, `almanca`, `deutsch`, `de`, `DEU` |
| Spanish | `spanish`, `espanol`, `ispanyolca`, `es`, `ESP` |
| French | `french`, `francais`, `fransizca`, `fr`, `FRA` |
| Italian | `italian`, `italiano`, `italyanca`, `it`, `ITA` |
| Portuguese | `portuguese`, `portugues`, `portekizce`, `pt`, `POR` |
| Dutch | `dutch`, `nederlands`, `hollandaca`, `nl`, `NLD` |
| Russian | `russian`, `rusca`, `ru`, `RUS` |
| Japanese | `japanese`, `japonca`, `ja`, `JPN` |
| Chinese | `chinese`, `cince`, `zh`, `CHN` |
| Korean | `korean`, `korece`, `ko`, `KOR` |
| Arabic | `arabic`, `arapca`, `ar`, `ARA` |

## Detection Rules

1. Check for explicit language keywords at the end of input
2. Auto-detect if idea/description is written in non-English
3. Look for patterns like "in [language]" or "[language] please"
4. Default to English if unclear

## When Non-English Detected

- Conduct entire interview in that language
- Use that language in all AskUserQuestion options
- Write final spec in that language
- Keep technical terms in English where industry-standard (API, UI, UX, database, etc.)
