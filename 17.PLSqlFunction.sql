--17.PLSqlFunction.sql

/*
1. 저장 함수(function)
	- 오라클 사용자 정의 함수 
	- 오라클 함수 종류
		- 지원함수(count(??){ }, avg()...) + 사용자 정의 함수
2. 주의사항
	- 절대 기존 함수명들과 중복 불가
	
3. 프로시저와 다른 문법
	- 리턴 타입 선언 + 리턴 값
	
4. 문법
create [or replace] function 함수명()
return
	반환 타입
is
	변수
begin
	로직
	return 값;
end;
/	 
	
*/

--1. emp table의 사번으로 사원 이름
-- (리턴 값, 이름의 타입이 리턴타입) 검색 로직 함수 
-- 사번 받고 사원명 반환 -> 함수 호출로 이름 값 검색
CREATE function user_fun(no number)
RETURN varchar2
IS
	v_ename emp.ename%TYPE;
BEGIN
	
	SELECT ename
		INTO v_ename
	FROM EMP e 
	WHERE empno=no;
	
	RETURN v_ename;
END;
/

SELECT length(ename) FROM emp;

-- 주의사항 : 함수 내부에 검색 table명이 명시되어 있을 경우 함수호출하는 from절에는
-- dual이라는 오라클 만의 잉여 table(dummy) 이라고도 함
-- oracle에선 from 생략 불가이기 때문에 문법시에 자주 사용
-- SELECT user_fun(7369) FROM emp; 실행시에는 직원수만큼 함수 호출 
-- 결과가 직원수 만큼 검색, 논리 적인 오류 
SELECT user_fun(7369) FROM dual;

select * from user_source;

-- 존재하는 함수 삭제 명령어 
DROP FUNCTION USER_FUN; 
select * from user_source;  -- 함수 삭제 확인 


-- OR REPLACE 와 parameter 타입 개선
CREATE OR REPLACE function user_fun(no emp.empno%TYPE)
RETURN varchar2
IS
	v_ename emp.ename%TYPE;
BEGIN
	
	SELECT ename
		INTO v_ename
	FROM EMP e 
	WHERE empno=no;
	
	RETURN v_ename;

END;
/
SELECT user_fun(7369) FROM dual;


-- return 타입을 v_ename 타입과 동일하게 선언
CREATE OR REPLACE function user_fun(no emp.empno%TYPE)
RETURN emp.ename%TYPE    -- e_ename이라는 변수의 타입
IS
	v_ename emp.ename%TYPE;
BEGIN
	
	SELECT ename
		INTO v_ename
	FROM EMP e 
	WHERE empno=no;
	
	RETURN v_ename;

END;
/
SELECT user_fun(7369) FROM dual;





--2.? %type 사용해서 사원명으로 해당 사원의 직무(job) 반환하는 함수 
-- 함수명 : emp_job
CREATE OR REPLACE FUNCTION emp_job(v_ename emp.ENAME%type)
RETURN 
	emp.job%TYPE
IS 
	v_job emp.job%TYPE;
BEGIN 
	SELECT job
		INTO v_job
	FROM EMP e 
	WHERE ename = v_ename;
	
	RETURN v_job;
END;

/

select emp_job('SMITH') from dual;
select job from emp WHERE ename='SMITH';



--? 15파일의 마지막 문제를 함수로 구현 및 호출 예정
-- 함수명 : enamestar
-- 함수 구현시에 변수 선언하는 영역 is 영역


CREATE OR REPLACE FUNCTION enamestar(v_empno emp.empno%TYPE)
RETURN varchar2   -- RETURN 타입 명시시에는 타입의 크기 명시 안 함
IS  
	v_ename_len NUMBER;		  -- 변수 선언	
	v_star varchar2(10);
BEGIN
	SELECT length(ename)
		INTO v_ename_len
	FROM EMP e 
	WHERE empno=v_empno;

	-- 1..5 에서 1~5값 i 변수에 대입, 반복마다 데이터값 대입 받는 변수 
	-- 단 i 변수는 문법만 맞출뿐 현 로직상에선 사용되지 않음
	FOR i IN 1..v_ename_len LOOP		
		v_star := v_star || '*';	-- * -> ** 		
	end LOOP;
	
	RETURN v_star;
END;

/

-- 호출
SELECT enamestar(7369) FROM dual;   -- *****


-- ********************************************


--3.? 특별 보너스를 지급하기 위한 저장 함수
	-- 급여를 200% 인상해서 지급(sal*2)
-- 함수명 : cal_bonus
-- test sql문장

CREATE OR REPLACE FUNCTION cal_bonus(v_empno emp.empno%TYPE)
RETURN emp.sal%TYPE
IS	
	v_sal emp.sal%TYPE;
BEGIN
	SELECT sal*2
		INTO v_sal
	FROM EMP
	WHERE empno = v_empno;

	RETURN v_sal;
END;
/

-- 검색 후에 변수에 연산된 결과 재 할당
create OR REPLACE function cal_bonus(v_empno emp.empno%type)
return emp.sal%type
is
	v_sal2 emp.sal%type;
begin
	select sal
		into v_sal2
	from emp where empno=v_empno;
	
	v_sal2 := v_sal2*2;
	
	return v_sal2;
end;
/

select cal_bonus FROM emp;
select empno, job, sal, cal_bonus(7369) from emp where empno=7369;




-- 4.? 부서 번호를 입력 받아 최고 급여액(max(sal))을 반환하는 함수
-- 사용자 정의 함수 구현시 oracle 자체 함수도 호출
-- 함수명 : s_max_sal
SELECT max(sal) FROM emp;


create or replace function s_max_sal(s_deptno emp.deptno%type)
return emp.sal%type
is
	max_sal emp.sal%type;
begin
	select max(sal) 
		into max_sal
	from emp
	where deptno=s_deptno;

	return max_sal;
end;
/

select s_max_sal(10) from dual;



--5. ? 부서 번호를 입력 받아 부서별 평균 급여를 구해주는 함수
-- 함수명 : avg_sal
-- 함수 내부에서 avg() 호출 가능
-- set serveroutput on
CREATE OR REPLACE FUNCTION avg_sal(v_deptno emp.deptno%type)
RETURN emp.sal%type
IS 
	avg_sal emp.sal%TYPE;
BEGIN 
	SELECT round(avg(sal))
		INTO avg_sal
	FROM EMP e 
	WHERE deptno=v_deptno;

	dbms_output.put_line('---' || v_deptno);
	RETURN avg_sal;
END;
/

SELECT round(avg(sal)) FROM emp;
select deptno from emp;
SELECT distinct deptno from emp;

-- 실행에 따른 차이점

-- deptno값이 있는 수 만큼 avg_sal() 함수 호출 
select distinct deptno, avg_sal(deptno) from emp;  -- 12번 호출
SELECT count(*) FROM emp;

select avg_sal(deptno) from emp;  -- 12번 호출

-- 12번 deptno의 row수 만큼 함수 호출, deptno값도 12개 존재 검색 에러 없음
SELECT deptno, avg_sal(deptno) FROM emp;

-- deptno의 중복 제거해서 검색 할 경우 각 부서별 평균만 filtering
SELECT DISTINCT deptno, avg_sal(deptno) FROM emp; -- 12번 호출

select avg_sal(10) from dual;  -- 한번만 실행 
SELECT deptno FROM emp;


-- 신재훈 작품
SELECT deptno, avg(sal)
FROM emp
WHERE deptno = deptno
GROUP BY deptno;


--select distinct deptno, avg(deptno) from emp; error
select distinct deptno, avg(deptno) 
from emp
GROUP BY deptno;


select avg_sal(10) from dual;

--6. 존재하는 함수 삭제 명령어
drop function avg_sal;

-- 함수 내용 검색
desc user_source;
select text from user_source where type='FUNCTION';

--7. procedure 또는 function에 문제 발생시 show error로 메세지 출력하기
show error

-- 참고 : dbms_output.put_line()의 실행 결과 확인시 : set serveroutput on
