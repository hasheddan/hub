-- Start transaction and plan tests
begin;
select plan(9);

-- Declare some variables
\set repo1ID '00000000-0000-0000-0000-000000000001'
\set repo2ID '00000000-0000-0000-0000-000000000002'
\set package1ID '00000000-0000-0000-0000-000000000001'
\set package2ID '00000000-0000-0000-0000-000000000002'

-- Using invalid queries
select throws_ok(
    $$ select search_packages('{}')::jsonb $$,
    'invalid query text',
    'Query text must be provided'
);
select throws_ok(
    $$ select search_packages('{"text": ""}')::jsonb $$,
    'invalid query text',
    'Query text cannot be empty'
);

-- No packages at this point
select is(
    search_packages('{
        "text": "package1"
    }')::jsonb,
    '{
        "packages": [],
        "facets": [{
            "title": "Kind",
            "options": []
        }, {
            "title": "Repository",
            "options": []
        }]
    }'::jsonb,
    'Text: package1 | No packages in db yet | No packages nor facets expected'
);

-- Seed some packages
insert into chart_repository (chart_repository_id, name, display_name, url)
values (:'repo1ID', 'repo1', 'Repo 1', 'https://repo1.com');
insert into chart_repository (chart_repository_id, name, display_name, url)
values (:'repo2ID', 'repo2', 'Repo 2', 'https://repo2.com');
insert into package (
    package_id,
    name,
    display_name,
    description,
    home_url,
    logo_url,
    keywords,
    latest_version,
    package_kind_id,
    chart_repository_id
) values (
    :'package1ID',
    'package1',
    'Package 1',
    'description',
    'home_url',
    'logo_url',
    '{"kw1", "kw2"}',
    '1.0.0',
    0,
    :'repo1ID'
);
insert into snapshot (
    package_id,
    version,
    app_version,
    digest,
    readme,
    links
) values (
    :'package1ID',
    '1.0.0',
    '12.1.0',
    'digest-package1-1.0.0',
    'readme',
    '{"link1": "https://link1", "link2": "https://link2"}'
);
insert into snapshot (
    package_id,
    version,
    app_version,
    digest,
    readme,
    links
) values (
    :'package1ID',
    '0.0.9',
    '12.0.0',
    'digest-package1-0.0.9',
    'readme',
    '{"link1": "https://link1", "link2": "https://link2"}'
);
insert into package (
    package_id,
    name,
    display_name,
    description,
    home_url,
    logo_url,
    keywords,
    latest_version,
    package_kind_id,
    chart_repository_id
) values (
    :'package2ID',
    'package2',
    'Package 2',
    'description',
    'home_url',
    'logo_url',
    '{"kw1", "kw2"}',
    '1.0.0',
    0,
    :'repo2ID'
);
insert into snapshot (
    package_id,
    version,
    app_version,
    digest,
    readme,
    links
) values (
    :'package2ID',
    '1.0.0',
    '12.1.0',
    'digest-package2-1.0.0',
    'readme',
    '{"link1": "https://link1", "link2": "https://link2"}'
);
insert into snapshot (
    package_id,
    version,
    app_version,
    digest,
    readme,
    links
) values (
    :'package2ID',
    '0.0.9',
    '12.0.0',
    'digest-package2-0.0.9',
    'readme',
    '{"link1": "https://link1", "link2": "https://link2"}'
);

-- Some packages have just been seeded
select is(
    search_packages('{
        "text": "kw1"
    }')::jsonb,
    '{
        "packages": [{
            "kind": 0,
            "name": "package1",
            "logo_url": "logo_url",
            "package_id": "00000000-0000-0000-0000-000000000001",
            "app_version": "12.1.0",
            "description": "description",
            "display_name": "Package 1",
            "chart_repository": {
                "name": "repo1",
                "display_name": "Repo 1"
            }
        }, {
            "kind": 0,
            "name": "package2",
            "logo_url": "logo_url",
            "package_id": "00000000-0000-0000-0000-000000000002",
            "app_version": "12.1.0",
            "description": "description",
            "display_name": "Package 2",
            "chart_repository": {
                "name": "repo2",
                "display_name": "Repo 2"
            }
        }],
        "facets": [{
            "title": "Kind",
            "options": [{
                "id": 0,
                "name": "Chart",
                "total": 2
            }]
        }, {
            "title": "Repository",
            "options": [{
                "id": "00000000-0000-0000-0000-000000000001",
                "name": "Repo1",
                "total": 1
            }, {
                "id": "00000000-0000-0000-0000-000000000002",
                "name": "Repo2",
                "total": 1
            }]
        }]
    }'::jsonb,
    'Text: kw1 | Two packages expected | Facets expected'
);
select is(
    search_packages('{
        "text": "package1"
    }')::jsonb,
    '{
        "packages": [{
            "kind": 0,
            "name": "package1",
            "logo_url": "logo_url",
            "package_id": "00000000-0000-0000-0000-000000000001",
            "app_version": "12.1.0",
            "description": "description",
            "display_name": "Package 1",
            "chart_repository": {
                "name": "repo1",
                "display_name": "Repo 1"
            }
        }],
        "facets": [{
            "title": "Kind",
            "options": [{
                "id": 0,
                "name": "Chart",
                "total": 1
            }]
        }, {
            "title": "Repository",
            "options": [{
                "id": "00000000-0000-0000-0000-000000000001",
                "name": "Repo1",
                "total": 1
            }]
        }]
    }'::jsonb,
    'Text: package1 | Package 1 expected | Facets expected'
);
select is(
    search_packages(
    '{
        "text": "kw1",
        "chart_repositories": [
            "00000000-0000-0000-0000-000000000002"
        ]
    }')::jsonb,
    '{
        "packages": [{
            "kind": 0,
            "name": "package2",
            "logo_url": "logo_url",
            "package_id": "00000000-0000-0000-0000-000000000002",
            "app_version": "12.1.0",
            "description": "description",
            "display_name": "Package 2",
            "chart_repository": {
                "name": "repo2",
                "display_name": "Repo 2"
            }
        }],
        "facets": [{
            "title": "Kind",
            "options": [{
                "id": 0,
                "name": "Chart",
                "total": 2
            }]
        }, {
            "title": "Repository",
            "options": [{
                "id": "00000000-0000-0000-0000-000000000001",
                "name": "Repo1",
                "total": 1
            }, {
                "id": "00000000-0000-0000-0000-000000000002",
                "name": "Repo2",
                "total": 1
            }]
        }]
    }'::jsonb,
    'Text: kw1 Repo: repo2 | Package 2 expected | Facets expected'
);
select is(
    search_packages('{
        "text": "kw1",
        "chart_repositories": [
            "00000000-0000-0000-0000-000000000003"
        ]
    }')::jsonb,
    '{
        "packages": [],
        "facets": [{
            "title": "Kind",
            "options": [{
                "id": 0,
                "name": "Chart",
                "total": 2
            }]
        }, {
            "title": "Repository",
            "options": [{
                "id": "00000000-0000-0000-0000-000000000001",
                "name": "Repo1",
                "total": 1
            }, {
                "id": "00000000-0000-0000-0000-000000000002",
                "name": "Repo2",
                "total": 1
            }]
        }]
    }'::jsonb,
    'Text: kw1 Repo: inexistent | No packages expected | Facets expected'
);
select is(
    search_packages('{
        "text": "kw1",
        "package_kinds": [1, 2]
    }')::jsonb,
    '{
        "packages": [],
        "facets": [{
            "title": "Kind",
            "options": [{
                "id": 0,
                "name": "Chart",
                "total": 2
            }]
        }, {
            "title": "Repository",
            "options": [{
                "id": "00000000-0000-0000-0000-000000000001",
                "name": "Repo1",
                "total": 1
            }, {
                "id": "00000000-0000-0000-0000-000000000002",
                "name": "Repo2",
                "total": 1
            }]
        }]
    }'::jsonb,
    'Text: kw1 Kinds: 1, 2 | No packages expected | Facets expected'
);
select is(
    search_packages('{
        "text": "kw3"
    }')::jsonb,
    '{
        "packages": [],
        "facets": [{
            "title": "Kind",
            "options": []
        }, {
            "title": "Repository",
            "options": []
        }]
    }'::jsonb,
    'Text: kw3 (inexistent) | No packages nor facets expected'
);

-- Finish tests and rollback transaction
select * from finish();
rollback;
