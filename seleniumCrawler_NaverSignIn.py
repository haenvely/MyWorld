#페이지를 바꿔서 데이터 수집해줘야하는 경우 Selenium 사용

from selenium import webdriver
from selenium.common import exceptions
import urllib.request as req
from bs4 import BeautifulSoup
import requests
import time

wd = "C:/Users/ohi02/PycharmProjects/chromedriver" #다운받은 크롬웹드라이버 위치

driver = webdriver.Chrome(wd)
driver.implicitly_wait(3)

#네이버 로그인할시
login = "https://nid.naver.com/nidlogin.login"
driver.get(login)

#네이버 아이디 로그인부분. my naver id랑 password 부분에 회원정보 입력
driver.find_element_by_name('id').send_keys('haen0202')
driver.find_element_by_name('pw').send_keys('Gd727800')

#로그인버튼 누르기
driver.find_element_by_xpath('//*[@id="frmNIDLogin"]/fieldset/input').click()

#크롤링할 주소로 들어가자.
addr = "https://search.naver.com/search.naver?sm=tab_hty.top&where=realtime&query=%EC%9E%A5%EC%84%B1%EA%B7%9C" #페이지가 있는 경우 댓글창 전체보기로 들어간 주소
driver.get(addr)

#페이지 넘기기
pages = 0 #한페이지당 약 20개의 댓글이 표시
try:
    while True:  #댓글 페이지가 몇개인지 모르므로
        driver.find_element_by_css_selector(".u_cbox_btn_more").click()
        time.sleep(1.5)
        print(pages, end = "    ")
        pages+=1
except exceptions.ElementNotVisibleException as e: #페이지 끝
    pass
except Exception as e: #다른 예외 발생시 확인
    print(e)


html = driver.page_source
dom = BeautifulSoup(html, "html.parser")

#댓글이 들어있는 페이지 전체 크롤링. 클래스랑 키를 확인하길!
comments_raw = dom.find_all("a", {"class": "txt_link"})

#댓글의 텍스트만 뽑는다
comments = [comment.text for comment in comments_raw]

#결과 도출을 위한 예시(0부터 3번째 까지만 뽑는다)
print(comments[:3])

#혹은 soup = BeautifulSoup(html, 'html.parser')
#comments_raw = soup.select('div.p_inr > div.p_info > a > span') 클래스 진입
# for comment in comments_raw: print(comment.text.strip())

#파일에 저장
file = open("장성규네이버실시간.txt", 'w', -1, 'UTF-8')

from datetime import datetime as dt
now = dt.now()
file.write('{}장성규1027일자01시04분 네이버 실시간검색\n'.format(now))
for i in range(len(comments)):
    file.write(comments[i] + '\n')
file.close()