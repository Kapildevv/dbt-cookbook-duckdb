-- Silver exists to feed gold. A silver model nothing reads is either an
-- oversight or dead code -- both worth knowing about before the bill.
select
    m.name
from dbt.models as m
left join dbt.edges as e
    on e.parent_unique_id = m.unique_id
where m.name like 'silver_%'
  and e.child_unique_id is null
