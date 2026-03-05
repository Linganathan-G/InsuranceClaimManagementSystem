DECLARE
    v_claim_number VARCHAR2(50);
BEGIN
    pkg_claim_management.prc_submit_claim(
        p_policy_id => 1,
        p_incident_date => SYSDATE-5,
        p_claim_amount => 5000,
        p_submitted_by => 'TEST_USER',
        p_claim_items_json => '[{"item_description":"Repair","item_category":"AUTO","item_amount":5000,"quantity":1,"unit_price":5000}]',
        p_claim_number => v_claim_number
    );

    DBMS_OUTPUT.PUT_LINE('Claim Created: '||v_claim_number);
END;
/

-- Validate
SELECT pkg_claim_management.fn_get_policy_utilization(1) FROM dual;