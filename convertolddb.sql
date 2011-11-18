CREATE SEQUENCE ojw28_temp;
ALTER TABLE item_definition_table ADD COLUMN def_id INT NOT NULL DEFAULT nextval('ojw28_temp');
ALTER TABLE item_definition_table ALTER def_id DROP DEFAULT;
DROP SEQUENCE ojw28_temp;

ALTER TABLE item_polygon_table ADD COLUMN item_def_id INT;
ALTER TABLE placed_item_table ADD COLUMN item_def_id INT;
UPDATE item_polygon_table SET item_def_id = (SELECT def_id FROM item_definition_table WHERE name = item_name);
UPDATE placed_item_table SET item_def_id = (SELECT def_id FROM item_definition_table WHERE name = item_name);
ALTER TABLE item_polygon_table ALTER COLUMN item_def_id SET NOT NULL;
ALTER TABLE placed_item_table ALTER COLUMN item_def_id SET NOT NULL;

ALTER TABLE item_polygon_table DROP CONSTRAINT item_polygon_table_pkey;
ALTER TABLE item_polygon_table ADD CONSTRAINT item_polygon_table_pkey PRIMARY KEY(item_def_id, poly_id);

ALTER TABLE item_polygon_table DROP COLUMN item_name;
ALTER TABLE placed_item_table DROP COLUMN item_name;

ALTER TABLE item_definition_table DROP CONSTRAINT item_definition_table_pkey;
ALTER TABLE item_definition_table ADD CONSTRAINT item_definition_table_pkey PRIMARY KEY(def_id);

ALTER TABLE item_polygon_table ADD CONSTRAINT item_polygon_table_fkey FOREIGN KEY (item_def_id) REFERENCES item_definition_table(def_id);
ALTER TABLE placed_item_table ADD CONSTRAINT placed_item_table_fkey FOREIGN KEY (item_def_id) REFERENCES item_definition_table(def_id);