import selenium
from selenium import webdriver
from selenium.common import exceptions
import urllib.request as req
from bs4 import BeautifulSoup
import requests
import time

from selenium.common.exceptions import NoSuchElementException, ElementNotInteractableException

wd = "C:/Users/ohi02/PycharmProjects/chromedriver" #다운받은 크롬웹드라이버 위치

driver = webdriver.Chrome(wd)
driver.implicitly_wait(3)
#크롤링할 주소로 들어가자.
#addr = "크롤링할주소" #페이지가 있는 경우 댓글창 전체보기로 들어간 주소
addr = 'https://sports.news.naver.com/kbaseball/vod/index.nhn?id=601661&category=kbo&gameId=77771026OBWO02019&date=20191026&listType=game#focusComment'
driver.get(addr)
driver.find_element_by_id("comment_menu_btn").click()

driver.implicitly_wait(2)
comment_list = []

while True:
        try:
            driver.find_element_by_class_name("u_cbox_btn_more").click()
            time.sleep(0.1)
            driver.implicitly_wait(1)
        except selenium.common.exceptions.ElementNotInteractableException:
            break


html = driver.page_source

dom = BeautifulSoup(html, 'html.parser')

comments_raw = dom.findAll('span', {'class': 'u_cbox_contents'})
for i in comments_raw:
    comment_list.append(i.get_text().strip())
with open('./장성규스포츠댓글_더보기버튼이용.txt', 'w', encoding = 'utf-8') as f:
    for a in comment_list:
        f.write(a + '\n')

# 댓글의 텍스트만 뽑는다
#comments = [comment.text for comment in comments_raw]

 # 결과 도출을 위한 예시(0부터 3번째 까지만 뽑는다)
#print(len(comments))


"""
while(True):
    try:
        driver.implicitly_wait(2)
        #driver.find_element_by_xpath("//a[@class='u_cbox_btn_more']").click() #//태그이름[@속성이름='속성값']
        #more = driver.find_element_by_css_selector(a".u_cbox_btn_more")
        #more = driver.find_element_by_class_name("u_cbox_btn_more")
        #more.click()
        load = driver.find_element_by_xpath('// *[ @ id = "cbox_module"] / div / div[8] / a')
        load.click()
        time.sleep(0.2)
        #more
        #element = driver.find_element("//a[@class='u_cbox_btn_more']/button")
        #driver.execute_script("arguments[0].click();", element)


    except NoSuchElementException:

        break;

html = driver.page_source
dom = BeautifulSoup(html, 'html.parser')

comments_raw = dom.findAll('span', {'class': 'u_cbox_contents'})
# 댓글의 텍스트만 뽑는다
comments = [comment.text for comment in comments_raw]

# 결과 도출을 위한 예시(0부터 3번째 까지만 뽑는다)
for i in comments:
    print(comments[i].text + '\n')


"""