create table periods (
  id integer primary key,
  name varchar(20) not null
);

create table composers (
  id integer primary key,
  name varchar(255) not null,
  period_id integer not null,
  foreign key(period_id) references periods(id)
);

create table works (
  id integer primary key,
  title varchar(255) not null,
  composer_id integer not null,
  foreign key(composer_id) references composers(id)
);

insert into periods (id, name)
values
(1, "Baroque"), (2, "Classical"), (3, "Romantic"), (4, "Modern");

insert into composers (id, name, period_id)
values
(1, "Johann Sebastian Bach", 1), 
(2, "Georg Friedrich Händel", 1), 
(3, "Wolfgang Amadeus Mozart", 2),
(4, "Ludwig van Beethoven", 2),
(5, "Frédéric Chopin", 3),
(6, "Johannes Brahms", 3),
(7, "Claude Debussy", 4),
(8, "Dmitri Shostakovich", 4);

insert into works (id, title, composer_id)
values
(1, "Mass in b minor", 1),
(2, "Goldberg Variations", 1),
(3, "The Art of Fugue", 1),
(4, "Rodelinda", 2),
(5, "Symphony No. 35", 3),
(6, "Piano Concerto No. 20", 3),
(7, "Don Giovanni", 3),
(8, "Symphony No. 8", 4),
(9, "String Quartet No. 13", 4),
(10, "Ballade No. 4", 5),
(11, "Polonaise-Fantasy", 5),
(12, "Piano Concerto No. 2", 6),
(13, "Symphony No. 4", 6),
(14, "Preludes", 7),
(15, "String Quartet", 7),
(16, "Preludes and Fugues", 8);