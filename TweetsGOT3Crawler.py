# GetOldTweet3 사용 준비

import GetOldTweets3 as got
# BeautifulSoup4 사용 준비

from bs4 import BeautifulSoup
# 가져올 범위를 정의
# 예제 : 2019-04-21 ~ 2019-04-24

import datetime

days_range = []

start = datetime.datetime.strptime("2019-01-31", "%Y-%m-%d")
end = datetime.datetime.strptime("2019-02-08", "%Y-%m-%d")
date_generated = [start + datetime.timedelta(days=x) for x in range(0, (end-start).days)]

for date in date_generated:
    days_range.append(date.strftime("%Y-%m-%d"))

print("=== 설정된 트윗 수집 기간은 {} 에서 {} 까지 입니다 ===".format(days_range[0], days_range[-1]))
print("=== 총 {}일 간의 데이터 수집 ===".format(len(days_range)))
# 특정 검색어가 포함된 트윗 검색하기 (quary search)
# 검색어 : 어벤져스, 스포

import time

# 수집 기간 맞추기
start_date = days_range[0]
end_date = (datetime.datetime.strptime(days_range[-1], "%Y-%m-%d")
           + datetime.timedelta(days=1)).strftime("%Y-%m-%d")  # setUntil이 끝을 포함하지 않으므로, day + 1

# 트윗 수집 기준 정의
tweetCriteria = got.manager.TweetCriteria().setQuerySearch('hyundai') \
    .setSince(start_date) \
    .setUntil(end_date) \
    .setMaxTweets(-1) \
    .setLang('en')

# 수집 with GetOldTweet3
print("Collecting data start.. from {} to {}".format(days_range[0], days_range[-1]))
start_time = time.time()

tweet = got.manager.TweetManager.getTweets(tweetCriteria)

print("Collecting data end.. {0:0.2f} Minutes".format((time.time() - start_time) / 60))
print("=== Total num of tweets is {} ===".format(len(tweet)))

# html parser 정의하기

import requests
from bs4 import BeautifulSoup


def get_bs_obj(url):
    result = requests.get(url)
    bs_obj = BeautifulSoup(result.content, "html.parser")

    return bs_obj


# 원하는 변수 골라서 저장하기

from random import uniform
from tqdm import tqdm_notebook

# initialize
tweet_list = []

for index in tqdm_notebook(tweet):
    # 메타데이터 목록
    username = index.username
    link = index.permalink
    content = index.text
    tweet_date = index.date.strftime("%Y-%m-%d")
    tweet_time = index.date.strftime("%H:%M:%S")
    retweets = index.retweets
    favorites = index.favorites

    # 밑에서 주석처리한 것 여기만 떼오기    # 결과 합치기
    # info_list = [tweet_date, tweet_time, username, content, link, retweets, favorites]
    info_list = [tweet_date, tweet_time, username, content, link, retweets, favorites]
    # , joined_date, num_tweets, num_following, num_follower]
    tweet_list.append(info_list)

    # 휴식
    time.sleep(uniform(1, 2))

'''    
    # === 유저 정보 수집 시작 ===
    try:
        personal_link = 'https://twitter.com/' + username
        bs_obj = get_bs_obj(personal_link)
        uls = bs_obj.find("ul", {"class": "ProfileNav-list"}).find_all("li")
        div = bs_obj.find("div", {"class": "ProfileHeaderCard-joinDate"}).find_all("span")[1]["title"]


        # 가입일, 전체 트윗 수, 팔로잉 수, 팔로워 수
        joined_date = div.split('-')[1].strip()
        num_tweets = uls[0].find("span", {"class": "ProfileNav-value"}).text.strip()
        num_following = uls[1].find("span", {"class": "ProfileNav-value"}).text.strip()
        num_follower = uls[2].find("span", {"class": "ProfileNav-value"}).text.strip()

    except AttributeError:
        print("=== Attribute error occurs at {} ===".format(link))
        print("link : {}".format(personal_link))   
        pass

    # 결과 합치기
    #info_list = [tweet_date, tweet_time, username, content, link, retweets, favorites]
    info_list = [tweet_date,tweet_time,username,content,link,retweets,favorites]
                    #, joined_date, num_tweets, num_following, num_follower]
    tweet_list.append(info_list)

    # 휴식 
    time.sleep(uniform(1,2))
'''
# 파일 저장하기

import pandas as pd

twitter_df = pd.DataFrame(tweet_list,
                          columns = ["date", "time", "user_name", "text", "link", "retweet_counts", "favorite_counts"])
                                     #, "user_created", "user_tweets", "user_followings", "user_followers"])

# csv 파일 만들기
twitter_df.head()
twitter_df.to_csv('hyundai_twitter_data_{}_to_{}.csv'.format(days_range[0], days_range[-1]) , index = False)
print("=== {} tweets are successfully saved ===".format(len(tweet_list)))

