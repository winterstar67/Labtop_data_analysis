# Labtop_data_analysis

## 자동적인 웹페이지 저장을 위한 과정설명:


### 1. 한 번에 javaport를 실행시키는 cmd파일 만들기.

java를 이용해서 RSelenium을 이용할 것이다. 따라서 cmd실행 및 java -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-3.9.1.jar -port 4446까지 자동입력이 이루어져야 한다.

먼저 텍스트 문서(Notepad)를 열고   
d: &&cd scraping&&java -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-3.9.1.jar -port 4446  
를 붙여 넣는다. 그 후에 파일 -> 다른이름으로 저장-> 확장자를 .cmd로 한다.  
이렇게 cmd 파일을 만든다.

※주의. 텍스트의 d: &&cd scraping부분에 따라 반드시 D드라이브의 scraping이라는 폴더 안에 3개의 RSelenium 파일을 넣어야한다.



### 2. RSelenium을 위해 자동으로 cmd파일 실행시키기

TaskScheduler에 들어가서 기본작업 만들기 -> 이름 -> 매일 -> 오후 12:00:00로 설정(시간은 상관없다) -> 프로그램시작 -> 찾아보기에서 위에서 만든 cmd파일을 선택한다.  
그 후에 마침을 하면 cmd파일이 매일 오후 12시에 실행된다.





### 3. R코드 자동실행 시키기

일단 맨 위의 R코드들을 R파일로 저장한다. 이 때 저장이름을 final_project.R로 한다.

처음에 Rstudio에서 install.packages("taskscheduleR")을 한다. 그 후에 설치해둔 R폴더 장소의 R-3.5.2(버전은 다를 수 있다.) -> library폴더 -> taskscheduleR폴더에 저장해놓은 R파일을 옮겨놓는다.

다시 Rstudio로 돌아와서   
library(taskscheduleR)

myscript <- system.file("final_project.R", package = "taskscheduleR")

taskscheduler_create(taskname = "AAAAAA", rscript = myscript, 
                     schedule = "ONCE", starttime = format(Sys.time() + 62, "%H:%M"))
                    
코드를 실행시킨다.  
그러면 윈도우의 taskscheduler의 작업에 AAAAAA 생겨있는데, 이 AAAAAA를 오른쪽 마우스 클릭 -> 속성 -> 트리거 -> 편집(E)을 누르고
한 번으로 되있는 것을 매일, 오후 12:00:15으로 바꾼다.(시간은 상관없다.)  
이렇게 하면 R코드역시 자동으로 실행되며,
맨 위의 R코드에 있던 파일저장 부분의 코드역시 동작하여 웹페이지에 대한 txt파일, 통계처리를 한 그래프에 대한 pdf파일이 생성되어있다.

※주의. 자동실행 시간은 상관이 없지만, 반드시 cmd파일이 R코드보다 먼저 실행되어야 한다. 그렇지 않으면 R코드에서 RSelenium을 실행시키지 못해, 오류가 발생하게 된다.


이렇게 파일 자동 저장 작업을 완료한다.

taskScheduler에 실행파일을 넣는 것만으로는 R프로그램이 켜지기만 하고 코드실행이 안되어 위의 작업을 하였다.
