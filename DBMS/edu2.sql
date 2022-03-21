drop table TMP_EMP;
drop table TMP_JOB;
create table TMP_EMP
(
  EMPNO     integer not null,
  EMPNAME   VARCHAR(15) not null,
  BIRTHDATE DATE not null
);
alter table TMP_EMP
  add primary key (EMPNO);

create table TMP_JOB
(
  JOBNO     integer not null,
  JOBNAME   VARCHAR(20) not null,
  MINSALARY real not null
);
alter table TMP_JOB
  add primary key (JOBNO);
commit;



