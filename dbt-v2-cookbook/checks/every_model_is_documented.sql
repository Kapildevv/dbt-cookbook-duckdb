-- A model with no description is a model nobody outside the team can use.
-- Rows returned are violations.
select
    name,
    original_file_path
from dbt.models
where coalesce(trim(description), '') = ''
