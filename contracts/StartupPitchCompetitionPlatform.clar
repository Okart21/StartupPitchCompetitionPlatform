;; Startup Pitch Competition Platform
;; Investor backing system for startup pitches

;; Define data structures
(define-map pitch-submissions uint {
    founder: principal,
    company-name: (string-ascii 100),
    pitch-summary: (string-ascii 1000),
    funding-goal: uint,
    investor-backing: uint,
    total-backers: uint,
    is-active: bool
})

(define-map investor-backing {investor: principal, pitch-id: uint} bool)
(define-data-var next-pitch-id uint u1)

;; Submit a pitch
(define-public (submit-pitch (company-name (string-ascii 100)) (pitch-summary (string-ascii 1000)) (funding-goal uint))
    (let ((pitch-id (var-get next-pitch-id)))
        (map-set pitch-submissions pitch-id {
            founder: tx-sender,
            company-name: company-name,
            pitch-summary: pitch-summary,
            funding-goal: funding-goal,
            investor-backing: u0,
            total-backers: u0,
            is-active: true
        })
        (var-set next-pitch-id (+ pitch-id u1))
        (ok pitch-id)
    )
)

;; Back a pitch
(define-public (back-pitch (pitch-id uint))
    (let ((pitch (unwrap! (map-get? pitch-submissions pitch-id) (err u404)))
          (backing-key {investor: tx-sender, pitch-id: pitch-id}))
        (asserts! (get is-active pitch) (err u400))
        (asserts! (is-none (map-get? investor-backing backing-key)) (err u403))
        
        (map-set investor-backing backing-key true)
        (map-set pitch-submissions pitch-id (merge pitch {
            investor-backing: (+ (get investor-backing pitch) u1),
            total-backers: (+ (get total-backers pitch) u1)
        }))
        (ok true)
    )
)

;; Get pitch details
(define-read-only (get-pitch (pitch-id uint))
    (map-get? pitch-submissions pitch-id)
)

;; Get backing status
(define-read-only (get-backing-status (pitch-id uint))
    (match (map-get? pitch-submissions pitch-id)
        pitch (ok {backing: (get investor-backing pitch), backers: (get total-backers pitch)})
        (err u404)
    )
)
