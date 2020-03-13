-- get_packages_stats returns the number of packages and releases registered in
-- the database as a json object.
create or replace function get_packages_stats()
returns setof json as $$
    select json_build_object(
        'packages', (
            select count(*)
            from package
            where deprecated is null or deprecated = false
        ),
        'releases', (
            select count(*)
            from snapshot s
            join package p using (package_id)
            where p.deprecated is null or p.deprecated = false
        )
    );
$$ language sql;
