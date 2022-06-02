--16.PLSqlProcedure.sql
/*
1. 저장 프로시저
	- 이름을 부여해서 필요한 시점에 재사용 가능한 plsql
	- DB에 사용자 정의 기능을 등록 -> 필요한 시점에 사용
	
	= user_source 사전 table
		- 프로시저 정보가 저장되는 table

2. 문법
	2-1. 생성만
		- 이미 동일한 이름의 procedure가 존재할 경우 error 발생 
		create procedure  이름
		is
		begin
		end;
		/

	2-2. 생성 및 치환
    		- 미 존재할 경우 생성, 존재할 경우 치화
		create or replace procedure
		is
		begin
		end;
		/

3. 에러 발생시
show error
*/


--1. procedure 정보 확인 sql문장
desc user_source;
select * from user_source; -- oracle의 dictionary table


--2. 실습을 위한 test table
drop table dept01;
create table dept01 as select * from dept;
drop table emp01;
create table emp01 as select * from emp;


--3. emp01의 부서 번호가 20인 모든 사원의 job을 
-- STUDENT로 변경하는 프로시저 생성
CREATE OR REPLACE PROCEDURE update_job
IS 
BEGIN
	UPDATE emp01 SET job= 'STUDENT' WHERE deptno=20;
	COMMIT; -- insert / update / delete 필수
END;

/



select * from emp01;
select * from user_source;
-- db에 등록은 되어 있으나 호출은 아직 안 한 상태

-- 프로시저 실행하는 명령어
execute update_job; -- sqlplus에서 실행
select * from emp01;

--4. 가변적인 사번(동적)으로 실행시마다 해당 사원의 급여에 +500 하는 프로시저 생성하기
-- sql문장 상의 컬럼에 plsql 변수값 대입할 경우엔 
-- 기본 대입 연산자 활용(=)
-- plsql 변수에 값 할당시에는 할당 연산자 활용(:=)
select empno, sal from emp01 where empno=7369;

CREATE OR REPLACE PROCEDURE sal_update(v_empno emp.empno%type)
IS
BEGIN
	UPDATE emp01 SET sal=sal+500 WHERE empno = v.empno;
	COMMIT;
END;

/


execute sal_update(7369);
select empno, sal from emp01 where empno=7369;


--5. 사번(empno)과, 급여(sal)를 입력받아서 해당 직원의 희망급여를 변경하는 프로시저 
-- 프로시저명 : update_sal

select empno, sal from emp01 where empno=7369;

CREATE OR REPLACE PROCEDURE update_sal(v_empno emp.empno%type,
									   v_sal emp.sal%type)
IS 
BEGIN 
	UPDATE emp01 SET sal = v_sal WHERE empno=v_empno;	
	COMMIT;
END;
/


BEGIN
	update_sal(7369, 2000);
END;


execute update_sal(7369, 2000);
select empno, sal from emp01 where empno=7369;



--6. 이름과 사번, 급여 검색하기
	-- inout 모드/ 이름을 주 고 사번, 급여를 검색
	-- procedure는 return 키워드 즉 호출한 곳으로 값을 제공
/*	-- mode(컨셉의 다른 용어)
 * 		1. in - procedure 내에서 사용될 데이터의 변수
 * 		2. out - procedure 내에서 발생된 데이터를 호출한 곳으로 제공(반환) 하는 데이터의 변수
 * 		3. inout - procedure 내에서 사용될 수도 있고, 호출한 곳으로 결과값을 반환할 수도 있음
 * 
 */

-- 변수 선언


-- 선언된 vempno에 값 할당, 프로시저 실행 후의 결과값을 대입 받게 되는 변수 선언
-- sqlplus에서 변수 선언하는 oracle의 정통 문법
variable vempno number;
variable vsal number;

CREATE OR REPLACE PROCEDURE info_empinfo
(
	v_ename IN emp.ename%TYPE,
	v_empno OUT emp.empno%TYPE, 
	v_sal OUT emp.sal%TYPE
)
IS
BEGIN
	SELECT empno, sal
		INTO v_empno, v_sal
	FROM emp
	WHERE ename=v_ename;
END;

/

-- 이미 db에 선언된 변수에 값을 할당하는 문법 :vempno(동적 변수값 대입, 바인딩 이라고도 함)
BEGIN
	info_empinfo('SMITH', :vempno, :vsal);
END;

/
-- out 모드로 반환되어온 변수값들 출력
print vempno; -- 7369
print vsal; -- 800
