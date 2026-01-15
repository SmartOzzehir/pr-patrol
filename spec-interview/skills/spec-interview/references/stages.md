# Interview Stages - Detailed Questions

Full question lists for each of the 8 interview stages.

---

## Stage 1: PROBLEM & VISION

**Goal:** Understand the root problem before jumping to solutions.

### Problem Discovery

- What specific problem or pain point triggered this idea?
- How is this problem currently being solved (workaround)?
- What happens if we don't build this? (Cost of inaction)
- How often does this problem occur?

### Vision & Success

- What does success look like 6 months after launch?
- How will we measure if this feature is successful? (Metrics)
- What would make users say "this is exactly what I needed"?

### Business Context

- What's the business priority? (Must-have vs nice-to-have)
- Any deadlines driving this?
- Budget or resource constraints?

---

## Stage 2: STAKEHOLDERS & USERS

**Goal:** Identify all people affected by this feature.

### Primary Users

- Who will use this feature daily? (Role, not name)
- What's their technical comfort level?
- What devices do they use?
- When/where do they typically work?

### Secondary Stakeholders

- Who else is affected but won't directly use this?
- Who needs to approve or sign off?
- Who will support users if something goes wrong?

---

## Stage 3: FUNCTIONAL REQUIREMENTS

**Goal:** Define concrete actions, inputs, outputs, and business logic.

### Core Actions (CRUD checklist)

- **Create:** What can users create/add?
- **Read:** What information do users need to see?
- **Update:** What can users modify?
- **Delete:** What can users remove?

### Data Requirements

- What information needs to be captured?
- Which fields are required vs optional?
- What validation rules apply?
- Where does the data come from?

### Business Logic

- Any calculations or formulas?
- Any conditional logic?
- Any workflows or approval chains?

### Integrations

- Connect with other systems?
- Import/export requirements?
- Notifications?

---

## Stage 4: UI/UX DESIGN

**Goal:** Define the user interface and experience in detail.

### Layout & Navigation

- Where does this feature live in the app?
- What's the primary layout?
- How do users navigate to this feature?

### State Design (CRITICAL)

- **Loading:** What do users see while data loads?
- **Empty:** What if there's no data yet?
- **Error:** How are errors displayed?
- **Success:** How is success confirmed?
- **Locked:** What if another user is editing?

### Responsive Design

- Must work on mobile? Tablet?
- Different layouts for different screens?

---

## Stage 5: EDGE CASES & ERROR HANDLING

**Goal:** Anticipate and handle exceptional situations.

### Permission & Access

- What if user doesn't have permission?
- Different permission levels?

### Concurrency

- What if two users edit the same thing?
- Locking mechanism needed?

### Data Edge Cases

- What if required data is missing?
- Maximum limits?
- Duplicate handling?

### User Errors

- Undo/redo capabilities?
- Confirmation for destructive actions?
- Auto-save or manual save?

---

## Stage 6: NON-FUNCTIONAL REQUIREMENTS

**Goal:** Define performance, security, and quality expectations.

### Performance

- Acceptable page load time?
- Concurrent users expected?
- Data volume expectations?

### Security

- Sensitivity of data?
- Authentication requirements?
- Audit trail needed?

### Accessibility

- WCAG compliance level?
- Screen reader support?
- Keyboard navigation?

### Compliance

- Regulatory requirements? (GDPR, HIPAA, KVKK)

---

## Stage 7: TECHNICAL ARCHITECTURE

**ALWAYS ask this stage - adapt explanation depth to tech level.**

**Goal:** Capture implementation preferences and constraints.

### Data Storage

- New tables/collections needed?
- Relationship to existing data?
- Caching strategy?

### API Design

- New endpoints needed?
- Rate limiting?

### Integration

- Third-party services?
- Authentication flow?

**For Non-technical users:** Use ELI5 analogies, include "Let the team decide" option.

---

## Stage 8: PRIORITIZATION & PHASING

**Goal:** Break down into manageable phases if needed.

### MoSCoW Prioritization

- **Must have:** Core functionality for MVP
- **Should have:** Important but not blocking
- **Could have:** Nice additions
- **Won't have:** Explicitly out of scope

### Dependencies

- What must exist before this can be built?
- What other features depend on this?

---

## Questioning Techniques

### The 5 Whys

When you get a surface-level answer, dig deeper:

1. "Why is that important?"
2. "Why does that happen?"
3. "Why would users want that?"
4. "Why not do it differently?"
5. "Why is that the constraint?"

### Clarification Pattern

When something is unclear:

```
question: "I want to make sure I understand. When you said '{quote}', did you mean...?"
header: "Clarify"
options:
  - label: "Interpretation A"
    description: "{your understanding 1}"
  - label: "Interpretation B"
    description: "{your understanding 2}"
  - label: "Neither"
    description: "Let me explain differently"
```

### Stage Completion Criteria

**Do NOT move to next stage until:**

- [ ] All questions in current stage are answered
- [ ] No ambiguous or vague answers remain
- [ ] You could explain this to a developer with 100% confidence
- [ ] User has confirmed your understanding
