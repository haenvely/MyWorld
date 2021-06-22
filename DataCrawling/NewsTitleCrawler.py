#NewsTitleCrawler
from bs4 import BeautifulSoup as bs
import requests
import datetime, time
import numpy as np
import pandas as pd
import csv
import os, sys
import logging
import re

from PyKomoran import *
from hdfs import InsecureClient
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


file_st_time = time.time()

#logging 생성
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
formatter = logging.Formatter('[%(name)s][%(asctime)s][%(levelname)s][%(filename)s][%(lineno)s] : %(message)s')
stream_handler = logging.StreamHandler(stream=sys.stdout)
stream_handler.setFormatter(formatter)
logger.addHandler(stream_handler)

logger.info('[START] ')



os.chdir('/data/jupyterhub/LOTTE/DT/HIO/NewsAnalysis')
path = '/data/jupyterhub/LOTTE/DT/HIO/nlp'


# ####################################################
# #             불용어 및 사용자 사전 로드
# ####################################################
komoran = Komoran('EXP')
komoran.set_user_dic(path + '/chilsung.csv')

stopwords = pd.read_csv(path+'/KoreanStopwords.csv', encoding = 'utf-8', header = None)
stop_words = stopwords.iloc[:,0].to_list()

# #####################################################
# #             날짜 형식 지정 함수
# ####################################################
def date_handle(year, month, day):
    date = datetime.date(year, month, day)
    handled_date = '{:%Y.%m.%d}'.format(date)

    return handled_date

def date_yesterday():
    today = datetime.date.today()
    yesterday = today - datetime.timedelta(days = 1)
    handled_yesterday = '{:%Y.%m.%d}'.format(yesterday)

    return handled_yesterday
# #####################################################
# #             뉴스 크롤링 함수-8일 이전 기간
# ####################################################
def page_bs(count = 1):
    
    startnumber = 10*(count - 1) + 1
    time.sleep(np.random.randint(3,5))
    
    url = 'https://search.naver.com/search.naver?&where=news&query={}&sm=tab_pge&sort=1&photo=0&field=0&reporter_article=&pd=3&ds={}&de={}&start={}&refresh_start=0'.format(user_query, user_startdate, user_enddate, startnumber)
    headers = {'data-useragent':"mozilla/5.0 (windows nt 10.0; win64; x64) applewebkit/537.36 (khtml, like gecko) chrome/89.0.4389.72 safari/537.36"}
    resp = requests.get(url, verify = False, headers = headers)
    time.sleep(np.random.randint(3,7))
    
    if resp.status_code == 200: #요청을 정상으로 처리했다면
        html = resp.text
        soup = bs(html, 'html.parser')
        news_html = soup.find_all('a', class_ = 'news_tit')
        pub_html = soup.find_all('a', class_ = 'info press')
        tmp_html = soup.find_all('span', class_ = 'info')  #같은 tag가 두개인 경우있음.
        div_html = soup.find_all('div', class_ = 'info_group')
        date_html = []
        naver_html = []
        
        for tmp in tmp_html:
                if tmp.get_text()[-1] == '.':  
                    date_html.append(tmp)  #날짜 html만 저장
                    
        for div in div_html: #네이버 뉴스 URL만 찾기
            info = div.find_all('a', class_ = 'info', target = '_blank')
            if len(info) == 1:
                naver_html.append('')
            elif len(info) == 0 :
                logger.info('naver_html 에러')
            else:
                naver_html.append(info[-1]['href'])
    
    
        if len(news_html) > 0:
            for i, news in enumerate(news_html):
                news_titles.append(news['title']) #제목
                news_hrefs.append(news['href']) #링크
                pub_names.append(pub_html[i].get_text()) #언론사
                pub_dates.append(date_html[i].get_text()) #게시일
                naver_url.append(naver_html[i]) #네이버뉴스 url
                
                
            try: 
                page_bs(count = count+1)
        
            except Exception as e:
                logger.info('---------------Exception Error-------------')
                logger.info(e)
            
            finally:
                logger.info("PageNumber:{}".format(count))
            
        
        else:
            logger.info("TotalPageNumber:{}".format(count -1))
        
    else:
        logger.info('---------------Request Error-------------')
        logger.info(resp.status_code)

# #####################################################
# #             뉴스 크롤링 함수-일별 수집
# ####################################################
def page_bs_revised(count=1):
    startnumber = 10 * (count - 1) + 1
    time.sleep(np.random.randint(3, 5))

    url = 'https://search.naver.com/search.naver?&where=news&query={}&sm=tab_pge&sort=1&photo=0&field=0&reporter_article=&pd=3&ds={}&de={}&start={}&refresh_start=0'.format(
        user_query, user_startdate, user_enddate, startnumber)
    headers = {
        'data-useragent': "mozilla/5.0 (windows nt 10.0; win64; x64) applewebkit/537.36 (khtml, like gecko) chrome/89.0.4389.72 safari/537.36"}
    resp = requests.get(url, verify=False, headers=headers)
    time.sleep(np.random.randint(3, 6))

    if resp.status_code == 200:  # 요청을 정상으로 처리했다면
        html = resp.text
        soup = bs(html, 'html.parser')
        news_html = soup.find_all('a', class_='news_tit')
        pub_html = soup.find_all('a', class_='info press')
        div_html = soup.find_all('div', class_='info_group')
        naver_html = []

        for div in div_html:  # 네이버 뉴스 URL만 찾기
            info = div.find_all('a', class_='info', target='_blank')
            if len(info) == 1:
                naver_html.append('')
            elif len(info) == 0:
                logger.info('naver_html 에러')
            else:
                naver_html.append(info[-1]['href'])

        if len(news_html) > 0:

            for i, news in enumerate(news_html):
                news_titles.append(news['title'])  # 제목
                news_hrefs.append(news['href'])  # 링크
                pub_names.append(pub_html[i].get_text())  # 언론사
                pub_dates.append(user_startdate + '.')  # 수집일(1일), 8일 이전 데이터와 형식 맞추기 위해 . 추가
                naver_url.append(naver_html[i])  # 네이버뉴스 url
            try:
                time.sleep(np.random.randint(3, 7))
                page_bs_revised(count=count + 1)

            except Exception as e:
                logger.info('---------------Exception Error-------------')
                logger.info(e)
            
            finally:
                logger.info("PageNumber:{}".format(count))                


        else:
            logger.info("TotalPageNumber:{}".format(count -1))


    else:
        logger.info('---------------Request Error-------------')
        logger.info(resp.status_code)

        
        
# #####################################################
# #             뉴스 크롤링 작업 사용자변수
# ####################################################        
user_query = '롯데 칠성'
user_startdate, user_enddate = date_yesterday(), date_yesterday()
#user_startdate, user_enddate = date_handle(2021,3,8), date_handle(2021,3,8)
news_titles = []
news_hrefs = []
pub_names = []
pub_dates = []
naver_url = []

page_bs_revised()
#page_bs()

query = user_query
category = '기업'


# #####################################################
# #             뉴스 제목 형태소 분석
# ####################################################

# 데이터 형태소 분석 및 저장
regex = re.compile('[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z]+')
colnames = ['title', 'href', 'publisher', 'date', 'naver_url', 'morphs', 'query', 'category']

result_df = pd.DataFrame(columns=colnames)
for i, news in enumerate(news_titles):
    corpus_cleaned_list = regex.findall(news)  # 리스트로 반환. regex 쓸 시 활용
    corpus_cleaned = ' '.join(corpus_cleaned_list)  # regex 쓸 시 활용
    news_cleaned = komoran.get_morphes_by_tags(corpus_cleaned, tag_list=['NNP', 'NNG', 'SL'])
    news_cleaned = [a for a in news_cleaned if len(a) >= 2 and a.lower() not in stop_words]

    tmp_df = pd.DataFrame(columns=colnames)
    tmp_df['title'] = pd.Series(news)
    tmp_df['href'] = pd.Series(news_hrefs[i])
    tmp_df['publisher'] = pd.Series(pub_names[i])
    tmp_df['date'] = pd.Series(re.sub('\.', '', pub_dates[i]))
    tmp_df['naver_url'] = pd.Series(naver_url[i])
    tmp_df['morphs'] = pd.Series(", ".join(news_cleaned))

    tmp_df['query'] = query
    tmp_df['category'] = category

    result_df = pd.concat([result_df, tmp_df], ignore_index=True)


    
# #####################################################
# #             데이터 저장 - 뉴스 크롤링+형태소
# ####################################################    

logger.info('TodayNewsNumber:{}'.format(len(result_df)))

clean_result_df = result_df.drop_duplicates(['href'])
clean_result_df = clean_result_df.reset_index(drop = True)

logger.info('TodayNewsNumber2:{}'.format(len(clean_result_df)))

#result_df.to_csv("/data/jupyterhub/LOTTE/DT/HIO/NewsAnalysis/BSData/lcs_news_pytest6.csv", encoding = 'utf-8', index = False, sep = '', header = False)

client_hdfs = InsecureClient('http://10.120.4.100:50070')
try:
    with client_hdfs.write('/ODS/DEV/EXTERNAL/NEWS_CRAWLING/ODS_NEWS/lcs_news_v2.csv', append = True, encoding = 'utf-8') as f:
        clean_result_df.to_csv(f, header = False, index =False, sep = '')
except:
    with client_hdfs.write('/ODS/DEV/EXTERNAL/NEWS_CRAWLING/ODS_NEWS/lcs_news_v2.csv', encoding = 'utf-8') as f:
        clean_result_df.to_csv(f, header = False, index = False, sep = '')

        
# #####################################################
# #         형태소 Column(Moprhs)으로 빈도수 계산
# ####################################################        
freq_df = pd.DataFrame(columns = ['date', 'keywords', 'frequencies', 'query', 'category'])
regex = re.compile('[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z]+')  #띄어쓰기 기준으로 나눠짐

for date in sorted(set(clean_result_df['date'])):
    tmp_merged = clean_result_df[clean_result_df['date'] == date]
    #print(tmp_merged.head())
    text = tmp_merged['morphs']
    text = text.fillna(" ")
    corpus = " ".join(text.to_list())
    
    words_cleaned = [c.strip(" ,.") for c in corpus.split()]  #moprhs 컬럼의 키워드 추출
    word_list = pd.Series(words_cleaned) #리스트를 시리즈로 반환
    rank = word_list.value_counts() #시리즈 빈도수 계산
    
    tmp_df = pd.DataFrame(columns = ['date', 'keywords', 'frequencies', 'query', 'category'])
    tmp_df['date']= pd.Series( [date] * (len(rank))) # 날짜 모양 수정(구분자 없음으로)

    tmp_df['keywords'] = pd.Series(rank.index)
    tmp_df['frequencies'] = pd.Series(rank.values)
    #print(tmp_df.head(2))
    freq_df = pd.concat([freq_df, tmp_df], ignore_index = True)

freq_df['query'] = None
freq_df['category'] = None

for i, row in enumerate(freq_df['date']):
    freq_df['query'][i] = query
    freq_df['category'][i] = category
    

# #####################################################
# #             데이터 저장 - 빈도수 데이터
# ####################################################
#freq_df.to_csv("/data/jupyterhub/LOTTE/DT/HIO/NewsAnalysis/FreqData/lcs_freq_pytest6.csv", encoding = 'utf-8', index = False, sep = '', header = False)


client_hdfs = InsecureClient('http://10.120.4.100:50070')
try:
    with client_hdfs.write('/ODS/DEV/EXTERNAL/NEWS_CRAWLING/FREQ_WORD/lcs_freq_v2.csv', append = True, encoding = 'utf-8') as writer:
        freq_df.to_csv(writer, header = False, index = False, sep = '')
except:
    with client_hdfs.write('/ODS/DEV/EXTERNAL/NEWS_CRAWLING/FREQ_WORD/lcs_freq_v2.csv', encoding = 'utf-8') as writer:
        freq_df.to_csv(writer, header = False, index = False, sep = '')

        
        
file_end_time = time.time()
runtime = file_end_time - file_st_time
logger.info('FILE EXECUTION RUNTIME: ' + str('{:.4f}'.format(runtime)))
logger.info('[END] ')