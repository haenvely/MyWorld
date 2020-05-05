# GetOldTweet3 사용 준비
import GetOldTweets3 as got

# BeautifulSoup4 사용 준비
from bs4 import BeautifulSoup

# 가져올 범위를 정의
# 예제 : 2019-04-21 ~ 2019-04-24

import datetime

days_range = []

start = datetime.datetime.strptime("2018-11-16", "%Y-%m-%d")
end = datetime.datetime.strptime("2019-01-02", "%Y-%m-%d")
date_generated = [start + datetime.timedelta(days=x) for x in range(0, (end-start).days)]

for date in date_generated:
    days_range.append(date.strftime("%Y-%m-%d"))

print("=== 설정된 트윗 수집 기간은 {} 에서 {} 까지 입니다 ===".format(days_range[0], days_range[-2]))
print("=== 총 {}일 간의 데이터 수집 ===".format(len(days_range) -1))

import time
query = 'Kia'
f = open('./현기차트윗갯수/{}_{}_{}_{}_트위터개수'.format(days_range[0], days_range[-2], len(days_range)-1, query) + '.txt', 'w', encoding = 'utf-8')
for i, day in enumerate(days_range):
    if i >= len(days_range) -1:
        break
    start_date = days_range[i]
    end_date = days_range[i+1]

    tweetCriteria = got.manager.TweetCriteria().setQuerySearch(query)\
                                           .setSince(start_date)\
                                           .setUntil(end_date)\
                                           .setMaxTweets(-1)\
                                            .setLang('en')
    start_time = time.time()
    try:
        tweet = got.manager.TweetManager.getTweets(tweetCriteria)
        print(i, '\t', start_date, '\t', len(tweet))
        # print("Collecting data end.. {0:0.2f} Minutes".format((time.time() - start_time)/60))
        f.write('{}\t{}\t{}\n'.format(i, start_date, len(tweet)))
    except AttributeError:
        pass
f.close()