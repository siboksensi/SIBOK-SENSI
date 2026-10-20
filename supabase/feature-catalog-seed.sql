-- 500 planning catalog entries; these are not 500 implemented features.
with nums as (select generate_series(1,500) n),
cats as (select unnest(array['Access & account','Sensitivity profiles','Device matching','HUD & controls','Performance guides','Downloads & versions','Favorites & history','Notifications','Language & accessibility','Admin operations']) c),
names as (select unnest(array['Profile search','Profile compare','Save favorite','Device filter','Version history','Export profile guide','Setup checklist','Change log','Customer notice','Access status']) f)
insert into public.feature_catalog(id,name,category,description,is_enabled)
select 'SS-'||lpad(n::text,3,'0'), f||' '||(((n-1)/10)+1)::text, c,
'Planned catalog entry; implement and test before enabling.', false
from nums cross join lateral (select c from cats offset ((n-1)%10) limit 1) ca(c)
cross join lateral (select f from names offset ((n-1)%10) limit 1) na(f)
on conflict(id) do nothing;
