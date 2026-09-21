BEGIN;
UPDATE isahl_meta.meta_collections SET config = config || '{"seed_family_root": true}'::jsonb WHERE table_name = ANY(ARRAY['zc_id_category', 'zc_id_factor', 'zc_id_function', 'zc_id_level', 'zc_id_rate', 'zc_id_ratio', 'zc_id_scene', 'zc_id_status', 'zc_id_tags', 'zc_id_unit']);
UPDATE isahl_meta.meta_collections mc SET config = mc.config || jsonb_build_object('row_layer', v.layer)
  FROM (VALUES
    ('zc_id_cate-inv-title', 'carry'),
    ('zc_id_cate-ope-title', 'carry'),
    ('zc_id_cate-sto-title', 'carry'),
    ('zc_id_cate-subject', 'carry'),
    ('zc_id_category', 'carry'),
    ('zc_id_contract', 'abstract'),
    ('zc_id_demand_rr_supply', 'carry'),
    ('zc_id_eval-calculable', 'carry'),
    ('zc_id_even-approve', 'carry'),
    ('zc_id_file-manual', 'carry'),
    ('zc_id_law-civil-book', 'carry'),
    ('zc_id_law-civil-code', 'carry'),
    ('zc_id_law-common-case', 'carry'),
    ('zc_id_law-common-statute', 'carry'),
    ('zc_id_law-intl-treaty', 'carry'),
    ('zc_id_level', 'carry'),
    ('zc_id_orga-legal', 'carry'),
    ('zc_id_place', 'carry'),
    ('zc_id_plan', 'carry'),
    ('zc_id_process', 'carry'),
    ('zc_id_prod-freight_ocean-sales', 'carry'),
    ('zc_id_prod-license', 'carry'),
    ('zc_id_prod-request', 'carry'),
    ('zc_id_prod-storage', 'carry'),
    ('zc_id_production', 'carry'),
    ('zc_id_production_rr_storage', 'carry'),
    ('zc_id_project', 'carry'),
    ('zc_id_stan-air-caac', 'carry'),
    ('zc_id_stan-air-easa', 'carry'),
    ('zc_id_stan-air-faa', 'carry'),
    ('zc_id_stan-air-icao', 'carry'),
    ('zc_id_stan-fin-cas', 'carry'),
    ('zc_id_stan-fin-gaap', 'carry'),
    ('zc_id_stan-fin-ifrs', 'carry'),
    ('zc_id_stat-trade_order', 'abstract'),
    ('zc_id_stor-account', 'carry'),
    ('zc_id_stus-container', 'carry'),
    ('zc_id_stus-org', 'abstract'),
    ('zc_id_stus-storage', 'carry'),
    ('zc_id_stus-trade', 'carry'),
    ('zc_id_subj-employee', 'carry'),
    ('zc_id_subj-ministry', 'carry'),
    ('zc_id_subj-org', 'carry'),
    ('zc_id_subjects', 'carry')
  ) v(table_name, layer)
 WHERE mc.table_name = v.table_name;
UPDATE isahl_meta.meta_collections mc SET config = mc.config || '{"seed_scope": "model"}'::jsonb
  FROM (VALUES
    ('zc_id_rate-illuminance'),
    ('zc_id_stus-duty'),
    ('zc_id_unit-illuminance')
  ) v(table_name)
 WHERE mc.table_name = v.table_name;
UPDATE isahl_meta.meta_collections mc SET config = mc.config || jsonb_build_object('seed_scope', 'namespace', 'seed_scope_reason', v.reason)
  FROM (VALUES
    ('zc_id_cate-contact_role', '并行会话 2026-09-07 新建分类字典（contact 角色族），seed 收录归属其会话/模型中心裁决'),
    ('zc_id_cate-inv-title-ns', 'namespace 特定科目，行供给归 ns 级种子链路（2026-09-04 用户裁决）'),
    ('zc_id_cate-ope-title-ns', 'namespace 特定科目，行供给归 ns 级种子链路（2026-09-04 用户裁决）'),
    ('zc_id_cate-tsp-title-ns', 'namespace 特定科目，行供给归 ns 级种子链路（2026-09-04 用户裁决）')
  ) v(table_name, reason)
 WHERE mc.table_name = v.table_name;
COMMIT;
