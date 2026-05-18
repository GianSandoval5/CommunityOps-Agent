# Agent Workflows

## Workflow: Plan Meetup

Input:

```txt
Organize a Flutter Piura meetup for 80 people about Flutter + AI.
Budget: S/500.
Needs: 2 talks, coffee break, certificates.
```

Steps:

1. Parse event requirements.
2. Query previous events and feedback.
3. Query available speakers by topic and availability.
4. Query sponsors with compatible sponsorship history.
5. Build event agenda.
6. Calculate readiness score.
7. Detect risks.
8. Generate tasks.
9. Draft messages.
10. Ask for approval.

Output before approval:

- Proposed event record.
- Recommended agenda.
- Speaker shortlist.
- Sponsor follow-up.
- Risk score.
- Task list.
- Message drafts.
- Approval checkpoint.

## Workflow: Execute Approved Plan

Steps:

1. Confirm approval.
2. Insert event document.
3. Insert tasks.
4. Insert message drafts.
5. Insert agent run log.
6. Insert approval record.
7. Return execution summary.

Important rule:

The agent must not perform important writes without approval.
