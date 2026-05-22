-- ============================================================
-- FRP1000 — Nouveau produit Osiris CI
-- 1. Catégorie + sous-catégories
-- 2. Groupe Consultants FRP1000
-- 3. Règle d'affectation automatique
-- ============================================================

-- ── 1. Catégorie FRP1000 (top-level) ────────────────────────
INSERT INTO glpi_itilcategories
    (name, completename, itilcategories_id, entities_id, is_recursive,
     is_incident, is_request, is_problem, is_change, date_creation, date_mod)
VALUES
    ('FRP1000', 'FRP1000', 0, 0, 1, 1, 1, 0, 0, NOW(), NOW());

SET @cat_frp = LAST_INSERT_ID();

-- Sous-catégories FRP1000
INSERT INTO glpi_itilcategories
    (name, completename, itilcategories_id, entities_id, is_recursive,
     is_incident, is_request, is_problem, is_change, date_creation, date_mod)
VALUES
    ('Anomalie / Bug',    CONCAT('FRP1000 > Anomalie / Bug'),    @cat_frp, 0, 1, 1, 0, 0, 0, NOW(), NOW()),
    ('Paramétrage',       CONCAT('FRP1000 > Paramétrage'),       @cat_frp, 0, 1, 1, 1, 0, 0, NOW(), NOW()),
    ('Formation FRP1000', CONCAT('FRP1000 > Formation FRP1000'), @cat_frp, 0, 1, 0, 1, 0, 0, NOW(), NOW()),
    ('Migration / Upgrade', CONCAT('FRP1000 > Migration / Upgrade'), @cat_frp, 0, 1, 1, 1, 0, 0, NOW(), NOW()),
    ('Reporting & Analyse', CONCAT('FRP1000 > Reporting & Analyse'), @cat_frp, 0, 1, 1, 1, 0, 0, NOW(), NOW());

-- ── 2. Groupe Consultants FRP1000 ──────────────────────────
INSERT INTO glpi_groups
    (name, completename, entities_id, is_recursive, is_assign, is_task,
     is_notify, is_requester, date_creation, date_mod)
VALUES
    ('Consultants FRP1000', 'Consultants FRP1000', 0, 1, 1, 1, 1, 0, NOW(), NOW());

SET @grp_frp = LAST_INSERT_ID();

-- ── 3. Règle d'affectation automatique FRP1000 ────────────
-- Modèle : même structure que règle 92 (Sage X3)
SET @max_rank = (SELECT COALESCE(MAX(ranking), 100) FROM glpi_rules WHERE sub_type='RuleTicket') + 1;

INSERT INTO glpi_rules
    (sub_type, ranking, name, description, `match`, is_active,
     is_recursive, entities_id, uuid, date_creation, date_mod)
VALUES
    ('RuleTicket', @max_rank, 'Osiris - Affectation FRP1000',
     'Affecte les tickets FRP1000 au groupe Consultants FRP1000',
     'AND', 1, 1, 0, UUID(), NOW(), NOW());

SET @rule_frp = LAST_INSERT_ID();

-- Critère : catégorie est sous FRP1000 (condition=6 = "sous la catégorie")
INSERT INTO glpi_rulecriterias (rules_id, criteria, `condition`, pattern)
VALUES (@rule_frp, 'itilcategories_id', 6, @cat_frp);

-- Action : affecter au groupe Consultants FRP1000
INSERT INTO glpi_ruleactions (rules_id, action_type, field, value)
VALUES (@rule_frp, 'assign', 'groups_id_assign', @grp_frp);

-- ── 4. Vérification ─────────────────────────────────────────
SELECT id, name, completename FROM glpi_itilcategories
WHERE name LIKE '%FRP%' OR completename LIKE '%FRP%'
ORDER BY completename;

SELECT id, name FROM glpi_groups WHERE name LIKE '%FRP%';

SELECT r.id, r.name, r.is_active,
       rc.criteria, rc.condition, rc.pattern AS cat_id,
       ra.field, ra.value AS group_id
FROM glpi_rules r
JOIN glpi_rulecriterias rc ON rc.rules_id = r.id
JOIN glpi_ruleactions ra ON ra.rules_id = r.id
WHERE r.name LIKE '%FRP%';
