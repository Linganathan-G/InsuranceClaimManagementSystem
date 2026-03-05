-- ================================
-- INSERT 30 POLICIES
-- ================================

BEGIN
    FOR i IN 1..30 LOOP
        INSERT INTO policy (
            policy_id,
            policy_number,
            policy_holder_name,
            policy_type,
            coverage_amount,
            premium_amount,
            start_date,
            end_date,
            status,
            created_date
        )
        VALUES (
            seq_policy.NEXTVAL,
            'POL-' || LPAD(i,5,'0'),
            'Holder_' || i,
            CASE MOD(i,4)
                WHEN 0 THEN 'AUTO'
                WHEN 1 THEN 'HEALTH'
                WHEN 2 THEN 'PROPERTY'
                ELSE 'LIFE'
            END,
            100000 + (i * 1000),
            5000 + (i * 200),
            SYSDATE - 365,
            SYSDATE + 365,
            CASE 
                WHEN i IN (5,10) THEN 'EXPIRED'
                WHEN i IN (15) THEN 'CANCELLED'
                ELSE 'ACTIVE'
            END,
            SYSDATE
        );
    END LOOP;
    COMMIT;
END;
/

-- ================================
-- INSERT 50 CLAIMS
-- ================================

DECLARE
    v_claim_id NUMBER;
BEGIN
    FOR i IN 1..50 LOOP
        
        v_claim_id := seq_claim.NEXTVAL;

        INSERT INTO claim (
            claim_id,
            claim_number,
            policy_id,
            claim_date,
            incident_date,
            claim_amount,
            claim_status,
            submitted_by,
            created_date
        )
        VALUES (
            v_claim_id,
            'CLM-' || LPAD(i,5,'0'),
            MOD(i,30) + 1,
            SYSDATE,
            SYSDATE - MOD(i,20),
            1000 + (i * 50),
            CASE 
                WHEN i <= 20 THEN 'APPROVED'
                WHEN i <= 35 THEN 'SUBMITTED'
                ELSE 'REJECTED'
            END,
            'USER_'||i,
            SYSDATE
        );

        -- Insert 5 Items per Claim
        FOR j IN 1..5 LOOP
            INSERT INTO claim_items (
                item_id,
                claim_id,
                item_description,
                item_category,
                item_amount,
                quantity,
                unit_price,
                supporting_doc_ref,
                created_date
            )
            VALUES (
                seq_claim_items.NEXTVAL,
                v_claim_id,
                'Item_'||j||'_Claim_'||i,
                'GENERAL',
                200,
                1,
                200,
                'DOC-'||i||'-'||j,
                SYSDATE
            );
        END LOOP;

    END LOOP;

    COMMIT;
END;
/