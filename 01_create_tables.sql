-- POLICY TABLE
CREATE TABLE policy (
    policy_id           NUMBER PRIMARY KEY,
    policy_number       VARCHAR2(30) UNIQUE NOT NULL,
    policy_holder_name  VARCHAR2(100) NOT NULL,
    policy_type         VARCHAR2(20) NOT NULL,
    coverage_amount     NUMBER(12,2) CHECK (coverage_amount > 0),
    premium_amount      NUMBER(12,2) CHECK (premium_amount > 0),
    start_date          DATE NOT NULL,
    end_date            DATE NOT NULL,
    status              VARCHAR2(20) NOT NULL,
    created_date        DATE DEFAULT SYSDATE,
    last_updated_date   DATE
);

ALTER TABLE policy ADD CONSTRAINT chk_policy_type
CHECK (policy_type IN ('AUTO','HEALTH','PROPERTY','LIFE'));

ALTER TABLE policy ADD CONSTRAINT chk_policy_status
CHECK (status IN ('ACTIVE','EXPIRED','CANCELLED'));

------------------------------------------------------

-- CLAIM TABLE
CREATE TABLE claim (
    claim_id            NUMBER PRIMARY KEY,
    claim_number        VARCHAR2(30) UNIQUE NOT NULL,
    policy_id           NUMBER NOT NULL,
    claim_date          DATE DEFAULT SYSDATE,
    incident_date       DATE NOT NULL,
    claim_amount        NUMBER(12,2) CHECK (claim_amount > 0),
    claim_status        VARCHAR2(20) NOT NULL,
    submitted_by        VARCHAR2(100),
    approved_by         VARCHAR2(100),
    approval_date       DATE,
    rejection_reason    VARCHAR2(500),
    created_date        DATE DEFAULT SYSDATE,
    last_updated_date   DATE,
    CONSTRAINT fk_claim_policy
        FOREIGN KEY (policy_id)
        REFERENCES policy(policy_id)
        ON DELETE CASCADE
);

ALTER TABLE claim ADD CONSTRAINT chk_claim_status
CHECK (claim_status IN 
('SUBMITTED','UNDER_REVIEW','APPROVED','REJECTED','PAID'));

ALTER TABLE claim ADD CONSTRAINT chk_incident_date
CHECK (incident_date <= claim_date);

------------------------------------------------------

-- CLAIM ITEMS TABLE
CREATE TABLE claim_items (
    item_id             NUMBER PRIMARY KEY,
    claim_id            NUMBER NOT NULL,
    item_description    VARCHAR2(200),
    item_category       VARCHAR2(50),
    item_amount         NUMBER(12,2) CHECK (item_amount > 0),
    quantity            NUMBER CHECK (quantity > 0),
    unit_price          NUMBER(12,2) CHECK (unit_price > 0),
    supporting_doc_ref  VARCHAR2(200),
    created_date        DATE DEFAULT SYSDATE,
    CONSTRAINT fk_claim_items
        FOREIGN KEY (claim_id)
        REFERENCES claim(claim_id)
        ON DELETE CASCADE
);

------------------------------------------------------
-- INDEXES
CREATE INDEX idx_policy_number ON policy(policy_number);
CREATE INDEX idx_claim_number ON claim(claim_number);
CREATE INDEX idx_claim_status ON claim(claim_status);
CREATE INDEX idx_claim_policy_id ON claim(policy_id);
CREATE INDEX idx_claim_date ON claim(claim_date);
CREATE INDEX idx_claim_items_claim_id ON claim_items(claim_id);
