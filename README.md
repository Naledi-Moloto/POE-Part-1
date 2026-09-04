# RaceDay — Event Management System for South African Road Running, Walking & Cycling Events

RaceDay is a full-stack event management platform built for the South African road running, walking, and cycling community. It allows **Organisers** to create and manage events, categories, and participant results, while **Participants** can browse events, enter events by selecting a category, and track their personal results.

This is an individual Portfolio of Evidence (POE) project, built progressively across three parts:

- **Part 1 (this submission):** System planning — ERD, API endpoint plan, and SQL database script. No application code is written in this part.
- **Part 2:** RESTful API built in C#, connected to the database, with unit tests and GitHub Actions CI/CD.
- **Part 3:** MVC web application consuming the API, with Azure Blob Storage integration and Docker containerisation.

---

## Roles

| Role | Capabilities |
|---|---|
| **Organiser** | Create, edit, and delete events; manage event categories; capture participant results; view all enrolments for their events. |
| **Participant** | Create an account; browse events; enter an event by selecting a category; view their own enrolments and results. |

Organisers and Participants are kept **fully separate at the data level** — they are stored in two independent database tables (`Organisers` and `Participants`), not a single `Users` table with a role flag. There is no shared table or direct relationship between the two; they only connect indirectly through the Events → Categories → Enrolments chain. This separation is enforced consistently through the ERD, the API endpoint plan, and the SQL script.

Role-based access is planned at the API level in Section B, and will be enforced in the API (Part 2) and reflected in the MVC interface (Part 3).

---

## Repository Structure

```
/docs
  ├── RaceDay-ERD.pdf                       -> Section A: Entity Relationship Diagram
  ├── Section-B-API-Endpoint-Plan.pdf       -> Section B: API Endpoint Plan
  ├── Section-B-API-Endpoint-Plan.md        -> Section B (Markdown version, renders on GitHub)
  ├── RaceDayDB.sql                         -> Section C: SQL Database Script
README.md                                   -> This file
```

---

## Section A — Entity Relationship Diagram

The ERD (`/docs/RaceDay-ERD.pdf`) contains **7 entities**: **Organisers, Participants, Venues, Events, Categories, Enrolments, Results**.

- `Organisers` and `Participants` are two fully independent tables — each with their own primary key sequence, their own attributes, and no foreign key linking them to one another. This reflects a requirement that the two user types be kept structurally separate, rather than combined into a single `Users` table distinguished by a `Role` column.
- `Enrolments` resolves the many-to-many relationship between Participants and Categories — a Participant can enrol in many categories, and a category can have many enrolled participants.
- `Results` has a 1-to-0..1 relationship with `Enrolments` — a result only exists once a Participant has completed (or not finished) their event. Each Result also links to the `Organiser` who captured it.

### Relationship summary
| Relationship | Cardinality |
|---|---|
| Organisers → Events | 1 : many |
| Venues → Events | 1 : many |
| Events → Categories | 1 : many |
| Participants → Enrolments | 1 : many |
| Categories → Enrolments | 1 : many |
| Enrolments → Results | 1 : 0..1 |
| Organisers → Results | 1 : many (who captured the result) |

### Deliberate deviations from a "pure" 1:1 diagram
- No `Roles` lookup table or `Role` column exists anywhere — role separation is achieved entirely through separate tables (`Organisers` vs `Participants`).
- Business-rule constraints (`UNIQUE(ParticipantID, CategoryID)` on Enrolments, `UNIQUE(EnrolmentID)` on Results) are defined in the SQL script but may not visually render as a distinct symbol on the ERD diagram itself, depending on the diagramming tool. They are documented here and enforced in Section C.

---

## Section B — API Endpoint Plan

The full endpoint plan (`/docs/Section-B-API-Endpoint-Plan.pdf` or `.md`) contains **27 endpoints** across Authentication, Organiser Profile, Participant Profile, Venues, Events, Categories, Enrolments, and Results.

Key design points, since the implemented API in Part 2 should closely match this plan:

- **Separate Auth and Profile endpoints per role**: because Organisers and Participants live in two separate tables, there is no shared `/api/auth/register`, `/api/auth/login`, or `/api/users/me`. Instead: `/api/auth/organiser/register` and `/api/auth/participant/register`; `/api/auth/organiser/login` and `/api/auth/participant/login`; `/api/organisers/me` and `/api/participants/me`. This keeps the two user types separate end-to-end, from database to API surface.
- **Venues endpoints** (`GET /api/venues`, `POST /api/venues`) were added beyond the literal functional requirements list. They exist because `Events.VenueID` is a foreign key in the ERD — without these endpoints, there would be no way to view or create a Venue for an Organiser to link an Event to.
- **`distanceKM` on Events**: the functional requirements state that each Event must capture a distance. Since Categories already have their own `DistanceKM` (e.g. a single event can have a 10km and a 21km category), a separate, nullable `DistanceKM` was added to `Events` itself to represent the event's main/advertised distance, without conflicting with per-category distances.

Sources referenced for endpoint design conventions (see the endpoint plan document for details):
- Microsoft REST API Guidelines — github.com/microsoft/api-guidelines
- Microsoft Learn, "Authentication and authorization in ASP.NET Core" — learn.microsoft.com/aspnet/core/security/
- MDN Web Docs, "HTTP response status codes" — developer.mozilla.org/en-US/docs/Web/HTTP/Status
- OWASP REST Security Cheat Sheet — cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html

---

## Section C — SQL Database Script

The full script (`/docs/RaceDayDB.sql`) creates the `RaceDayDB` database and matches the ERD in Section A exactly — 7 tables, same attributes, same primary/foreign keys, with `Organisers` and `Participants` as two fully separate tables (no shared `Users` table).

### Running the script
1. Open **SQL Server Management Studio (SSMS)** and connect to a local or clean SQL Server instance.
2. Open `RaceDayDB.sql`.
3. Execute the entire script (it will create the database, all 7 tables, and seed sample data in one run).
4. Verify with `SELECT * FROM Organisers;` and `SELECT * FROM Participants;` that the seed data loaded correctly into both tables independently.

### Seed data included
- 2 Organisers, 2 Participants (in two separate tables, each with their own ID sequence)
- 3 Venues (Pietermaritzburg, Cape Town, Soweto)
- 3 Events (Comrades Marathon, Cape Town Cycle Tour, Soweto Charity Fun Walk) — one of each `EventType` (Run, Cycle, Walk)
- 6 Categories (2 per event)
- 4 Enrolments
- 3 Results, including one **DNF** result that records `DistanceCoveredKM` instead of a `FinishTime`, demonstrating that the Results table supports both outcome types

---
---

## Commit History

This repository contains a minimum of 20 meaningful commits, tracking the incremental development of the ERD, endpoint plan, and SQL script across Part 1 — including the later revision that split the single `Users` table into separate `Organisers` and `Participants` tables.

---

## Author

Naledi — Part 1 of the RaceDay POE.

