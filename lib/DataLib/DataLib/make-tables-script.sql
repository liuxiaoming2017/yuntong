begin transaction;

create table if not exists journal (
    j_id        integer primary key,
    j_name      text
);

create table if not exists issue (
    i_id                text primary key,
    j_id                integer not null,
    i_name              text,
    i_cover_path_med    text,
    i_pkg_size          integer not null,
    i_pkg_url           text,
    i_pub_date          interger not null,
    i_status            interger not null
);

commit;
