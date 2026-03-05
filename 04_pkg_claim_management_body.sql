CREATE OR REPLACE PACKAGE BODY pkg_claim_management AS

--------------------------------------------------------
-- VALIDATION FUNCTION
--------------------------------------------------------
FUNCTION fn_validate_claim (p_claim_id NUMBER)
RETURN VARCHAR2
IS
    v_policy_id policy.policy_id%TYPE;
    v_claim_amount NUMBER;
    v_coverage NUMBER;
    v_total NUMBER;
BEGIN

    SELECT policy_id, claim_amount
    INTO v_policy_id, v_claim_amount
    FROM claim
    WHERE claim_id = p_claim_id;

    SELECT coverage_amount
    INTO v_coverage
    FROM policy
    WHERE policy_id = v_policy_id
    AND status = 'ACTIVE';

    SELECT NVL(SUM(claim_amount),0)
    INTO v_total
    FROM claim
    WHERE policy_id = v_policy_id
    AND claim_status IN ('APPROVED','PAID');

    IF (v_total + v_claim_amount) > v_coverage THEN
        RETURN 'ERROR: Coverage limit exceeded';
    END IF;

    RETURN 'VALID';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'ERROR: Invalid Claim or Policy';
END;

--------------------------------------------------------
-- POLICY UTILIZATION
--------------------------------------------------------
FUNCTION fn_get_policy_utilization (p_policy_id NUMBER)
RETURN NUMBER
IS
    v_total NUMBER := 0;
    v_coverage NUMBER;
BEGIN
    SELECT coverage_amount INTO v_coverage
    FROM policy WHERE policy_id = p_policy_id;

    SELECT NVL(SUM(claim_amount),0)
    INTO v_total
    FROM claim
    WHERE policy_id = p_policy_id
    AND claim_status IN ('APPROVED','PAID');

    IF v_total = 0 THEN
        RETURN 0;
    END IF;

    RETURN ROUND((v_total / v_coverage) * 100,2);
END;

--------------------------------------------------------
-- SUBMIT CLAIM
--------------------------------------------------------
PROCEDURE prc_submit_claim (...)
IS
    SAVEPOINT sp_submit;
BEGIN
    -- Policy validation, duplicate check,
    -- filing window check (<=30 days),
    -- insert claim
    -- insert items using JSON_TABLE
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_submit;
        RAISE;
END;

--------------------------------------------------------
-- PROCESS CLAIM
--------------------------------------------------------
PROCEDURE prc_process_claim (...)
IS
    SAVEPOINT sp_process;
    v_validation VARCHAR2(200);
BEGIN
    v_validation := fn_validate_claim(p_claim_id);

    IF v_validation <> 'VALID' THEN
        RAISE_APPLICATION_ERROR(-20010, v_validation);
    END IF;

    -- status transition logic enforcement
    -- rejection reason mandatory
    -- insert audit record
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_process;
        RAISE;
END;

END pkg_claim_management;
/