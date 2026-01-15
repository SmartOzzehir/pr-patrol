# Specification Document Template

Use this template when writing the final specification document.

---

```markdown
# [Feature Name]

> **Status:** Draft | In Review | Approved
> **Author:** [Name]
> **Last Updated:** [Date]
> **Version:** 1.0

---

## 1. Executive Summary

[2-3 sentence overview of what this feature does and why it matters]

**Success Metrics:**
- [Metric 1]: [Target]
- [Metric 2]: [Target]

---

## 2. Problem Statement

### Current State
[How things work today / the pain point]

### Desired State
[How things should work after this feature]

### Cost of Inaction
[What happens if we don't build this]

---

## 3. User Personas

### Primary: [Role Name]
- **Goals:** [What they want to achieve]
- **Frustrations:** [Current pain points]
- **Tech Level:** [Non-technical / Somewhat / Very]
- **Usage:** [Daily / Weekly / Monthly]

### Secondary: [Role Name] (if applicable)
[Same format]

---

## 4. User Stories

### Must Have (P0)
- [ ] As a [role], I want to [action] so that [benefit]
- [ ] As a [role], I want to [action] so that [benefit]

### Should Have (P1)
- [ ] As a [role], I want to [action] so that [benefit]

### Could Have (P2)
- [ ] As a [role], I want to [action] so that [benefit]

### Out of Scope
- [Explicitly excluded item 1]
- [Explicitly excluded item 2]

---

## 5. Functional Requirements

### 5.1 Core Features

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-1 | [Description] | P0 | [How to verify] |
| FR-2 | [Description] | P0 | [How to verify] |

### 5.2 Data Requirements

| Field | Type | Required | Validation | Source |
|-------|------|----------|------------|--------|
| [name] | [type] | Yes/No | [rules] | [where from] |

### 5.3 Business Logic

```
IF [condition]
THEN [action]
ELSE [alternative]
```

### 5.4 Integrations

| System | Type | Purpose | Notes |
|--------|------|---------|-------|
| [Name] | Import/Export/API | [Why] | [Details] |

---

## 6. UI/UX Specifications

### 6.1 Information Architecture

[Where this feature lives in the navigation]

### 6.2 Layout

```
[ASCII diagram or description]
```

### 6.3 Component Specifications

| Component | Behavior | Notes |
|-----------|----------|-------|
| [Name] | [How it works] | [Details] |

### 6.4 States

| State | Trigger | Display | User Action |
|-------|---------|---------|-------------|
| Loading | Data fetching | Skeleton/spinner | Wait |
| Empty | No data exists | Empty state message + CTA | Create first item |
| Error | Request failed | Error message | Retry/contact support |
| Success | Action completed | Toast notification | Dismiss/continue |
| Locked | Another user editing | Lock badge + message | Wait or notify |

### 6.5 Responsive Behavior

| Breakpoint | Layout Changes |
|------------|----------------|
| Desktop (>1024px) | [Default layout] |
| Tablet (768-1024px) | [Adjustments] |
| Mobile (<768px) | [Mobile layout] |

---

## 7. Edge Cases & Error Handling

| Scenario | Expected Behavior | Error Message |
|----------|-------------------|---------------|
| [Edge case 1] | [How system responds] | [User-facing message] |
| [Edge case 2] | [How system responds] | [User-facing message] |

---

## 8. Non-Functional Requirements

### Performance
- Page load time: < [X] seconds
- API response time: < [X] ms
- Concurrent users supported: [N]

### Security
- Authentication: [Required/Not required]
- Authorization: [Role-based access details]
- Audit logging: [Yes/No, what's logged]
- Data sensitivity: [Public/Internal/Confidential/Restricted]

### Accessibility
- WCAG Level: [A/AA/AAA]
- Keyboard navigation: [Required/Not required]
- Screen reader support: [Required/Not required]

### Compliance
- [Regulation]: [Requirement]

---

## 9. Technical Notes

[Implementation guidance for developers - only if technical interview was conducted]

### Suggested Approach
- [Technical recommendation 1]
- [Technical recommendation 2]

### Known Constraints
- [Constraint 1]
- [Constraint 2]

---

## 10. Dependencies

### Requires Before Start
- [ ] [Dependency 1]
- [ ] [Dependency 2]

### Blocks Other Work
- [What this feature unblocks]

---

## 11. Phasing (if applicable)

### Phase 1: MVP ([Target Date])
- [Scope item 1]
- [Scope item 2]

### Phase 2: Enhancement ([Target Date])
- [Scope item 1]
- [Scope item 2]

---

## 12. Open Questions

| Question | Owner | Due Date | Status |
|----------|-------|----------|--------|
| [Question] | [Who decides] | [When] | Open/Resolved |

---

## 13. Appendix

### A. Glossary
- **[Term]:** [Definition]

### B. References
- [Link to related doc]
- [Link to design mockup]

### C. Revision History
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [Date] | [Name] | Initial draft |
```
