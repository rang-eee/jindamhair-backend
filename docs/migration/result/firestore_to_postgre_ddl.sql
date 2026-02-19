----------------------------------------------
-- firestore 컬렉션을 기반으로 postgre에 테이블을 생성하는 DDL
----------------------------------------------

----------------------------------------------
-- 확장 실행
----------------------------------------------
create extension if not exists pgcrypto;


----------------------------------------------
-- 최상위 컬렉션
----------------------------------------------
-- alerts
create table fs_alerts (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- appointments
create table fs_appointments (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- banners
create table fs_banners (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- chatRooms
create table fs_chatrooms (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- configuration
create table fs_configuration (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- dynamicLinks
create table fs_dynamiclinks (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- notifications
create table fs_notifications (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- offers
create table fs_offers (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- payments
create table fs_payments (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- pushes
create table fs_pushes (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- reservations
create table fs_reservations (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- reviews
create table fs_reviews (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- statistics
create table fs_statistics (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- stores
create table fs_stores (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- treatmentClassfications
create table fs_treatmentclassfications (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- treatments
create table fs_treatments (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- users
create table fs_users (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);

-- usersFavorites
create table fs_usersfavorites (
  doc_id text primary key,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now()
);


----------------------------------------------
-- 서브 컬렉션
----------------------------------------------
create table fs_appointments__menus (
  parent_doc_id text not null,
  doc_id text not null,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now(),
  primary key (parent_doc_id, doc_id)
);
create table fs_appointments__sign (
  parent_doc_id text not null,
  doc_id text not null,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now(),
  primary key (parent_doc_id, doc_id)
);
create table fs_chatrooms__chatmessages (
  parent_doc_id text not null,
  doc_id text not null,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now(),
  primary key (parent_doc_id, doc_id)
);
create table fs_offers__designers (
  parent_doc_id text not null,
  doc_id text not null,
  data jsonb not null,
  migrated_at timestamptz default now(),
  primary key (parent_doc_id, doc_id)
);
create table fs_reservations__menus (
  parent_doc_id text not null,
  doc_id text not null,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now(),
  primary key (parent_doc_id, doc_id)
);

create table fs_users__menus (
  parent_doc_id text not null,
  doc_id text not null,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now(),
  primary key (parent_doc_id, doc_id)
);


create table fs_users__stores (
  parent_doc_id text not null,
  doc_id text not null,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now(),
  primary key (parent_doc_id, doc_id)
);


create table fs_users__notificationcenters (
  parent_doc_id text not null,
  doc_id text not null,
  data jsonb not null,
  created_at timestamptz,
  updated_at timestamptz,
  migrated_at timestamptz default now(),
  primary key (parent_doc_id, doc_id)
);

