# Tool Contract

These are the intended tool-level capabilities exposed through Google Cloud Agent Builder and MongoDB MCP.

## read_previous_events

Reads historical events, attendance, topics, feedback, and outcomes.

## find_relevant_speakers

Finds speakers by topic, availability, rating, and historical participation.

## find_sponsor_candidates

Finds sponsors by status, sponsorship type, previous support, and contact priority.

## create_event_plan

Creates agenda, readiness score, risks, tasks, and drafts.

## request_human_approval

Stops execution and asks the organizer to confirm important writes.

## create_event

Creates an event document in MongoDB after approval.

## create_tasks

Creates operational tasks for the approved event.

## create_message_drafts

Creates message drafts without sending them.

## record_agent_run

Persists the run steps, tool calls, approval status, and execution summary.
