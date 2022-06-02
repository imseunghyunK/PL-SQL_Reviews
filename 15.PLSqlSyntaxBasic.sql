-- 15.PLSqlSyntaxBasic.sql
/* 
* 프로시저 & 함수
	- 재사용을 위한 기능 구현
	- 학습 우선 tool은 sqlplus 권장

1. 프로시저
	- db 자체에 기능을 직접 구현하는 메타니즘
	- 호출 방법이 함수와 차이가 있음
		- 프로시저 개발시에 return 키워드가 없음
		- 함수는 return 키워드로 명확하게 호출한 곳으로 값 제공
		
		- oracle 함수
			1. 내장함수 - max()/min()...
				select max(sal) from emp;
				
				Java 관점 public int max(int v1, int v2){두 개의 값 비교 후 반환}
				sql 관점 숫자 - max(컬럼명){from절에 있는 해당 table의 데이터 중에 해당 컬럼의 가장 큰 값 반환}
				- java와 sql함수의 공통점 : 반환값이 있다 return 키워드로 값 제공
				
			2. 사용자 정의 함수
				select 사용자정의함수(..) from table명;
2. 함수
	- oracle 함수 호출하듯 사용자 정의 함수 호출 가능

-------

1. oracle db만의 프로그래밍 개발 방법
	1. 이름 없이 단순 개발
	2. 프로스저라는 타이틀로 개발 - 이름 부여(재사용)
	3. 함수라는 타이틀로 개발 - 이름 부여(재사용)

	java 관점에서 이름 없는 문법
		- static{}
		- 개발자가 코드로 호출 불가능
		- 단 실행은 byte code(실행코드)가 메모리에 로딩 시에 자동 단 한번 실행
	
2. 장점
	- 단 한번의 개발 만으로 내장 함수처럼 만들어서 필요시 호출해서 실행 가능
	- 프로시저와 함수로 구현시 db내부에 pcode로 변환
	- java는 컴파일 후 class라는 byte code로 변환

3. test를 위한 필수 셋팅 
	- set serveroutput on 
	
	
4. 필수 암기 
	1. 할당(대입) 연산자  :=
	2. 선언, 시작, 끝
		declare ~ begin ~ end;/		
	

5. 참고
	1. 사용 tool에 따른 차이점
		1. dbeaver인 경우 / 표기가 있을 경우 문법 에러 야기
			- 기본은 필수
			- sqlplus의 동작이 우선
		
6. 문법
	declare
		변수
	begin
		로직
	end;
	/

*/

--1. 실행 결과 확인을 위한 필수 설정 명령어
-- sqlplus에선 필수
-- 기본은 필수이나 tool 종류에 따라 다름(tool 탄다)
set serveroutput on

--2. 연산을 통한 간단한 문법 습득
declare
	no integer; -- no 변수(컬럼) 선언 : 정수 타입만 대입(할당)
begin
	no := 10; -- no 변수에 10 대입
	dbms_output.put_line('결과 ' || no); -- 출력, || 결합 연산자

	no := 10 / 5; -- / 나누기 후에 no 변수에 값 대입
	dbms_output.put_line('결과 ' || no);
end;

/

-- ? 이름(문자열, String, varchar2())을 대입(:=)해서 출력(dbms_output.put_line)
DECLARE
	name varchar2(10);
BEGIN
	name := '흥민';
	dbms_output.put_line(name || ' playdata');
END;

/

--3. 연산을 통한 간단한 문법 습득 + 예외(exception) 처리 문장
-- 혹여 문제가 생겨도 프로그램 종료가 아니라 유연하게 실행 유지

-- 예외처리시 실행 유지
-- 예외 미처리시 실행 강제 종료
/* java에서의 예외 처리
 * 1. 메소드 내부에서 발생시 해당 메소드 호출한 곳으로 예외처리 위임
 * 		- 메소드 선언구에 throws 예외
 * 2. 예외 발생 로직 상에 직접처리
 * 	- try{
 * 		구현 로직
 * 	  }catch(예외타입 변수){
 * 		발생시 처리하는 로직
 * 		변수.printStackTrace(); 	
 * 	  }
 * 
 */

-- step01 : 에러 발생 SQL Error [1476] [22012]: ORA-01476: divisor is equal to zero ORA-06512
declare
	no integer;
begin
	no := 10 / 0; -- 문제 발생시 강제 종료
	dbms_output.put_line('결과 ' || no);
end;

/

-- step02 - 예외 처리 적용
declare
	no integer := 0;
begin
	no := 10 / 0; 	-- 문제 발생시 예외 처리 로직에서 처리 후에 실행 유지
	-- 예외 처리
	EXCEPTION
		WHEN OTHERS THEN  -- OTHERS : 발생된 모든 예외 의미
		dbms_output.put_line('연산 오류');

	dbms_output.put_line('결과 ' || no);
end;

/

--4. 중첩 block & 변수 선언 위치에 따른 구분
-- step01 - 전역(java의 멤버), 로컬(java의 로컬) 변수 선언 및 활용

-- step01 에러 : 에러 - 로컬 변수 선언시에는 중첩 declare 선언
DECLARE
	v_g varchar2(10) := 'global';
BEGIN
	v_l varchar2(10) := 'variable';
	dbms_output.put_line(1 || v_g);
	dbms_output.put_line(2 || v_l);
END;

/

-- step02 - 정상 실행
DECLARE
	v_g varchar2(10) := 'global';
BEGIN
	dbms_output.put_line(1 || ' - ' || v_g); -- 1 - global
END;

/

-- step03 - 전역, 로컬 정상 문법으로 선언 및 호출
DECLARE
	v_g varchar2(10) := 'global';
BEGIN
	DECLARE
	v_l varchar2(10) := 'variable';
	BEGIN
	dbms_output.put_line(1 || v_g); -- 1global
	dbms_output.put_line(2 || v_l); -- 2variable
	END;
END;

/

-- step04 - 에러 : 전역, 로컬 정상 문법으로 선언 단 로컬 변수 호출 영역의 오류
DECLARE
	v_g varchar2(10) := 'global';
BEGIN
	DECLARE
		v_l varchar2(10) := '선언된 declare begin내에서만 사용 가능한 로컬 변수';
	BEGIN
		dbms_output.put_line(1 || v_g); -- 1global
		dbms_output.put_line(2 || v_l); -- 2variable
	END;
		dbms_output.put_line(1 || v_g); -- 1global
		dbms_output.put_line(2 || v_l); -- 문법 오류
END;

/


--5. emp01 table의 컬럼 타입을 그대로 사용하고 싶다면?
	-- %type : db의 특정 컬럼의 타입 의미
		-- 예시 emp01의 emp01.empno%type 표현은 NUMBER(4) 의미
drop table emp01;
create table emp01 as select * from emp;
SELECT * FROM emp01;

-- 사번(empno, 4자리 정수값)으로 사원의 이름(ename) 색하는 로직의 프로시저
-- select ename from emp01 where empno = 7369; SMITH 검색
DECLARE
	v_empno emp01.empno%TYPE := 7369;
	v_ename emp01.ename%TYPE;
BEGIN
	
	SELECT ename
		INTO v_ename -- select절에 검색된 컬럼 데이터를 프로시저 변수에 대입( into 절 이용 )
	FROM emp01
	WHERE empno=v_empno;
	
	dbms_output.put_line(v_ename);
END;

/


--6. 이미 존재하는 table의 record의 모든 컬럼 타입 활용 키워드 : %rowtype
-- emp01%rowtype - emp01의 모든 컬럼의 모든 타입을 복제
/* 7369 사번으로 해당 사원의 모든 정보를 검색해서 사번, 이름만 착출해서 출력 */
DECLARE
	v_rows emp01%rowtype; -- 8개의 변수 선언
BEGIN
	SELECT *
		INTO v_rows -- 검색된 8개 컬럼의 모든 데이터가 대입
	FROM emp01
	WHERE empno=7369;

	dbms_output.put_line(v_rows.empno || ' ' || v_rows.ename); -- 7369 SMITH
END;

/


--7. 
-- emp05라는 table을 데이터 없이 emp table로 부터 생성하기
-- %rowtype을 사용하셔서 emp의 사번이 7369인 사원 정보 검색해서 
-- emp05 table에 insert
-- 힌트 : begin 부분엔 다수의 sql문장 작성 가능, into 절
drop table emp05;
create table emp05 as select * from emp where 1=0;

DECLARE
	v_rows emp01%rowtype;
BEGIN
	SELECT *
		INTO v_rows
	FROM emp01
	WHERE empno=7369;

	INSERT INTO emp05 VALUES v_rows;

	dbms_output.put_line('실행 완료');
END;

select * from emp05;


--8. 조건식
/*  1. 단일 조건식
	if(조건) then
		
	end if;
	
   2. 다중 조건
	if(조건1) then
		조건1이 true인 경우 실행되는 블록 
	elsif(조건2) then
		조건2가 true인 경우 실행되는 블록
	end if; 
*/
-- 사원의 연봉을 계산하는 procedure 개발[comm이 null인 직원들은 0으로 치환]

-- null 로 연산시 null
select sal, sal*12+comm from emp where empno = 7369;
-- 해결책 : null값을 0으로 치환(oracle : nvl(), mysql : ifnull())
select sal, sal*12+ nvl(comm, 0) from emp where empno = 7369;

select empno, ename, sal, comm 
	from emp 
	where ename='SMITH';

DECLARE
	v_emp emp%rowtype;
	total_sal number(7, 2); -- 검색된 연봉을 대입받을 프로시저 전역 변수
BEGIN
	SELECT empno, ename, sal, comm 
		INTO v_emp.empno, v_emp.ename, v_emp.sal, v_emp.comm
	FROM emp e
	WHERE ename='SMITH';
	
	dbms_output.put_line(v_emp.empno || ' ' || v_emp.comm);

	-- v_emp.comm null인 경우 0으로 재할당(대입)
	IF (v_emp.comm IS null) THEN
		v_emp.comm := 0;
	END IF;

	total_sal := v_emp.sal*12 + v_emp.comm;
	dbms_output.put_line('연봉' || ' ' || total_sal); -- 연봉 9600
END;

/

-- 9. 실행시 가변적인 데이터 적용해 보기
-- 실행시마다 가변적인 데이터(동적 데이터) 반영하는 문법 : 변수 선언시 "&변수명"
-- sqlplus 창에서 실행시 입력 후 결과 확인

-- step01 동적 변수 연습
DECLARE
    -- 실행시 마다 입력 데이터를 즉 동적 데이터 대입을 위한 문법
	v_inputename emp.ename%type := &v; 
	v_emp emp%rowtype;
	total_sal number(7, 2); 
BEGIN
	SELECT empno, ename, sal, comm 
		INTO v_emp.empno, v_emp.ename, v_emp.sal, v_emp.comm
	FROM emp e
	WHERE ename=v_inputename;
	
	dbms_output.put_line(v_emp.empno || ' ' || v_emp.comm);

	IF (v_emp.comm IS null) THEN
		v_emp.comm := 0;
	END IF;

	total_sal := v_emp.sal*12 + v_emp.comm;
	dbms_output.put_line('연봉' || ' ' || total_sal); 

	dbms_output.put_line('실행 완료');
END;

/

-- step 02
-- emp table의 deptno=10 : ACCOUNT 출력, 
-- deptno=20 이라면 RESEARCH 출력, 10번과 20번이 아닌 경우엔 NONE 출력
-- test data는 emp table의 각 사원의 사번(empno)
-- 제약조건 : emp table만 사용 즉 다중 조건식으로 출력 시에 dbms_output.put_line('ACCOUNT');
-- := - 할당(대입) 연산자 / = : 동등비교 연산자
DECLARE
	ck_empno emp.empno%type := &v;
	v_deptno emp.deptno%type;
BEGIN
	SELECT deptno
		INTO v_deptno
	FROM emp
	WHERE empno=ck_empno;

	IF (v_deptno = 10) THEN
		dbms_output.put_line('ACCOUNT');
	ELSIF (v_deptno = 20) THEN
		dbms_output.put_line('RESEARCH');
	ELSE
		dbms_output.put_line('NONE');
	END IF;
END;

/



--10. 반복문
/* 
1. 기본
	loop 
		ps/sql 문장들 + 조건에 사용될 업데이트
		exit 조건;
	end loop;

2. while 기본문법
	 while 조건식 loop
		plsql 문장;
	 end loop;

3. for 기본 문법
	for 변수 in [reverse] start ..end loop
		plsql문장
	end loop;
*/
-- loop 
declare
	num number(2) := 0;
begin
	loop
		dbms_output.put_line(num);
		num := num+1;
		exit when num > 5; -- 5 초과인 경우 반복문 종료
	end loop;
end;

/

-- while

DECLARE
	num number(2) := 0;
BEGIN
	WHILE num <= 5 LOOP 	-- 조건식
		dbms_output.put_line(num);	-- 데이터 활용
		num := num + 1; -- 증감식
	end LOOP;
END;

/



-- for 
-- 오름차순
DECLARE
BEGIN
	FOR num IN 1..5 LOOP
		dbms_output.put_line(num);
	end LOOP;
END;

/

-- 내림차순
DECLARE
BEGIN
	FOR num IN reverse 1..5 LOOP
		dbms_output.put_line(num);
	end LOOP;
END;

/


--11. emp table 직원들의 특정 사원의 사번을 입력받아서(동적데이터) 해당하는 
-- 사원의 이름 음절 수 만큼 * 표 찍기  SMITH -> ***** / FORD -> ****
-- length()
SELECT length (ename) FROM emp;

/* 입력 받는 사원병 변수 / 이름 글자 수만큼 * 적재하게 되는 변수
 * 이름의 길이 값 보유하게 되는 변수?
 * 로컬 변수? 전역 변수?
 */

DECLARE
	v_empno emp.empno%type := &no;
	v_ename emp.ename&type;		-- 검색된 이름
	v_ename_len NUMBER;			-- 검색된 사원명의 길이
	v_star varchar2(10);
BEGIN
	SELECT ename, length(ename)
		INTO v_ename, v_ename_len
	FROM emp
	WHERE empno = v_empno;

	FOR i IN 1..v_ename_len LOOP
		v_star := v_star || '*';    -- * -> ** -> ***
	end LOOP;
	
	dbms_output.put_line(v_ename || '의 문자열 길이 수 만큼의 별' : || v_star);

END;
/

SELECT emp FROM emp;

