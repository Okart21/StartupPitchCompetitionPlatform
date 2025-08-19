# Startup Pitch Competition Platform

A decentralized smart contract system for evaluating and backing startup pitches in investment competitions.

## Overview

The Pitch Competition platform allows investors to evaluate startup pitches and express their backing decisions transparently. Each investor can back one startup per competition round, creating a fair and democratic selection process.

## Features

- **Pitch Submission**: Startups can submit their pitches to the competition
- **Investor Backing**: Qualified investors can back one startup per round
- **Transparent Evaluation**: All backing decisions are recorded on-chain
- **Competition Tracking**: Real-time tracking of pitch performance and investor interest

## Smart Contract Functions

### Public Functions
- `submit-pitch()` - Submit a new startup pitch to the competition
- `back-startup(pitch-id)` - Back a specific startup pitch

### Read-Only Functions
- `get-backing-count(pitch-id)` - Get total backing count for a pitch
- `has-backed(investor)` - Check if investor has backed any startup
- `get-total-pitches()` - Get total number of submitted pitches

## Usage

Deploy the contract to facilitate transparent startup pitch competitions where investors can fairly evaluate and back promising ventures.
\`\`\`

```clarity file="project-3-event-planning/contracts/event-democracy.clar"
;; EventDemocracy: A decentralized platform for community event planning decisions
;; Core Data Structures
(define-map community-members principal uint) ;; Tracks members and their event choices
(define-map event-proposals uint uint)        ;; Tracks events and their support counts
(define-data-var event-counter uint u0)       ;; Keeps count of total proposed events

;; Public function to propose a new community event
(define-public (propose-event)
  (let ((event-id (+ (var-get event-counter) u1)))
    (map-set event-proposals event-id u0)     ;; Initialize support for the new event to 0
    (var-set event-counter event-id)          ;; Increment event-counter
    (ok event-id)
  )
)

;; Public function to support an event proposal
(define-public (support-event (event-id uint))
  (let ((member tx-sender))
    (if (is-some (map-get? community-members member))
        (err u5000)  ;; Error: Member has already supported an event
        (if (is-none (map-get? event-proposals event-id))
            (err u5001)  ;; Error: Event proposal does not exist
            (begin
              ;; Register the member's event support
              (map-set community-members member event-id)
              ;; Increment the event's support count
              (map-set event-proposals event-id (+ (default-to u0 (map-get? event-proposals event-id)) u1))
              (ok event-id)
            )
        )
    )
  )
)

;; Read-only function to get total support for an event
(define-read-only (get-event-support (event-id uint))
  (default-to u0 (map-get? event-proposals event-id))
)

;; Read-only function to check if a member has supported any event
(define-read-only (has-supported (member principal))
  (is-some (map-get? community-members member))
)

;; Read-only function to get the total number of proposed events
(define-read-only (get-proposed-events)
  (var-get event-counter)
)

;; Read-only function to find the higher support count
(define-read-only (max-support (support-a uint) (support-b uint))
  (if (>= support-a support-b)
      support-a
      support-b
  )
)
