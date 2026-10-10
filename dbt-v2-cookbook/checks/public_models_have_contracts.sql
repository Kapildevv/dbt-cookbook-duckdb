-- access: public is a promise. A contract is what makes it enforceable.
select
    name,
    access,
    contract_enforced
from dbt.models
where access = 'public'
  and not contract_enforced
