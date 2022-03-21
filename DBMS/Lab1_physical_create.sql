-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-09-28 10:40:11.812

-- tables
-- Table: Certificate
CREATE TABLE Certificate
(
    id         integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    "file"     blob                                                               NOT NULL,
    student_id integer                                                            NOT NULL,
    course_id  integer                                                            NOT NULL,
    CONSTRAINT Certificate_pk PRIMARY KEY (id)
);

-- Table: Course
CREATE TABLE Course
(
    id                 integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    type               varchar(10) CHECK ( type IN ('captain', 'skipper', 'sailor'))      NOT NULL,
    training_center_id integer                                                            NOT NULL,
    CONSTRAINT Course_pk PRIMARY KEY (id)
);

-- Table: Exam
CREATE TABLE Exam
(
    id         integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    mark       integer                                                            NULL CHECK (mark >= 4),
    "date"     date                                                               NOT NULL check ( "date" >= DATE '2020-01-01' ),
    passed     varchar(10) CHECK ( passed IN ('success', 'fail', 'absence'))      NOT NULL,
    student_id integer                                                            NOT NULL,
    stage_id   integer                                                            NOT NULL,
    CONSTRAINT Exam_pk PRIMARY KEY (id)
);

-- Table: Stage
CREATE TABLE Stage
(
    id            integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    price         integer                                                            NOT NULL check ( price > 0 ),
    start_date    date                                                               NOT NULL CHECK (start_date >= DATE '2020-01-01'),
    course_id     integer                                                            NOT NULL,
    stage_type_id integer                                                            NOT NULL,
    CONSTRAINT Stage_pk PRIMARY KEY (id)
);

-- Table: StageType
CREATE TABLE StageType
(
    id             integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    name           varchar(50)                                                        NOT NULL,
    duration       integer                                                            NOT NULL CHECK (duration in (1, 2, 4)),
    is_theoretical smallint                                                           NOT NULL check ( is_theoretical in (0, 1) ),
    is_distance    smallint                                                           NOT NULL check ( is_distance in (0, 1) ),
    CONSTRAINT StageType_pk PRIMARY KEY (id)
);

-- Table: Student
CREATE TABLE Student
(
    id      integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    name    varchar(20)                                                        NOT NULL,
    surname varchar(30)                                                        NOT NULL,
    CONSTRAINT Student_pk PRIMARY KEY (id)
);

-- Table: Student_Course
CREATE TABLE Student_Course
(
    student_id integer                                                            NOT NULL,
    course_id  integer                                                            NOT NULL,
    id         integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    CONSTRAINT Student_Course_ak_1 UNIQUE (student_id, course_id),
    CONSTRAINT Student_Course_pk PRIMARY KEY (id)
);

-- Table: TrainingCenter
CREATE TABLE TrainingCenter
(
    id      integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    address varchar(100)                                                       NOT NULL,
    CONSTRAINT TrainingCenter_pk PRIMARY KEY (id)
);

-- Table: payment
CREATE TABLE payment
(
    id         integer GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    date_time  timestamp                                                          NOT NULL CHECK ( date_time >= to_timestamp('2020-01-01', 'YYYY-MM-DD') ),
    amount     integer                                                            NOT NULL CHECK ( amount > 0),
    stage_id   integer                                                            NOT NULL,
    student_id integer                                                            NOT NULL,
    CONSTRAINT payment_pk PRIMARY KEY (id)
);

-- foreign keys
-- Reference: Certificate_Course (table: Certificate)
ALTER TABLE Certificate
    ADD CONSTRAINT Certificate_Course
        FOREIGN KEY (course_id)
            REFERENCES Course (id);

-- Reference: Certificate_Student (table: Certificate)
ALTER TABLE Certificate
    ADD CONSTRAINT Certificate_Student
        FOREIGN KEY (student_id)
            REFERENCES Student (id);

-- Reference: Course_TrainingCenter (table: Course)
ALTER TABLE Course
    ADD CONSTRAINT Course_TrainingCenter
        FOREIGN KEY (training_center_id)
            REFERENCES TrainingCenter (id);

-- Reference: Exam_Stage (table: Exam)
ALTER TABLE Exam
    ADD CONSTRAINT Exam_Stage
        FOREIGN KEY (stage_id)
            REFERENCES Stage (id);

-- Reference: Exam_Student (table: Exam)
ALTER TABLE Exam
    ADD CONSTRAINT Exam_Student
        FOREIGN KEY (student_id)
            REFERENCES Student (id);

-- Reference: Stage_Course (table: Stage)
ALTER TABLE Stage
    ADD CONSTRAINT Stage_Course
        FOREIGN KEY (course_id)
            REFERENCES Course (id);

-- Reference: Stage_StageType (table: Stage)
ALTER TABLE Stage
    ADD CONSTRAINT Stage_StageType
        FOREIGN KEY (stage_type_id)
            REFERENCES StageType (id);

-- Reference: Student_Course_Course (table: Student_Course)
ALTER TABLE Student_Course
    ADD CONSTRAINT Student_Course_Course
        FOREIGN KEY (course_id)
            REFERENCES Course (id);

-- Reference: Student_Course_Student (table: Student_Course)
ALTER TABLE Student_Course
    ADD CONSTRAINT Student_Course_Student
        FOREIGN KEY (student_id)
            REFERENCES Student (id);

-- Reference: payment_Stage (table: payment)
ALTER TABLE payment
    ADD CONSTRAINT payment_Stage
        FOREIGN KEY (stage_id)
            REFERENCES Stage (id);

-- Reference: payment_Student (table: payment)
ALTER TABLE payment
    ADD CONSTRAINT payment_Student
        FOREIGN KEY (student_id)
            REFERENCES Student (id);

-- End of file.

INSERT INTO StageType (name, duration, is_theoretical, is_distance)
VALUES ('Матрос практика', 1, 0, 0);
INSERT INTO StageType (name, duration, is_theoretical, is_distance)
VALUES ('Шкипер практика', 1, 0, 0);
INSERT INTO StageType (name, duration, is_theoretical, is_distance)
VALUES ('Шкипер матчасть', 4, 1, 1);
INSERT INTO StageType (name, duration, is_theoretical, is_distance)
VALUES ('Шкипер теория навигации', 4, 1, 1);
INSERT INTO StageType (name, duration, is_theoretical, is_distance)
VALUES ('Шкипер теория вождения яхты', 4, 1, 1);
INSERT INTO StageType (name, duration, is_theoretical, is_distance)
VALUES ('Капитан практика', 2, 0, 0);
INSERT INTO StageType (name, duration, is_theoretical, is_distance)
VALUES ('Капитан матчасть', 1, 1, 0);
INSERT INTO StageType (name, duration, is_theoretical, is_distance)
VALUES ('Капитан теория навигации', 1, 1, 0);
INSERT INTO StageType (name, duration, is_theoretical, is_distance)
VALUES ('Капитан теория вождения яхты', 1, 1, 0);

INSERT INTO TrainingCenter (address)
VALUES ('наб. Петра Великого, 1, Калининград, Калининградская обл., Россия, 236006');
INSERT INTO TrainingCenter (address)
VALUES ('İsmet Kaptan, Şair Eşref Blv. No: 22/802, 35210 Konak/İzmir, Турция');
INSERT INTO TrainingCenter (address)
VALUES ('Budva Old Town, Budva 85310, Черногория');
INSERT INTO TrainingCenter (address)
VALUES ('Leoforos Posidonos - Delta Falirou, Kallithea, Athens 176 74, Греция');

INSERT INTO Course (type, training_center_id)
VALUES ('captain', (SELECT id FROM TrainingCenter where address like '%Греция%' and ROWNUM = 1));

INSERT INTO Course (type, training_center_id)
VALUES ('skipper',
        (SELECT id FROM TrainingCenter where address like '%Калининград%' and ROWNUM = 1));

INSERT INTO Course (type, training_center_id)
VALUES ('sailor', (SELECT id FROM TrainingCenter where address like '%Турция%' and ROWNUM = 1));

INSERT INTO Course (type, training_center_id)
VALUES ('sailor', (SELECT id FROM TrainingCenter where address like '%Черногория%' and ROWNUM = 1));

INSERT INTO Stage (price, start_date, course_id, stage_type_id)
VALUES (1000, DATE '2020-10-28', 3, 1);
INSERT INTO Stage (price, start_date, course_id, stage_type_id)
VALUES (1050, DATE '2020-11-05', 4, 1);

INSERT INTO Stage (price, start_date, course_id, stage_type_id)
VALUES (500, DATE '2020-10-28', 1, 7);
INSERT INTO Stage (price, start_date, course_id, stage_type_id)
VALUES (500, DATE '2020-10-28', 1, 8);
INSERT INTO Stage (price, start_date, course_id, stage_type_id)
VALUES (500, DATE '2020-10-28', 1, 9);
INSERT INTO Stage (price, start_date, course_id, stage_type_id)
VALUES (2500, DATE '2020-11-12', 1, 6);

INSERT INTO Stage (price, start_date, course_id, stage_type_id)
VALUES (300, DATE '2020-11-05', 2, 3);
INSERT INTO Stage (price, start_date, course_id, stage_type_id)
VALUES (300, DATE '2020-11-05', 2, 4);
INSERT INTO Stage (price, start_date, course_id, stage_type_id)
VALUES (300, DATE '2020-11-05', 2, 5);
INSERT INTO Stage (price, start_date, course_id, stage_type_id)
VALUES (1200, DATE '2020-12-02', 2, 2);

INSERT INTO Student (surname, name)
VALUES ('Иванов', 'Петр');

INSERT INTO Student (surname, name)
VALUES ('Сидоров', 'Иван');

INSERT INTO Student (surname, name)
VALUES ('Сергеев', 'Константин');

INSERT INTO Student (surname, name)
VALUES ('Козлов', 'Захар');

INSERT INTO Student (surname, name)
VALUES ('Белов', 'Артём');

INSERT INTO Student (surname, name)
VALUES ('Котов', 'Алексей');

INSERT INTO Student (surname, name)
VALUES ('Серов', 'Александр');

INSERT INTO Student (surname, name)
VALUES ('Петров', 'Иван');

INSERT INTO Student (surname, name)
VALUES ('Крюк', 'Кирилл');

INSERT INTO Student (surname, name)
VALUES ('Константинов', 'Павел');

INSERT INTO Student (surname, name)
VALUES ('Белый', 'Даниил');

INSERT INTO Student (surname, name)
VALUES ('Чернов', 'Пётр');

INSERT INTO Student (surname, name)
VALUES ('Кириллов', 'Валентин');

INSERT INTO Student (surname, name)
VALUES ('Баранов', 'Дмитрий');

INSERT INTO Student (surname, name)
VALUES ('Круглов', 'Борис');

INSERT INTO Student (surname, name)
VALUES ('Хмызов', 'Тимофей');

INSERT INTO Student (surname, name)
VALUES ('Круглов', 'Борис');

INSERT INTO Student (surname, name)
VALUES ('Киселев', 'Павел');

INSERT INTO Student (surname, name)
VALUES ('Морозов', 'Александр');

INSERT INTO Student (surname, name)
VALUES ('Андреев', 'Егор');

INSERT INTO Student (surname, name)
VALUES ('Кекелев', 'Кирилл');

INSERT INTO Student (surname, name)
VALUES ('Котиков', 'Михаил');

INSERT INTO Student (surname, name)
VALUES ('Михаилов', 'Петр');


INSERT INTO Student_Course (student_id, course_id)
VALUES (1, 3);
INSERT INTO Student_Course (student_id, course_id)
VALUES (2, 3);
INSERT INTO Student_Course (student_id, course_id)
VALUES (3, 3);
INSERT INTO Student_Course (student_id, course_id)
VALUES (4, 3);
INSERT INTO Student_Course (student_id, course_id)
VALUES (5, 3);
INSERT INTO Student_Course (student_id, course_id)
VALUES (6, 3);
INSERT INTO Student_Course (student_id, course_id)
VALUES (7, 3);

INSERT INTO Student_Course (student_id, course_id)
VALUES (8, 4);
INSERT INTO Student_Course (student_id, course_id)
VALUES (9, 4);
INSERT INTO Student_Course (student_id, course_id)
VALUES (10, 4);
INSERT INTO Student_Course (student_id, course_id)
VALUES (11, 4);
INSERT INTO Student_Course (student_id, course_id)
VALUES (12, 4);
INSERT INTO Student_Course (student_id, course_id)
VALUES (13, 4);
INSERT INTO Student_Course (student_id, course_id)
VALUES (14, 4);

INSERT INTO Student_Course (student_id, course_id)
VALUES (15, 2);
INSERT INTO Student_Course (student_id, course_id)
VALUES (16, 2);
INSERT INTO Student_Course (student_id, course_id)
VALUES (17, 2);
INSERT INTO Student_Course (student_id, course_id)
VALUES (18, 2);
INSERT INTO Student_Course (student_id, course_id)
VALUES (19, 2);
INSERT INTO Student_Course (student_id, course_id)
VALUES (20, 2);
INSERT INTO Student_Course (student_id, course_id)
VALUES (21, 1);
INSERT INTO Student_Course (student_id, course_id)
VALUES (22, 1);
INSERT INTO Student_Course (student_id, course_id)
VALUES (23, 1);


INSERT INTO EXAM (mark, "date", passed, student_id, stage_id)
VALUES (9, DATE '2020-11-05', 'success', 21, 3);
INSERT INTO EXAM (mark, "date", passed, student_id, stage_id)
VALUES (5, DATE '2020-11-05', 'success', 22, 3);
INSERT INTO EXAM ("date", passed, student_id, stage_id)
VALUES (DATE '2020-11-05', 'fail', 23, 3);
INSERT INTO EXAM (mark, "date", passed, student_id, stage_id)
VALUES (8, DATE '2020-11-07', 'success', 21, 4);
INSERT INTO EXAM ("date", passed, student_id, stage_id)
VALUES (DATE '2020-11-07', 'fail', 22, 4);
INSERT INTO EXAM (mark, "date", passed, student_id, stage_id)
VALUES (10, DATE '2020-11-09', 'success', 21, 5);

INSERT INTO EXAM (mark, "date", passed, student_id, stage_id)
VALUES (10, DATE '2020-11-27', 'success', 21, 6);


select *
from Student
         join Student_Course on Student_Course.student_id = Student.id
         join Course on Student_Course.course_id = Course.id
where Course.type = :type
  and EXISTS(select id
             from STAGE
             where STAGE.COURSE_ID = COURSE_ID
               and STAGE.start_date between (DATE '2020-10-28') and (DATE '2020-10-28' + 7 *
                                                                                         (select duration
                                                                                          from StageType
                                                                                          where StageType.id = Stage.stage_type_id)));

select *
from STUDENT
where ID in (select STUDENT_ID
             from STUDENT_COURSE
             where COURSE_ID in (select id
                                 from COURSE
                                 where TRAINING_CENTER_ID = (SELECT id
                                                             FROM TrainingCenter
                                                             where address like '%Греция%'
                                                               and ROWNUM = 1))
               and EXISTS(select id
                          from STAGE
                          where STAGE.COURSE_ID = COURSE_ID
                            and STAGE.start_date between (DATE '2020-10-28') and (
                                  DATE '2020-10-28' + 7 * (select duration
                                                           from StageType
                                                           where StageType.id = Stage.stage_type_id))));

select *
from STUDENT
where EXISTS(
              select ID
              from COURSE
              where COURSE.ID in (
                  select COURSE_ID
                  from STUDENT_COURSE
                  where STUDENT_ID = STUDENT.ID)
                and (
                        select COUNT(*)
                        from STAGE
                                 join EXAM E on STAGE.ID = E.STAGE_ID
                        where STAGE.COURSE_ID = COURSE.ID
                          and E.STUDENT_ID = STUDENT.ID
                          and E.PASSED = 'success'
                    ) = (select count(*) from STAGE where STAGE.COURSE_ID = COURSE.ID)
          );

select *
from STUDENT
where EXISTS(
              select ID
              from COURSE
              where COURSE.ID in (
                  select COURSE_ID
                  from STUDENT_COURSE
                  where STUDENT_ID = STUDENT.ID)
                and (
                        select COUNT(*)
                        from STAGE
                                 join EXAM E on STAGE.ID = E.STAGE_ID
                        where STAGE.COURSE_ID = COURSE.ID
                          and E.STUDENT_ID = STUDENT.ID
                          and E.PASSED = 'success'
                    ) < (select count(*) from STAGE where STAGE.COURSE_ID = COURSE.ID)
          );



CREATE TRIGGER multiple_courses
    BEFORE INSERT OR UPDATE
    ON Student_Course
    for each row
declare
    count_courses DECIMAL(10);
    start_date    date;
    finish_date   date;
    duration      DECIMAL(10);
begin
    select min(Stage.start_date), max(Stage.start_date)
    into start_date, finish_date
    from Stage
    where Stage.course_id = :new.course_id;
    select max(StageType.duration)
    into duration
    from Stage
             join StageType on Stage.stage_type_id = StageType.id
    where Stage.course_id = :new.course_id
      and Stage.start_date = finish_date;
    select COUNT(*)
    into count_courses
    from Student_Course
             join
         Course on Course.id = Student_Course.course_id
             join STAGE S
                  on Student_Course.course_id = S.COURSE_ID
    where (Student_Course.student_id = :new.student_id)
      and (S.start_date between start_date and finish_date + 7 * duration);
    if (count_courses > 0) then
        raise_application_error(
                -20007,
                'Cannot select multiple courses'
            );
    end if;
end multiple_courses;

INSERT INTO Student_Course (student_id, course_id)
VALUES (1, 1);

CREATE TRIGGER practice_after_exam
    BEFORE INSERT OR UPDATE
    ON Exam
    for each row
    when ( new.passed != 'absence' )
declare
    theoretical       DECIMAL(10);
    passed_count      DECIMAL(10);
    need_count        DECIMAL(10);
    current_course_id DECIMAL(10);
begin
    select StageType.is_theoretical, Stage.course_id
    into theoretical, current_course_id
    from Stage
             join StageType on Stage.stage_type_id = StageType.id
    where Stage.id = :new.stage_id;
    if (theoretical = 0) then
        select count(*)
        into need_count
        from Stage
                 join StageType on Stage.stage_type_id = StageType.id
        where Stage.course_id = current_course_id
          and StageType.is_theoretical = 1;
        select count(*)
        into passed_count
        from Stage
                 join StageType on Stage.stage_type_id = StageType.id
                 join Exam on Exam.stage_id = Stage.id
        where Stage.course_id = current_course_id
          and StageType.is_theoretical = 1
          and Exam.student_id = :new.student_id
          and Exam.passed = 'success';
        if (passed_count < need_count) then
            raise_application_error(
                    -20007,
                    'Theory is not passed'
                );
        end if;
    end if;
end practice_after_exam;

INSERT INTO EXAM (mark, "date", passed, student_id, stage_id)
VALUES (10, DATE '2020-11-27', 'success', 22, 6);

CREATE TRIGGER group_size
    BEFORE INSERT OR UPDATE
    ON Student_Course
    for each row
declare
    count_students DECIMAL(10);
begin
    select count(*) into count_students from Student_Course where course_id = :new.course_id;
    if (count_students >= 7) then
        raise_application_error(
                -20007,
                'Too much students in group'
            );
    end if;
end group_size;

INSERT INTO Student (surname, name)
VALUES ('Петров', 'Петр');

INSERT INTO Student_Course (student_id, course_id)
VALUES (41, 3);

DELETE FROM Student_Course where STUDENT_ID = 23 and course_id = 1;

INSERT INTO Student_Course (student_id, course_id)
VALUES (23, 1);