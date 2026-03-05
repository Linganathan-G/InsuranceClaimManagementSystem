CREATE OR REPLACE PACKAGE pkg_claim_management AS

    -- Status Constants
    c_status_submitted    CONSTANT VARCHAR2(20) := 'SUBMITTED';
    c_status_review       CONSTANT VARCHAR2(20) := 'UNDER_REVIEW';
    c_status_approved     CONSTANT VARCHAR2(20) := 'APPROVED';
    c_status_rejected     CONSTANT VARCHAR2(20) := 'REJECTED';
    c_status_paid         CONSTANT VARCHAR2(20) := 'PAID';

    -- Submit Claim
    PROCEDURE prc_submit_claim (
        p_policy_id        IN NUMBER,
        p_incident_date    IN DATE,
        p_claim_amount     IN NUMBER,
        p_submitted_by     IN VARCHAR2,
        p_claim_items_json IN CLOB,
        p_claim_number     OUT VARCHAR2
    );

    -- Process Claim
    PROCEDURE prc_process_claim (
        p_claim_id         IN NUMBER,
        p_action           IN VARCHAR2,
        p_processed_by     IN VARCHAR2,
        p_rejection_reason IN VARCHAR2 DEFAULT NULL
    );

    -- Validate Claim
    FUNCTION fn_validate_claim (
        p_claim_id IN NUMBER
    ) RETURN VARCHAR2;

    -- Policy Utilization
    FUNCTION fn_get_policy_utilization (
        p_policy_id IN NUMBER
    ) RETURN NUMBER;

END pkg_claim_management;
/